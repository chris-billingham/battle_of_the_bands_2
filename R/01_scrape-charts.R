library(tidyverse)
library(rvest)
library(lubridate)
library(glue)
library(polite)

# set up our dates
start_date <- ymd("1994-01-02")
end_date <- ymd("1995-08-13")
dates <- seq.Date(start_date, end_date, "week")

# lets bow to the official charts website as i am a polite web scraper
chart_bow <- bow("https://www.officialcharts.com/")

# set up the scrape function
scrape_chart <- function(date_of_chart) {
  # convert date into character for url
  date <- str_replace_all(as.character(date_of_chart), "-", "")
  
  # nod for the url of the date
  session <- nod(chart_bow, path = glue("charts/singles-chart/{date}/7501/"))

  # scrape the chart table and remove some google tag rubbish
  df_raw <- scrape(session) %>%
    html_node("table.chart-positions") %>% 
    html_table(header = TRUE) %>% 
    select(1:5) %>%
    filter(str_detect(`Title, Artist`, "google", negate = TRUE))

  # we need every 5th row and we should get rid of some escaped characters
  df_data <- df_raw %>%
    filter(row_number() %% 5 == 1) %>%
    mutate(`Title, Artist` = str_replace_all(`Title, Artist`, "\n", ""))

  # split Title, Artist into title, artist and label based on gaps of 2 or more spaces
  df_final <- df_data %>% 
    separate(`Title, Artist`, into = c("title", "artist", "label"), sep = "( ){2,}") %>%
    mutate(date_of_chart = ymd(str_extract(session$url, "[0-9]{8}")))

  # return that
  return(df_final)
}

# run the function through all the weeks
charts_all <- map_dfr(dates, scrape_chart) %>%
  mutate(Pos = as.integer(Pos),
         PeakPos = as.integer(PeakPos),
         WoC = as.integer(WoC))

# seems they did top 100 from first week in feb 94 so will need to truncate at that

# how many new entries do we have?
charts_all %>% 
  filter(LW == 'New') %>% 
  filter(Pos <= 40) %>%
  group_by(Pos) %>% 
  summarise(n = n()) %>% 
  ungroup %>%
  ggplot(aes(x = Pos, y = n)) +
    geom_col()

# hmm not much volume in the top 10, might need to group for targets
charts_new_binned <- charts_all %>%
  filter(LW == 'New') %>% 
  mutate(bin = cut(Pos, c(1, 5, 10, 15, 20, 25, 30, 35 ,40, Inf), include.lowest = TRUE))

# let's visualise that (getting rid of the out of top 40s)
charts_new_binned %>%
  filter(Pos <= 40) %>%
  group_by(bin) %>% 
  summarise(n = n()) %>% 
  ungroup %>%
  ggplot(aes(x = bin, y = n)) +
  geom_col()
