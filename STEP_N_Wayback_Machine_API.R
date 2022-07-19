## Purpose: Find if resource url is archived in Wayback Machine
## Parts: 1) Find Archived URLs from Wayback Machine 2) submit failed URLs to be archived
## Package(s): wayback, dplyr
## Input file(s): ner_predictions_all_reshape_2022-07-01.csv
## Output file(s):
## Notes: wayback package is only on Github https://github.com/hrbrmstr/wayback

library(wayback)
library(dplyr)
library(httr)
library(RCurl)

##=========================================================##
###### PART 1: Find Archived URLs from Wayback Machine ###### 
##=========================================================##

pred <- read.csv("ner_predictions_all_reshape_2022-07-01.csv")
##remove rows without a url
pred <- pred[(which(nchar(pred$url_1) > 0)),]
urls <- pred$url_1

wayback<- NULL
for (url in urls) {
  response <- archive_available(url)
  wayback <- bind_rows(wayback, response)
}

## get current http status


