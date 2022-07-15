## Purpose: Extract db records for biodata resources from FAIRsharing API
## Parts: 1) Retrieve records 2) filter to biodata resources (obsolete)
## Package(s): RCurl, jsonlite, tidyverse, data.table, httr
## Input file(s): FAIRsharing login credential script
## Output file(s): fairsharing_dbs_all_2022-06-09.csv, fairsharing_subjects_all_2022-06-09.csv
## NOTES: FAIRsharing data is under CC-BY-SA - do not push output file to Github! Run FAIRsharing login credential script first to obtain "hji_login" argument for the below. For rest, see API documentation on https://fairsharing.org/API_doc and https://api.fairsharing.org/model/database_schema.json

library(RCurl)
library(jsonlite)
library(tidyverse)
library(data.table)
library(httr)

##======================================================##
######### PART 1: Extract Records from FAIRsharing ####### 
##======================================================##

## run FAIRsharing login script to get hji_login argument

url<-'https://api.fairsharing.org/users/sign_in'
request <- POST(url,
                add_headers(
                  "Content-Type"="application/json",
                  "Accept"="application/json"),
                body=hji_login)
con <- jsonlite::fromJSON(rawToChar(request$content))
auth<-con$jwt

## just life science only
query_url<-"https://api.fairsharing.org/search/fairsharing_records?fairsharing_registry=database&subjects=life%20science&page[number]=1&page[size]=3600"

## note that this had a tendency to time out sometimes - just keep trying until works. Other days it seemed fine, so not sure if my connection or theirs.

get_res<-POST(
  query_url,
  add_headers(
    "Content-Type"="application/json",
    "Accept"="application/json",
    "Authorization"=paste0("Bearer ",auth,sep="")
  )
)

query_con <-fromJSON(rawToChar(get_res$content))

## get db info of interest

dbs1 <- as.data.frame(query_con[["data"]][["attributes"]][["metadata"]][["doi"]])
dbs2 <- as.data.frame(query_con[["data"]][["attributes"]][["metadata"]][["name"]])
dbs3 <- as.data.frame(query_con[["data"]][["attributes"]][["metadata"]][["homepage"]])
dbs4 <- as_tibble_col(query_con[["data"]][["attributes"]][["subjects"]])
dbs <- cbind(dbs1, dbs2, dbs3, dbs4)

##rename
names(dbs)[names(dbs)=="query_con[[\"data\"]][[\"attributes\"]][[\"metadata\"]][[\"doi\"]]"]<- "doi"
names(dbs)[names(dbs)=="query_con[[\"data\"]][[\"attributes\"]][[\"metadata\"]][[\"name\"]]"]<- "name"
names(dbs)[names(dbs)=="query_con[[\"data\"]][[\"attributes\"]][[\"metadata\"]][[\"homepage\"]]"]<- "url"
names(dbs)[names(dbs)=="value"]<- "subjects"

## dbs <- apply(dbs,2,as.character)
## write.csv(dbs,"fairsharing_life_sci_2022-07-14.csv", row.names = FALSE) 

##======================================================##
########## PART 2: Filter for Biodata Resources ########## 
##======================================================##

## no longer needed now that can filter on life science directly in API call

# ## find unique subject classifications in FAIRsharing
# all_fs_subjects <- as.data.frame(unique(unlist(dbs$subjects))) ##340 return
# ## write.csv(all_fs_subjects,"fairsharing_subjects_all_2022-06-09.csv", row.names = FALSE) 
# 
# ## closest is "life sciences" - "biomedical" seems like will return clinical dbs, too
# 
# dbs$match <- str_extract(dbs$subjects, "Life Science")
# ls_db_count <- dbs %>% count(match)

## to write files, may need to do ... dbs <- apply(dbs,2,as.character)
## write.csv(dbs,"fairsharing_dbs_all_2022-06-09.csv", row.names = FALSE) 



