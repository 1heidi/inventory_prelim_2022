## Purpose: Test Country Retrieval from Affiliations
## Parts: 1)  Extract affiliations from Europe PMC record, 2) extract country from affiliation using countrycode/maps package, and 3) compare with countrycode/maps packages with ePMC's algorithm (Arthur's via Aravind)
## Package(s): europepmc, tidyverse, countrycode, maps, stringdist
## Input file(s): epmc_geo_test_2022-05-19.csv, epmc_geo_test_V1_results.csv
## Output file(s): compare_geo_epmc_2022-06-08.csv
## NOTES: See - https://stackoverflow.com/questions/5318076/extracting-country-name-from-author-affiliations for original idea

library(tidyverse)
library(europepmc)
library(countrycode)
library(maps)

##=========================================##
######### PART 1: Extract Affiliation ####### 
##=========================================##

## epmc_geo_test_2022-05-19.csv was created with a set of ids for testing with ePMC's algorithm; using these ids w/ the code I drafted for use with the countrycode & maps packages to can compare directly

y <- read.csv("epmc_geo_test_2022-05-19.csv", col.names = "id")
y_id <- y$id

t  <- NULL;

for (i in y_id) {
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
  report <- cbind(id, title, abstract, affiliation)
  t <- rbind(t, report)
}

##=========================================##
########## PART 2: Extract Country  ######## 
##=========================================##

z <- t %>%
  group_by(id) %>%
    mutate(no_punc = gsub("[[:punct:]\n]","",affiliation)) %>%
        mutate(split = strsplit(no_punc, " ")) %>%
          mutate(country = lapply(split, function(x)x[which(x %in% world.cities$country.etc)]))

## proof of concept processing... not fit for long term

z <- select(z, 1:4, 7)
z["country"][z["country"] == "character(0)"] <- NA
z <- z %>% unnest_wider(country)

names(z)[names(z)=="...1"] <- "C1"
names(z)[names(z)=="...2"] <- "C2"
names(z)[names(z)=="...3"] <- "C3"
names(z)[names(z)=="...4"] <- "C4"
names(z)[names(z)=="...5"] <- "C5"

z <- z %>%
  group_by(id) %>%
    mutate(country = ifelse(test = (is.na(C2) & is.na(C3) & is.na(C4) & is.na(C5)),
                      yes = C1,
                      no = ifelse(test = (C1 == C2 & is.na(C3) & is.na(C4) & is.na(C5)),
                        yes = C1,
                        no = ifelse(test = (C1 == C2 & C2 == C3 & is.na(C4) & is.na(C5)),
                          yes = C1,
                          no = ifelse(test = (C1 == C2 & C2 == C3 & C3 == C4 & is.na(C5)),
                            yes = C1,
                            no = ifelse(test = (C1 == C2 & C2 == C3 & C3 == C4 & C4 == C5),
                              yes = C1,
                              no = paste0(C1, ", ", C2, ", ", C3, ", ", C4, ", ", C5)))))))

## set up for comparison with A's ePMC algorithm results

## replacements
z$country <- gsub('USA', 'United_States', z$country)
z$country <- gsub('UK', 'United_Kingdom', z$country)

zz <- select(z, 1, 10)
zz <- unique(zz)
zz$country <- gsub('NA', '', zz$country)
zz$country <- gsub(', , , ', '', zz$country)

zzz<- zz %>%
  group_by(id) %>%
    mutate (all_countries = list(country))

zzz <- select(zzz, 1, 3)
h <- unique(zzz)

names(h)[names(h)=="id"] <- "PMID"
h$PMID <- as.integer(h$PMID)
names(h)[names(h)=="all_countries"] <- "h_all_countries"

##====================================================##
######## PART 3: Compare with A's ePMC algorithm  ###### 
##====================================================##

## compare with returns from ePMC algorithm (Arthur's via Aravind)

geo_epmc <- read.csv("epmc_geo_test_V1_results.csv")

ids <- unique(as.data.frame(geo_epmc$PMID))
p <- unique(select(geo_epmc, 1, 11))
p2 <- p %>%
  group_by(PMID) %>%
  mutate (a_all_countries = list(Country))

a <- unique(select(p2, 1, 3)) ##460
a$a_all_countries <- gsub('NULL', NA, a$a_all_countries)

compare_a_h <- full_join(h,a)

library(stringdist)
compare_a_h$match <- ifelse(stringdist(compare_a_h$h_all_countries, compare_a_h$a_all_countries) < 12, "MATCH", "NOT MATCH")

compare_a_h <- apply(compare_a_h,2,as.character)
## write.csv(compare_a_h,"compare_geo_epmc_2022-06-08.csv", row.names = FALSE)


