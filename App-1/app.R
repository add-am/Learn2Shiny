#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(bslib)

## Define UI ----
ui <- page_sidebar(
  title = "CensusVis",
  sidebar = sidebar(
    helpText(
      "Create demographic maps with information from the 2010 US Census."
    ),
    selectInput(
      "var",
      label = "Choose a variable to display",
      choices = 
        list(
          "Percent White", 
          "Percent Black",
          "Percent Hispanic", 
          "Percent Asian"
          ),
      selected = "Percent White"
    ),
    sliderInput(
      "range",
      label = "Range of interest:",
      value = c(0, 100),
      min = 0,
      max = 100,
      step = 10)
  )
)

  



# Define server logic ----
server <- function(input, output) {
  
}

# Run the app ----
shinyApp(ui = ui, server = server)