context("Testing basic prediction")

test_that("Look-up works recursively", {
        model <- hash()
        model$"_" <- setNames(c(0.4,0.2,0.1),c("next","word","is"))
        mypred <- TextPredictor(model, maxorder = 4)
        actual <- predict(mypred,c("some", "random", "text"))
        expect_identical(actual, setNames(c(0.4,0.2,0.1),c("next","word","is")))

})


test_that("Look-up with top-level", {
        model <- hash()
        model$"_" <- setNames(c(0.4,0.2,0.1),c("next","word","is"))
        model$"some_random_text" <- setNames(c(0.4,0.2,0.1), c("the","right","word"))
        mypred <- TextPredictor(model, maxorder = 4)
        actual <- predict(mypred,c("some", "random", "text"))
        expect_identical(actual, setNames(c(0.4,0.2,0.1),c("the","right","word")))

})
