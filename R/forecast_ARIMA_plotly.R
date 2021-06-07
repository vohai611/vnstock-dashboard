forecast_ARIMA_plotly <- function(.tbl, h = 10) {

  stock_ts <- .tbl %>%
    select(date, close) %>%
    arrange(date) %>%
    mutate(day= row_number()) %>%
    as_tsibble(index = day)

  stock_arima <- stock_ts %>%
    model(ARIMA(close))

    # unpack_hilo()
    # stock_arima %>%
    #   forecast() %>%
    #   hilo() %>%
    #   unpack_hilo(cols = `80%`)

    stock_arima <- stock_arima %>%
      forecast(h = h) %>%
      hilo() %>%
      mutate(lower_80 = `$`(`80%`, "lower"),
             upper_80 = `$`(`80%`, "upper"),
             lower_95 = `$`(`95%`, "lower"),
             upper_95 = `$`(`95%`, "upper"),
             .keep= "unused")
    ## draw ggplot
    forecast_dat <- stock_arima %>% mutate(date = seq(max(stock_ts$date)+ 1, max(stock_ts$date)+ h , 1))

    (autoplot(stock_ts %>% as_tsibble(index = date),.vars = close)+
      geom_line(data= forecast_dat, aes(x= date, y = .mean), color = "red")+
      geom_ribbon(data= forecast_dat, aes(x= date, ymin = lower_80, ymax = upper_80), inherit.aes = F,
                  alpha = .3)) %>% ggplotly()

}






