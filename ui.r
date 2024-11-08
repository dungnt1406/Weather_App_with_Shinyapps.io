library(shiny)
library(shinydashboard)
library(leaflet)
library(plotly)

# UI
###############################################################################################
#                                           UI                                                #
###############################################################################################

ui <- dashboardPage(
  
  skin = "black",
  
  # Header
  dashboardHeader(title = "LIVE TIME WEATHER APP", titleWidth = 350),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      menuItem("Current Weather", icon = icon("cloud-sun"), tabName = "weather"),
      menuItem("Forecast", icon = icon("dashboard"), tabName = "forecast")
    )
  ),
  
  ######################################  
  dashboardBody(
    tags$head(
      tags$style(HTML("
  /* Existing styles */

  /* Change box title color to white */
  .box .box-title {
    color: #ffffff !important;
  }
")),
      tags$style(HTML("
      /* Global styling for text and background */
      body, .content-wrapper {
        background-color: #1a1d2e; /* Dark background for content area */
        color: #ffffff;
      }
      
      /* Header logo customization */
      .main-header .logo {
        font-family: 'Arial';
        font-weight: bold;
        font-size: 25px;
        color: #ffffff;
      }

      /* Custom box styling */
      .box {
        background-color: #252a41 !important;
        color: #ffffff !important;
        border-radius: 5px;
      }
      
      .box .box-title {
        font-weight: bold;
      }

      /* Custom styling for icons and text output */
      .custom-text-output1, .custom-text-output2, .custom-text-temp {
        font-size: 20px !important;
        color: #ffffff !important;
      }
      
      /* Icon styling */
      .box-icon {
        color: #ffffff !important;
        margin-right: 8px;
      }

      /* Leaflet map container */
      .map-container {
        width: 90%;
        margin: 0 auto;
      }
      
      /* Adjust box background colors */
      .aqua { background-color: #1a73e8 !important; }
      .red { background-color: #ff4b4b !important; }
      .olive { background-color: #4b6e4b !important; }
      .teal { background-color: #008080 !important; }
      .navy { background-color: #000080 !important; }
      .maroon { background-color: #800000 !important; }
    "))
    ),
    
    tabItems(
      tabItem(
        tabName = "weather",
        fluidRow(
          
          # Current Weather Box
          box(
            width = 12,
            tags$div(
              h2("CURRENT WEATHER", style = "font-weight: bold;", class = "custom-text")
            ),
            tags$div(
              style = "display: flex; align-items: center;",
              tags$i(class = "fas fa-map-marker-alt custom-icon"),
              tags$div(tags$span(strong(textOutput("location")), class = "custom-text-output1")),
              tags$i(" ", class = "fas fa-cloud-sun-rain custom-cloud1")
            ),
            br(),
            tags$div(
              style = "display: flex; align-items: center;",
              h3("Current Temperature:", class = "custom-text-output2"),  
              tags$div(tags$span(h3(textOutput("temperature")), class = "custom-text-temp"))
            ),
            br(),
            
            # Boxes for Weather Metrics
            fluidRow(
              box(
                width = 6,
                title = div(tags$i(class = "fa-solid fa-droplet box-icon"), "Humidity"),
                textOutput("humidity"),
                class = "aqua"
              ),
              box(
                width = 6,
                title = div(tags$i(class = "fas fa-temperature-high box-icon"), "Feels Like"),
                textOutput("feels_like"),
                class = "red"
              ),
              box(
                width = 6,
                title = div(tags$i(class = "fas fa-smog box-icon"), "Weather Condition"),
                textOutput("weather_condition"),
                class = "olive"
              ),
              box(
                width = 6,
                title = div(tags$i(class = "fas fa-eye box-icon"), "Visibility"),
                textOutput("visibility"),
                class = "teal"
              ),
              box(
                width = 6,
                title = div(tags$i(class = "fas fa-wind box-icon"), "Wind Speed"),
                textOutput("wind_speed"),
                class = "navy"
              ),
              box(
                width = 6,
                title = div(tags$i(class = "fas fa-globe-americas box-icon"), "Air Pressure"),
                textOutput("air_pressure"),
                class = "maroon"
              )
            )
          ),
          
          # Map Box
          box(
            width = 12,
            div(
              leafletOutput("map"),
              style = "width: 100%; height: 60vh;"  # Full width, adjust height as needed
            ),
            class = 'map-container'
          )
        )
      ),
      
      ###############################################################################################
      #                                     FORECAST UI                                             #
      ###############################################################################################      
      tabItem(
        tabName = "forecast",
        
        # Location Output at Full Width
        tags$div(
          textOutput("location_"),
          style = "font-size: 18px; padding: 10px;"  # Optional styling for better readability
        ),
        
        # Feature Selection Dropdown at Full Width
        tags$div(
          selectInput(
            "feature",
            "Select Feature:",
            list(
              "temp",
              "feels_like",
              "temp_min",
              "temp_max",
              "pressure",
              "sea_level",
              "grnd_level",
              "humidity",
              "speed",
              "deg",
              "gust"
            )
          ),
          style = "width: 100%; padding: 10px;"  
        ),
        
        # Full Width Chart Box
        box(
          width = 12,  # Full width in Shiny
          title = "Line Chart",
          plotlyOutput("line_chart", height = "500px")  # Increased height for full-screen view
        )
      )
    )
  )
)
