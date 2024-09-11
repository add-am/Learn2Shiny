
#load packages
library(shiny)
library(bslib)
library(maps)
library(mapproj)
library(sf)
library(tidyverse)
library(ggplot2)
library(units)
library(plotly)

#load data
n3_land_use <- st_read("data/n3_land_use.gpkg")

#filter for just Black Basin
black_basin <- n3_land_use |> 
  filter(basin == "Black") |> 
  st_make_valid()

#calculate areas of each land use type
black_basin <- black_basin |> 
  rowwise() |> 
  mutate(area = st_area(geom)) |> 
  ungroup() |> 
  st_drop_geometry() |> 
  group_by(sub_basin, year, landuse) |> 
  summarise(area = sum(area)) |> 
  ungroup()

#update the units to a more reasonable metric
black_basin$area <- units::set_units(black_basin$area, km^2)

#pivot data wider
black_basin <- black_basin |> 
  pivot_wider(names_from = "sub_basin", values_from = "area")

#set the variables that are allowed to be called
vars <- setdiff(names(black_basin), c("landuse", "year"))

#create a simply UI
ui <- fluidPage(
  titlePanel("K-means Clustering on Iris Dataset"),
  sidebarLayout(
    sidebarPanel(
      selectInput("x_var", "X Variable:", choices = vars)
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

#create the server logic
server <- function(input, output) {
  output$plot <- renderPlot({
    
    selectedData <- reactive({
      black_basin[, c("year", "landuse", input$x_var)]
    })

    #plot
    ggplot(black_basin, aes(x = year, y = .data[[input$x_var]], group = landuse)) +
      geom_line()
  })
}

# Run the app ----
shinyApp(ui = ui, server = server)