library(stringr)
library(tidyverse)
source("simple_tibble.R")


## TODO:
## 1) replace code from draft.R and path_draft.R files for corresponding
## function
## 2) remove path_draft.R
## 3) make test file for each function

################### TEST file_name FUN #########

# Function make file name from file's path:
test_root_path = c("test_data/krainafm/2017/05/01", "test_data/krainafm/2017/05")
test_re_file_name = "([a-z]+)(?=/\\d{4})(/[0-9/]+)"
# out: test_data/krainafm/2017/05/krainafm_2017_05.RDS
(file_name(test_root_path[1], test_re_file_name))
(file_name(test_root_path[2], test_re_file_name))

################## Set root dir for work ##########
my_path <- "test_data/krainafm/2017/05"
(list.dirs(my_path))

# Show level "test_data/krainafm/2017/05"
(month_level <- list.dirs(my_path)[1]) # simple char
# Show paths with files
(days_level <- list.dirs(my_path)[-1]) # chr vector

################### TEST write_read_tibbles  FUN #########
## 1. Write simple tibble
(test_path1 <- days_level[3]) #"test_data/krainafm/2017/05/26"
write_read_tibbles(test_path1, "([a-z]+)(?=/\\d{4})(/[0-9/]+)", ".html$",
                                map_fun = map_dfr, my_fun = simple_tibble)
# Result view
file_name(test_path1, "([a-z]+)(?=/\\d{4})(/[0-9/]+)") %>%
    readRDS %>%
    View()

## 2. Write multiple tibbles
map(days_level, write_read_tibbles, "([a-z]+)(?=/\\d{4})(/[0-9/]+)", ".html$",
    map_dfr, simple_tibble) %>%
    invisible() # hide output

## 3. Create big RDS file that contains data from whole month
map(days_level, write_read_tibbles, "([a-z]+)(?=/\\d{4})(/[0-9/]+)", ".rds$",
    map, readRDS) %>%
    invisible() # hide output

# Result view
file_name(month_level, "([a-z]+)(?=/\\d{4})(/[0-9/]+)") %>%
    readRDS %>%
    View()

################### TEST write_simple_tibbles FUN #########
# Directory with test data
(test_dir <- str_subset(list.dirs("test_data"),"/\\d\\d$"))
# Filter non html files (.RDS is present)
list.files(test_dir[2], full.names = T, pattern = ".html$")

write_simple_tibbles(test_dir[2])
# Result view
readRDS("test_data/krainafm/2017/05/01/krainafm_2017_05_01.RDS") %>%
    View()

# Test with real data
(real_dir <- str_subset(list.dirs("raw_data"), "(\\d{4}/\\d{2}/\\d{2})"))

write_simple_tibbles(real_dir[1])

readRDS("raw_data/krainafm/2017/05/01/krainafm_2017_05_01.RDS") %>%
    View()

################### TEST simple_tibble FUN ################
#path2file <- "krainafm_2017_05_01_01.html"
path2file <- "test_data/write_simple_tibble/01/krainafm_2017_05_26_01.html"
#xml2::read_html(path2file)

simple_tibble(path2file) %>%
    View()
