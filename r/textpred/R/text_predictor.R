# for use in ngram
library(stringi)
# constants, to use in tokenize_for_predict
# note: 's could be is or possessive, so simply striping for vocab reduction
kContractionsTo = c("won't",        "can't",  "n't",  "'ll",   "'re",  "'d",     "'ve",   "'m",  "'s")
kContractionsFrom =   c("will not", "cannot", " not", " will", " are", " would", " have", " am", "")

# helper functions
tokenize_from_input <- function(string) {
        # Extract last sentence
        sentence <- stri_extract_last_boundaries(string, type="sentence")
        # Expand contractions
        sentence <- stri_replace_all_fixed(sentence, pattern=kContractionsTo, replacement=kContractionsFrom, vectorize_all = FALSE)
        # Case fold
        sentence <- stri_trans_tolower(sentence)
        # Tokenize on all non-alpha characters
        tokens <- unlist(stri_extract_all_charclass(sentence, "[a-z]", merge=T))
        return(tokens)
}

ngram_from_tokens <- function(tokens, n, bos_tag, ngram_delim) {
        num_tokens <- length(tokens)
        if (num_tokens + 1 >= n) {
                # use history to predict n-th token
                ngram_history <- paste0(tokens[(num_tokens-n+2):num_tokens],collapse=ngram_delim)
        } else {
                # pad history with beginning of sentence tag
                pad_length <- n - num_tokens - 1
                full_tokens <- c(rep(self$bos_tag, pad_length), tokens)
                ngram_history <- paste0(full_tokens, collapse=ngram_delim)
        }
        return(ngram_history)
}

# class functions
TextPredictor <- function(model, maxorder, ngram_delim = "_", bos_tag="BOS") {
        self <- list(maxorder = maxorder,
                     ngram_delim = ngram_delim,
                     bos_tag=bos_tag)

        if (class(model) == "environment" ) {
                self[["model"]] = model
        } else if (class(model) == "character") {
                self[["model"]] = readRDS(model)
        } else {
                stop("model must be r environment (namespace of lookups) or path to RDS of such")
        }

        # ensure there is at least non-null value for no-history if not in model
        # to prevent infinite loop in recursive look-up
        if (is.null(self[["model"]][[ngram_delim]])) {
                self[["model"]][[ngram_delim]] = ""
        }

        class(self) <- "TextPredictor"
        self
}

print.TextPredictor <- function(self, ...) {
        cat(paste0("TextPredictor with maximum order of ",self$maxorder))
}

predict.TextPredictor <- function(self, tokens, n=self$maxorder) {
        # history: vector of tokens used to predict nth token in n-gram language model
        # need to be adjusted to n-1 tokens
        stopifnot(class(tokens)=="character")
        if (n == 1) {
                # delim-only represents any possible history
                ngram_history <- self$ngram_delim
        } else {
                ngram_history <- ngram_from_tokens(tokens, n=n, bos_tag=self$bos_tag, ngram_delim=self$ngram_delim)
        }
        result <- self$model[[ngram_history]]
        # Recursively look-up shorter word history if nothing is found
        if (is.null(result)) {
                return(predict(self, tokens, n = n-1))
        } else {
                return(result)
        }

}

