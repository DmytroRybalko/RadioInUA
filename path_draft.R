library(stringr)
library(tidyverse)
source("simple_tibble.R")
# Function than go throgh dir paths and 

#construct_path<- function(station_name, year, month, day) {
## statioin_name - chr, 
## year - integer vector in range 2015:2017
## month - integer vector in range 1:12
## day - integer vector in range 1:31

 #   my_args <- c("raw_data", station_name, year, month, day)
 #  list.files(paste0(my_args, collapse = "/"))
#}



# Function take list of files from directory, get access to read simple file
# and write cummulative tibble with data from each files. This function is
# wrapper around of simple_tibble function.

write_simple_tibbles <- function(dir_with_files) {
    # Get list of files
    files <- list.files(dir_with_files)
    
    # Get list of tibbles from each file 
    ## map(files, simple_tibble)
    ## map_dfr(files, simple_tibble)
}
############### DRAFT ZONE ############################
# Test regex template for file name
# /\\d\\d$ for region 01..31
(files <- str_subset(list.dirs("test_data"),"/\\d\\d$") %>%
     list.files(full.names = T))
# /01$
### Code block for function!!!!
(files <- str_subset(list.dirs("test_data"),"/\\d\\d$") %>%
    list.files(full.names = T))
map_dfr(files, simple_tibble) %>%
    View()
################################################

# It's work!!! Get char vector of dirs that correspond pattern
(str_subset(list.dirs("test_data"),"2[6|7]"))
# Get list of dirs
(my_dirs <- str_subset(list.dirs("raw_data"),"05/0[1-9]"))
# Get list of files
(my_list <- list.files(my_dirs[1], full.names = T))
#map_chr(my_list,)


# Extract file name from full path
#path2file <- "krainafm_2017_05_01_01.html"
path2file <- "test_data/write_simple_tibble/01/krainafm_2017_05_26_01.html"
str_split(path2file, "/")[[1]] %>%
    .[length(.)]
    xml2::read_html()

dir("raw_data")
list.dirs("raw_data")[1:4]
list.files("raw_data/krainafm/2017/05/12")
# Make path
my_args <- c("raw_data", "krainafm", "2017", "05", "12")
list.files(paste0(my_args, collapse = "/"))

my_args <- c("raw_data", "krainafm", "2017", "05", "2[6|7]")
paste0(my_args, collapse = "/")

dir("test_data/raw_data/krainafm/2017/05", pattern = "0[4|5]", full.names = T)

################### TEST simple_tibble FUN ################
#path2file <- "krainafm_2017_05_01_01.html"
path2file <- "test_data/write_simple_tibble/01/krainafm_2017_05_26_01.html"
#xml2::read_html(path2file)

simple_tibble(path2file) %>%
    View()
