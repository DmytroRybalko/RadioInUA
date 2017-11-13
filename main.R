# This is workflow by creating tibbles with data from radio station's playlists

# We have to choose directory that contains data for one month. The raw data are
# contain in html files. So we extract these data to make final tibble that will
# contain data for this month. 

# 1. Set up directory with data.
#library(stringr)
#library(tidyverse)
source("simple_tibble.R")

my_path <- "raw_data/krainafm/2017/05"
(list.dirs(my_path))

# Show level "test_data/krainafm/2017/05"
(month_level <- list.dirs(my_path)[1]) # simple char
# Show paths with files
(days_level <- list.dirs(my_path)[-1]) # chr vector

# 2. Write tibble for one day (for testing)

# Make name for RDS-file
local_path <- days_level[12]
make_simple_tibbles(local_path, re_file_ext = ".html$",
                    map_fun = map_dfr, my_fun = simple_tibble)

#rds_name <- file_name(local_path, "([a-z]+)(?=/\\d{4})(/[0-9/]+)")
#write_read_tibbles(local_path, re_file_ext = ".html$", my_fun = simple_tibble)

# Result view
str_extract(local_path, "([/_a-z]+)([/0-9]+)(?=/\\d{2})") %>%
    list.files(full.names = T, pattern = ".rds$") %>%
    readRDS() %>%
    View()

# readRDS(rds_name) %>%
#     View()

## 2. Write tibbles this data from each day in range 1-31
map(days_level, make_simple_tibbles, re_file_ext = ".html$",
    map_fun = map_dfr, my_fun = simple_tibble) %>%
    invisible() # hide output

#!!!!! time ~ 60 c

# days_level %>%
#     map(write_read_tibbles,
#         "([a-z]+)(?=/\\d{4})(/[0-9/]+)", ".html$", map_dfr, simple_tibble) %>%
#     invisible() # hide output

## Pattern for choosing folders in range 21-31 (3[01]|[2][1-9])
str_view("raw_data/krainafm/2017/05/22", "([a-z]+)(?=/\\d{4})(/2017/05/)(3[01]|[2][1-9])")
str_view("raw_data/krainafm/2017/05/22", "(/2017/05/)(3[01]|[2][1-9])$")

(new_days <- str_detect(days_level, "/(3[01]|[2][1-9])$") %>%
        new_days[.])

new_days <- str_detect(days_level, "/(3[01]|[2][3-9])$") %>%
    new_days[.] %>%
    map(write_read_tibbles,
       "([a-z]+)(?=/\\d{4})(/[0-9/]+)", ".html$", map_dfr, simple_tibble) %>%
    invisible() # hide output

# 4. Make tibble that will contain data for whole month
map(days_level, write_read_tibbles,
    re_file_name = "([a-z]+)(?=/\\d{4})(/[0-9/]+)",
    re_file_ext = ".rds$", map_fun = map_dfr, my_fun = readRDS) %>%
        invisible() # hide output

days_level %>%
    map_chr(list.files(full.names = T, pattern = ".rds$"))

## Result view
file_name(month_level, "([a-z]+)(?=/\\d{4})(/[0-9/]+)") %>%
    readRDS %>%
    View()

