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
library(SCRCdata)

key <- readLines("token.txt")
todays_date <- Sys.time()

# initialise parameters ---------------------------------------------------

product_name <- paste("records", "SARS-CoV-2", "scotland",
              "cases_and_management", sep = "/")

# create version number (this is used to generate the *.csv and *.h5 filenames)
tmp <- as.Date(todays_date, format = "%Y-%m-%d")
version_number <- paste("0", gsub("-", "", tmp), "0" , sep = ".")

# dataset name
doi_or_unique_name <- "scottish coronavirus-covid-19-management-information"

# where was the source data download from? (original source)
source_name <- "Scottish Government Open Data Repository"
original_root <- "https://statistics.gov.scot/sparql.csv?query="
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

# where is the processing script stored?
github_info <- get_package_info(repo = "ScottishCovidResponse/SCRCdata",
                                script = "scotgov_management.R",
                                package = "SCRCdata")




# Additional parameters (automatically generated) -------------------------

namespace <- "SCRC"

# when was the source data downloaded?
source_downloadDate <- todays_date

# when was the data product generated?
script_processingDate <- todays_date

# where is the source data downloaded to? (locally, before being stored)
local_path <- file.path("data-raw", product_name)
source_filename <- paste0(version_number, ".csv")

# where is the data product saved? (locally, before being stored)
processed_path <- file.path("data-raw", product_name)
product_filename <- paste0(version_number, ".h5")



# where is the source data stored?
source_storageRoot <- "boydorr"
source_path <- file.path(product_name, source_filename)

# where is the submission script stored?
script_storageRoot <- "text_file"
submission_text <- paste("R -f", github_info$processing_script)


# where is the data product stored?
product_storageRoot <- "boydorr"
product_path <- product_name



# default data that should be in database ---------------------------------

# original source name
original_sourceId <- new_source(
  name = source_name,
  abbreviation = "Scottish Government Open Data Repository",
  website = "https://statistics.gov.scot/",
  key = key)

# original source root
original_storageRootId <- new_storage_root(
  name = "Scottish Government Open Data Repository",
  root = original_root,
  key = key)

# source data storage root
source_storageRootId <- new_storage_root(name = source_storageRoot,
                                         root = "ftp://boydorr.gla.ac.uk/scrc/",
                                         key = key)

# submission script storage root
script_storageRootId <- new_storage_root(name = script_storageRoot,
                                         root = "https://data.scrc.uk/api/text_file/",
                                         key = key)

# data product storage root
product_storageRootId <- new_storage_root(name = product_storageRoot,
                                          root = "ftp://boydorr.gla.ac.uk/scrc/",
                                          key = key)

# github repo storage root
repo_storageRootId <- new_storage_root(name = github_info$repo_storageRoot,
                                       root = "https://github.com",
                                       key = key)

# namespace
namespaceId <- new_namespace(name = namespace,
                             key = key)



# download source data ----------------------------------------------------

download_from_database(source_root = original_root,
                       source_path = original_path,
                       filename = source_filename,
                       path = local_path)



# upload source metadata to registry --------------------------------------

sourceDataURIs <- upload_source_data(
  doi_or_unique_name = doi_or_unique_name,
  original_source_id = original_sourceId,
  original_root_id = original_storageRootId,
  original_path = original_path,
  local_path = file.path(local_path, source_filename),
  storage_root_id = source_storageRootId,
  target_path = paste(product_name, source_filename, sep = "/"),
  download_date = source_downloadDate,
  version = version_number,
  key = key)



# generate data product ---------------------------------------------------

process_scotgov_management(
  sourcefile = file.path(local_path, source_filename),
  filename = file.path(local_path, product_filename))



# upload data product metadata to the registry ----------------------------

dataProductURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = product_name,
  processed_path = file.path(processed_path, product_filename),
  product_path = paste(product_path, product_filename, sep = "/"),
  version = version_number,
  namespace_id = namespaceId,
  key = key)



# upload submission script metadata to the registry -----------------------

submissionScriptURIs <- upload_submission_script(
  storage_root_id = script_storageRootId,
  hash = openssl::sha1(submission_text),
  text = submission_text,
  run_date = script_processingDate,
  key = key)



# link objects together ---------------------------------------------------

githubRepoURIs <- upload_github_repo(
  storage_root_id = repo_storageRootId,
  repo = github_info$script_gitRepo,
  hash = github_info$github_hash,
  version = github_info$repo_version,
  key = key)

upload_object_links(run_date = script_processingDate,
                    description = paste("Script run to upload and process",
                                           doi_or_unique_name),
                    code_repo_id = githubRepoURIs$repo_objectId,
                    submission_script_id = submissionScriptURIs$script_objectId,
                    inputs = list(sourceDataURIs$source_objectComponentId),
                    outputs = dataProductURIs$product_objectComponentId,
                    key = key)
