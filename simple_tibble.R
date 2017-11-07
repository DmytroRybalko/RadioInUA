library(rvest)
library(selectr)
library(tidyverse)
library(stringr)
library(readr)
library(lubridate)

################### HELP FUNCTIONS #####################

# Function extract data from xml object 
extract_data <- function(composition, dom) {
    html_nodes(composition, dom) %>%
        html_text() %>%
        subset(nchar(.) > 1) # replace empty element in vector
}

################### Make TIBBLE ##########################

# Observation template look like:
# FM station | year | month | day | start_hour | start_min | end_hour | end_min
# duration_min | duration_sec | singer | song

# Each variable in template is a vector. Then we should bind theirs in tibble.

simple_tibble <- function(file_name = "krainafm_2017_05_01_19.html") {
    
    # Load XML data from file
    composition <- xml2::read_html(file_name)
    
    # Define tibble's length
    tibble_length <- extract_data(composition, "div.col-xs-12.playlist-item") %>%
        length() - 1
    
    ### Make template's variables
    
    ## FM station
    FMs <- str_extract(file_name, "^[a-zA-Z]+") %>%
        rep(tibble_length)
    
    # Extract date from file name
    ddate <- str_extract(file_name, "\\d\\d\\d\\d_\\d\\d_\\d\\d") %>%
        as_date()
    
    ## year
    year_s <- year(ddate) %>%
        rep(tibble_length)
    
    ## month
    month_s <- month(ddate) %>%
        rep(tibble_length)
    
    ## day
    day_s <- day(ddate) %>%
        rep(tibble_length)
    
    ## start_hour
    start_hour <- extract_data(composition, "div.time.col-xs-2") %>%
            str_extract("(?<=\\[)(\\d\\d:\\d\\d)") %>%
            hm %>%
            hour
    
    ## start_min
    start_min <- extract_data(composition, "div.time.col-xs-2") %>%
            str_extract("(?<=\\[)(\\d\\d:\\d\\d)") %>%
            hm %>%
            minute()
    
    ## end_hour
    end_hour <- extract_data(composition, "div.time.col-xs-2") %>%
            str_extract("(\\d\\d:\\d\\d)(?=])") %>%
            hm %>%
            hour()
    
    ## end_min
    end_min <- extract_data(composition, "div.time.col-xs-2") %>%
            str_extract("(\\d\\d:\\d\\d)(?=])") %>%
            hm %>%
            minute()
    
    ## duration_min
    duration_min <- extract_data(composition, "div.length.col-xs-1") %>%
        ms %>%
        minute()
    
    ## duration_sec
    duration_sec <- extract_data(composition, "div.length.col-xs-1") %>%
        ms %>%
        second()
    
    ## singer
    singer <- extract_data(composition, "span.ellipsis") %>%
            str_split(" - ", simplify = TRUE) %>%
            .[, 1]
    
    ## song
    song <- extract_data(composition, "span.ellipsis") %>%
            str_split(" - ", simplify = TRUE) %>%
            .[, 2]
    
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
    
    return(my_tibble)
}

######################### TEST ZONE ########################

simple_tibble("krainafm_2017_05_01_01.html") %>%
    View()
