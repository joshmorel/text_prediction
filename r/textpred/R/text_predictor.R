# for use in ngram
library(stringi)
library(data.table)
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

# class functions
TextPredictor <- function(model, maxorder, ngram_delim = " ", bos_tag="BOS") {
        self <- list(maxorder = maxorder,
                     ngram_delim = ngram_delim,
                     bos_tag=bos_tag,
                     model=data.table::fread(model))

        # will always look up next word using word history only
        data.table::setkey(self$model, history)

        class(self) <- "TextPredictor"
        self
}

print.TextPredictor <- function(object, ...) {
        cat(paste0("TextPredictor with maximum order of ",object$maxorder))
}

ngrams <- function(object, tokens, n) {
        UseMethod('ngrams', object)
}

ngrams.TextPredictor <- function(object, tokens) {
        # if only empty string, then convert to NULL as nothing typed
        if (length(tokens) == 1 & is.na(tokens[1])) {
                tokens = character(0)
        }
        num_tokens <- length(tokens)

        if (num_tokens + 1 < object$maxorder) {
                # pad history with beginning of sentence tag
                pad_length <- object$maxorder - num_tokens - 1
                tokens <- c(rep(object$bos_tag, pad_length), tokens)
                num_tokens <- length(tokens)
        }

        # include ngram_delim for any history (unigram)
        if (object$ngram_delim == " ") {
                #data.table will convert space to zero-length string
                ngram_histories = ""
        } else {
                ngram_histories = object$ngram_delim
        }
        # add histories from w-1 to w-maxorder+1
        for (i in 2:object$maxorder) {
                ngram_history <- paste0(tokens[(num_tokens-i+2):num_tokens],collapse=object$ngram_delim)
                ngram_histories <- append(ngram_histories,ngram_history)
        }

        return(ngram_histories)

}

predict.TextPredictor <- function(object, tokens) {
        # history: vector of tokens used to predict nth token in n-gram language model
        # need to be adjusted to n-1 tokens
        stopifnot(class(tokens)=="character")

        # object$model[c('something','_'),.(score=max(score)),by=.(word)]
        ngram_histories <- ngrams(object, tokens)

        predictions <- object$model[ngram_histories,.(score=max(score)),by=.(word)
                                    ][!is.na(score)][order(-score)]
        return(predictions)
}
