library(RCurl)
library(jsonlite)
library(tidyverse)
library(data.table)
library(httr)

##sign in

url<-'https://api.fairsharing.org/users/sign_in'
request <- POST(url,
              add_headers(
                "Content-Type"="application/json",
                "Accept"="application/json"),
              body="{\"user\": {\"login\":\"imker@illinois.edu\",\"password\":\"123fair-456data\"} }")
con<-jsonlite::fromJSON(rawToChar(request$content))
auth<-con$jwt

query_url<-"https://api.fairsharing.org/search?fairsharingRegistry=Database"

get_res<-GET(
  query_url,
  add_headers(
    "Content-Type"="application/json",
    "Accept"="application/json",
    "Authorization"=paste0("Bearer ",auth,sep="")
  )
)

query_con<-fromJSON(rawToChar(get_res$content))
#4. see results
data<-query_con$data