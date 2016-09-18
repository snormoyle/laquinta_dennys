
library(rvest)
library(magrittr)
library(stringr)
library(dplyr)

# load all dennys xml files #
files = dir("data/dennys/", pattern = "*.xml", full.names = TRUE)
list_df = list()

# loop through all xml files #
# information for each variable gets added to a data frame #
for (i in 1:length(files)){

    xml = read_xml(files[i])

    # number of counts of denny's in each file #
    n =  length(xml_nodes(xml, xpath = "//name"))

    # create empty data frame with variables of appropriate type #
    df = data.frame(phone = vector(mode = "character", length = n),
                    street_address = vector(mode = "character", length = n),
                    city = vector(mode = "character", length = n),
                    state = vector(mode = "character", length = n),
                    zipcode = vector(mode = "character", length = n),
                    latitude = vector(mode = "numeric", length = n),
                    longitude = vector(mode = "numeric", length = n),
                    country = vector(mode = "character", length = n),

                    stringsAsFactors = FALSE)


    df$phone = xml_nodes(xml, xpath = "//phone") %>%
               xml_text() %>%
               str_replace_all("\\(|\\)", "") %>%
               str_replace_all(" ", "-")

    df$fax = xml_nodes(xml, xpath = "//fax") %>%
             xml_text()

    df$street_address = xml_nodes(xml, xpath = "//address1") %>%
                        xml_text()

    df$city = xml_nodes(xml, xpath = "//city") %>%
              xml_text() 

    df$state = xml_nodes(xml, xpath = "//state") %>%
               xml_text()

    df$zipcode = xml_nodes(xml, xpath = "//postalcode") %>%
                 xml_text()


    df$latitude = xml_nodes(xml, xpath = "//latitude") %>%
                  xml_text() %>%
                  as.numeric()

    df$longitude = xml_nodes(xml, xpath = "//longitude") %>%
                   xml_text %>%
                   as.numeric()

    df$country = xml_nodes(xml, xpath = "//country") %>%
    			 xml_text 

    list_df[[i]] = df
}

# combine all data frames from list one one data frame #
# filter only US #
# remove repeated dennys #
dennys_df = bind_rows(list_df) %>%
            as.data.frame() %>%
            filter(country == "US") %>%
            distinct()

save(dennys_df, file = "data/dennys.Rdata")

