# Install and import required libraries

require(shiny)

require(shiny)

require(leaflet)

require(tidyverse)

require(httr)

require(scales)

# Import model_prediction R which contains methods to call OpenWeather API

# and make predictions

source("model_prediction.R")





test_weather_data_generation<-function(){
  
  #Test generate_city_weather_bike_data() function
  
  city_weather_bike_df<-generate_city_weather_bike_data()
  
  stopifnot(length(city_weather_bike_df)>0)
  
  print(head(city_weather_bike_df))
  
  return(city_weather_bike_df)
  
}

read_csv("selected_cities.csv")

# Create a RShiny server

shinyServer(function(input, output){
  
  # Define a city list
  
  
  # Define color factor
  
  color_levels <- colorFactor(c("green", "yellow", "red"), 
                              
                              levels = c("small", "medium", "large"))
  
  city_weather_bike_df <- test_weather_data_generation()
  
  
  cities_max_bike <- city_weather_bike_df %>%
    
    group_by(CITY_ASCII,LAT,LNG,BIKE_PREDICTION,BIKE_PREDICTION_LEVEL,
             
             LABEL,DETAILED_LABEL,FORECASTDATETIME,TEMPERATURE ) %>%
    
    summarize(count = n(),max = max(BIKE_PREDICTION, na.rm = TRUE))})
  
  
  