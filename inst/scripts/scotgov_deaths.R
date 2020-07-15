#' scottish deaths-involving-coronavirus-covid-19
#'
#' This dataset presents the weekly, and year to date, provisional number of
#' deaths associated with coronavirus (COVID-19) alongside the total number
#' of deaths registered in Scotland, broken down by age, sex. (From: https://statistics.gov.scot/data/deaths-involving-coronavirus-covid-19)
#'

library(SCRCdataAPI)
library(SCRCdata)


# initialise parameters ---------------------------------------------------

key <- read.table("token.txt")
namespace <- "SCRC"

doi_or_unique_name <- "scottish scottish deaths-involving-coronavirus-covid-19"

product_name <- paste("human", "infection", "SARS-CoV-2", "scotland",
                      "mortality", sep = "/")

todays_date <- as.POSIXct("2020-07-15 17:46:00",
                          format = "%Y-%m-%d %H:%M:%S")
version <- 0

# where was the source data download from? (original source)
dataset_name <- "Scottish Government Open Data Repository"
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

# where is the processing script stored?
repo_storageRoot <- "github"
script_gitRepo <- "ScottishCovidResponse/SCRCdata"
repo_version <- "0.1.0"





# Additional parameters (automatically generated) -------------------------

# when was the source data downloaded?
source_downloadDate <- todays_date

# when was the data product generated?
script_processingDate <- todays_date

# create version number (this is used to generate the *.csv and *.h5 filenames)
tmp <- as.Date(todays_date, format = "%Y-%m-%d")
version_number <- paste(gsub("-", "", tmp), version , sep = ".")

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
script_storageRoot <- "boydorr"
script_filename <- "exec.sh"
script_path <- file.path(product_name, script_filename)

# where is the data product stored?
product_storageRoot <- "boydorr"
product_path <- file.path(product_name, product_filename)



# default data that should be in database ---------------------------------

# original source name
original_sourceId <- new_source(
  name = dataset_name,
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
                                         root = "ftp://boydorr.gla.ac.uk/scrc/",
                                         key = key)

# data product storage root
product_storageRootId <- new_storage_root(name = product_storageRoot,
                                          root = "ftp://boydorr.gla.ac.uk/scrc/",
                                          key = key)

# github repo storage root
repo_storageRootId <- new_storage_root(name = repo_storageRoot,
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
  version = version,
  key = key)



# generate data product ---------------------------------------------------

scriptURIs <- process_scotgov_deaths(
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



# upload processing script metadata to the registry -----------------------

submissionScriptURIs <- upload_submission_script(
  storage_root_id = script_storageRootId,
  path = script_path,
  hash = get_github_hash(script_gitRepo),
  run_date = script_processingDate,
  key = key)



# link objects together ---------------------------------------------------

githubRepoURIs <- upload_github_repo(
  storage_root_id = script_storageRootId,
  repo = script_gitRepo,
  hash = get_github_hash(script_gitRepo),
  version = repo_version,
  key = key)

upload_object_links(run_date = script_processingDate,
                    run_identifier = paste("Script run to upload and process",
                                           doi_or_unique_name),
                    code_repo_id = githubRepoURIs$repo_objectId,
                    submission_script_id = submissionScriptURIs$script_objectId,
                    inputs = list(sourceDataURIs$source_objectComponentId),
                    outputs = dataProductURIs$product_objectComponentId,
                    key = key)


