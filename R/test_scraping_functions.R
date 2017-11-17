source("R/scraping_functions.R")

################### TEST file_name #########

# Make RDS file name from html file
(file_name("data/raw/krainafm/2017/05/01",
          "data/processing/krainafm/2017/05"))

# Make RDS file name from other RDS file
(file_name("data/raw/krainafm/2017/05",
           "data/processing/krainafm/2017"))

################### TEST write_read_tibbles #########

in_path <- "data/test/raw/krainafm/2017/05"
(list.dirs(in_path))
out_path <- "data/test/processing/krainafm/2017/05"
(list.dirs(out_path))

# Show level "test_data/krainafm/2017/05"
(month_level <- list.dirs(in_path)[1]) # simple char
# Show paths with files
(days_level <- list.dirs(in_path)[-1]) # chr vector

## 1. Make simple tibble from html
(in_path1 <- days_level[3])
write_read_tibbles(days_level[3],
                   out_path,
                   re_file_ext = ".html$",
                   map_fun = map_dfr, my_fun = simple_tibble)

# Result view
(file_name(in_path1, out_path))
file_name(in_path1, out_path) %>%
     readRDS %>%
     View()

## 2. Write multiple tibbles
map(days_level, write_read_tibbles, out_path, re_file_ext = ".html$",
    map_fun = map_dfr, my_fun = simple_tibble) %>%
    invisible() # hide output

# Result view
file_name(days_level[1], out_path) %>%
    readRDS %>%
    View()

file_name(days_level[2], out_path) %>%
    readRDS %>%
    View()

file_name(days_level[3], out_path) %>%
    readRDS %>%
    View()

file_name(days_level[4], out_path) %>%
    readRDS %>%
    View()

## 3. Create big rds-file that contains data from whole month
in_path3 <- "data/test/processing/krainafm/2017/05"
out_path3 <- "data/test/processing/krainafm/2017"
write_read_tibbles(in_path3, out_path3,
                   re_file_ext = ".rds$",
                   map_fun = map_dfr, my_fun = readRDS)

file_name(in_path3, out_path3) %>%
    readRDS %>%
    View()

################### TEST simple_tibble ################
path2file <- c("data/test/krainafm_2017_05_01_01.html",
               "data/test/krainafm_2017_05_01_01.html")

simple_tibble(path2file[1]) %>%
    View()
