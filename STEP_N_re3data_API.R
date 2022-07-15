## Purpose: Extract db records for biodata resources from re3data API
## Parts: 1) Retrieve all records 2) filter to life science only
## Package(s): httr, xml2, dplyr, tidyr
## Output file(s): re3data_life_sci_2022-07-15.csv
## Note: correct schema (2.2) is here: https://gfzpublic.gfz-potsdam.de/pubman/faces/ViewItemOverviewPage.jsp?itemId=item_758898
## https://www.re3data.org/api/doc
## Scripts found at: https://github.com/re3data/using_the_re3data_API/blob/main/re3data_API_certification_by_type.ipynb

library(httr)
library(xml2)
library(dplyr)
library(tidyr)

##=======================================================##
######### PART 1: Retrieve Records from re3data.org ####### 
##=======================================================##

re3data_request <- GET("http://re3data.org/api/v1/repositories")
re3data_IDs <- xml_text(xml_find_all(read_xml(re3data_request), xpath = "//id"))
URLs <- paste("https://www.re3data.org/api/v1/repository/", re3data_IDs, sep = "")

extract_repository_info <- function(url) {
  list(
    re3data_ID = xml_text(xml_find_all(repository_metadata_XML, "//r3d:re3data.orgIdentifier")),
    type = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:type"))), collapse = "_AND_"),
    certificate = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:certificate"))), collapse = "_AND_"),
    repositoryURL = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:repositoryURL"))), collapse = "_AND_"),
    repositoryName = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:repositoryName"))), collapse = "_AND_"),
    subject = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:subject"))), collapse = "_AND_"),
    providerType = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:providerType"))), collapse = "_AND_"),
    dataLicenseName = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:dataLicenseName"))), collapse = "_AND_"),
    databaseAccessType = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:databaseAccessType"))), collapse = "_AND_"),
    dataAccessType = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:dataAccessType"))), collapse = "_AND_"),
    policyName = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:policyName"))), collapse = "_AND_"),
    description = paste(unique(xml_text(xml_find_all(repository_metadata_XML, "//r3d:description"))))
  )
}

repository_info <- data.frame(matrix(ncol = 12, nrow = 0))
colnames(repository_info) <- c("re3data_ID","repositoryName", "repositoryURL", "subject", "description", "type", "providerType", "certificate", "dataLicenseName", ",databaseAccessType", "dataAccessType", "policyName")

for (url in URLs) {
  repository_metadata_request <- GET(url)
  repository_metadata_XML <-read_xml(repository_metadata_request) 
  results_list <- extract_repository_info(repository_metadata_XML)
  repository_info <- rbind(repository_info, results_list)
}

##if want to save all repos, save file here

##=========================================================##
######### PART 2: Filter to Life Science records only ####### 
##=========================================================##

## Notes:
## 1) filter down to only life science (domain focused), but do not remove service providers as many are data resources
## 2) many nat sci look to be life sci too, but not all - to stay consistent for the comparison with GBCI and FAIRsharing, restricting to Life Science only

life_sci_re3data <- filter(repository_info, grepl("Life", subject))

## remove any strictly institutional as these are too general purpose and any that are "other" as most of these could not count for the GBC Inventory either (e.g. city data portals and generalist non-institutional repos like figshare)
life_sci_re3data <- filter(life_sci_re3data, life_sci_re3data$type != "institutional")
life_sci_re3data <- filter(life_sci_re3data, life_sci_re3data$type != "other")

write.csv(life_sci_re3data,"re3data_life_sci_2022-07-15.csv", row.names = FALSE) 

##what was removed - this looks basically correct
removed <- anti_join(repository_info, life_sci_re3data)



