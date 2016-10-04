# for use in ngram
library(stringi)
library(data.table)
# constants, to use in tokenize_for_predict
# note: 's could be is or possessive, so simply striping for vocab reduction
kContractionsTo = c("won't",        "can't",  "n't",  "'ll",   "'re",  "'d",     "'ve",   "'m",  "'s")
kContractionsFrom =   c("will not", "cannot", " not", " will", " are", " would", " have", " am", "")

#' Tokenize from English Text Input
#' Returns tokens from an English text input for last sentence only. Not flexible - to be used for next word prediction
#' only.
#'
#' @param string Some English text
#' @export
#' @examples
#' tokenize_from_input("hello my darling")
tokenize_from_input <- function(string) {
        # if likely sentence ender then want to provide predictions as if new sentence
        if (grepl("[.!?]\\s{1,}$",string)) {
                return(character(0))
        }
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

#' Build a Text Predictor
#' This builds a Text Predictor object from a tab-delimited text file containing the model.
#' It can be used to predict the next word from a parsed history.
#'
#' @param model A tab-delimited text file consisting of word history, word, score columns
#' @param maxorder The maximum order of the model, e.g. 3 = trigram
#' @param ngram_delim The delimiter of the word history ngrams in the file
#' @param bos_tag The tag indicating the beginning of sentence token
#' @return A Text Predictor object
#' @export
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

ngrams <- function(object, tokens) {
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

#' Predict Next Word
#' Using the Text Predictor and tokens as input, predict a table of the next word
#'
#' @param object The TextPredictor object
#' @param tokens A character vector of tokens representing word history
#' @return A data.table of next best words in order
#' @export
#' @examples
#' predict(mytextpred, c("hello","my","darling"))

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
