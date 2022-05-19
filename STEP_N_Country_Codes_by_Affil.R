## Purpose: Test Country Retrieval from Affiliations and Map to ISO Country Codes
## Parts: 1)  Extract affiliation from Europe PMC record and 2) extract country from affiliation using countrycode package
## Package(s): europepmc, tidyverse, countrycode, maps
## Input file(s): pmc_seed_all_2021-08-06.csv
## Output file(s): 
## NOTES: See - https://stackoverflow.com/questions/5318076/extracting-country-name-from-author-affiliations

library(tidyverse)
library(europepmc)
library(countrycode)
library(maps)

##=========================================##
######### PART 1: Extract Affiliation ####### 
##=========================================##

## testing with work done in summer 2021 (https://github.com/1heidi/inventory_prelim_2021)
pmc_seed <- read.csv("pmc_seed_all_2021-08-06.csv")
slice <- slice(pmc_seed, 1:500)
test_ids <-slice$id

y  <- NULL;
for (i in test_ids) {
  r <- sapply(i, epmc_details) 
  id <- r[[1]]["id"]
  title <- r[[1]]["title"]
  abstract <- r[[1]]["abstractText"]
  ## adding affiliation - NOTE this only returns 1 author affilation, see below to return the rest
  affiliation <- tryCatch(r[[1]]["affiliation"], error = function(cond) {
    message(paste("affiliation issue"))
    message(cond, sep="\n")
    return(NA)
    force(do.next)})
  report <- cbind(id, title, abstract, affiliation)
  y <- rbind(y, report)
}

##======================================================##
######### PART 2: Extract Country from Affiliation ####### 
##======================================================##

## IDs for Aravind to try the ePMC algorithm  

write.table(y$id,"epmc_geo_test_2022-05-19.csv", col.names = F, row.names = F)

##test two names, edited y to have New Zealand in 1st record (34167460) and South Africa in 20th (33813885)
##failed

write.csv(y,".csv", row.names = FALSE)
y <- read.csv("2name_test.csv")

data(world.cities)

with_country <- y %>%
  group_by(id) %>%
    mutate(no_punc = gsub("[[:punct:]\n]","",affiliation)) %>%
      mutate(split = strsplit(no_punc, " ")) %>%
        mutate(country = lapply(split, function(x)x[which(x %in% world.cities$country.etc)]))

with_country <- select(with_country, 1:4, 7)
with_country["country"][with_country["country"] == "character(0)"] <- NA
with_country <- with_country %>% unnest_wider(country)

names(with_country)[names(with_country)=="...1"] <- "C1"
names(with_country)[names(with_country)=="...2"] <- "C2"
names(with_country)[names(with_country)=="...3"] <- "C3"

with_country <- with_country %>%
  group_by(id) %>%
  mutate(country = ifelse(test = (is.na(C2) & is.na(C3)),
                         yes = C1,
                         no = ifelse(test = (C1 == C2),
                                     yes = C1,
                                     no = ifelse(test = (C1 != C2 & C1 != C3 & C3 != C2),
                                                 yes = NA, 
                                                 no = "FAIL!")))) ## check that no countries = FAIL!

country_summary <- as.data.frame(table(with_country['country'], useNA = "ifany"))

## 13/472 failed to return any affiliation
## 47/472 failed to extract a country from the returned affiliation
## 3/472 returned multiple locations (including US, [state] issues) = ambiguous
## Final - 63 NA out of 472 records (87% assigned country, 13% could not)


### TEST AREA ####
## Getting *ALL* affiliations

test_details <- epmc_details(ext_id = 34314492)

id <- 34314492

z  <- NULL;
for (i in id) {
  r <- sapply(i, epmc_details) 
  id <- r[[1]]["id"]
  title <- r[[1]]["title"]
  abstract <- r[[1]]["abstractText"]
  ## adding affiliation
  affiliation <- tryCatch(r[[2]]["affiliation"], error = function(cond) {
    message(paste("affiliation issue"))
    message(cond, sep="\n")
    return(NA)
    force(do.next)})
  report <- cbind(id, title, abstract, affiliation) ### a row for every affiliation, need to condense for affiliation all in one 
  z <- rbind(z, report)
}
