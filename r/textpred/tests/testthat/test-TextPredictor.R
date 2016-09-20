context("Testing basic prediction")

test_that("Look-up works recursively", {
        model <- new.env()
        model$"_" <- c("next","word","is")
        mypred <- TextPredictor(model, maxorder = 4)
        actual <- predict(mypred,c("some", "random", "text"))
        expect_identical(actual, c("next","word","is"))

})


test_that("Look-up with top-level", {
        model <- new.env()
        model$"_" <- c("next","word","is")
        model$"some_random_text" <- c("the","right","word")
        mypred <- TextPredictor(model, maxorder = 4)
        actual <- predict(mypred,c("some", "random", "text"))
        expect_identical(actual, c("the","right","word"))

})
