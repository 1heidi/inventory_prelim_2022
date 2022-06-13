## Purpose: ePMC Annotations by Provider
## Parts: 1) Annotations via europePMC R package and 2) Annotations via ePMC Annotations API 
## Package(s): RCurl, jsonlite, tidyverse, data.table, httr
## Input file(s): 
## Output file(s): 
## NOTES: 

library(RCurl)
library(jsonlite)
library(tidyverse)
library(data.table)
library(httr)
library(europepmc)

##=========================================================##
######### PART 1: Annotations via europePMC R package ####### 
##=========================================================##

## example using PheneBank; provider could be "GlobalBiodataCoalition" instead

my_query <- '(ANNOTATION_TYPE:"Resources") AND (ANNOTATION_PROVIDER:"PheneBank")'

pmc_seed <- epmc_search(query=my_query, limit = 500) ## 500 just for testing
pmc_seed <- filter(pmc_seed, !is.na(pmc_seed$id)) ## in case any all NA rows

## from here can tally citations, journals, etc. - whatever is based on the article metadata

## can use function epmc_annotations_by_id if want to see all annotations for IDs returned above and can filter by a given provider's annotations

prep <- unite(pmc_seed, source, pmid, col=ids, sep=":")
ids <- prep$ids
anno_all <- epmc_annotations_by_id(ids)
anno_pb <- filter(anno_all, anno_all$provider == "PheneBank")

##==========================================================##
######### PART 2: Annotations via ePMC Annotations API ####### 
##==========================================================## 

## code from ePMC at https://europepmc.org/AnnotationsApi

## See : https://stackoverflow.com/questions/70997049/im-trying-to-get-bulk-data-from-europe-pmc-annotations-api-in-python

## curl -X GET --header 'Accept: application/json' 'https://www.ebi.ac.uk/europepmc/annotations_api/annotationsByProvider?provider=PheneBank&filter=1&format=JSON&pageSize=4'

## FYI - filter 1 for only PheneBank annotation, 0 would give all annotations for articles per documentation

query_url <- "https://www.ebi.ac.uk/europepmc/annotations_api/annotationsByProvider?provider=PheneBank&filter=1&format=JSON&pageSize=8"

get_res <- GET(
  query_url,
  add_headers(
    "Content-Type"="application/json",
    "Accept"="application/json"
  )
)

query_con<-fromJSON(rawToChar(get_res$content)) ##works!

## explore query_con to understand the structure

t0 <- as.data.frame(query_con)

## ? How do you get past page 1 (or whatever... must be a way to query until retrieved all??) i.e. above gives for 8 articles but PheneBank provided annotations for 90K... how would you get the rest? (we'll never have that many)


