##### Exponential smoothing

# Simple exponential smoothing --------------------------------------------

library(rvest)
library(httr)
library(lubridate)

link <- "https://s.cafef.vn/Lich-su-giao-dich-VNG-1.chn"

## extract form from url
form <- read_html(link) %>%
  html_form() %>%
  .[[1]]

## fill POST request (look at network request body)
## the result might in multiple page, so we need to make more request
## page size = 20
symbol <- "VNG"
start_date <- "1/04/2021"
end_date <- "20/05/2021"



get_cafeF <- function(symbol, start_date, end_date) {

  result_row <- sum(! wday(seq(dmy(start_date), dmy(end_date), by = "day")) %in% c(1,7))
  total_page <- result_row %/% 20 + 1
  get_page <- function(symbol, start_date , end_date , page ) {

  request <-   POST(
      link,
      body = list(
        `ctl00$ContentPlaceHolder1$scriptmanager` = "ctl00$ContentPlaceHolder1$ctl03$panelAjax|ctl00$ContentPlaceHolder1$ctl03$pager2",
        `ctl00$ContentPlaceHolder1$ctl03$txtKeyword` = symbol,
        `ctl00$ContentPlaceHolder1$ctl03$dpkTradeDate1$txtDatePicker` = start_date,
        `ctl00$ContentPlaceHolder1$ctl03$dpkTradeDate2$txtDatePicker` = end_date,
        `ctl00$UcFooter2$hdIP` = NULL,
        `__EVENTTARGET` =  "ctl00$ContentPlaceHolder1$ctl03$pager2",
        `__EVENTARGUMENT` = page,
        `__VIEWSTATE` = form$fields$`__VIEWSTATE`$value,
        `__VIEWSTATEGENERATOR` = form$fields$`__VIEWSTATEGENERATOR`$value,
        `__ASYNCPOST:` = "true"
      )
    )
  ## parse request to tibble
  request %>%
      read_html() %>%
      html_table(header = TRUE) %>%
      .[[2]] %>%
      janitor::clean_names() %>%
      dplyr::slice(-1) %>%
      dplyr::select(-dplyr::contains("kl_dot"), - dplyr::contains("thay_doi_percent")) %>%
      mutate(ngay = lubridate::dmy(ngay)) %>%
      mutate(across(-ngay, readr::parse_number))
  }

  library(furrr)
  plan(multisession, workers = 4)
  future_map_dfr(seq_len(total_page),
                        ~ get_page(symbol, start_date, end_date, .x),
                        .progress = TRUE)

}






