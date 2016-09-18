
library(rvest)
library(magrittr)
library(stringr)
library(dplyr)

# load all lq html files #
files = dir("data/lq/", pattern = "*address.html", full.names = TRUE)

# total number of la quinta's#
n = length(files)

# create empty data frame with variables #
lq_df = data.frame(phone = vector(mode = "character", length = n),
                   fax = vector(mode = "character", length = n),
                   street_address = vector(mode = "character", length = n),
                   city = vector(mode = "character", length = n),
                   state = vector(mode = "character", length = n),
                   zipcode = vector(mode = "character", length = n),
                   latitude = vector(mode = "numeric", length = n),
                   longitude = vector(mode = "numeric", length = n),

                   stringsAsFactors = FALSE)

# loop through each html file #
# information for each variable from html gets added to data frame #
for (i in 1:n){

    html = read_html(files[i])


    addr_phone_fax =  html_nodes(html, ".hotelDetailsBasicInfoTitle p") %>% 
                      html_text() %>% 
                      str_trim() %>%
                      str_replace_all("\\n", "")

    lq_df$phone[i] = addr_phone_fax %>%
                     str_extract("Phone: [1][-. ][0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}") %>%
                     str_replace("Phone: ", "")


    lq_df$fax[i] = addr_phone_fax %>%
                   str_extract("Fax: [1][-. ][0-9]{3}[-. ][0-9]{3}[-. ][0-9]{4}") %>%
                   str_replace("Fax: ", "")
  
    address = addr_phone_fax %>%
              str_replace("Phone.*", "")

    lq_df$street_address[i] = address %>%
                              str_replace(",.*", "")

    city_state_zip = address %>%
                     str_replace(paste0(lq_df$street_address[i], ","), "") %>%
                     str_trim()

    lq_df$city[i] = city_state_zip %>%
                    str_replace(",.*", "")

    lq_df$state[i] = city_state_zip %>%
                     str_extract("[A-Z]{2}")

    lq_df$zipcode[i] = city_state_zip %>%
                       str_extract("[0-9-]{5,}")


    lat_long = html_nodes(html, ".minimap") %>%
               html_attr("src") %>%
               str_replace(".*\\|", "") %>%
               str_replace("\\&.*", "")

    lq_df$latitude[i] = lat_long %>%
                        str_replace(",.*", "") %>%
                        as.numeric()

    lq_df$longitude[i] = lat_long %>%
                         str_replace(".*,", "") %>%
                         as.numeric()

}

# remove repeated la quinta's #
lq_df = distinct(lq_df)

save(lq_df, file = "data/lq.Rdata")
