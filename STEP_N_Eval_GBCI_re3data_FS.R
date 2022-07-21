## Purpose: Cross check FAIRsharing and re3data via Resource Names and URLs
## Parts: 1) prep and clean data 2) compare with re3data and FAIRsharing
## Package(s): tidyverse
## Input file(s): ner_predictions_all_reshape_2022-07-01.csv, fairsharing_life_sci_2022-07-14.csv, re3data_life_sci_2022-07-15.csv
## Output file(s):

library(tidyverse)
library(stringr)
library(urltools)

##=====================================================##
########## PART 1: Prep and clean data frames  ########## 
##=====================================================##

## Includes removing white space and cleaning urls, otherwise those that end with a "/" or differ only between "http" vs "https" will be missed matches

## Prep predicted GBC inventory resources
## --------------------------------------

pred <- read.csv("ner_predictions_all_reshape_2022-07-01.csv")
pred <- select(pred, 1, 37, 23)

## trim white space
pred %>% 
  mutate(across(where(is.character), str_trim))

## remove any blank urls
pred <- pred[(which(nchar(pred$url_1) > 0)),]

## clean urls
pred$url_1 <- sub("^http://(?:www[.])", "\\1", pred$url_1)
pred$url_1 <- sub("^https://(?:www[.])", "\\1", pred$url_1)
pred$url_1 <- sub("^http://", "\\1", pred$url_1)
pred$url_1 <- sub("^https://", "\\1", pred$url_1)
pred$url_1 <- sub("/$", "", pred$url_1)

## remove 1 character names
pred <- pred[(which(nchar(pred$best_name_overall) > 1)),]

## for pred only, must also de-duplicate when both names and urls are the same (gather article IDs for these)

pred <- pred %>% 
  group_by(best_name_overall, url_1) %>% 
   mutate(IDs = paste0(ID, collapse = ", "))

pred <- select(pred, -1)
pred <- pred[, c(3, 1, 2)]
pred <- ungroup(pred)
pred <- unique(pred)

## Prep re3data Life Science Repos
## -------------------------------

re3d <- read.csv("re3data_life_sci_2022-07-15.csv")
re3d <- select(re3d, 1, 5, 4)

## trim white space
re3d %>% 
  mutate(across(where(is.character), str_trim))

## remove any blank urls
re3d <- re3d[(which(nchar(re3d$repositoryURL) > 0)),]

## clean urls
re3d$repositoryURL <- sub("^http://(?:www[.])", "\\1", re3d$repositoryURL)
re3d$repositoryURL <- sub("^https://(?:www[.])", "\\1", re3d$repositoryURL)
re3d$repositoryURL <- sub("^http://", "\\1", re3d$repositoryURL)
re3d$repositoryURL <- sub("^https://", "\\1", re3d$repositoryURL)
re3d$repositoryURL <- sub("/$", "", re3d$repositoryURL)

## Prep FAIRsharing Life Science Repos
## -----------------------------------

fs <- read.csv("fairsharing_life_sci_2022-07-14.csv")
fs <- select(fs, 1:3)

## trim white space
fs %>% 
  mutate(across(where(is.character), str_trim)) 

## remove any blank urls
fs <- fs[(which(nchar(fs$url) > 0)),]

## clean urls
fs$url <- sub("^http://(?:www[.])", "\\1", fs$url)
fs$url <- sub("^https://(?:www[.])", "\\1", fs$url)
fs$url <- sub("^http://", "\\1", fs$url)
fs$url <- sub("^https://", "\\1", fs$url)
fs$url <- sub("/$", "", fs$url)

##==============================================================##
########## PART 2: Compare with re3data and FAIRsharing ########## 
##==============================================================##

names_pred_re3d <- inner_join(pred, re3d, by = c("best_name_overall" = "repositoryName"))
urls_pred_re3d <- inner_join(pred, re3d, by = c("url_1" = "repositoryURL"))

names_pred_fs <- inner_join(pred, fs, by = c("best_name_overall" = "name"))
urls_pred_fs <- inner_join(pred, fs, by = c("url_1" = "url"))

