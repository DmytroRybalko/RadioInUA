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



############### DRAFT ZONE ############################
# Construct path with regex
# Create function that will read data on one level of directory's structure
str_view("test_data/krainafm/2017/05/01/krainafm_2017_05_01_01.html",
         "(\\d{4}/\\d{2}/\\d{2})") # 2017/05/01

my_path <- "test_data/krainafm/2017/05"
(list.dirs(my_path))
(mfiles <- str_subset(list.dirs(my_path),"(\\d{4}/\\d{2}/\\d{2})"))

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

###### Make name for RDS ########

# Extract name from full directory name path
str_view("raw_data/krainafm/2017/05/01", "([a-z]+)(?=/\\d\\d\\d\\d/)")
## krainafm
str_view("raw_data/krainafm/2017/05/01", "([a-z]+)(?=/\\d\\d\\d\\d/)(/[0-9/]+)")
## krainafm/2017/05/01
str_extract(my_dirs[1], "([a-z]+)(?=/\\d\\d\\d\\d/)(/[0-9/]+)")

# Make full name for RDS file
(dir_name <- str_extract(my_dirs[1], "([a-z]+)(?=/\\d\\d\\d\\d/)(/[0-9/]+)") %>%
    str_replace_all("/", "_")) %>%
    str_c(my_dirs[1], "/", ., ".RDS")


# Get last dir name (dfef/dwf/04, 04 is true)
(dir_name <- str_split(my_dirs[1], "/")[[1]] %>%
    .[length(.)])
# Get full dir name
(dir_name <- str_replace_all(my_dirs[1], "/", "_"))
# Make new name
(rds_name <- paste0(my_dirs[1], "/", dir_name, ".RDS"))
# All at one
(dir_name <- str_split(my_dirs[1], "/")[[1]] %>%
        .[length(.)] %>%
        paste0(my_dirs[1], "/", ., ".RDS"))
#################################################

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
