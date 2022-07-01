## Purpose: Evaluate NER Predictions
## Parts: 1) Find the best names for the resources across predicted names 2) plotting, sanity checks, and sampling
## Package(s): tidyverse
## Input file(s): predictions_2022-06-18.csv
## Output file(s): eval_predictions_all_2022-07-01.csv, eval_predictions_sample_2022-07-01.csv

library(tidyverse)

##=======================================================##
########## PART 1: Find ~ best matches for names ########## 
##=======================================================##

pred <- read.csv("predictions_2022-06-18.csv")

## separate lists using overestimates potential names/urls
pred <- separate(pred, 'common_name', paste("common_name", 1:10, sep="_"), sep=",", extra="drop")
pred <- separate(pred, 'common_prob', paste("common_prob", 1:10, sep="_"), sep=",", extra="drop")
pred <- separate(pred, 'full_name', paste("full_name", 1:10, sep="_"), sep=",", extra="drop")
pred <- separate(pred, 'full_prob', paste("full_prob", 1:10, sep="_"), sep=",", extra="drop")
pred <- separate(pred, 'url', paste("url", 1:20, sep="_"), sep=",", extra="drop")

## remove all NA columns (excess from overestimates)
pred <- pred[,colSums(is.na(pred))<nrow(pred)]

## convert to numeric
pred$common_prob_1 <- as.numeric(pred$common_prob_1)
pred$common_prob_2 <- as.numeric(pred$common_prob_2)
pred$common_prob_3 <- as.numeric(pred$common_prob_3)
pred$common_prob_4 <- as.numeric(pred$common_prob_4)
pred$common_prob_5 <- as.numeric(pred$common_prob_5)

pred$full_prob_1 <- as.numeric(pred$full_prob_1)
pred$full_prob_2 <- as.numeric(pred$full_prob_2)
pred$full_prob_3 <- as.numeric(pred$full_prob_3)
pred$full_prob_4 <- as.numeric(pred$full_prob_4)
pred$full_prob_5 <- as.numeric(pred$full_prob_5)

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

## find best between common and full name sincer a single name will be needed for annotations
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
## NOTE for the life of me I can't figure out why I'm still getting NAs...
pred <- pred %>%
  group_by(ID) %>%
      mutate(best_name_type = ifelse(test = (best_common_name == best_name_overall), 
                              yes = "COMMON",
                              no = ifelse(test = is.na(best_common_name),
                                          yes = "FULL", 
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
write.csv(pred,"eval_predictions_all_2022-07-01.csv", row.names = FALSE)
write.csv(slice,"eval_predictions_sample_2022-07-01.csv", row.names = FALSE)



