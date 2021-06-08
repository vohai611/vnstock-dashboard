library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(here)
library(tidyverse)
library(lubridate)
library(tsibble)
library(fable)
i_am("app/server.R")

source(here("R/get-vndirect.R"))
source(here("R/forecast_plotly.R"))
## make get_stock fall back as a tibble
get_stock <- purrr::possibly(get_stock, tibble())

###### SERVER

server <- function(input, output, session) {

# get stock data ----------------------------------------------------------
stock_data <- reactive({
  get_stock(
    symbol =  input$symbol,
    start_date = input$stock_date[1],
    end_date = input$stock_date[2]
  )
})


# output ------------------------------------------------------------------
#1 Plot stock price and forecast
## fit model (ETS or ARIMA)

model <- reactive({
  model_forcast(stock_data(), model = input$model)
})

output$plot1 <- renderPlotly({


  forecast_plotly(stock_data(), model(), h = input$forecast_h)

  })
#2 model report
output$model_report <- renderPrint({
  model() %>%
    report()
})

#3 forecast data on table
output$forecast_table <- renderDataTable({
  model() %>%
    forecast(h = input$forecast_h) %>%
    as_tibble() %>%
    select(day, forecast = .mean) %>%
    datatable()
})

output$table1 <- renderDataTable({
    stock_data() %>%
    select(1:12, -time) %>%
      datatable(extensions = c("Buttons"),
                options = list(
                  dom = "Bfrtip",
                  buttons = list("pageLength",
                                 list(extend = "collection",
                                      buttons = c("csv", "excel", "pdf"),
                                      text ="Download"))))
})

}


