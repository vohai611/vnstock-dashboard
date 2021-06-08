library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(here)
library(tidyverse)
library(lubridate)
library(tsibble)
library(fable)

ui <- dashboardPage(
  title = ,
  dashboardHeader(),
  dashboardSidebar(
    width = 250,
    textInput(
      "symbol",
      "Choose stock",
      placeholder = "Symbol of your stock",
      value = "VCB"
    ),
    dateRangeInput("stock_date", label = "Period", start = today() - 30),
    selectInput("model", "Forecast model", choices = c("ETS", "ARIMA")),
    numericInput("forecast_h", "Forecast time", value = 10),
    hr(),
    fluidRow(column(width = 1), submitButton("Get!"))
  ),
  dashboardBody(
    fluidRow(
    tabBox(
      width = 660,
      height = "400px",
      tabPanel("Stock chart", plotlyOutput("plot1")),
      tabPanel("Model report", verbatimTextOutput("model_report")),
      tabPanel("Forecast data", DTOutput("forecast_table")),
      tabPanel("Raw data", DTOutput("table1"))

    )
  ))

)
