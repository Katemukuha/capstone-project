# Install and import required libraries
require(shiny)
require(ggplot2)
require(leaflet)
require(tidyverse)
require(httr)
require(scales)
# Import model_prediction R which contains methods to call OpenWeather API
# and make predictions
source("model_prediction.R")


test_weather_data_generation<-function(){
  city_weather_bike_df<-generate_city_weather_bike_data()
  print(head(city_weather_bike_df))
}

# Create a RShiny server
shinyServer(function(input, output, session){
  # Define a city list
  
  # Define color factor
  color_levels <- colorFactor(c("green", "yellow", "red"), 
                              levels = c("small", "medium", "large"))
  
  # Test generate_city_weather_bike_data() function
  # city_weather_bike_df <- test_weather_data_generation()
  city_weather_bike_df <- test_weather_data_generation()
  # Create another data frame called `cities_max_bike` with each row contains city location info and max bike
  # prediction for the city
  cities_max_bike <- city_weather_bike_df %>%
    
    group_by(CITY_ASCII,LAT,LNG,BIKE_PREDICTION,BIKE_PREDICTION_LEVEL,
             
             LABEL,DETAILED_LABEL,FORECASTDATETIME,TEMPERATURE ) %>%
    
    summarize(count = n(),max = max(BIKE_PREDICTION, na.rm = TRUE))
  print(head(cities_max_bike))
})