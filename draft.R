library(rvest)
library(selectr)
library(tidyverse)
library(stringr)
library(readr)
library(lubridate)
# Test selectr library
css_to_xpath(".testclass")
selectr::css_to_xpath("#selectr")

# 1. Download the HTML and turn it into an XML file with read_html()
#krainafm <- xml2::read_html("http://radioscope.in.ua/krainafm/2017/10/04/09")

# Download the static HTML
#krainafm <- xml2::read_html("krainafm2017_10_04_09FULL.html")
file_name <- "krainafm_2017_05_01_19.html"
krainafm <- xml2::read_html(file_name)
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
        subset(nchar(.) > 1))

(song_time <- rvest::html_nodes(krainafm, "div.time.col-xs-2") %>%
        html_text() %>%
        .[-1])

# Extract song duration
(song_length <- rvest::html_nodes(krainafm, "div.length.col-xs-1") %>%
        html_text() %>%
        .[-1])

################### EXTRACT ZONE ############################

# Observation tamplate should be
# FM station | year | month | day | start_hour | start_min | end_hour | end_min
# duration_min | duration_sec | singer | song

# Extract radio station's name from file name
FM <- str_extract(file_name, "^[a-zA-Z]+")

# Extract date info from file name
ddate <- str_extract(file_name, "\\d\\d\\d\\d_\\d\\d_\\d\\d") %>%
    as_date()

# Extract start song's time in formate hh:mm
(start_time <- str_extract(song_time[1], "(?<=\\[)(\\d\\d:\\d\\d)"))

# Extract end song's time in formate hh:mm
(end_time <- str_extract(song_time[1], "(\\d\\d:\\d\\d)(?=])"))

# Extract song and singer name
(singer <- str_split(sing_song[1], " - ")[[1]][1])
(song <- str_split(sing_song[1], " - ")[[1]][2])

################### TRANSFORM ZONE ############################

# Make single year, month, day from krainafm_2017_05_01_19.html
(s_year <- year(ddate))
(s_month <- month(ddate))
(s_day <- day(ddate))

# Make sinlge hour and minute from template hh:mm
start_time
(start_hour <- hour(hm(start_time)))
(start_min <- minute(hm(start_time)))
end_time
(end_hour <- hour(hm(end_time)))
(end_min <- minute(hm(end_time)))

# Make duration time in format mm:ss
song_length[1]
(duration_min <- minute(ms(song_length[1])))
(duration_min <- second(ms(song_length[1])))

################### Make TIBBLE ##########################

# FM station | year | month | day | start_hour | start_min | end_hour | end_min
# duration_min | duration_sec | singer | song
# Each variable in template is a vector. Then we should bind theirs in tibble.

# Extract singer, song and ... 
extract_data <- function(station_name, dom) {
    html_nodes(station_name, dom) %>%
        html_text() %>%
        subset(nchar(.) > 1) # replace empty element in vector
}

(tibble_length <- extract_data(krainafm, "div.col-xs-12.playlist-item") %>%
    length() - 1)

# FM station
# Create vector of FM station's
FMs <- str_extract(file_name, "^[a-zA-Z]+") %>%
    rep(tibble_length)

# Extract date from file name
ddate <- str_extract(file_name, "\\d\\d\\d\\d_\\d\\d_\\d\\d") %>%
    as_date()

# year
year_s <- year(ddate) %>%
    rep(tibble_length)
# month
month_s <- month(ddate) %>%
    rep(tibble_length)
# day
day_s <- day(ddate) %>%
    rep(tibble_length)

# start_hour
(start_hour <- extract_data(krainafm, "div.time.col-xs-2") %>%
    str_extract("(?<=\\[)(\\d\\d:\\d\\d)") %>%
    hm %>%
    hour)

# start_min
(start_min <- extract_data(krainafm, "div.time.col-xs-2") %>%
    str_extract("(?<=\\[)(\\d\\d:\\d\\d)") %>%
    hm %>%
    minute())

# end_hour
(end_hour <- extract_data(krainafm, "div.time.col-xs-2") %>%
    str_extract("(\\d\\d:\\d\\d)(?=])") %>%
    hm %>%
    hour())

# end_min
(end_min <- extract_data(krainafm, "div.time.col-xs-2") %>%
        str_extract("(\\d\\d:\\d\\d)(?=])") %>%
        hm %>%
        minute())

# duration_min
duration_min <- extract_data(krainafm, "div.length.col-xs-1") %>%
    ms %>%
    minute()

# duration_sec
duration_sec <- extract_data(krainafm, "div.length.col-xs-1") %>%
    ms %>%
    second()

# singer
(singer <- extract_data(krainafm, "span.ellipsis") %>%
    str_split(" - ", simplify = TRUE) %>%
        .[, 1])

# song
(song <- extract_data(krainafm, "span.ellipsis") %>%
        str_split(" - ", simplify = TRUE) %>%
        .[, 2])

# Make finale tibble
my_tibble <- tibble(FM_station = FMs,
       year = year_s,
       month = month_s,
       day = day_s,
       start_hour = start_hour,
       end_hour = end_hour,
       end_min = end_min,
       duration_min = duration_min,
       duration_sec = duration_sec,
       singer = singer,
       song = song)


################### DRAFT ZONE ############################

# Make tibble from vectors
start_s <- c("3:56", "7:21", "10:23")
end_s <- c("5:16", "10:21", "12:43")
length_s <- c("3:12", "4:15", "3:58")
singer <- c("Гайтана", "Скрябін", "Антитіла")
(tb <- tibble(start = start_s, end = end_s, duration = length_s, singer = singer))
