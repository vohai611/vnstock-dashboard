

get_stock <- function(symbol, start_date = NULL, end_date = NULL) {
  library(httr)
  library(dplyr)
  library(lubridate)
  # symbol <- enexpr(symbol)
  # symbol <-  str_remove_all(expr_text(symbol), '\\"' )
  # try tidyeval this way does not work with map()
  
  if(is.null(start_date)) {start_date = today() - 15} else start_date = ymd(start_date)
  if(is.null(end_date )) {end_date = today()} else end_date = ymd(end_date) 
  size <- as.double(end_date - start_date)
  
  url <- "https://finfo-api.vndirect.com.vn"
  path <- glue::glue("/v4/stock_prices?sort=date&q=code:{symbol}~date:gte:{start_date}~date:lte:{end_date}&size={size}&page=1")
  
  get_result <- modify_url(url, path = path)  %>%
    httr::GET() %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON()

  get_result$data %>%
    as_tibble() %>%
    mutate(date = ymd(date)) %>%
    return()
}

