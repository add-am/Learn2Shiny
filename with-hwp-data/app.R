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
library(sf)
library(tidyverse)
library(ggplot2)
library(units)
library(plotly)

#source helper functions
#source("helpers.R")

#load data
n3_land_use <- st_read("data/n3_land_use.gpkg")

#filter for just Black River
black_river <- n3_land_use |> 
  filter(sub_basin == "Black River")

#calculate areas of each land use type
black_river <- black_river |> 
  rowwise() |> 
  mutate(area = st_area(geom)) |> 
  ungroup() |> 
  st_drop_geometry() |> 
  group_by(year, landuse) |> 
  summarise(area = sum(area)) |> 
  ungroup()

#update the units to a more reasonable metric
black_river$area <- units::set_units(black_river$area, km^2)

#pivot data wider
black_river <- black_river |> 
  pivot_wider(names_from = "year", values_from = "area")

#black_river <- black_river |> mutate(year = as.numeric(year))

ui <- fluidPage(
  titlePanel("K-means Clustering on Iris Dataset"),
  sidebarLayout(
    sidebarPanel(
      selectInput("x_var", "X Variable:", choices = names(black_river)[-1]),
      #selectInput("y_var", "Y Variable:", choices = names(iris)[-5]),
      #sliderInput("clusters", "Number of clusters:", min = 1, max = 5, value = 3)
    ),
    mainPanel(
      plotOutput("plot")
    )
  )
)

server <- function(input, output) {
  output$plot <- renderPlot({
    # Perform K-means clustering on the selected X and Y variables
    #iris_clusters <- kmeans(iris[,c(input$x_var, input$y_var)],centers = input$clusters)
    
    # Plot clusters
    plot(black_river[, c("landuse", input$x_var)],# col = iris_clusters$cluster,
         main = "K-means Clustering on Iris Dataset")
    #points(iris_clusters$centers, col = 1:input$clusters, pch = 8, cex = 2)
  })
}


# Run the app ----
shinyApp(ui = ui, server = server)