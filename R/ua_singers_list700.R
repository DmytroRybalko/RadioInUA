# Here we make tibble with ukrainian bands from here:
# http://www.pravda.com.ua/cdn/graphics/music/index.html

library(rvest)
library(tidyverse)
library(stringr)

#########################################################
####################### FUNCTIONS #######################
#########################################################

extract_data <- function(number, id_name, xml_node) {
    # Function takes number of singer in range 0:699, construct css selector
    # from id_name and extract coresponding data from xml_node
    
    dom <- str_c("div#list-", number, ".list>span.", id_name)
    # dom is object from DOM-tree like "div#list-127.list>span.gurt"
    html_nodes(xml_node, dom) %>%
        html_text() %>%
        str_replace("^\\s*$", replacement = NA_character_)
        # if data is only spaces - replace it with NA
}
######################### TEST ##########################
# extract_data(7, "gurt", xml_list)

ukrainian_singers_tibble <- function(number, xml_node) {
    # Function takes number of singer in range 0:699, construct css selector,
    # extract coresponding data from xml_node and save it
    # into tibble with following template: gurt | region | lang | solo | year
    
    # Extract data from html file
    gurt <- extract_data(number, "gurt", xml_node)
    region <- extract_data(number, "city", xml_node)
    lang <- extract_data(number, "lang1", xml_node)
    solo <- extract_data(number, "solo", xml_node)
    s_year <- extract_data(number, "year", xml_node)
    
    # Make tibble
    my_tibble <- tibble(gurt = gurt,
                        region = region,
                        languages = lang,
                        solo = solo,
                        start_year = s_year)
    return(my_tibble)
}
######################### TEST ##########################
ukrainian_singers_tibble(7, xml_list)
# 5'nizza|Харківська|укр. рос.|гурт|2000

#########################################################
################### MAIN WORKFLOW #######################
#########################################################

# 1. Load XML data from file
xml_list <- xml2::read_html("data/raw/bands_db/700_ukrainian_bands.html")
# 2. Test step for control result
map_dfr(0:7, ukrainian_singers_tibble, xml_list)
# 3. Make final tibble with ukrainian singers and bands:
bands_tibble <- map_dfr(0:699, ukrainian_singers_tibble, xml_list)
View(bands_tibble)
# 4. Make rds file with ukrainian singers and bands:
saveRDS(bands_tibble, "data/processing/bands_db/ua_700_bands.rds")
