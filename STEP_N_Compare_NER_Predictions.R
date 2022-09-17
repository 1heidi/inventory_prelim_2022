## Purpose: Compare old (june) and new (ddup/sept) ner predictions

library(tidyverse)
library(europepmc)

ddup <- read.csv("deduped_predictions.csv")
ddup <- select(ddup, 1, 11)
ddup <- separate_rows(ddup, ID, sep = ",")
ddup$ID <- trimws(sub("\\.\\d+$", "", ddup$ID))
names(ddup)[names(ddup) == "best_name"] <- "best_name_sept"

june <- read.csv("ner_predictions_all_reshape_2022-07-01.csv")
june <- select(june, 1,2,34,37)
names(june)[names(june) == "text"] <- "text_june"
names(june)[names(june) == "best_name_overall"] <- "best_name_june"
names(june)[names(june) == "max_either_prob"] <- "best_prob_june"

test <- left_join(june, ddup, by = "ID")

## check to make sure present in new query (e.g. there to be predicted at all)

new <- '(ABSTRACT:(www OR http*) AND ABSTRACT:(data OR resource OR database*)) NOT (TITLE:(retract* OR withdraw* OR erratum)) NOT (ABSTRACT:(retract* OR withdraw* OR erratum OR github.* OR cran.r OR youtube.com OR bitbucket.org OR links.lww.com OR osf.io OR bioconductor.org OR annualreviews.org OR creativecommons.org OR sourceforge.net OR bit.ly OR zenodo OR onlinelibrary.wiley.com OR proteomecentral.proteomexchange.org/dataset OR oxfordjournals.org/nar/database OR figshare OR mendeley OR .pdf OR "clinical trial" OR registration OR "trial registration" OR clinicaltrial OR "registration number" OR pre-registration OR preregistration)) AND (SRC:(MED OR PMC OR AGR OR CBA)) AND (FIRST_PDATE:[2011 TO 2021])'

new_seed <- epmc_search(query=new, limit = 25000) 
new_ids <- as.data.frame(select(new_seed, 1))
new_ids$in_new_query <- "True"

test2 <- left_join(test, new_ids, by = c("ID"="id"))

## count NA (e.g. not there to be predicted)
sum(is.na(test2$in_new_query)) ## 188 not present to get prediction

write.csv(test2,"compare_ner_results_2022-09-17.csv", row.names = FALSE) 

