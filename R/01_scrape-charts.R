library(tidyverse)
library(rvest)
library(polite)

url <- "https://www.officialcharts.com/charts/singles-chart/19940102/7501/"

test <- read_html(url) %>% html_node("table.chart-positions") %>% html_table(header = TRUE) %>% 
  select(1:5) %>%
  filter(!grepl("google", `Title, Artist`))

rows <- seq(1, nrow(test), by = 5)

df <- test[rows,]

df$`Title, Artist` <- gsub("\n", "", df$`Title, Artist`)

df2 <- df %>% separate(`Title, Artist`, into = c("title", "artist", "label"), sep = "( ){2,}")

