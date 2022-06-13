## Purpose: Compare re3data and FAIRsharing
## Parts: 1) Compare re3data and FAIRsharing dbs
## Package(s): tidyverse
## Input file(s): fairsharing_dbs_all_2022-06-09.csv, re3data_life_sci_repos_2021-08-06.csv
## Output file(s): NA
## NOTES: FAIRsharing data is under CC-BY-SA - do not push to Github

library(tidyverse)

##=========================================================##
######### PART 1: Compare re3data and FAIRsharing dbs ####### 
##=========================================================##

r3 <- read.csv("re3data_life_sci_repos_2021-08-06.csv") ##1912
fs <- read.csv("fairsharing_dbs_all_2022-06-09.csv") ##1885

r3 <- select(r3, re3data_ID, repositoryName, repositoryURL) 
fs <- select(fs, doi, name, url) 

names(r3)[names(r3)=="re3data_ID"]<- "id"
names(r3)[names(r3)=="repositoryName"]<- "name"
names(r3)[names(r3)=="repositoryURL"]<- "url"
names(fs)[names(fs)=="doi"]<- "id"

## find exact matches
match_name <- semi_join(r3, fs, by = "name") ## 390
match_url <- semi_join(r3, fs, by = "url") ## 319

## on names only
r <- select(r3, name) 
f <- select(fs, name) 
all_exact_name <- bind_rows(r, f) ## 3797
all_dedup_exact_name <- unique(bind_rows(r, f)) ## 3404 ... should be 3407?
