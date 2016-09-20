context("Testing parsing of text")

test_that("Parsing some simple text", {
        actual <- tokenize_from_input("hello we want to invite you")
        expect_identical(actual, c("hello", "we", "want", "to", "invite", "you"))

})

test_that("Parsing a contraction ", {
        actual <- tokenize_from_input("You're stupid")
        expect_identical(actual, c("you", "are", "stupid"))

})

test_that("Parsing multi-sentence ", {
        actual <- tokenize_from_input("When are we going to the fare? I want to ride on the donkey!")
        expect_identical(actual, c("i", "want", "to", "ride", "on", "the", "donkey"))
})

