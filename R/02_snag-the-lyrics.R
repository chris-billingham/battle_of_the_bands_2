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
new_lyrics <- map2_dfr(charts_new_binned$artist[1:10], 
                       charts_new_binned$title[1:10], 
                       possible_lyrics, 
                       info = "all")

# i need something better actually, i need to see how many are missing
lyrics_possible <- possibly(genius_lyrics, 
                            otherwise = tibble(artist = "missing",
                                                  track_title = "missing"))

# right, third time lucky
new_lyrics <- map2_dfr(charts_new_binned$artist, 
                       charts_new_binned$title, 
                       lyrics_possible, 
                       info = "all")
# crap! more than half missing.
