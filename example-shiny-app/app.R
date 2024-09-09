# Load packages

library(shiny)
library(bslib)
library(ggplot2)

# Get the data

file <- "https://github.com/rstudio-education/shiny-course/raw/main/movies.RData"
destfile <- "movies.RData"

download.file(file, destfile)

# Load data

load("movies.RData")

#define a key for movie variables
movie_var_key <- c("IMDB Rating" = "imdb_rating", "IMDB Number of Votes" = "imdb_num_votes",
                   "Critic's Score" = "critics_score", "Audience Score" = "audience_score", "Runtime" = "runtime")

# Define UI

ui <- page_sidebar(
  sidebar = sidebar(
    # Select variable for y-axis
    selectInput(inputId = "y",
                label = "Y-axis:",
                choices = movie_var_key,
                selected = "audience_score"
    ),
    # Select variable for x-axis
    selectInput(inputId = "x",
                label = "X-axis:",
                choices = movie_var_key,
                selected = "critics_score"
    ),
    selectInput(inputId = "z",
                label = "Colour by:",
                choices = c("Title Type" = "title_type", "Genere" = "genre", "MPAA Rating" =  "mpaa_rating",
                            "Critic's Rating" = "critics_rating", "Audience Rating" = "audience_rating"),
                selected = "mpaa_rating")
    
  ),
  # Output: Show scatterplot
  card(plotOutput(outputId = "scatterplot"))
)

# Define server

server <- function(input, output, session) {
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y, color = input$z)) +
      geom_point()
  })
}

# Create a Shiny app object

shinyApp(ui = ui, server = server)