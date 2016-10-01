library(shiny)
# library(devtools)
# devtools::install_github('joshmorel/text_prediction',subdir = 'R/textpred')
library(textpred)
# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {

        model <- TextPredictor("model.json",maxorder = 4, ngram_delim = " ")

        fulltext  <- reactive({
                mytext <- input$typing
        })


        output$typeout <- renderPrint({
                print(fulltext())
                # print(mytext)
        })

        output$tokenized <- renderPrint({
                tokens <- tokenize_from_input(fulltext())
                # tokens <- unlist(strsplit("hello there"," "))
                print(tokens)

        })


})
