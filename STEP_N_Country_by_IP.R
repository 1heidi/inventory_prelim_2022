library(rgeolocate)
# library(RCurl)
# library(jsonlite)

##example
url <- "data.glygen.org"
ip <- nsl(url)
return <- ip_info(ip, token = NULL)