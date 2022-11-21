## Purpose: Verify inventory articles with full text available in Europe PMC
## Parts: 1) retrieve records from query with full text and OA filter and then compare ID list with the IDs in the inventory
## Package(s): europepmc, tidyverse
## Input file(s): processed_manual_review.csv (temp! until final inventory file is available)
## Output file(s): inventory_FT_OA_ids_2022-11-21.csv

library(europepmc)
library(tidyverse)

## get IDs in query with full text and OA = Y

oa_ft <- '(ABSTRACT:(www OR http*) AND ABSTRACT:(data OR resource OR database*)) NOT (TITLE:(retract* OR withdraw* OR erratum)) NOT (ABSTRACT:(retract* OR withdraw* OR erratum OR github.* OR cran.r OR youtube.com OR bitbucket.org OR links.lww.com OR osf.io OR bioconductor.org OR annualreviews.org OR creativecommons.org OR sourceforge.net OR bit.ly OR zenodo OR onlinelibrary.wiley.com OR proteomecentral.proteomexchange.org/dataset OR oxfordjournals.org/nar/database OR figshare OR mendeley OR .pdf OR "clinical trial" OR registration OR "trial registration" OR clinicaltrial OR "registration number" OR pre-registration OR preregistration)) AND (SRC:(MED OR PMC OR AGR OR CBA)) AND (FIRST_PDATE:[2011 TO 2021]) AND ((HAS_FT:Y AND OPEN_ACCESS:Y))'

oa_ft_list <- epmc_search(query=oa_ft, limit = 25000)
oa_ft_list <- select(oa_ft_list, 1)
  
## get IDs from inventory

inventory <- read.csv("processed_manual_review.csv")
inv <- inventory
inv <- separate(inv, 'ID', paste("ID", 1:30, sep="_"), sep=",", extra="drop")
inv <- inv[,colSums(is.na(inv))<nrow(inv)]
inv[, c(1:14)] <- sapply(inv[, c(1:14)],as.numeric)

ids <- select(inv, 1:14)
ids <- melt(ids, na.rm = TRUE, value.name = "ID")
id_list <- ids$ID
id_list <- as.data.frame(id_list)
names(id_list)[1] ="id"
id_list$id <- as.character(id_list$id)

same <- inner_join(id_list, oa_ft_list, keep = TRUE)
names(same)[1] ="inventory_ids"
names(same)[2] ="epmc_query_ids"

write.csv(same,"inventory_FT_OA_ids_2022-11-21.csv", row.names = FALSE)