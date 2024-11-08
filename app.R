library(shiny)
source("ui.R")       
source("server.R")   

# Chạy ứng dụng Shiny
shinyApp(ui = ui, server = server)