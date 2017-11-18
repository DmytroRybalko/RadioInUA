# Here is main workflow for scraping data with radio station's playlists from 
# html files and saving it into tibbles. The workflow consists of two tasks.
#
# The first one is immediately scraping data from html files. Each html file
# contains composition data for two hours (approximate). Therefore we have
# 12 files for one day. We extract data from these html files and save it in
# tibble. So one tibble contains data for one day.
# 
# The second one is cummulate small tibbles into big one. For example, from days
# to month, from months to year, from year for one station to multiple stations
# and so on. 

source("R/scraping_functions.R")

################################################################################
#################### TASK 1 - PARSING RAW DATA (HTML) ##########################
################################################################################
# IMPORTANT: the template of folder's structure has to be like this:
# ../raw/{station name}/{yyyy}/{mm}/{dd}/station_yyyy_mm_dd_01.html"
# Example: "data/raw/krainafm/2017/05/12/krainafm_2017_05_12_01.html"

# IMPORTANT: before execute following steps it needs to create folder's
# structure for processing data (rds files) similar to raw data:
# # ../processing/{station name}/{yyyy}/{mm}/"
# For example:
# before processing: "data/processing/krainafm/2017/05/"
# after processing: "data/processing/krainafm/2017/05/krainafm_2017_05_01.rds"

## 1.1 Choose folder with raw data: html files
path2html <- "data/raw/hitfm/2017/05"
## Show paths with files
(days_level <- list.dirs(path2html)[-1]) # chr vector
(list.files(days_level[12], full.names = T))

## 1.2 Choose folder for processing data (folder must already exist!!!)
path2rds <- "data/processing/hitfm/2017/05"
## Show paths with files
(list.dirs(path2rds) %>%
        list.files(full.names = T))

################################################################################
# IMPORTANT! This code chunk is simple test for making certain that tibbles
# created in correct way.

# 1.3 Write tibble for one day
(local_path <- days_level[12])
write_read_tibbles(local_path, path2rds, re_file_ext = ".html$",
                   map_fun = map_dfr, my_fun = simple_tibble)

## Result view
(file_name(local_path, path2rds))
file_name(local_path, path2rds) %>%
    readRDS %>%
    View()
################################################################################

# 1.4 Write tibbles this data from each day in range 1-31
map(days_level, write_read_tibbles, path2rds, re_file_ext = ".html$",
    map_fun = map_dfr, my_fun = simple_tibble) %>%
    invisible() # hide output

################################################################################
######### TASK 2 - CUMMULATE SMALL TIBBLES IN A BIG ONE (RDS) ##################
################################################################################
# 2.1 Choose folder for processed data (folder and rds files must already exist)
small_rds <- "data/processing/hitfm/2017/05"
## Show paths with files
(list.dirs(small_rds) %>%
        list.files(full.names = T))

## 2.2 Choose folder to cummulate processing data into big rds file
## (folder must already exist!!!)
big_rds <- "data/processing/hitfm/2017"
(list.dirs(big_rds))

# 2.3 Create big rds-file that contains data from small tibbles
small_rds <- "data/processing/hitfm/2017/05"
big_rds <- "data/processing/hitfm/2017"
write_read_tibbles(small_rds, big_rds,
                   re_file_ext = ".rds$", map_fun = map_dfr, my_fun = readRDS)

## Result view
file_name(small_rds, big_rds) %>%
    readRDS %>%
    View()
