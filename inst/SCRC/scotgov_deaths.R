#' scottish deaths-involving-coronavirus-covid-19
#'
#' This dataset presents the weekly, and year to date, provisional number of
#' deaths associated with coronavirus (COVID-19) alongside the total number
#' of deaths registered in Scotland, broken down by age, sex. (From: https://statistics.gov.scot/data/deaths-involving-coronavirus-covid-19)
#'

library(SCRCdataAPI)
library(SCRCdata)


# Go to data.scrc.uk, click on Links, then Generate API Token, and save your
# token in your working directory as token.txt. If the following returns an
# error, then save a carriage return after the token.
key <- readLines("token/token.txt")


# Define data set ---------------------------------------------------------

# doi_or_unique_name is a free text field specifying the name of your dataset
doi_or_unique_name <- "scottish deaths-involving-coronavirus-covid-19"

# version_number is used to generate the source data and data product
# filenames, e.g. 0.20200716.0.csv and 0.20200716.0.h5 for data that is
# downloaded daily, or 0.1.0.csv and 0.1.0.h5 for data that is downloaded once
todays_date <- Sys.time()
tmp <- as.Date(todays_date, format = "%Y-%m-%d")
version_number <- paste("0", gsub("-", "", tmp), "0" , sep = ".")
source_filename <- paste0(version_number, ".csv")
product_filename <- paste0(version_number, ".h5")

# product_name is used to identify the data product as well as being used to
# generate various file locations:
# (1) source data is downloaded, then saved locally to data-raw/[product_name]
# (2) source data should be stored on the Boydorr server at
# ../../srv/ftp/scrc/[product_name]
# (3) data product is processed, then saved locally to data-raw/[product_name]
# (4) data product should be stored on the Boydorr server at
# ../../srv/ftp/scrc/[product_name]
product_name <- "records/SARS-CoV-2/scotland/human-mortality"
# Construct the path to a file in a platform independent way
product_path <- do.call(file.path, as.list(strsplit(product_name, "/")[[1]]))
namespace <- "SCRC"


# Where was the data download from? (original source) ---------------------

original_source_name <- "Scottish Government Open Data Repository"

# Add the website to the data registry (e.g. home page of the database)
original_sourceId <- new_source(
  name = original_source_name,
  abbreviation = "Scottish Government Open Data Repository",
  website = "https://statistics.gov.scot/",
  key = key)

# Note that file.path(original_root, original_path) is the download link.
# Examples of downloading data from a database rather than a link, can be
# found in the scotgov_deaths or scotgov_management scripts
original_root <- "https://statistics.gov.scot/sparql.csv?query="
original_path <- "PREFIX qb: <http://purl.org/linked-data/cube#>
PREFIX data: <http://statistics.gov.scot/data/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dim: <http://purl.org/linked-data/sdmx/2009/dimension#>
PREFIX sdim: <http://statistics.gov.scot/def/dimension/>
PREFIX stat: <http://statistics.data.gov.uk/def/statistical-entity#>
PREFIX mp: <http://statistics.gov.scot/def/measure-properties/>
SELECT ?featurecode ?featurename ?areatypename ?date ?cause ?location ?gender ?age ?type ?count
WHERE {
  ?indicator qb:dataSet data:deaths-involving-coronavirus-covid-19;
              mp:count ?count;
              qb:measureType ?measType;
              sdim:age ?value;
              sdim:causeofdeath ?causeDeath;
              sdim:locationofdeath ?locDeath;
              sdim:sex ?sex;
              dim:refArea ?featurecode;
              dim:refPeriod ?period.

              ?measType rdfs:label ?type.
              ?value rdfs:label ?age.
              ?causeDeath rdfs:label ?cause.
              ?locDeath rdfs:label ?location.
              ?sex rdfs:label ?gender.
              ?featurecode stat:code ?areatype;
                rdfs:label ?featurename.
              ?areatype rdfs:label ?areatypename.
              ?period rdfs:label ?date.
}"


# Where is the submission script stored? ----------------------------------

# This template is an example of a submission script.
# The submission script should download the source data, generate a data
# product, and upload all associated metadata to the data registry.
# This script assumes you will store your submission script in the
# ScottishCovidResponse/SCRCdata repository within the inst/[namespace]/
# directory

submission_script <- "scotgov_deaths.R"


# download source data ----------------------------------------------------

download_from_database(source_root = original_root,
                       source_path = original_path,
                       filename = source_filename,
                       path = file.path("data-raw", product_path))


# convert source data into a data product ---------------------------------

process_scotgov_deaths(
  sourcefile = file.path("data-raw", product_path, source_filename),
  filename = file.path("data-raw", product_path, product_filename))

# register metadata with the data registry --------------------------------

register_everything(product_name = product_name,
                    version_number = version_number,
                    doi_or_unique_name = doi_or_unique_name,
                    namespace = namespace,
                    submission_script = submission_script,
                    original_source_name = original_source_name,
                    original_sourceId = original_sourceId,
                    original_root = original_root,
                    original_path = original_path,
                    key = key)
