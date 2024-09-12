
#load packages
library(shiny)
library(bslib)
library(sf)
library(tidyverse)
library(ggplot2)
library(units)
library(glue)
library(RColorBrewer)

#turn off scientific notation
options(scipen=999)

#get the helper function
source("helper.R")

#run the helper function (creates the desired data)
n3_land_use <- helper()

#store a reference dataset
n3_reference <- n3_land_use

#pivot data wider as this is easier for the shiny app to handle
n3_land_use <- n3_land_use |> 
  pivot_wider(names_from = "SubBasin", values_from = "Area")

#set the variables that are allowed to be called
vars <- setdiff(names(n3_land_use), c("Region", "Basin", "Landuse", "Year"))

#create a simply UI
ui <- page_sidebar(
  title = "Landuse Types in The Northern Three Regions",
  sidebar = sidebar(
      selectInput("region_var", "Region:", choices = unique(n3_land_use$Region)),
      selectInput("basin_var", "Basin:", choices =  NULL),
      selectInput("y_var", "Sub Basin:", choices = vars)
    ),
  plotOutput("plot")
)


#create the server logic
server <- function(input, output, session) {
  
  observe({#use observe to return a reactive set of options for the selectInput Button
    
    basins <- n3_land_use |> 
      filter(Region == input$region_var) |> #based on region, extract only basins within the region
      pull(Basin) |> 
      unique()
    
    updateSelectInput(session, "basin_var", choices = basins, #update the "basin_var" input
                      selected = if (length(basins) > 0) basins[1] else NULL)

    })
  
  observe({#use observe to return a reactive set of options for the selectInput Button
    
    sub_basins <- n3_reference |> 
      filter(Basin == input$basin_var) |> #based on basin, extract only sub basins within the basin
      pull(SubBasin) |> 
      unique()
    
    updateSelectInput(session, "y_var", choices = sub_basins, #update the "y_var" input
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
      geom_line(size = 2) +
      geom_point(size = 5, shape = 21, fill = "white", stroke = 2) +
      scale_y_continuous(trans = "log10") +
      labs(y = glue("{input$y_var} (km2)")) +
      theme_bw() +
      theme(legend.title = element_text(size = 18),
            legend.text = element_text(size = 12),
            legend.key.size = unit(2, "line"),
            axis.title = element_text(size = 16),
            axis.text = element_text(size = 12)) +
      scale_color_brewer(palette = "Dark2")
  })
}

# Run the app ----
shinyApp(ui = ui, server = server)