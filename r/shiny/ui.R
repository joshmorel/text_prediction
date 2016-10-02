library(shiny)
library(markdown)

# Define UI for dataset viewer application
shinyUI(fluidPage(
        titlePanel(title="My Text Prediction App"),
        tabsetPanel(
        tabPanel("App",
          fluidRow(
            column(12,
                   fluidRow(
                     column(12,
                            textInput("activeText", "Type Away...", width='100%'),
                            # script to return cursor back to text input if next word button clicked
                            tags$script(HTML("
                                 Shiny.addCustomMessageHandler('cursorEnd', function(message) {
                                           var input = $('#activeText');
                                           input[0].selectionStart = input[0].selectionEnd = input.val().length;
                                           input.focus();
                                           });
                                           ")
                            )
                     )),
                   hr(),
                   fluidRow("Predicted Words"),
                   fluidRow(
                           column(3,uiOutput("predict1_word")),
                           column(3,uiOutput("predict2_word")),
                           column(3,uiOutput("predict3_word")),
                           column(3,uiOutput("predict4_word"))

                   ),
                   hr(),
                   fluidRow("Stupid Backoff Scores"),
                   fluidRow(
                           column(3,uiOutput("predict1_score")),
                           column(3,uiOutput("predict2_score")),
                           column(3,uiOutput("predict3_score")),
                           column(3,uiOutput("predict4_score"))
                           )

            )
          )
        )
        ,tabPanel("Notes",
            includeMarkdown("description.md")
        )
        )
))

