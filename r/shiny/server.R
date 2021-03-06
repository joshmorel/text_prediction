library(shiny)
library(textpred)
suppressPackageStartupMessages(library(data.table))

updateText <- function(currentText, extraText) {
        baseText <- trimws(currentText)
        if (nchar(baseText) == 0) {
                newText <- paste(extraText,"")
        } else {
                newText <- paste(baseText,extraText,"")
        }
        return(newText)

}


shinyServer(function(input, output, session) {



        model <- TextPredictor(model='model.txt', vocab='vocab.txt', maxorder=4, ngram_delim=" ")

        prediction  <- reactive({
                predict(model, input$activeText)
        })

        output$predict1_word <- renderUI({
          actionButton("predict1", label = prediction()[1,word])
        })

        output$predict1_score <- renderText({
          print(prediction()[1,score])
        })

        output$predict2_word <- renderUI({
          actionButton("predict2", label = prediction()[2,word])
        })

        output$predict2_score <- renderText({
          print(prediction()[2,score])
        })

        output$predict3_word <- renderUI({
          actionButton("predict3", label = prediction()[3,word])
        })

        output$predict3_score <- renderText({
          print(prediction()[3,score])
        })

        output$predict4_word <- renderUI({
                actionButton("predict4", label = prediction()[4,word])
        })

        output$predict4_score <- renderText({
                print(prediction()[4,score])
        })

        observeEvent(input$predict1, {
                updateTextInput(session, "activeText",
                                value = updateText(input$activeText, prediction()[1,word]))
                session$sendCustomMessage("cursorEnd", TRUE)

        })
        observeEvent(input$predict2, {
                updateTextInput(session, "activeText",
                                value = updateText(input$activeText, prediction()[2,word]))
                session$sendCustomMessage("cursorEnd", TRUE)

        })
        observeEvent(input$predict3, {
                updateTextInput(session, "activeText",
                                value = updateText(input$activeText, prediction()[3,word]))
                session$sendCustomMessage("cursorEnd", TRUE)
        })
        observeEvent(input$predict4, {
                updateTextInput(session, "activeText",
                                value = updateText(input$activeText, prediction()[4,word]))
                session$sendCustomMessage("cursorEnd", TRUE)
        })


})
