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


# initialise --------------------------------------------------------------

# misc
key <- read.table("token.txt")
namespace <- "SCRC"
doi_or_unique_name <- "scottish coronavirus-covid-19-management-information"
version <- 0
path <- paste("human", "infection", "SARS-CoV-2", "scotland",
              "cases_and_management", sep = "/")

# original source
dataset_name <- "Scottish Government Open Data Repository"
original_path <- "PREFIX qb: <http://purl.org/linked-data/cube#>
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
source_downloadDate <- as.POSIXct("2010-07-11 12:15:00",
                                  format = "%Y-%m-%d %H:%M:%S")

# source data storage
source_storageRoot <- "boydorr"

# processing script storage
script_storageRoot <- "github"
script_gitRepo <- "ScottishCovidResponse/SCRCdata"

# data product storage
product_storageRoot <- "boydorr"



# default data that should be in database ---------------------------------

original_storageRootId <- new_storage_root(
  name = "Scottish Government Open Data Repository",
  root = "https://statistics.gov.scot/sparql.csv?query=",
  key = key)

original_sourceId <- new_source(
  name = dataset_name,
  abbreviation = "Scottish Government Open Data Repository",
  website = "https://statistics.gov.scot/",
  key = key)

source_storageRootId <- new_storage_root(name = source_storageRoot,
                                         root = "ftp://boydorr.gla.ac.uk/scrc/",
                                         key = key)

script_storageRootId <- new_storage_root(name = script_storageRoot,
                                         root = "https://github.com",
                                         key = key)

product_storageRootId <- new_storage_root(name = product_storageRoot,
                                          root = "ftp://boydorr.gla.ac.uk/scrc/",
                                          key = key)

namespaceId <- new_namespace(name = namespace,
                             key = key)



# download source data ----------------------------------------------------

tmp <- as.Date(source_downloadDate, format = "%Y-%m-%d")
day_version <- paste(gsub("-", "", tmp), version , sep = ".")
local_sourcePath <- file.path("data-raw", path)
source_filename <- paste0(day_version, ".csv")

download_from_database(original_root,
                       original_path,
                       filename = source_filename,
                       path = local_sourcePath)

# upload source metadata to registry --------------------------------------

externalObjectId <- upload_source_data(
  doi_or_unique_name = doi_or_unique_name,
  original_source_id = original_sourceId,
  original_root_id = original_storageRootId,
  original_path = original_path,
  local_path = file.path(local_sourcePath, source_filename),
  storage_root_id = source_storageRootId,
  target_path = paste(path, source_filename, sep = "/"),
  download_date = source_downloadDate,
  version = day_version,
  key = key)



# upload processing script metadata to the registry -----------------------

# processingScriptId <- upload_processing_script(storage_root = script_storageRootId,
#                                                path = script_gitRepo,
#                                                key = key)



# generate data product ---------------------------------------------------

product_filename <- paste0(product_version, ".h5")

process_scotgov_management(
  sourcefile = file.path(local_sourcePath, source_filename),
  h5filename = file.path(local_sourcePath, product_filename))

# ** upload this to boydorr server **


# upload data product metadata to the registry ----------------------------

upload_data_product(
  storage_root_id = product_storageRootId,
  path = path,
  name = product_name,
  component_name = NA,
  filename = product_filename,
  version = product_version,
  namespace_id = namespaceId,
  key = key)

