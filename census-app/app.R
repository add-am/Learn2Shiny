#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#load packages
library(shiny)
library(bslib)
library(maps)
library(mapproj)

#source helper functions
source("helpers.R")

#load data
counties <- readRDS("data/counties.rds")

## Define UI ----
ui <- page_sidebar(
  title = "CensusVis",
  sidebar = sidebar(
    helpText(
      "Create demongraphic maps with information from the 2010 US Census."
    ),
    selectInput(
      "var",
      label = "Choose a variable to display",
      choices = 
        c("Percent White",
          "Percent Black",
          "Percent Hispanic",
          "Percent Asian"),
      selected = "Percent White"
    ),
    sliderInput(
      "range",
      label = "Range of interest:",
      min = 0,
      max = 100,
      value = c(0, 100)
    )
  ),
  card(
    plotOutput("map")
  )
)

# Define server logic ----
server <- function(input, output) {
  output$map <- renderPlot({
    
    data <- switch(input$var,
                   "Percent White" = counties$white,
                   "Percent Black" = counties$black,
                   "Percent Hispanic" = counties$hispanic,
                   "Percent Asian" = counties$asian)
    
    color <- switch(input$var,
                   "Percent White" = "darkgreen",
                   "Percent Black" = "black",
                   "Percent Hispanic" = "darkorange",
                   "Percent Asian" = "darkviolet")
    
    legend <- switch(input$var,
                   "Percent White" = "% White",
                   "Percent Black" = "% Black",
                   "Percent Hispanic" = "% Hispanic",
                   "Percent Asian" = "% Asian")
    
    percent_map(
      var = data,
      color = color,
      legend.title = "A normal title",
      max = input$range[2],
      min = input$range[1]
    )
  })
}

# Run the app ----
shinyApp(ui = ui, server = server)