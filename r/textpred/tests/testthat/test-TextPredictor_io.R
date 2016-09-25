context("Testing reading & writing model with files")


test_that("Read/write to RDS", {
        model <- hash()
        model$"_" <- setNames(c(0.4,0.2,0.1),c("next","word","is"))
        output <- TextPredictor(model, maxorder = 4)
        modelpath = "model.RDS"
        saveRDS(output$model, file = modelpath)
        input <- TextPredictor(modelpath, maxorder = 4)
        actual <- predict(input,c("some", "random", "text"))
        expect_identical(actual, setNames(c(0.4,0.2,0.1),c("next","word","is")))
        file.remove(modelpath)
})


test_that("Read from JSON", {
        model <- "inputs/model.json"
        mypred <- TextPredictor(model, maxorder = 4)
        actual <- predict(mypred,c("some", "random", "text"))
        expect_identical(actual, setNames(c(0.4,0.2,0.1),c("next","word","is")))

})


