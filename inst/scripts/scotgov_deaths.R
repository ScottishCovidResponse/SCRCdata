#' scottish deaths-involving-coronavirus-covid-19
#'
#' This dataset presents the weekly, and year to date, provisional number of
#' deaths associated with coronavirus (COVID-19) alongside the total number
#' of deaths registered in Scotland, broken down by age, sex. (From: https://statistics.gov.scot/data/deaths-involving-coronavirus-covid-19)
#'

library(SCRCdataAPI)
library(SPARQL)
library(dplyr)
library(devtools)



# initialise --------------------------------------------------------------


# Source data

key <- read.table("token.txt")
sourceData <- "scottish deaths-involving-coronavirus-covid-19"
sourceVersion <- 0

dataSource <- "Scottish Government Open Data Repository"
endpoint <- "https://statistics.gov.scot/sparql.csv?query="
query <- "PREFIX qb: <http://purl.org/linked-data/cube#>
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

sourceDownloadDate <- as.POSIXct("2010-07-09 12:00:00", format = "%Y-%m-%d %H:%M:%S")
localSourcePath <- file.path("data-raw",
                             "v0.1.0.csv")

sourceStorageRoot <- "boydorr"
targetSourcePath <- file.path("human", "infection", "SARS-CoV-2", "scotland",
                              "mortality",
                              "v0.1.0.csv")

# Processing script

scriptStorageRoot <- "github"
scriptGitRepo <- "ScottishCovidResponse/SCRCdata"
h5filename <- "v0.1.0.h5"

# Data product

productStorageRoot <- "boydorr"
path <- file.path("human", "infection", "SARS-CoV-2", "scotland",
                  "mortality")
namespace <- "SCRC"
productVersion <- "0.1.0"



# check -------------------------------------------------------------------

# Check whether dataSource exists in the registry
if(!check_exists("source", list(name = dataSource))) {
  sourceId <- new_source(
    name = "Scottish Government Open Data Repository",
    abbreviation = "Scottish Government Open Data Repository",
    website = "https://statistics.gov.scot/",
    key = key)
}

# Check whether sourceStorageRoot exists in the registry
if(!check_exists("storage_root", list(name = sourceStorageRoot))) {
  storageRootId <- new_storage_root(name = "boydorr",
                                    root = "ftp://boydorr.gla.ac.uk/scrc/",
                                    key = key)
}

# Check whether scriptStorageRoot exists in the registry
if(!check_exists("storage_root", list(name = scriptStorageRoot))) {
  storage_rootId <- new_storage_root(name = "github",
                                     root = "https://github.com",
                                     key = key)
}

# Check whether productStorageRoot exists in the registry
if(!check_exists("storage_root", list(name = productStorageRoot))) {
  storage_rootId <- new_storage_root(name = productStorageRoot,
                                     root = "ftp://boydorr.gla.ac.uk/scrc/",
                                     key = key)
}

# Check whether namespace exists in the registry
if(!check_exists("namespace", list(name = namespace))) {
  namespaceId <- new_namespace(name = namespace,
                               key = key)
}



# source data -------------------------------------------------------------

# 1. upload original source metadata to registry
# 2. download source data
# 3. upload source data to store
# 4. upload source data metadata to registry
externalObjectId <- upload_source_data(
  dataset = sourceData,
  source = dataSource,
  source_root = endpoint,
  source_path = query,
  local_path = localSourcePath,
  storage_root = sourceStorageRoot,
  target_path = targetSourcePath,
  download_date = sourceDownloadDate,
  version = sourceVersion,
  key = key)



# processing script -------------------------------------------------------

# 1. upload processing script metadata to the registry
# 2. run processing script (not done yet)
processingScriptId <- upload_processing_script(storage_root = scriptStorageRoot,
                                               path = scriptGitRepo,
                                               key = key)

# Process data and generate hdf5 file
process_scot_gov_deaths(sourcefile = localSourcePath,
                        h5filename = h5filename)



# data product ------------------------------------------------------------

upload_data_product(storage_root = productStorageRoot,
                    path = path,
                    dataset = dataset,
                    filename = h5filename,
                    version = productVersion,
                    key = key)



