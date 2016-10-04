context("Testing prediction")
suppressPackageStartupMessages(library(data.table))

test_that("Look-up with only low-level", {
        model <- "inputs/model_simple.txt"
        mypred <- TextPredictor(model, maxorder = 4)
        actual <- predict(mypred,"some random text")
        expected <- data.table(word = c("next","word","is"), score = c(0.4,0.2,0.1))
        expect_identical(actual, expected)

})

test_that("Look-up with empty input", {
        #want to make sure empty input gets BOS token
        model <- "inputs/model_empty.txt"
        mypred <- TextPredictor(model, maxorder = 2)
        actual <- predict(mypred, "")
        expected <- data.table(word = c("i","the","are","next","word","is"),
                               score = c(0.6,0.5,0.45,0.4,0.2,0.1))
        expect_identical(actual, expected)
})


test_that("Look-up should predict as if new sentence", {
        #what to make sure empty input gets BOS token
        model <- "inputs/model_empty.txt"
        mypred <- TextPredictor(model, maxorder = 2)
        actual <- predict(mypred,"hello there. ")
        expected <- data.table(word = c("i","the","are","next","word","is"),
                               score = c(0.6,0.5,0.45,0.4,0.2,0.1))
        expect_identical(actual, expected)
})


test_that("Look-up with top-level", {
        model <- "inputs/model_larger.txt"
        mypred <- TextPredictor(model, maxorder=4, ngram_delim="_")
        actual <- predict(mypred,"some random text")
        expected <- data.table(word = c("the","right","i","word","am","okay","are","cool","next","is"),
                               score = c(0.4,0.3,0.23,0.21,0.20,0.11,0.1,0.09,0.04,0.01))
        expect_identical(actual, expected)

})


test_that("Putting it all together look-up with long sentence and tokenize", {
        model <- "inputs/model_mid.txt"
        mypred <- TextPredictor(model, maxorder = 2)
        actual <- predict(mypred,"i am writing to you today to be the change in the world that is the")
        expected <- data.table(word = c("world","winter","game","next","word","is"),
                               score = c(0.4,0.2,0.1, 0.04,0.02,0.01))
})

test_that("Handling unknown words and vocab", {
        model <- "inputs/model_unknowns.txt"
        vocab <- "inputs/vocab.txt"
        mypred <- TextPredictor(model, vocab=vocab, maxorder = 2)
        actual <- predict(mypred, "unknown")
        expected <- data.table(word = c("some","dude","hates","next","word","is"),
                               score = c(0.3,0.2,0.1, 0.03,0.02,0.01))
})
