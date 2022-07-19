## Purpose: 
## Parts: 1) Get copy of the whole registry 2) compare 
## Package(s): RCurl, jsonlite, tidyverse, httr
## Input file(s): 
## Output file(s): 
## Notes: https://docs.identifiers.org/articles/api.html#getdataset

library(RCurl)
library(jsonlite)
library(tidyverse)
library(httr)

query_url <- "https://registry.api.identifiers.org/resolutionApi/getResolverDataset"

get_res <- GET(
  query_url,
)

query_con<-fromJSON(rawToChar(get_res$content)) 

t0 <- as.data.frame(query_con[["payload"]][["namespaces"]])