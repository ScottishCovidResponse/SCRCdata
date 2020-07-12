#' coronavirus-covid-19-management-information
#'
#' This dataset presents Management Information, which is collected and
#' distributed each day in order to support understanding of the progress
#' of the outbreak in Scotland. (From: https://statistics.gov.scot/data/coronavirus-covid-19-management-information)
#'
#' Definitions found here:
#' https://www.gov.scot/publications/coronavirus-covid-19-data-definitions-and-sources/
#'

library(SCRCdataAPI)
library(SPARQL)
library(dplyr)
library(devtools)


# initialise --------------------------------------------------------------


# Source data

key <- read.table("token.txt")
sourceData <- "scottish coronavirus-covid-19-management-information"
sourceVersion <- 0

dataSource <- "Scottish Government Open Data Repository"
endpoint <- "https://statistics.gov.scot/sparql.csv?query="
query <- "PREFIX qb: <http://purl.org/linked-data/cube#>
PREFIX data: <http://statistics.gov.scot/data/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mp: <http://statistics.gov.scot/def/measure-properties/>
PREFIX dim: <http://purl.org/linked-data/sdmx/2009/dimension#>
PREFIX sdim: <http://statistics.gov.scot/def/dimension/>
PREFIX stat: <http://statistics.data.gov.uk/def/statistical-entity#>
SELECT ?featurecode ?featurename ?date ?measure ?variable ?count
WHERE {
  ?indicator qb:dataSet data:coronavirus-covid-19-management-information;
              dim:refArea ?featurecode;
              dim:refPeriod ?period;
              sdim:variable ?varname;
              qb:measureType ?type.
{?indicator mp:count ?count.} UNION {?indicator mp:ratio ?count.}

  ?featurecode <http://publishmydata.com/def/ontology/foi/displayName> ?featurename.
  ?period rdfs:label ?date.
  ?varname rdfs:label ?variable.
  ?type rdfs:label ?measure.
}"

sourceDownloadDate <- as.POSIXct("2010-07-11 12:15:00", format = "%Y-%m-%d %H:%M:%S")
localSourcePath <- file.path("data-raw",
                             "coronavirus-covid-19-management-information.csv")

sourceStorageRoot <- "boydorr"
targetSourcePath <- file.path("human", "infection", "SARS-CoV-2", "scotland",
                              "cases_and_management",
                              "v0.1.0.csv")

# Processing script

scriptStorageRoot <- "github"
scriptGitRepo <- "ScottishCovidResponse/SCRCdata"
h5filename <- "v0.1.0.h5"

# Data product

productStorageRoot <- "boydorr"
path <- file.path("human", "infection", "SARS-CoV-2", "scotland",
                   "cases_and_management")
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
process_scotgov_management(sourcefile = localSourcePath,
                           h5filename = h5filename)


# data product ------------------------------------------------------------

upload_data_product(storage_root = productStorageRoot,
                    path = path,
                    dataset = dataset,
                    filename = h5filename,
                    version = productVersion,
                    key = key)



