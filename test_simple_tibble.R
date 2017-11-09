library(stringr)
library(tidyverse)
source("simple_tibble.R")

################### TEST write_simple_tibbles FUN #########
# Directory with test data
(test_dir <- str_subset(list.dirs("test_data"),"/\\d\\d$"))
list.files(test_dir[2], full.names = T)

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
