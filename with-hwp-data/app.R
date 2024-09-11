
#load packages
library(shiny)
library(bslib)
#library(maps)
#library(mapproj)
library(sf)
library(tidyverse)
library(ggplot2)
library(units)
#library(plotly)

source("helper.R")

n3_land_use <- helper()

#store a reference dataset
n3_reference <- n3_land_use

#pivot data wider as this is easier for the shiny app to handle
n3_land_use <- n3_land_use |> 
  pivot_wider(names_from = "SubBasin", values_from = "Area")

#set the variables that are allowed to be called
vars <- setdiff(names(n3_land_use), c("Region", "Basin", "Landuse", "Year"))

#create a simply UI
ui <- fluidPage(
  titlePanel("Landuse Types in The Northern Three Region"),
  sidebarLayout(
    sidebarPanel(
      selectInput("region_var", "Region:", choices = unique(n3_land_use$Region)),
      selectInput("basin_var", "Basin:", choices =  NULL),
      selectInput("y_var", "Sub Basin:", choices = vars)
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

#create the server logic
server <- function(input, output, session) {
  
  observe({
    
    basins <- n3_land_use |> 
      filter(Region == input$region_var) |> 
      pull(Basin) |> 
      unique()
    
    updateSelectInput(session, "basin_var", choices = basins,
                      selected = if (length(basins) > 0) basins[1] else NULL)

    })
  
  observe({
    
    sub_basins <- n3_reference |> 
      filter(Basin == input$basin_var) |> 
      pull(SubBasin) |> 
      unique()
    
    updateSelectInput(session, "y_var", choices = sub_basins,
                      selected = if (length(sub_basins) > 0) sub_basins[1] else NULL)
    
  })
  
  #select the region to look at
  regionData <- reactive({
    
    n3_land_use |> filter(Region == input$region_var)
    
  })
  
  #select the basin to look at
  basinData <- reactive({
    
    regionData() |> filter(Basin == input$basin_var)
    
  })
  
  #select the sub basin to look at
  finalData <- reactive({
    
    basinData() |> select(Year, Landuse, input$y_var)
    
  })
  
  output$plot <- renderPlot({

    #plot
    ggplot(finalData(), aes(x = Year, y = .data[[input$y_var]], group = Landuse, color = Landuse)) +
      geom_line() +
      scale_y_continuous(trans = "log10") +
      theme_bw()
  })
}

# Run the app ----
shinyApp(ui = ui, server = server)