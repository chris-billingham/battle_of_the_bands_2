library(tidyverse)
library(genius)

# read in the new binned
charts_new_binned <- readRDS("data/charts_new_binned.rds")

# let's read in all the lyrics
new_lyrics <- map2_dfr(charts_new_binned$artist, 
                       charts_new_binned$title, 
                       genius_lyrics, 
                       info = "all")

# oh crap some don't exist, better use possible_lyrics
new_lyrics <- map2_dfr(charts_new_binned$artist, 
                       charts_new_binned$title, 
                       possible_lyrics, 
                       info = "all")



