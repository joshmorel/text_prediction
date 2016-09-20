library(shiny)

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
        
        # Application title
        headerPanel("Shiny Text"),
        
        # Sidebar with controls to select a dataset and specify the number
        # of observations to view
        sidebarPanel(
                textInput("typing", "Type Stuff:")
                
        ),
        
        # Show a summary of the dataset and an HTML table with the requested
        # number of observations
        mainPanel(
                verbatimTextOutput("typeout"),
                verbatimTextOutput("splittext")
        )
))