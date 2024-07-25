require(leaflet)

library(shiny)
library(leaflet)

# Define UI
shinyUI(fluidPage(padding = 5,
  titlePanel("Bike-sharing Demand Prediction app"),
  
  sidebarLayout(
    mainPanel(
      # leaflet output with id = 'city_bike_map', height = 1000
      leafletOutput("city_bike_map", width = "100%", height = 1000),
    ),
    # Create a side bar to show detailed plots for a city
    sidebarPanel(
      # select drop down list to select city
      selectInput(inputId = "city_dropdown", 
                  "Choose City",
                  c("All", "Seoul", "Suzhou", "London", "New York", "Paris")
      ),
      plotOutput("temp_line"),
      plotOutput("bike_line",click = "plot_click"),
      verbatimTextOutput("bike_date_output"),
      plotOutput("humidity_pred_chart")
))))
