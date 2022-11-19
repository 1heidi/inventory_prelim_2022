## Purpose: Determine which articles associated with the biodata resource inventory are Open Access, have text-mined terms, etc. 
## Parts: 1) Retrieve additional metadata from Europe PMC, 2) analyze metadata, and 3) save output files
## Package(s): europepmc, tidyverse, reshape2
## Input file(s): processed_manual_review.csv (temp! until final inventory file is available)
## Output file(s): inventory_articles_all_2022-11-18.csv, inventory_article_stats_2022-11-18.csv, inventory_license_counts_2022-11-18.csv, journals,inventory_journal_counts_2022-11-18.csv, inventory_journal_db_counts_2022-11-18.csv

##================================================================##
####### PART 1: Retrieve additional metadata from Europe PMC ####### 
##================================================================##

library(europepmc)
library(tidyverse)
library(reshape2)

## split and melt IDs from the inventory into a list of just IDs 
inv <- read.csv("processed_manual_review.csv")
inv <- separate(inv, 'ID', paste("ID", 1:30, sep="_"), sep=",", extra="drop")
inv <- inv[,colSums(is.na(inv))<nrow(inv)]
inv[, c(1:14)] <- sapply(inv[, c(1:14)],as.numeric)

ids <- select(inv, 1:14)
ids <- melt(ids, na.rm = TRUE, value.name = "ID")
id_list <- ids$ID

## Retrieve Y/N metadata via Europe PMC API
## takes 10-15 minutes on several thousand IDs

y  <- NULL;
for (i in id_list) {
  r <- sapply(i, epmc_details) 
  id <- r[[1]]["id"]
  title <- r[[1]]["title"]
  oa <- r[[1]]["isOpenAccess"]
  terms <- r[[1]]["hasTextMinedTerms"]
  dbcross <- r[[1]]["hasDbCrossReferences"]
  lablinks <- r[[1]]["hasLabsLinks"]
  acc_num <- r[[1]]["hasTMAccessionNumbers"]
  j_title <- r[[3]]["journal.title"]
  license <- tryCatch(r[[1]]["license"], error = function(cond) {
    message(paste("licence issue"))
    message(cond, sep="\n")
    return(NA)
    force(do.next)})
  report <- cbind(id, title, oa, terms, dbcross, lablinks, acc_num, j_title, license)
  y <- rbind(y, report)
}

## find lost PMIDs 
y_id <- as.data.frame(y$id)
names(y_id)[1] ="id"
id_l <- as.data.frame(id_list)
names(id_l)[1] ="id"
y_id$id <- as.numeric(y_id$id)
id_l$id <- as.numeric(id_l$id)
lost <- anti_join(id_l, y_id)
lost_id <- lost$id

## all from MED
med  <- NULL;
for (i in lost_id) {
  r <- sapply(i, epmc_details, data_src = "med") 
  id <- r[[1]]["id"]
  title <- r[[1]]["title"]
  oa <- r[[1]]["isOpenAccess"]
  terms <- r[[1]]["hasTextMinedTerms"]
  dbcross <- r[[1]]["hasDbCrossReferences"]
  lablinks <- r[[1]]["hasLabsLinks"]
  acc_num <- r[[1]]["hasTMAccessionNumbers"]
  ## in just this set, one journal title absent
  journal.title <- tryCatch(r[[3]]["journal.title"], error = function(cond) {
    message(paste("title issue"))
    message(cond, sep="\n")
    return(NA)
    force(do.next)})
  license <- tryCatch(r[[1]]["license"], error = function(cond) {
    message(paste("licence issue"))
    message(cond, sep="\n")
    return(NA)
    force(do.next)})
  report <- cbind(id, title, oa, terms, dbcross, lablinks, acc_num, journal.title, license)
  med <- rbind(med, report)
}

y <- rbind(y, med)

##========================================================##
####### PART 2: Analyze  metadata from Europe PMC ####### 
##========================================================##

## Y/N metadata 
isOpenAccess <- table(y['isOpenAccess'])
hasTextMinedTerm <- table(y['hasTextMinedTerms'])
hasDbCrossReferences <- table(y['hasDbCrossReferences'])
hasLabsLinks <- table(y['hasLabsLinks'])
hasTMAccessionNumbers <- table(y['hasTMAccessionNumbers'])

sum <- rbind (isOpenAccess, hasTextMinedTerm, hasDbCrossReferences, hasLabsLinks, hasTMAccessionNumbers)
sum <- as.data.frame(sum)

sum <- sum %>%
  mutate("percent" = (sum$Y/(sum$Y+sum$N))*100)

## analyze licenses
license <- as.data.frame(table(y['license'], useNA = "always"))
license$Freq <- as.numeric(license$Freq)
names(license)[1] ="Article_License"
names(license)[2] ="Count"

## analyze journals
journals <- as.data.frame(table(y['journal.title']))
journals$Freq <- as.numeric(journals$Freq)
names(journals)[1] ="Journal Name"
names(journals)[2] ="Biodata Resouce Count"

j_db <- as.data.frame(table(journals[2]))
names(j_db)[1] ="Count_Biodata_Resources"
names(j_db)[2] ="Count_Journals"

##=====================================##
####### PART 3: Save output files ####### 
##=====================================##

write.csv(y,"inventory_articles_all_2022-11-18.csv", row.names = FALSE)
write.csv(sum,"inventory_article_stats_2022-11-18.csv")
write.csv(license,"inventory_license_counts_2022-11-18.csv", row.names = FALSE)
write.csv(journals,"inventory_journal_counts_2022-11-18.csv", row.names = FALSE)
write.csv(j_db,"inventory_journal_db_counts_2022-11-18.csv", row.names = FALSE)


