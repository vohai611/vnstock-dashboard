
# Create Tsibble object ---------------------------------------------------
stock_ts <- function(.tbl){
  stock_ts <- .tbl %>%
    select(date, close) %>%
    arrange(date) %>%
    mutate(day= row_number()) %>%
    as_tsibble(index = day)
  return(stock_ts)
}


# Forecast  ----------------------------------------------------
model_forcast <- function(.tbl, model) {

  stock_ts <- stock_ts(.tbl)

if (model == "ARIMA") {
  stock_model <- stock_ts %>%
    model(arima = ARIMA(close))
}

if (model == "ETS"){
  stock_model <- stock_ts %>%
    model(ets = ETS(close ~ error("A") + trend("Ad")))
}
return(stock_model)
}


# Plotly result -----------------------------------------------------------

forecast_plotly <- function(.tbl, stock_model, h = 10) {

stock_forecast <-  stock_model %>%
  forecast(h = h) %>%
  hilo() %>%
  mutate(lower_80 = `$`(`80%`, "lower"),
         upper_80 = `$`(`80%`, "upper"),
         lower_95 = `$`(`95%`, "lower"),
         upper_95 = `$`(`95%`, "upper"),
         .keep= "unused")
## draw ggplot
stock_ts <- stock_ts(.tbl)
forecast_dat <- stock_forecast %>% mutate(date = seq(max(stock_ts$date)+ 1, max(stock_ts$date)+ h , 1))

(autoplot(
  stock_ts %>% as_tsibble(index = date),
  .vars = close) +
    geom_line(data = forecast_dat, aes(x = date, y = .mean), color = "red") +
    geom_ribbon(
      data = forecast_dat,
      aes(x = date, ymin = lower_80, ymax = upper_80),
      inherit.aes = F,
      alpha = .3)) %>%
  plotly::ggplotly() %>%
  plotly::layout(hovermode = "x")
}


