## Purpose: Evaluate NER Predictions
## Parts: 1) Find the best names for the resources across predicted names, 2) plotting, sanity checks, and sampling, 3) evaluate manual review of sample
## Package(s): tidyverse
## Input file(s): ner_predictions_all_raw_2022-06-18.csv
## Output file(s): eval_predictions_all_2022-07-01.csv, eval_predictions_sample_2022-07-01.csv

library(tidyverse)

##=======================================================##
########## PART 1: Find ~ best matches for names ########## 
##=======================================================##

pred <- read.csv("ner_predictions_all_raw_2022-06-18.csv")

## separate lists using an overestimated # of potential names/urls
pred <- separate(pred, 'common_name', paste("common_name", 1:10, sep="_"), sep=",", extra="drop")
pred <- separate(pred, 'common_prob', paste("common_prob", 1:10, sep="_"), sep=",", extra="drop")
pred <- separate(pred, 'full_name', paste("full_name", 1:10, sep="_"), sep=",", extra="drop")
pred <- separate(pred, 'full_prob', paste("full_prob", 1:10, sep="_"), sep=",", extra="drop")
pred <- separate(pred, 'url', paste("url", 1:20, sep="_"), sep=",", extra="drop")

## remove all NA columns (excess from overestimates)
pred <- pred[,colSums(is.na(pred))<nrow(pred)]

## convert probability columns to numeric

pred[, c(8:12, 18:22)] <- sapply(pred[, c(8:12, 18:22)],as.numeric)

## find best returns
pred$max_common_name_prob <- do.call(pmax, c(pred[8:12], list(na.rm=TRUE)))
pred$max_full_name_prob <- do.call(pmax, c(pred[18:22], list(na.rm=TRUE)))
pred$max_either_prob <- do.call(pmax, c(pred[32:33], list(na.rm=TRUE)))

## fine best common name
pred <- pred %>%
  group_by(ID) %>%
    mutate(best_common_name = ifelse(test = (common_prob_1 == max_common_name_prob), 
      yes = common_name_1,
      no = ifelse(test = (common_prob_2 == max_common_name_prob), 
          yes = common_name_2,
          no = ifelse(test = (common_prob_3 == max_common_name_prob), 
              yes = common_name_3,
              no = ifelse(test = (common_prob_4 == max_common_name_prob), 
                  yes = common_name_4,
                  no = ifelse(test = (common_prob_5 == max_common_name_prob), 
                      yes = common_name_5,
                      no = "fail"))))))

## fine best full name
pred <- pred %>%
  group_by(ID) %>%
  mutate(best_full_name = ifelse(test = (full_prob_1 == max_full_name_prob), 
    yes = full_name_1,
    no = ifelse(test = (full_prob_2 == max_full_name_prob), 
        yes = full_name_2,
        no = ifelse(test = (full_prob_3 == max_full_name_prob), 
          yes = full_name_3,
          no = ifelse(test = (full_prob_4 == max_full_name_prob), 
            yes = full_name_4,
            no = ifelse(test = (full_prob_5 == max_full_name_prob), 
              yes = full_name_5,
              no = "fail"))))))

## find best between common and full name since a single name will be needed for annotations
pred <- pred %>%
  group_by(ID) %>%
    mutate(best_name_overall = ifelse(test = is.na(max_full_name_prob), 
        yes = best_common_name,
        no = ifelse(test = is.na(max_common_name_prob), 
              yes = best_full_name,
              no = ifelse(test = (max_common_name_prob > max_full_name_prob), 
                                    yes = best_common_name,
                                    no = best_full_name))))

## determine which type of name was best (for the sake of reporting) 

pred <- pred %>%
  group_by(ID) %>%
  mutate(best_name_type = ifelse(test = is.na(best_common_name), 
                          yes = "FULL",
                          no = ifelse(test = (best_common_name == best_name_overall),
                                             yes = "COMMON", 
                                             no = "FULL")))

pred <- ungroup(pred)

##===============================================================##
########## PART 2: Plotting, sanity checks, and sampling ########## 
##===============================================================##

## check redundancy
ids <- unique(pred$ID)  ## no duplicates

## look at various breakdowns
pred_high <- filter(pred, max_either_prob > 0.95) ## 3942/4680 = 84%
pred_very_high <- filter(pred, max_either_prob > 0.99) ## 3333/4680 = 71%
pred_very_very_high <- filter(pred, max_either_prob > 0.995) ## 2935/4680 = 63%

## plot 
hist(as.numeric(pred$max_either_prob))

## count multi-url records
check <- sum(is.na(pred$url_2)) ## (4680-4316)/4680 = 7.7%

## clean up white space
pred$best_full_name <- trimws(pred$best_full_name)
pred$best_common_name <- trimws(pred$best_common_name)
pred$best_name_overall <- trimws(pred$best_name_overall)

## create sample for evaluation
slice <- sample_frac(pred, 0.1)

## save files
write.csv(pred,"ner_predictions_all_reshape_2022-07-01.csv", row.names = FALSE)
write.csv(slice,"ner_predictions_sample_2022-07-01.csv", row.names = FALSE)

##==========================================================##
########## PART 3: Evaluate manual review of sample ########## 
##==========================================================##

pred <- read.csv("ner_predictions_all_reshape_2022-07-01.csv")

hji <- read.csv("ner_predictions_sample_hji_2022-07-01_V4.csv")
hji2 <- select(hji, 1, 2, 32:45)

class_count <- count(hji2, hji_classification)
common_count <- count(hji2, hji_best_common)
full_count <- count(hji2, hji_best_full)

test <- hji2 %>% 
  group_by(hji_best_common) %>%
      mutate(mean_prob = mean(na.omit(max_common_name_prob)))

test2 <- unique(select(test, hji_best_common, mean_prob))
test3 <- filter(test, best_name_type == "COMMON")
test4 <- filter(test3, hji_best_common != "CORRECT")

above <- filter(hji2, max_either_prob > 0.9780) 

library(ggplot2)

p <- ggplot(hji2, aes(x=hji_best_common, y=max_common_name_prob)) + 
  geom_violin()
p + stat_summary(fun.y=median, geom="point", size=2, color="red")

