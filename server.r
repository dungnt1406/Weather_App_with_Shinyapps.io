# server.R
library(shiny)
library(leaflet)
library(jsonlite)
library(plotly)

###############################################################################################
#                              GET INFORMATION FROM OPENWEATHER                               #
###############################################################################################

get_weather_info <- function(lat, lon) {
  api_key <- "923ac13dae459cfb67333a0c63f7f0bb"
  API_call <- "https://api.openweathermap.org/data/2.5/weather?lat=%s&lon=%s&appid=%s"
  complete_url <- sprintf(API_call, lat, lon, api_key)
  json <- fromJSON(complete_url)
  
  if (is.null(json$name)) {return(NULL)}
  
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
###############################################################################################
#                                      FORECAST FUNCTION                                      #
###############################################################################################


get_forecast <- function(lat, lon) {
  api_key <- "d076ef1cee22c7c2a00ad9afcf232eb5"
  API_call <- "https://api.openweathermap.org/data/2.5/forecast?lat=%s&lon=%s&appid=%s"
  complete_url <- sprintf(API_call, lat, lon, api_key)
  json <- fromJSON(complete_url)
  
  if (is.null(json$list)) {
    return(NULL)  
  }
  
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
    id = sapply(json$list$weather, function(entry) entry$id),
    main = sapply(json$list$weather, function(entry) entry$main),
    icon = sapply(json$list$weather, function(entry) entry$icon),
    weather_conditions = sapply(json$list$weather, function(entry) entry$description),
    speed = json$list$wind$speed,
    deg = json$list$wind$deg,
    gust = json$list$wind$gust,
    stringsAsFactors = FALSE
  )
  
  return(df)
}

###############################################################################################
#                                        MAIN FUNCTION                                        #
###############################################################################################

server <- function(input, output, session) {
  ####################################DEFAULT
  default_lat <- 21.0124167
  default_lon <- 105.5227143
  weather_info <- get_weather_info(default_lat, default_lon)
  
  output$location <- renderText({ paste("_", weather_info$Location, "_") })
  output$humidity <- renderText({ paste(weather_info$Humidity, "%") })
  output$temperature <- renderText({ paste(weather_info$Temperature, "°C") })
  output$feels_like <- renderText({ paste(weather_info$Feels_like, "°C") })
  output$weather_condition <- renderText({ paste(toupper(weather_info$WeatherCondition)) })
  output$visibility <- renderText({ paste(weather_info$Visibility, "Km") })
  output$wind_speed <- renderText({ paste(weather_info$Wind_speed, "Km/h") })
  output$air_pressure <- renderText({ paste(weather_info$Air_pressure, "hPa")})
  
  output$map <- renderLeaflet({leaflet() %>% addTiles() %>% setView(lng = default_lon, lat = default_lat, zoom = 15)})
  ########################################### SESSION ONE
  
  click <- NULL
  
  observeEvent(input$map_click, {
    click <<- input$map_click
    weather_info <<- get_weather_info(click$lat, click$lng)
    
    if (is.null(weather_info)) {return()}
    
    output$location <- renderText({paste("_", weather_info$Location, "_")})
    output$humidity <- renderText({ paste(weather_info$Humidity, "%") })
    output$temperature <- renderText({ paste(weather_info$Temperature, "°C") })
    output$feels_like <- renderText({ paste(weather_info$Feels_like, "°C") })
    output$weather_condition <- renderText({ paste(toupper(weather_info$WeatherCondition)) })
    output$visibility <- renderText({ paste(weather_info$Visibility, "Km") })
    output$wind_speed <- renderText({ paste(weather_info$Wind_speed, "Km/h") })
    output$air_pressure <- renderText({ paste(weather_info$Air_pressure, "hPa")})
  })
  ############################################## SESSION TWO
  observeEvent(input$feature, {
    output$location_ <- renderText({paste('Location: ', weather_info$Location)})
    
    default_lat <- 21.0124167
    default_lon <- 105.5227143
    data <- get_forecast(default_lat, default_lon)
    output$line_chart <- renderPlotly({
      # Create a line chart using plot_ly
      feature_data <- data[, c("Time", input$feature)]
      # Create a line chart using plot_ly
      plot_ly(data = feature_data, x = ~Time, 
              y = ~.data[[input$feature]], 
              type = 'scatter', 
              mode = 'lines+markers', 
              name = input$feature) %>%
        
          layout(title = paste("Line Chart of", input$feature),
                 xaxis = list(title = "Time"),
                 yaxis = list(title = input$feature)) %>%
        
          add_trace(line = list(color = "#03DAC6"),  
                    marker = list(color = "#018786"),
                    showlegend = FALSE)
    })    
    if (!is.null(click)) {
      
    data <- get_forecast(click$lat, click$lng)
    
    if (is.null(data)) {
      output$line_chart <- renderText({"MISSING VALUE."})
      return()
    }
    
    output$line_chart <- renderPlotly({
      
      feature_data <- data[, c("Time", input$feature)]
      
      plot_ly(data = feature_data, x = ~Time, y = ~.data[[input$feature]], type = 'scatter', mode = 'lines+markers', name = input$feature) %>%
        layout(
          title = paste("Line Chart of", input$feature),
          xaxis = list(title = "Time"),
          yaxis = list(title = input$feature)
        ) %>%
        add_trace(
          line = list(color = "#03DAC6"),  
          marker = list(color = "#018786"),
          showlegend = FALSE)
    })
  }})
}

