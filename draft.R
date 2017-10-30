library(rvest)
library(selectr)
library(magrittr)
# Test selectr library
css_to_xpath(".testclass")
selectr::css_to_xpath("#selectr")

# 1. Download the HTML and turn it into an XML file with read_html()
#krainafm <- xml2::read_html("http://radioscope.in.ua/krainafm/2017/10/04/09")

# Download the static HTML
#krainafm <- xml2::read_html("krainafm2017_10_04_09FULL.html")
krainafm <- xml2::read_html("krainafm_2017_05_01_19.html")
#krainafm_2017_05_01_01.html

# Extract playlist from page
(playlist <- rvest::html_nodes(krainafm, "div.col-xs-12.playlist-item") %>%
    html_text() %>%
    .[-1]) # remove first row with station's name

# Extract singer name
(sing_song <- rvest::html_nodes(krainafm, "span.ellipsis") %>%
        html_text())

# Extract time range of song
(song_time <- rvest::html_nodes(krainafm, "div.time.col-xs-2") %>%
        html_text() %>%
        .[-1])

# Extract song duration
(song_length <- rvest::html_nodes(krainafm, "div.length.col-xs-1") %>%
        html_text() %>%
        .[-1])
# Observation tamplate
(observ <- c(song_time[1], song_length[1], sing_song[1]))
