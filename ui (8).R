library(shiny)
library(leaflet)

# Define UI
shinyUI(fluidPage(
  titlePanel("Bike-sharing Demand Prediction"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("city", "Select a city:", choices = c("All", "Seoul", "New York", "Paris", "Suzhou", "London"))
    ),
    
    mainPanel(
      leafletOutput("city_bike_map")
    )
  )
))
