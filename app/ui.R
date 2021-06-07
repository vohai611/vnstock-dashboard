library(shiny)
library(shinydashboard)
library(plotly)
library(DT)

ui <- dashboardPage(
  title = ,
  dashboardHeader(),
  dashboardSidebar(
    width = 300,
    textInput(
      "symbol",
      "Choose stock",
      placeholder = "Symbol of your stock",
      value = "VCB"
    ),
    dateRangeInput("stock_date", label = "Period", start = today() - 10),
    selectInput("model", "Forecast model", choices = c("ETS", "ARIMA")),
    numericInput("forecast_h", "Forecast time", value = 10),
    hr(),
    fluidRow(column(width = 1), submitButton("Get!"))
  ),
  dashboardBody(fluidPage(tabBox(width = 660, height = "400px",
                                 tabPanel("Stock chart", plotlyOutput("plot1")),
                                 tabPanel("Data on table", DTOutput("table1")))))




)



shinyApp(ui, server)
