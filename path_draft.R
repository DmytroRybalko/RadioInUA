library(stringr)
# Function than go throgh dir paths and 
construct_path<- function(station_name, year, month, day) {
## statioin_name - chr, 
## year - integer vector in range 2015:2017
## month - integer vector in range 1:12
## day - integer vector in range 1:31

    my_args <- c("raw_data", station_name, year, month, day)
    list.files(paste0(my_args, collapse = "/"))
}

############### DRAFT ZONE ############################
dir("raw_data")
list.dirs("raw_data")[1:4]
list.files("raw_data/krainafm/2017/05/12")
# Make path
my_args <- c("raw_data", "krainafm", "2017", "05", "12")
list.files(paste0(my_args, collapse = "/"))

my_args <- c("raw_data", "krainafm", "2017", "05", "0[4|5]")
paste0(my_args, collapse = "/")

dir("test_data/raw_data/krainafm/2017/05", pattern = "0[4|5]", full.names = T)
