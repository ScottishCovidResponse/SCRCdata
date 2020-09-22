library(SCRCdataAPI)
library(SCRCdata)

key <- readLines(file.path("", "home", "soniamitchell", "scrc_cron_scripts",
                           "token", "token.txt"))


# Where was the data download from? (original source) ---------------------

original_source_name <- "Scottish Government Open Data Repository"

# Add the website to the data registry (e.g. home page of the database)
original_sourceId <- new_source(
  name = original_source_name,
  abbreviation = "Scottish Government Open Data Repository",
  website = "https://statistics.gov.scot/",
  key = key)

cat("this works", file = "/srv/ftp/scrc/records/SARS-CoV-2/scotland/cases-and-management/test.txt")

