# for use in ngram
library(stringi)
library(jsonlite)
# constants, to use in tokenize_for_predict
# note: 's could be is or possessive, so simply striping for vocab reduction
kContractionsTo = c("won't",        "can't",  "n't",  "'ll",   "'re",  "'d",     "'ve",   "'m",  "'s")
kContractionsFrom =   c("will not", "cannot", " not", " will", " are", " would", " have", " am", "")

# helper functions
tokenize_from_input <- function(string) {
        # Extract last sentence
        sentence <- stringi::stri_extract_last_boundaries(string, type="sentence")
        # Expand contractions
        sentence <- stringi::stri_replace_all_fixed(sentence, pattern=kContractionsTo, replacement=kContractionsFrom, vectorize_all = FALSE)
        # Case fold
        sentence <- stringi::stri_trans_tolower(sentence)
        # Tokenize on all non-alpha characters
        tokens <- unlist(stringi::stri_extract_all_charclass(sentence, "[a-z]", merge=T))
        return(tokens)
}

model_from_json <- function(path) {
        rawtext <- readChar(path, file.info(path)$size)
        model_json <- jsonlite::fromJSON(rawtext)
        model <- new.env(hash = TRUE , parent=emptyenv())
        # expecting nested object with:
        # word history as level 1 object keys
        # word as level 2 object keys and score as value
        for (i in seq_along(model_json)) {
                words <- unlist(model_json[[i]])
                words <- words[order(words, decreasing = T)]
                model[[names(model_json)[i]]] <- words

        }
        return (model)
}

# class functions
TextPredictor <- function(model, maxorder, ngram_delim = "_", bos_tag="BOS", eos_tag="EOS") {
        self <- list(maxorder = maxorder,
                     ngram_delim = ngram_delim,
                     bos_tag=bos_tag)

        if (class(model) == "environment" ) {
                self[["model"]] = model
        } else if (class(model) == "character") {
                if (!file.exists(model)) {
                        stop("Looking for file, does not exist...")
                } else if (grepl("\\.rds", model , ignore.case = T)) {
                        print("Loading model from RDS...")
                        self[["model"]] = readRDS(model)
                } else {
                        print("Loading model from text, JSON expected...")
                        self[["model"]] = model_from_json(model)
                }
        }
        else {
                stop("Model must be environment or path to file containing model in RDS or Json")
        }

        # ensure there is at least non-null value for no-history if not in model
        # to prevent infinite loop in recursive look-up
        if (is.null(self$model[[self$ngram_delim]])) {
                self$model[[self$ngram_delim]] = ""
        }

        class(self) <- "TextPredictor"
        self
}

print.TextPredictor <- function(object, ...) {
        cat(paste0("TextPredictor with maximum order of ",object$maxorder))
}

ngrams <- function(object, tokens, n) {
        UseMethod('ngrams', object)
}

ngrams.TextPredictor <- function(object, tokens, n) {
        num_tokens <- length(tokens)
        if (num_tokens + 1 >= n) {
                # use history to predict n-th token
                ngram_history <- paste0(tokens[(num_tokens-n+2):num_tokens],collapse=object$ngram_delim)
        } else {
                # pad history with beginning of sentence tag
                pad_length <- n - num_tokens - 1
                full_tokens <- c(rep(object$bos_tag, pad_length), tokens)
                ngram_history <- paste0(full_tokens, collapse=object$ngram_delim)
        }
        return(ngram_history)

}

merge_predictions <- function(object, existing_predictions, additional_predictions) {
        UseMethod('merge_predictions', object)
}

merge_predictions.TextPredictor <- function(object, existing_predictions, additional_predictions) {
        updated_predictions <- existing_predictions
        existing_words <- names(existing_predictions)
        for (i in seq_along(additional_predictions)) {
                word <- names(additional_predictions)[i]
                if (word %in% existing_words) {
                        # only add existing if score is higher
                        if (additional_predictions[[word]] >= existing_predictions[[word]]) {
                                updated_predictions[[word]] <- additional_predictions[[word]]
                        }
                } else {
                        updated_predictions <- append(updated_predictions, additional_predictions[i])
                }
        }
        return(updated_predictions)
}

predict.TextPredictor <- function(object, tokens, n=object$maxorder, existing_predictions=numeric()) {
        # history: vector of tokens used to predict nth token in n-gram language model
        # need to be adjusted to n-1 tokens
        stopifnot(class(tokens)=="character")
        if (n == 1) {
                # delim-only represents any possible history
                ngram_history <- object$ngram_delim
        } else {
                ngram_history <- ngrams(object, tokens, n)
        }
        current_predictions <- object$model[[ngram_history]]
        current_predictions <- merge_predictions(object, existing_predictions, current_predictions)
        # Recursively look-up shorter word history adding lower-order words to overall prediction
        # assume back-off penalty already applied to score in model building
        if (n > 1) {
                return(predict(object, tokens, n-1, current_predictions))
        } else {
                return(current_predictions[order(current_predictions, decreasing = T)])
        }

}
