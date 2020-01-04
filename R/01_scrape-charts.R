library(tidyverse)
library(rvest)
library(lubridate)
library(polite)

# so this works
# it's needs polite-ing

start_date <- ymd("1994-01-02")
end_date <- ymd("1995-08-13")
dates <- seq.Date(start_date, end_date, "week")

scrape_chart <- function(date_of_chart) {
  # convert date into character for url
  date <- gsub("-", "", as.character(date_of_chart))
  
  # create scrape url
  url <- paste0("https://www.officialcharts.com/charts/singles-chart/", date, "/7501/")

  # scrape the chart table and remove some google tag rubbish
  df_raw <- read_html(url) %>% 
    html_node("table.chart-positions") %>% 
    html_table(header = TRUE) %>% 
    select(1:5) %>%
    filter(!grepl("google", `Title, Artist`))

  # we need every 5th row for the data
  rows <- seq(1, nrow(df_raw), by = 5)

  # get rid of some escaped characters
  df_data <- df_raw[rows,] %>%
    mutate(`Title, Artist` = gsub("\n", "", `Title, Artist`))

  # split Title, Artist into title, artist and label based on gaps of 2 or more spaces
  df_final <- df_data %>% 
    separate(`Title, Artist`, into = c("title", "artist", "label"), sep = "( ){2,}") %>%
    mutate(date_of_chart = ymd(str_extract(url, "[0-9]{8}")))

  # return that
  return(df_final)
}

# run the function through all the weeks
df_all <- map_dfr(dates, scrape_chart) %>%
  mutate(Pos = as.integer(Pos),
         PeakPos = as.integer(PeakPos),
         WoC = as.integer(WoC))

# seems they did top 100 from first week in feb 94 so will need to truncate at that

