## Purpose: Retrieve and analyze funder metadata
## Parts: 1) Retrieve funder metadata from Europe PMC, 2) analyze, and 3) save output files
## Package(s): europepmc, tidyverse, reshape2
## Input file(s): processed_manual_review.csv (temp! until final inventory file is available)
## Output file(s): inventory_raw_funder_return_2022-11-18.csv, inventory_funders_2022-11-18.csv, inventory_simplified_funders_2022-11-18.csv, inventory_NNFSC_only_2022-11-18.csv

##============================================================##
####### PART 1: Retrieve funder metadata from Europe PMC ####### 
##============================================================##

library(europepmc)
library(tidyverse)
library(reshape2)

## split and melt IDs into a list of just IDs 
inventory <- read.csv("processed_manual_review.csv")
inv <- inventory
inv <- separate(inv, 'ID', paste("ID", 1:30, sep="_"), sep=",", extra="drop")
inv <- inv[,colSums(is.na(inv))<nrow(inv)]
inv[, c(1:14)] <- sapply(inv[, c(1:14)],as.numeric)

ids <- select(inv, 1:14)
ids <- melt(ids, na.rm = TRUE, value.name = "ID")
id_list <- ids$ID

## Retrieve funder metadata via Europe PMC API

## Retrieve funder metadata
## Takes 10-15 minutes on several thousand

a  <- NULL;
for (i in id_list) {
  r <- sapply(i, epmc_details) 
  id <- r[[1]]["id"]
  title <- r[[1]]["title"]
  agency <- tryCatch(r[[9]]["agency"], error = function(cond) {
    message(paste("funder issue"))
    message(cond, sep="\n")
    return(NA)
    force(do.next)})
  report <- cbind(id, title, agency)
  a <- rbind(a, report)
}

## check for any lost PMIDs 
a_id <- as.data.frame(a$id)
names(a_id)[1] ="id"
id_l <- as.data.frame(id_list)
names(id_l)[1] ="id"
a_id$id <- as.numeric(a_id$id)
id_l$id <- as.numeric(id_l$id)
lost <- anti_join(id_l, a_id)
lost_id <- lost$id

##===========================================================##
####### PART 2: Analyze funder metadata from Europe PMC ####### 
##===========================================================##

## isolate funders returned
f <- a %>% filter(complete.cases(.))
f_ids <- unique(f$id)
f <- select(f, -2)
## get data resource names 
sep <- separate_rows(inventory, ID, sep = ",")
names(sep)[1] ="id"
sep_ids <- unique(sep$id)
best_names <- select(sep, 1, 7)

##join
best_names$id <- trimws(best_names$id)
f$id <- trimws(f$id)
f_dbs <- left_join(f, best_names)

funders <- f_dbs %>%
  group_by(agency) %>%
    mutate(count_all_article_instances = length(id)) %>%
      mutate(count_unique_articles = length(unique(id))) %>%
        mutate(count_unique_biodata_resources = length(unique(best_name))) %>%
           mutate(list_PMIDs_for_funder = str_c(id, collapse = ", "))

names(funders)[3] ="biodata_resource_best_name"

## simplifying to just "unique" funders
funders2 <- unique(select(funders, 2,4:7)) 

## example with National Natural Science Foundation of China
NNFSC <- unique(filter(funders, agency == "National Natural Science Foundation of China"))
NNFSC <- select(NNFSC, 1:3)

##=====================================##
####### PART 3: Save output files ####### 
##=====================================##

write.csv(a,"inventory_raw_funder_return_2022-11-18.csv", row.names = FALSE)
write.csv(funders,"inventory_funders_2022-11-18.csv", row.names = FALSE)
write.csv(funders2,"inventory_simplified_funders_2022-11-18.csv", row.names = FALSE)
write.csv(NNFSC,"inventory_NNFSC_only_2022-11-18.csv", row.names = FALSE)

