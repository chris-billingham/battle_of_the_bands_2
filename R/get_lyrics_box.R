library(tidyverse)
library(rvest)
library(curl)
library(genius)

# this is a faff but a function that'll scrape lyrics box
# currently it uses google to find the link
# takes the top 1
# then goes and gets the lyric
# there is a tonne of rubbish for errors or missing lyrics
get_lyrics_box <- function(artist, song) {
  # the search url
  url <- "https://www.google.com/search?q=site:www.lyricsbox.com"
  
  # fix up the artist and song name for the url
  artist_fix <- str_replace_all(artist, " ", "+")
  song_fix <- str_replace_all(str_remove_all(prep_info(song), "[0-9]"), " ", "+")
  
  # create the entire search string
  url_fix <- paste(url, artist_fix, song_fix, sep = "+")
  
  # read the entire page for that google search
  ht <- read_html(url_fix)
  
  # google requires a 5s delay
  Sys.sleep(5)
  
  # get all the links
  links <- ht %>% html_nodes(xpath='//a') %>% html_attr('href')
  
  # get ONLY the links we want
  fix_links <- gsub('/url\\?q=','',sapply(strsplit(links[as.vector(grep('url',links))],split='&'),'[',1))
  
  # choose the top link
  top_link <- fix_links[1]
  print(top_link)
  if(str_detect(top_link, "lyricsbox", negate = TRUE)) {return("xxmissingxx")}

  
  # to get around the annoy SSL certificate thing we need to fetch the page using
  # curl and specify to ignore ssl verify
  raw_html <- curl_fetch_memory(top_link, 
                                handle = curl::new_handle(ssl_verifypeer = FALSE))
  
  # lyricbox requires a 5 secod crawl delay
  Sys.sleep(5)
  
  # read in the raw_html of what we need
  lyrics_ht <- read_html(rawToChar(raw_html$content))
  
  # scrape out the lyrics
  lyrics <- lyrics_ht %>% 
    html_nodes("div#lyrics") %>% 
    html_text() %>% 
    str_replace_all("(\n|\r)", " ")
  
  if(length(lyrics) == 0){lyrics <- "xxmissingxx"}
  
  return(lyrics)
}
