library(tidyverse)
library(genius)

# read in the new binned
charts_new_binned <- readRDS("data/charts_new_binned.rds")

# let's read in all the lyrics, genius-wise
genius_lyrics <- map2_dfr(charts_new_binned$artist, 
                       charts_new_binned$title, 
                       possible_lyrics,
                       info = "all")

lyricsbox_lyrics <- pro_map2_chr(charts_new_binned$artist[1:50], 
                             charts_new_binned$title[1:50],
                             get_lyrics_box)

# i need something better actually, i need to see how many are missing
lyrics_possible <- possibly(genius_lyrics, 
                            otherwise = tibble(artist = "missing",
                                               track_title = "missing",
                                               line = NA_integer_,
                                               lyric = "missing",
                                               element = "missing",
                                               element_artist = "missing"))

# right, third time lucky
new_lyrics <- map2_dfr(charts_new_binned$artist, 
                       charts_new_binned$title, 
                       lyrics_possible, 
                       info = "all")
# crap! more than half missing.

# guys, this takes ages and who knows how long
# time to crack out my old pal pbapply
library(pbapply)

# of course this is just as easy as map2_dfr.. :upside_down_smile:
new_lyrics_pb <- pbmapply(lyrics_possible, 
                          charts_new_binned$artist, 
                          charts_new_binned$title, 
                          info = "all", 
                          SIMPLIFY = FALSE) %>% 
  set_names(c("artist", "track_title", "line", "lyric", "element", "element_artist"), nm = NULL) %>% 
  bind_rows()

