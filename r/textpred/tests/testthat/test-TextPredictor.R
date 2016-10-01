context("Testing basic prediction")

test_that("Look-up with only low-level", {
        model <- hash()
        model$"_" <- setNames(c(0.04,0.02,0.01),c("next","word","is"))
        mypred <- TextPredictor(model, maxorder = 4)
        actual <- predict(mypred,c("some", "random", "text"))
        expect_identical(actual, setNames(c(0.04,0.02,0.01),c("next","word","is")))

})


test_that("Look-up with top-level", {
        model <- hash()
        model$"_" <- setNames(c(0.04,0.02,0.01),c("next","word","is"))
        model$"text" <- setNames(c(0.16,0.1,0.09),c("we","are","cool"))
        model$"random_text" <- setNames(c(0.23,0.20,0.11),c("i","am","okay"))
        model$"some_random_text" <- setNames(c(0.4,0.3,0.21), c("the","right","word"))
        mypred <- TextPredictor(model, maxorder = 4)
        actual <- predict(mypred,c("some", "random", "text"))
        expect_identical(actual, setNames(c(0.4,0.3,0.23,0.21,0.20,0.16,0.11,0.1,0.09,0.04,0.02,0.01),
                                          c("the","right","i","word","am","we","okay","are","cool","next","word","is")))

})


test_that("Putting it all together look-up with long sentence and tokenize", {
        model <- hash()
        model$"_" <- setNames(c(0.04,0.02,0.01),c("next","word","is"))
        model$"the" <- setNames(c(0.4,0.2,0.1),c("world","winter","game"))
        mypred <- TextPredictor(model, maxorder = 2)
        actual <- predict(mypred,tokenize_from_input("i am writing to you today to be the change in the world that is the"))
        expect_identical(actual, setNames(c(0.4,0.2,0.1, 0.04,0.02,0.01),c("world","winter","game","next","word","is")))
})
