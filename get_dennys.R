# set API key
key = "6B962D40-03BA-11E5-BC31-9A51842CA48B"

# Function 'get_dennys_locs' is used to download the Denny's information in a certain region,
# which is a circle with ('lat','long') as its center and the 'radius' as its radius.
# Inputs: 'dest' - the name of the file
#          'key' - API key
#          'lat' - latitude of the center of the search circle
#          'long' - the longitude of the center of the search circle
#          'limit' - limit of the number of the result
# Output: downloaded file
get_dennys_locs = function(dest, key, lat, long, radius, limit) {
    # url address
    url = paste0(
      "https://hosted.where2getit.com/dennys/responsive/ajax?&xml_request=",
      "<request>",
      "<appkey>", key, "%3C%2Fappkey%3E%3Cformdata%20id%3D%22locatorsearch%22%3E", 
      "<dataview>store_default</dataview>",
      "<limit>", limit, "</limit>",
      "<order>rank,_distance</order>",
      "<geolocs><geoloc><addressline></addressline>",
      "<longitude>", long, "</longitude>",
      "<latitude>", lat, "</latitude>",
      "<country>US</country></geoloc></geolocs><stateonly>1</stateonly>",
      "<searchradius>",radius,"</searchradius></formdata></request>")
    # download the file
    download.file(url, destfile = dest)
}

# The regions we search. They should cover all the place we are interested in (USA).
locs = read.csv("dennys_coords.csv",header = TRUE)

# Create a directory to store the files
dir.create("data/dennys/",recursive = TRUE,showWarnings = FALSE)
limit = 1000

# For all the regions, download the .xml file with Denny's information
for(i in 1:nrow(locs)) {
  long = locs[i,1]
  lat = locs[i,2]
  radius = locs[i,3]
  dest = paste0("data/dennys/",i,".xml")
  get_dennys_locs(dest, key, lat, long, radius, limit)
}





