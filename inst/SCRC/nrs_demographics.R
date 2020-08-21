#' Small Area Population Estimates 2018. Estimated population by sex,
#' single year of age, 2011 Data Zone area, and council area: 30 June 2018.
#' (From: https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/2011-based-special-area-population-estimates/small-area-population-estimates/time-series)
#'

library(SCRCdata)
library(SCRCdataAPI)

key <- readLines("token.txt")
todays_date <- Sys.time()

# initialise parameters ---------------------------------------------------

product_name <- paste("human", "demographics", "population", "scotland", sep = "/")

# create version number (this is used to generate the *.csv and *.h5 filenames)

version_number <- paste("1", "0", "0" , sep = ".")

# dataset name

doi_or_unique_name <- "demographic-population-Scotland"

# where was the source data download from? (original source)
source_name = " National Records of Scotland"
original_root = "https://www.nrscotland.gov.uk"
original_path = list(file.path("files//statistics", "population-estimates",
                             "sape-time-series", "males", "sape-2018-males.xlsx"),
                   file.path("files//statistics", "population-estimates",
                             "sape-time-series/females/sape-2018-females.xlsx"),
                   file.path("files//statistics", "population-estimates",
                             "sape-time-series", "persons", "sape-2018-persons.xlsx"))
source_path = "data-raw"
source_filename = list("data-raw/sape-2018-persons.xlsx",
                "data-raw/sape-2018-females.xlsx",
                "data-raw/sape-2018-males.xlsx")


# where is the submission script stored?
github_info <- get_package_info(repo = "ScottishCovidResponse/SCRCdata",
                                script = "inst/SCRC/nrs_demographics.R",
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
submission_text <- paste("R -f", github_info$submission_script)


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
for(i in seq_along(source_path)){
download_from_url(
  source_root = original_root,
  source_path = original_path[[i]],
  path = source_path,
  filename = source_filename[[i]])
}

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

# Process data and generate hdf5 file
sourcefile <- c("data-raw/sape-2018-persons.xlsx",
                "data-raw/sape-2018-females.xlsx",
                "data-raw/sape-2018-males.xlsx")

genderbreakdown = list("persons"="persons",
                       "genders"=c("females","males"))


grp.names <- c("dz","ur", "iz","mmw","spc","la", "hb", "ttwa"
               , "grid1km",  "grid10km"
               )

full.names <- c("datazone","urban rural classification", "intermediate zone", "multi member ward",
                "scottish parliamentary constituency", 
                "local authority", 
                "health board",
                "travel to work area",
                 "grid area",
                "grid area")

age.classes <- list(0:90)

conversionh5filepath = paste("data-raw", "geography", "lookup_table", "gridcell_admin_area", "scotland",sep = "/")
conversionh5version_number = "1.0.0.h5"
conversionh5component =  paste("conversiontable","scotland","table", sep = "/")
if(SCRCdataAPI::check_for_hdf5(filename = paste(conversionh5filepath, conversionh5version_number,sep = "/"),
                            component = conversionh5component)==FALSE){
  stop("Can't find conversion table, SCRCdata/inst/SCRC/scotgov_dz_lookup.R should be used to download and process file")
}

process_nrs_demographics(sourcefile = source_filename,
                         h5filename = h5filename,
                         grp.names = grp.names,
                         full.names = full.names,
                         age.classes = age.classes,
                         conversionh5filename = conversionh5filename,
                         genderbreakdown = genderbreakdown)

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