library(europepmc)
library(tidyverse)

my_query <- '(((ABSTRACT:"www" OR ABSTRACT:"http" OR ABSTRACT:"https") AND (ABSTRACT:"data" OR ABSTRACT:"resource" OR ABSTRACT:"database"))  NOT (TITLE:"retraction" OR TITLE:"retracted" OR TITLE:"withdrawn" OR TITLE:"withdrawal" OR TITLE:"erratum") NOT ((ABSTRACT:"retract" OR ABSTRACT:"withdraw" ABSTRACT:"erratum" OR ABSTRACT:"github.com" OR ABSTRACT:"github.io" OR ABSTRACT:"cran.r" OR ABSTRACT:"youtube.com" OR ABSTRACT:"bitbucket.org" OR ABSTRACT:"links.lww.com" OR ABSTRACT:"osf.io" OR ABSTRACT:"bioconductor.org" OR ABSTRACT:"annualreviews.org" OR ABSTRACT:"creativecommons.org" OR ABSTRACT:"sourceforge.net" OR ABSTRACT:".pdf" OR ABSTRACT:"clinical trial" OR ABSTRACT:"registry" OR ABSTRACT:"registration" OR ABSTRACT:"trial registration" OR ABSTRACT:"clinicaltrial" OR ABSTRACT:"registration number" OR ABSTRACT:"pre-registration" OR ABSTRACT:"preregistration"))) AND (((SRC:MED OR SRC:PMC OR SRC:AGR OR SRC:CBA))) AND (FIRST_PDATE:[2011 TO 2021]) AND ((HAS_FT:Y AND OPEN_ACCESS:Y))'

query_count <-epmc_hits(query = my_query)
pmc_seed <- epmc_search(query=my_query, limit = 25000)

sum(is.na(pmc_seed$id)) ## usually a few all NA rows return
pmc_seed <- filter(pmc_seed, !is.na(pmc_seed$id))
year_counts <-count(pmc_seed, pubYear) ## a few pre-2011 years may sneak in
pmc_seed <- filter(pmc_seed, pmc_seed$pubYear > 2010)

pmc_seed2 <- select(pmc_seed, 1,2,8,10)

predict <- read.csv("predictions_2022-06-18.csv") 
predict2 <- select(predict, 1,2,3)

names(predict)[names(predict)=="ID"]<- "id"
test <- left_join(predict2, pmc_seed2, by = "id")

sum(is.na(test$source))

