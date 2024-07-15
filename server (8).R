library(shiny)
library(leaflet)
library(dplyr)
library(readr)

# Load city data
cities <- read_csv("selected_cities.csv")

# Generate color levels for bike demand
color_levels <- colorFactor(c("green", "yellow", "red"), levels = c("small", "medium", "large"))

# Define server logic
shinyServer(function(input, output, session) {
  
  # Generate the bike-sharing demand prediction data frame
  source("model_prediction.R")
  city_weather_bike_df <- generate_weather_bike_data()
  
  # Calculate max bike prediction for each city
  cities_max_bike <- city_weather_bike_df %>%
    group_by(city) %>%
    summarize(max_bike = max(predicted_demand, na.rm = TRUE))
  
  # Define bike prediction level based on max_bike values
  cities_max_bike <- cities_max_bike %>%
    mutate(BIKE_PREDICTION_LEVEL = cut(max_bike, breaks = c(-Inf, 200, 500, Inf), labels = c("small", "medium", "large")))
  
  # Render leaflet map
  output$city_bike_map <- renderLeaflet({
    leaflet(cities) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = cities$lon,
        lat = cities$lat,
        color = ~color_levels(BIKE_PREDICTION_LEVEL),
        radius = ~case_when(
          BIKE_PREDICTION_LEVEL == "small" ~ 5,
          BIKE_PREDICTION_LEVEL == "medium" ~ 10,
          BIKE_PREDICTION_LEVEL == "large" ~ 15
        ),
        popup = ~paste(
          "City:", cities$name, "<br>",
          "Max Predicted Demand:", cities_max_bike$max_bike
        )
      )
  })
  
  # Update map based on selected city
  observeEvent(input$city, {
    if (input$city == "All") {
      leafletProxy("city_bike_map") %>%
        clearMarkers() %>%
        addCircleMarkers(
          lng = cities$lon, lat = cities$lat,
          color = ~color_levels(BIKE_PREDICTION_LEVEL),
          radius = ~case_when(
            BIKE_PREDICTION_LEVEL == "small" ~ 5,
            BIKE_PREDICTION_LEVEL == "medium" ~ 10,
            BIKE_PREDICTION_LEVEL == "large" ~ 15
          ),
          popup = ~paste(
            "City:", cities$name, "<br>",
            "Max Predicted Demand:", cities_max_bike$max_bike
          )
        )
    } else {
      city_data <- cities %>% filter(name == input$city)
      city_prediction <- cities_max_bike %>% filter(city == input$city)
      
      leafletProxy("city_bike_map") %>%
        clearMarkers() %>%
        addCircleMarkers(
          lng = city_data$lon, lat = city_data$lat,
          color = ~color_levels(city_prediction$BIKE_PREDICTION_LEVEL),
          radius = ~case_when(
            city_prediction$BIKE_PREDICTION_LEVEL == "small" ~ 5,
            city_prediction$BIKE_PREDICTION_LEVEL == "medium" ~ 10,
            city_prediction$BIKE_PREDICTION_LEVEL == "large" ~ 15
          ),
          popup = paste(
            "City:", city_data$name, "<br>",
            "Max Predicted Demand:", city_prediction$max_bike
          )
        )
    }
  })
})
