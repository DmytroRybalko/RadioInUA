library(rvest)
library(selectr)
library(tidyverse)
library(stringr)
library(readr)
library(lubridate)


#########################################################
################### write_read_tibbles ##################
######################################################### 

write_read_tibbles <- function(
    in_path, # data/raw/krainafm/2017/05
    out_path, # data/processed/krainafm/2017/05
    re_rds_name = "([a-z]+)(?=/\\d{4})(/[0-9/]+)",
    re_file_ext = ".html$", # ".rds$"
    map_fun = map_dfr,
    my_fun = simple_tibble) {
    
    # Function takes list of files that contain tibbles or data for transforming
    # into tibbles by calling respective functions (my_fun). These functions
    # create or read tibbles that then accummulate by map_* function and write
    # into file.
    
    # Make name for RDS-file
    rds_name <- file_name(in_path, out_path)
    
    # Bind list of tibbles at one and save to rds-file
    list.files(in_path, full.names = T, pattern = re_file_ext) %>%
        map_fun(my_fun) %>%
        saveRDS(rds_name)
}

#########################################################
################### file_name ###########################
#########################################################

file_name <- function(in_path, out_path,
                      re_rds_name = "([a-z]+)(?=/\\d{4})(/[0-9/]+)") {
    
    # Function make file name from file's path:
    # in_path - path to files (html or RDS) for processing:
    # "data/raw/krainafm/2017/05/01/01"
    # out_path - path to processed files (RDS):
    # "data/processed/krainafm/2017/05"
    # re_rds_name -regex template for RDS-file name:
    # "([a-z]+)(?=/\\d{4})(/[0-9/]+)"
    # output is RDS file: out_path/krainafm_2017_05.rds
    
    # Make full name for RDS-file
    #rds_path <- str_extract(path2RDS, re_rds_path)
    rds_name <- str_extract(in_path, re_rds_name) %>%
        str_replace_all("/", "_") %>%
        str_c(out_path, "/", .,".rds")
}

#########################################################
################### simple_tibble #######################
#########################################################

# Function scraping data from html file into tibble which has following
# template:

# FM station | year | month | day | start_hour | start_min | end_hour | end_min
# duration_min | duration_sec | singer | song

# Each variable in template is a vector. Then we should bind theirs in tibble.

simple_tibble <- function(full_file_name) {
    # full_file_name look like ../krainafm_2017_05_01_01.html
    
    # Load XML data from file
    composition <- xml2::read_html(full_file_name)
    
    # Define tibble's length
    tibble_length <- extract_data(composition, "div.col-xs-12.playlist-item") %>%
        length() - 1 #!!! can be problem with length = 1 !!!
    
    ### Make template's variables
    
    # Get bare file name
    file_name <- str_split(full_file_name, "/")[[1]] %>%
        .[length(.)]
    
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
    
    # Extract start time
    start_time <- extract_data(composition, "div.time.col-xs-2") %>%
        str_extract("(?<=\\[)(\\d\\d:\\d\\d)") %>%
        hm
    
    ## start_hour
    start_hour <- hour(start_time)
    
    ## start_min
    start_min <- minute(start_time)
    
    # Extract end time
    end_time <- extract_data(composition, "div.time.col-xs-2") %>%
        str_extract("(\\d\\d:\\d\\d)(?=])") %>%
        hm
        
    ## end_hour
    end_hour <- hour(end_time)
    
    ## end_min
    end_min <- minute(end_time)
    
    # Extract duration
    duration_time <- extract_data(composition, "div.length.col-xs-1") %>%
        ms
    
    ## duration_min
    duration_min <- minute(duration_time)
    
    ## duration_sec
    duration_sec <- second(duration_time)
    
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
                        start_min = start_min,
                        end_hour = end_hour,
                        end_min = end_min,
                        duration_min = duration_min,
                        duration_sec = duration_sec,
                        singer = singer,
                        song = song)
    
    return(my_tibble)
}

#########################################################
################### extract_data  #######################
#########################################################

# Function extract data from xml object 
extract_data <- function(composition, dom) {
    # composition is an xml object
    # dom is object from DOM-tree like "div.col-xs-12.playlist-item"
    html_nodes(composition, dom) %>%
        html_text() %>%
        subset(nchar(.) > 1) # replace empty element in vector
}
