# This is workflow by creating tibbles with data from radio station's playlists

# We have to choose directory that contains data for one month. The raw data are
# contain in html files. So we extract these data to make final tibble that will
# contain data for this month. 

source("R/scraping_functions.R")

# 1. Set up directory with data.
in_path <- "data/raw/krainafm/2017/05"
(list.dirs(in_path))
out_path <- "data/processing/krainafm/2017/05"
(list.dirs(out_path))

## Show level "../krainafm/2017/05"
(month_level <- list.dirs(in_path)[1]) # simple char
## Show paths with files
(days_level <- list.dirs(in_path)[-1]) # chr vector

# 2. Write tibble for one day (for testing)
(local_path <- days_level[12])
write_read_tibbles(local_path, out_path, re_file_ext = ".html$",
                    map_fun = map_dfr, my_fun = simple_tibble)

## Result view
(file_name(local_path, out_path))
file_name(local_path, out_path) %>%
    readRDS %>%
    View()

# 3. Write tibbles this data from each day in range 1-31
map(days_level, write_read_tibbles, out_path, re_file_ext = ".html$",
    map_fun = map_dfr, my_fun = simple_tibble) %>%
    invisible() # hide output


# 4. Create big rds-file that contains data from whole month
in_path2 <- "data/processing/krainafm/2017/05"
out_path2 <- "data/processing/krainafm/2017"
write_read_tibbles(in_path2, out_path2,
                    re_file_ext = ".rds$", map_fun = map_dfr, my_fun = readRDS)

## Result view
file_name(in_path2, out_path2) %>%
    readRDS %>%
    View()
