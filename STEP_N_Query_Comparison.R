## Purpose: Compare old and new query returns from EPMC; check against manually curated training dataset 

library(tidyverse)
library(europepmc)
library (readr)

old <- '(((ABSTRACT:"www" OR ABSTRACT:"http" OR ABSTRACT:"https") AND (ABSTRACT:"data" OR ABSTRACT:"resource" OR ABSTRACT:"database"))  NOT (TITLE:"retraction" OR TITLE:"retracted" OR TITLE:"withdrawn" OR TITLE:"withdrawal" OR TITLE:"erratum") NOT ((ABSTRACT:"retract" OR ABSTRACT:"withdraw" ABSTRACT:"erratum" OR ABSTRACT:"github.com" OR ABSTRACT:"github.io" OR ABSTRACT:"cran.r" OR ABSTRACT:"youtube.com" OR ABSTRACT:"bitbucket.org" OR ABSTRACT:"links.lww.com" OR ABSTRACT:"osf.io" OR ABSTRACT:"bioconductor.org" OR ABSTRACT:"annualreviews.org" OR ABSTRACT:"creativecommons.org" OR ABSTRACT:"sourceforge.net" OR ABSTRACT:".pdf" OR ABSTRACT:"clinical trial" OR ABSTRACT:"registry" OR ABSTRACT:"registration" OR ABSTRACT:"trial registration" OR ABSTRACT:"clinicaltrial" OR ABSTRACT:"registration number" OR ABSTRACT:"pre-registration" OR ABSTRACT:"preregistration"))) AND (((SRC:MED OR SRC:PMC OR SRC:AGR OR SRC:CBA))) AND (FIRST_PDATE:[2011 TO 2021])'

new <- '(ABSTRACT:(www OR http*) AND ABSTRACT:(data OR resource OR database*)) NOT (TITLE:(retract* OR withdraw* OR erratum)) NOT (ABSTRACT:(retract* OR withdraw* OR erratum OR github.* OR cran.r OR youtube.com OR bitbucket.org OR links.lww.com OR osf.io OR bioconductor.org OR annualreviews.org OR creativecommons.org OR sourceforge.net OR bit.ly OR zenodo OR onlinelibrary.wiley.com OR proteomecentral.proteomexchange.org/dataset OR oxfordjournals.org/nar/database OR figshare OR mendeley OR .pdf OR "clinical trial" OR registration OR "trial registration" OR clinicaltrial OR "registration number" OR pre-registration OR preregistration)) AND (SRC:(MED OR PMC OR AGR OR CBA)) AND (FIRST_PDATE:[2011 TO 2021])'

old_count <-epmc_hits(query = old) ##22,169
old_seed <- epmc_search(query=old, limit = 25000) 
old_seed <- select(old_seed, 1,6)

new_count <-epmc_hits(query = new) ##21,414
new_seed <- epmc_search(query=new, limit = 25000) 
new_seed <- select(new_seed, 1,6)

common <- semi_join(new_seed, old_seed, by = "id")
full <- full_join(old_seed, new_seed, by = "id", suffix = c(".old", ".new"))

## examine those that are not in common

test <- full %>% filter(!complete.cases(.))
set1_list <- test$id
y  <- NULL;
for (i in set1_list) {
  r <- sapply(i, epmc_details) 
  id <- r[[1]]["id"]
  title <- r[[1]]["title"]
  abstract <- r[[1]]["abstractText"]
  report <- cbind(id, title, abstract)
  y <- rbind(y, report)
}
unmatched <- y
unmatched <- left_join(test, unmatched, by = "id")
unmatched <- select(unmatched, -4)

url_pattern <- "http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"
unmatched$ContentURL <- str_extract_all(unmatched$abstractText, url_pattern)
unmatched <- apply(unmatched,2,as.character)
write.csv(unmatched,"all_unmatched_query_check_2022-09-17.csv", row.names = FALSE) 

## checking training data vs. new query
urlfile="https://raw.githubusercontent.com/globalbiodata/inventory_2022/inventory_2022_dev/data/manual_classifications.csv"
man <-read_csv(url(urlfile))

unmatched_man <- anti_join(man, new_seed, by = "id")
unmatched_man <- apply(unmatched_man,2,as.character)
write.csv(unmatched_man,"manually_classified_not_in_new_query_2022-09-17.csv", row.names = FALSE) 