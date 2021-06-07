library(shiny)
library(shinydashboard)
library(plotly)
library(DT)
library(here)
i_am("app/server.R")

source(here("R/get-vndirect.R"))
get_stock <- purrr::possibly(get_stock, tibble())

###### server side
server <- function(input, output, session) {

# get stock data ----------------------------------------------------------
stock_data <- reactive({
  get_stock(
    symbol =  input$symbol,
    start_date = input$stock_date[1],
    end_date = input$stock_date[2]
  )
})
observeEvent(input$symbol, {print(stock_data())})


# output ------------------------------------------------------------------
output$plot1 <- renderPlotly({
  (stock_data() %>%
     ggplot(aes(date, close))+
     geom_point()+
     geom_line()+
     theme_minimal()) %>%
    ggplotly()
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


