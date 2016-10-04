context("Testing parsing of text")

test_that("Parsing some simple text", {
        model <- "inputs/model_simple.txt"
        mypred <- TextPredictor(model, maxorder = 7)
        actual <- tokenize(mypred, "hello we want to invite you")
        expect_identical(actual, c("hello", "we", "want", "to", "invite", "you"))

})

test_that("Parsing a contraction ", {
        model <- "inputs/model_simple.txt"
        mypred <- TextPredictor(model, maxorder = 4)
        actual <- tokenize(mypred, "You're stupid")
        expect_identical(actual, c("you", "are", "stupid"))

})

test_that("Parsing multi-sentence with BOS tag", {
        model <- "inputs/model_simple.txt"
        mypred <- TextPredictor(model, maxorder = 9)
        actual <- tokenize(mypred,"When are we going to the fare? I want to ride on the donkey!")
        expect_identical(actual, c("BOS", "i", "want", "to", "ride", "on", "the", "donkey"))
})

