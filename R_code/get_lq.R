library(rvest)
library(stringr)

# create a directory to store html files
dir.create("data/lq/", recursive = TRUE, showWarnings = FALSE)

# read the state we are interested in
state = unlist(read.csv("lq_states.csv", header = FALSE))

base_url = "http://www.lq.com"
listing_page = "/en/findandbook/hotel-listings.html"

# downlad the list page of all hotels
download.file(paste(base_url,listing_page, sep = ''),
              destfile = "data/lq/listings.html")
listings = read_html("data/lq/listings.html")

# we use 'get_state_hotels' function to download the html files
# Inputs: 'html' - the html of a list including all hotels
#         'states' - all the states where we are interested in
#         'base_url' - base url address
#         'out_dir'  - output directory
get_state_hotels = function(html, states, base_url, out_dir = "data/lq/") {
  
  # download the html files for each state
  for(state in states) {
    dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
    hotels = html_nodes(html, "#hotelListing a")
    
    # Find the start of a state's hotels by finding its name in the node text
    # +2 to skip State and Back to Top anchor tags
    start = 2 + which(html_text(hotels) %>% 
            str_trim() %in% paste("Hotels in", state))
    
    # if there is some bug on the website, state might be NA, so we check that
    if(length(start) ==1){
      urls = html_attr(hotels, "href")
      label_index = which(is.na(urls))
      # find the end 
      end = label_index[label_index > start] %>% min() - 1
      
      for(url in urls[start:end]) {
      	# download the files
        download.file(paste0(base_url,url),
                      destfile = paste0(out_dir,basename(url)),
                      quiet = TRUE)
        # delay 5 seconds 
        Sys.sleep(5)
        }
    }else{
      break
    }
  }
}

get_state_hotels(listings, state, base_url)
