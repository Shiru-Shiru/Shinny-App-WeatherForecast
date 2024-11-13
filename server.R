get_weather_info <- function(lat, lon) {
  api_key <- "2a4e41f1831a443007706ac617ce7730"
  API_call <-
    "https://api.openweathermap.org/data/2.5/weather?lat=%s&lon=%s&appid=%s"
  complete_url <- sprintf(API_call, lat, lon, api_key)
  json <- fromJSON(complete_url)
  
  location <- json$name
  temp <- json$main$temp - 273.2
  feels_like <- json$main$feels_like - 273.2
  humidity <- json$main$humidity
  weather_condition <- json$weather$description
  visibility <- json$visibility/1000
  wind_speed <- json$wind$speed
  air_pressure <- json$main$pressure
  weather_info <- list(
    Location = location,
    Temperature = temp,
    Feels_like = feels_like,
    Humidity = humidity,
    WeatherCondition = weather_condition,
    Visibility = visibility,
    Wind_speed = wind_speed,
    Air_pressure = air_pressure
  )
  return(weather_info)
}
get_forecast <- function(lat, lon) {
  api_key <- "2a4e41f1831a443007706ac617ce7730"
  # base_url variable to store url
  API_call = "https://api.openweathermap.org/data/2.5/forecast?lat=%s&lon=%s&appid=%s"
  
  # Construct complete_url variable to store full url address
  complete_url = sprintf(API_call, lat, lon, api_key)
  #print(complete_url)
  json <- fromJSON(complete_url)
  df <- data.frame(
    Time = json$list$dt_txt,
    Location = json$city$name,
    feels_like = json$list$main$feels_like - 273.2,
    temp_min = json$list$main$temp_min - 273.2,
    temp_max = json$list$main$temp_max - 273.2,
    pressure = json$list$main$pressure,
    sea_level = json$list$main$sea_level,
    grnd_level = json$list$main$grnd_level,
    humidity = json$list$main$humidity,
    temp_kf = json$list$main$temp_kf,
    temp = json$list$main$temp - 273.2,
    id = sapply(json$list$weather, function(entry)
      entry$id),
    main = sapply(json$list$weather, function(entry)
      entry$main),
    icon = sapply(json$list$weather, function(entry)
      entry$icon),
    humidity = json$list$main$humidity,
    weather_conditions = sapply(json$list$weather, function(entry)
      entry$description),
    speed = json$list$wind$speed,
    deg = json$list$wind$deg,
    gust = json$list$wind$gust
  )
  
  return (df)
}

server <- function(input, output, session) {
  # Set default coordinates
  default_lat <- 21.0277644
  default_lon <- 105.8341598
  
  # Function to update weather and forecast data based on the selected location
  update_weather_and_forecast <- function(lat, lon) {
    weather_info <<- get_weather_info(lat, lon)
    forecast_data <<- get_forecast(lat, lon)
    
    # Update the weather information outputs
    output$location <- renderText({ paste("Location:", weather_info$Location) })
    output$humidity <- renderText({ paste(weather_info$Humidity, "%") })
    output$temperature <- renderText({ paste(weather_info$Temperature, "°C") })
    output$feels_like <- renderText({ paste(weather_info$Feels_like, "°C") })
    output$weather_condition <- renderText({ paste("Weather Condition:", weather_info$WeatherCondition) })
    output$visibility <- renderText({ paste(weather_info$Visibility, "Km") })
    output$wind_speed <- renderText({ paste(weather_info$Wind_speed, "Km/h") })
    output$air_pressure <- renderText({ paste(weather_info$Air_pressure) })
    
    # Update the forecast chart based on the selected feature
    output$line_chart <- renderPlotly({
      feature_data <- forecast_data[, c("Time", input$feature)]
      plot_ly(data = feature_data, x = ~Time, y = ~.data[[input$feature]], type = 'scatter', mode = 'lines+markers') %>%
        layout(
          title = paste("5-Day Forecast for", weather_info$Location),
          xaxis = list(title = "Time"),
          yaxis = list(title = input$feature)
        )
    })
  }
  
  # Initial call to update weather and forecast information for the default location
  update_weather_and_forecast(default_lat, default_lon)
  
  # Map output
  output$map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = default_lon, lat = default_lat, zoom = 10)
  })
  
  # Update data when the map is clicked
  observeEvent(input$map_click, {
    click <- input$map_click
    update_weather_and_forecast(click$lat, click$lng)
  })
  
  # Update the forecast chart when the selected feature changes
  observeEvent(input$feature, {
    if (exists("forecast_data")) {
      output$line_chart <- renderPlotly({
        feature_data <- forecast_data[, c("Time", input$feature)]
        plot_ly(data = feature_data, x = ~Time, y = ~.data[[input$feature]], type = 'scatter', mode = 'lines+markers') %>%
          layout(
            title = paste("Forecast for", weather_info$Location),
            xaxis = list(title = "Time"),
            yaxis = list(title = input$feature)
          )
      })
    }
  })
}
