#' dataset-name
#'
#' Dataset description and link to source
#'

library(SCRCdataAPI)
library(SCRCdata)


# Download a key from https://data.scrc.uk and store it somewhere safe!
key <- read.table("token.txt")


# The product_name is used to identify the data product and will be used to
# generate various file locations:
# (1) source data is downloaded locally to data-raw/[product_name]
# (2) source data is stored on the Boydorr server at
# ../../srv/ftp/scrc/[product_name]
# (3) data product is saved locally (after processing) to data-raw/[product_name]
# (4) data product is stored on the Boydorr server at
# ../../srv/ftp/scrc/[product_name]
product_name <- paste("human", "infection", "SARS-CoV-2", "scotland",
                      "cases_and_management", sep = "/")

# The following information is used to generate the source data and data
# product filenames, e.g. 20200716.0.csv and 20200716.0.h5
todays_date <- as.POSIXct("2020-07-16 11:26:00",
                          format = "%Y-%m-%d %H:%M:%S")
version <- 0

# This is the name of your dataset
doi_or_unique_name <- "scottish coronavirus-covid-19-management-information"

# Where was the source data download from? (original source)
# The source_name is the name associated with to the original_root
source_name <- "Scottish Government Open Data Repository"
original_root <- "https://statistics.gov.scot/sparql.csv?query="
# Here, the original_path is a query (which is later converted into a path
# on line 164), if you have a url, you can use download_from_url() instead
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
repo_storageRoot <- "github"
script_gitRepo <- "ScottishCovidResponse/SCRCdata"
repo_version <- "0.1.0"
processing_script <- "scotgov_management.R"

# Now go to line 164 and check whether you want to use download_from_database()
# or download_from_url()

# Insert your processing script function on line 189

# Additional parameters ---------------------------------------------------
# The following parameters are automatically generated and assume the following:
# (1) you intend to download your source data now
# (2) you intend to process this data and generate a data product now
# (3) your source data will be automatically downloaded to data-raw/[product_name]
# (4) your source data filename will be [version_number].csv
# (5) your data product will be automatically saved to data-raw/[product_name]
# (6) your data product filename will be [version_number].csv
# (7) you will upload your source data to the Boydorr server
# (8) you will upload your data product to the Boydorr server

namespace <- "SCRC"

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
script_storageRoot <- "text_file"
submission_text <- paste0("R -f inst/scripts/", processing_script)

# where is the data product stored?
product_storageRoot <- "boydorr"
product_path <- file.path(product_name, product_filename)


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
tmp <- gsub("^.*/([0-9]+)/$", "\\1", script_storageRootId)
script_path <- paste0(tmp, "/?format=text")

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
  path = script_path,
  hash = openssl::sha1(submission_text),
  text = submission_text,
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
