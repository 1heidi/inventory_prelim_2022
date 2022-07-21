## Purpose: Check status of extracted urls and retrieve from Wayback Machine urls
## Parts: 1) Check status of extracted urls 2) find archived URLs in Wayback Machine
## Package(s): wayback, dplyr, httr, RCurl
## Input file(s): ner_predictions_sample_2022-07-01.csv
## Output file(s): ner_predictions_sample_URL_check_2022-07-21.csv
## Notes: wayback package is only on Github https://github.com/hrbrmstr/wayback

library(wayback)
library(dplyr)
library(httr)
library(RCurl)

##=====================================##
###### PART 1: Retrieve URL Status ###### 
##=====================================##

sample <- read.csv("ner_predictions_sample_2022-07-01.csv")
sample <- sample[(which(nchar(sample$url_1) > 0)),]
urls <- sample$url_1

## do in batches, takes several hours

urls1 <- urls[1:100]
urls2 <- urls[101:200]
urls3 <- urls[201:300]
urls4 <- urls[301:400]
urls5 <- urls[401:467]

test <- NULL;

for (i in urls1) {
  delayedAssign("do.next", {next})
  r <- tryCatch(RETRY(
    "GET", i,
    times = 5,
    pause_min = 5,
    pause_base = 2), error = function(cond) {
      message(paste("URL issue:", i, sep="\n"))
      message(cond, sep="\n")
      return(NA)
      force(do.next)})
  input_URL <- i
  returnedURL <- r[[1]]
  status_code <- if(is.na(r)) {paste0("fail")} else {r[["status_code"]]}
  report <- cbind(input_URL,returnedURL, status_code)
  test <- as.data.frame(rbind(test, report))
}

for (i in urls2) {
  delayedAssign("do.next", {next})
  r <- tryCatch(RETRY(
    "GET", i,
    times = 5,
    pause_min = 5,
    pause_base = 2), error = function(cond) {
      message(paste("URL issue:", i, sep="\n"))
      message(cond, sep="\n")
      return(NA)
      force(do.next)})
  input_URL <- i
  returnedURL <- r[[1]]
  status_code <- if(is.na(r)) {paste0("fail")} else {r[["status_code"]]}
  report <- cbind(input_URL,returnedURL, status_code)
  test <- as.data.frame(rbind(test, report))
}

for (i in urls3) {
  delayedAssign("do.next", {next})
  r <- tryCatch(RETRY(
    "GET", i,
    times = 5,
    pause_min = 5,
    pause_base = 2), error = function(cond) {
      message(paste("URL issue:", i, sep="\n"))
      message(cond, sep="\n")
      return(NA)
      force(do.next)})
  input_URL <- i
  returnedURL <- r[[1]]
  status_code <- if(is.na(r)) {paste0("fail")} else {r[["status_code"]]}
  report <- cbind(input_URL,returnedURL, status_code)
  test <- as.data.frame(rbind(test, report))
}

for (i in urls4) {
  delayedAssign("do.next", {next})
  r <- tryCatch(RETRY(
    "GET", i,
    times = 5,
    pause_min = 5,
    pause_base = 2), error = function(cond) {
      message(paste("URL issue:", i, sep="\n"))
      message(cond, sep="\n")
      return(NA)
      force(do.next)})
  input_URL <- i
  returnedURL <- r[[1]]
  status_code <- if(is.na(r)) {paste0("fail")} else {r[["status_code"]]}
  report <- cbind(input_URL,returnedURL, status_code)
  test <- as.data.frame(rbind(test, report))
}

for (i in urls5) {
  delayedAssign("do.next", {next})
  r <- tryCatch(RETRY(
    "GET", i,
    times = 5, # the function has other params to tweak its behavior
    pause_min = 5,
    pause_base = 2), error = function(cond) {
      message(paste("URL issue:", i, sep="\n"))
      message(cond, sep="\n")
      return(NA)
      force(do.next)})
  input_URL <- i
  returnedURL <- r[[1]]
  status_code <- if(is.na(r)) {paste0("fail")} else {r[["status_code"]]}
  report <- cbind(input_URL,returnedURL, status_code)
  test <- as.data.frame(rbind(test, report))
}

write.csv(test,"ner_predictions_sample_URL_check_2022-07-21.csv", row.names = FALSE) 

##=========================================================##
###### PART 2: Find Archived URLs from Wayback Machine ###### 
##=========================================================##

wayback<- NULL

for (url in urls1) {
  response <- archive_available(url)
  wayback <- bind_rows(wayback, response)
}

for (url in urls2) {
  response <- archive_available(url)
  wayback <- bind_rows(wayback, response)
}

for (url in urls3) {
  response <- archive_available(url)
  wayback <- bind_rows(wayback, response)
}

for (url in urls4) {
  response <- archive_available(url)
  wayback <- bind_rows(wayback, response)
}

for (url in urls5) {
  response <- archive_available(url)
  wayback <- bind_rows(wayback, response)
}
 
## join and analyze

t <- left_join(test, wayback, by = c("input_URL" = "url"))
t <- select(t, 1, 3, 5, 6)

names(t)[names(t)=="input_URL"] <- "extracted_url"
names(t)[names(t)=="status_code"] <- "extracted_url_status"
names(t)[names(t)=="closet_url"] <- "wayback_url" ## [sic] closet
names(t)[names(t)=="timestamp"] <- "wayback_url_timestamp"

write.csv(t,"ner_predictions_sample_URL_check_2022-07-21.csv", row.names = FALSE) 

