library(shiny)

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {
        
        fulltext  <- reactive({
                mytext <- input$typing
        })
        

        output$typeout <- renderPrint({
                print(fulltext())
                # print(mytext)
        })
        
        output$splittext <- renderPrint({
                print(strsplit(fulltext()," "))
        })
        
        
})