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
  #Test generate_city_weather_bike_data() function
  city_weather_bike_df<-generate_city_weather_bike_data()
  stopifnot(length(city_weather_bike_df)>0)
  print(head(city_weather_bike_df))
  return(city_weather_bike_df)
}
test_weather_data_generation()

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
  
  observeEvent(input$city_dropdown, {
    
    print(input$city_dropdown)
    
    filteredData <- cities_max_bike %>%
      
      filter(CITY_ASCII == input$city_dropdown)
    
    print(head(filteredData))
    
    if(input$city_dropdown == "All") {
      
      output$city_bike_map <- renderLeaflet({
        
        # Complete this function to render a leaflet map
        
        leaflet(cities_max_bike) %>%
          
          addTiles() %>%
          
          addCircleMarkers(data = cities_max_bike, lng = cities_max_bike$LNG, lat = cities_max_bike$LAT, 
                           
                           popup = cities_max_bike$LABEL,
                           
                           radius= ~ifelse(cities_max_bike$BIKE_PREDICTION_LEVEL=='small', 6, 12),
                           
                           color = ~color_levels(cities_max_bike$BIKE_PREDICTION_LEVEL))
        
      })
      
      
    }
    
    else {
      
      print("Hello")
      
      output$city_bike_map <- renderLeaflet({
        
        leaflet(data=filteredData) %>% addTiles()  %>%
          
          addMarkers(data=filteredData,lng = filteredData$LNG, lat = filteredData$LAT
                     
                     ,popup=filteredData$DETAILED_LABEL)
        
        
      })
      
      
      
      output$temp_line <- renderPlot({
        
        line_plot<- ggplot(city_weather_bike_df, aes(x=1:length(TEMPERATURE), y= TEMPERATURE)) +
          
          geom_line(color="yellow", size=1) +  labs(x = "Time (3 hours ahead)", y ="TEMPERATURE (C)") +
          
          geom_point() +
          
          geom_text(aes(label=paste(TEMPERATURE, " C")),hjust=0, vjust=0) +
          
          ggtitle("TEMPERATURE Chart")
        
        line_plot
        
      })
      
      
      output$bike_line <- renderPlot({
        
        line_plot<- ggplot(city_weather_bike_df, aes(x=as.POSIXct(FORECASTDATETIME, "%Y-%m-%d %H:%M",tz="EST"), 
                                                     
                                                     y=BIKE_PREDICTION)) +  
          
          geom_point() + 
          
          geom_text(aes(label=BIKE_PREDICTION),hjust=0, vjust=0) +
          
          geom_line(color="#69b3a2", size=1, alpha=0.9, linetype=2) + 
          
          scale_x_datetime(labels = scales::time_format("%m-%d-%H")) + 
          
          labs(x = "Time (3 hours ahead)", y ="Predicted Bike Count")
        
        line_plot
        
      })
      
      
      
      output$bike_date_output <- renderText({
        
        paste0("Time=", as.POSIXct(as.integer(input$plot_click$x), origin = "1970-01-01"),
               
               "\nBikeCountPred=", as.integer(input$plot_click$y))
        
      })
      
      
      output$humidity_pred_chart <- renderPlot({
        
        line_plot<- ggplot(data=city_weather_bike_df, aes(HUMIDITY, BIKE_PREDICTION)) + 
          
          geom_point() +
          
          geom_smooth(method = "lm", formula = y ~ poly(x, 4), color="red")
        
        line_plot    
        
      })
      
      
    } 
    
  })
  
  
})