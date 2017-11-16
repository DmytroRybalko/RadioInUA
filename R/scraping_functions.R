library(rvest)
library(selectr)
library(tidyverse)
library(stringr)
library(readr)
library(lubridate)

################### extract_data function  #####################

# Function extract data from xml object 
extract_data <- function(composition, dom) {
    # composition is an xml object
    # dom is object from DOM-tree like "div.col-xs-12.playlist-item"
    html_nodes(composition, dom) %>%
        html_text() %>%
        subset(nchar(.) > 1) # replace empty element in vector
}

################### extract_data function  #####################
file_name <- function(file_path, re_file_name, file_ext = ".rds") {
    # Function make file name from file's path:
    # root_path = "test_data/krainafm/2017/05" or "test_data/krainafm/2017"
    # re_file_name = "([a-z]+)(?=/\\d\\d\\d\\d/)(/[0-9/]+)"
    # out: test_data/krainafm/2017/05/krainafm_2017_05.rds
    
    str_extract(file_path, re_file_name) %>%
        str_replace_all("/", "_") %>%
       str_c(file_path, "/", ., file_ext) #str_c("./", ., file_ext)
}

########################################################


################### write_read_tibbles ##########################
################################################################# 


write_read_tibbles <- function(
    root_path, # test_data/krainafm/2017/05
    file_path,
    re_file_name, # "([a-z]+)(?=/\\d{4})([/0-9]+)(?=/\\d{2})",
    re_file_ext = ".html$", # ".rds$"
    map_fun = map_dfr,
    my_fun = simple_tibble) {
    
    # Function takes list of files that contain tibbles or data for transforming
    # into tibbles by calling respective functions (my_fun). These functions
    # create or read tibbles that then accummulate by map_* function and write
    # into file.
    
    # Make name for RDS-file
    rds_name <- file_name(file_path, re_file_name)
    
    # Bind list of tibbles at one and save to rds-file
    list.files(root_path, full.names = T, pattern = re_file_ext) %>%
        map_fun(my_fun) %>%
        saveRDS(rds_name)
}

################### make simple tibbles ##########################
make_simple_tibbles <- function(
    path2files,
    re_rds_path = "([/_a-z]+)([/0-9]+)(?=/\\d{2})",
    re_rds_name = "([a-z]+)(?=/\\d{4})(/[0-9/]+)",
    re_file_ext = ".html$", # ".rds$"
    map_fun = map_dfr,
    my_fun = simple_tibble) {
    
    # Make full name for RDS-file
    rds_path <- str_extract(path2files, re_rds_path)
    rds_name <- str_extract(path2files, re_rds_name) %>%
    str_replace_all("/", "_") %>%
    str_c(rds_path, "/", .,".rds")
    
    # Work with list of HTML (!!!) files
    files <- list.files(path2files, full.names = T, pattern = re_file_ext) %>%
        map_fun(my_fun) %>%
        saveRDS(rds_name)
}

################### Write simple tibbles ##########################

# Function take list of files from directory, get access to read simple file
# and write cummulative tibble with data from each files. This function is
# wrapper around of simple_tibble function.

write_simple_tibbles <- function(dir_with_files) {
    # dir_with_files look like root_dir/station_name/2017/05/01
    # Make name for RDS-file
    rds_name <- str_extract(dir_with_files,
                            "([a-z]+)(?=/\\d\\d\\d\\d/)(/[0-9/]+)") %>%
        str_replace_all("/", "_") %>%
        str_c(dir_with_files, "/", ., ".rds")
    
    # Work with list of HTML (!!!) files
    files <- list.files(dir_with_files, full.names = T, pattern = ".html$") %>%
        map_dfr(simple_tibble) %>%
        saveRDS(rds_name)
}

################### Make TIBBLE ##########################
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
