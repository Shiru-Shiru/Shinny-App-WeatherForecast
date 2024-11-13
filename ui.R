# Load required libraries
library(shiny)
library(leaflet)
library(jsonlite)
library(ggplot2)
library(tidyverse)
library(shinydashboard)
library(dplyr)
library(shinyMatrix)
library(plotly)

# Define UI
ui <- fluidPage(
  titlePanel("Weather"),
  
  tags$head(
    tags$style(HTML("
      .card {
        display: block;
        width: 100%;
        padding: 8px;
        margin: 4px;
        color: white;
        font-size: 16px;
        font-weight: bold;
        text-align: center;
        border-radius: 8px;
      }
      .humidity-card { background-color: #17a2b8; } /* Cyan */
      .temperature-card { background-color: #dc3545; } /* Red */
      .feels-like-card { background-color: #ff7f50; } /* Coral */
      .visibility-card { background-color: #28a745; } /* Green */
      .wind-speed-card { background-color: #343a40; } /* Dark */
      .air-pressure-card { background-color: #e83e8c; } /* Pink */
    
      .card-icon {
        font-size: 24px;
        margin-right: 8px;
      }
      .map-container {
        width: 100%;
        height: 400px;
        padding-top: 20px;
      }
    "))
  ),
  
  # Location and Weather Condition Display
  fluidRow(
    column(6,textOutput("location")),
    column(7,textOutput("weather_condition"))
  ),
  
  # Map and Cards in a single row
  fluidRow(
    # Map on the left side
    column(
      width = 6,
      div(class = "map-container", leafletOutput("map"))
    ),
    
    # Cards on the right side
    column(
      width = 6,
      div(class = "card humidity-card",
          tags$span(class = "card-icon", "\U1F4A7"), # Droplet icon
          "Humidity", textOutput("humidity")),
      div(class = "card temperature-card",
          tags$span(class = "card-icon", "\U1F321"), # Thermometer icon
          "Temperature", textOutput("temperature")),
      div(class = "card feels-like-card",
          tags$span(class = "card-icon", "\U2600"), # Sun icon
          "Feels Like", textOutput("feels_like")),
      div(class = "card visibility-card",
          tags$span(class = "card-icon", "\U1F441"), # Eye icon
          "Visibility", textOutput("visibility")),
      div(class = "card wind-speed-card",
          tags$span(class = "card-icon", "\U1F4A8"), # Wind icon
          "Wind Speed", textOutput("wind_speed")),
      div(class = "card air-pressure-card",
          tags$span(class = "card-icon", "\U1F30D"), # Globe icon
          "Air Pressure", textOutput("air_pressure"))
    )
  ),
  
  # Forecast feature selection and chart display
  fluidRow(
    column(
      12,
      selectInput("feature", "Select Forecast Feature:", 
                  choices = list("Temperature" = "temp", "Min Temperature" = "temp_min", "Max Temperature" = "temp_max")),
      plotlyOutput("line_chart")
    )
  )
)
