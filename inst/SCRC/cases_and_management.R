#' coronavirus-covid-19-management-information ambulance data
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

key <- readLines("/home/soniamitchell/scrc_cron_scripts/token/token.txt")


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


# download source data ----------------------------------------------------

product_name <- "records/SARS-CoV-2/scotland/cases-and-management"
product_path <- do.call(file.path, as.list(strsplit(product_name, "/")[[1]]))
namespace <- "SCRC"

save_location <- file.path("data-raw")
save_data_here <- file.path(save_location, product_path)

todays_date <- Sys.time()
tmp <- as.Date(todays_date, format = "%Y-%m-%d")
version_number <- paste("0", gsub("-", "", tmp), "0" , sep = ".")
source_filename <- paste0(version_number, ".csv")
product_filename <- paste0(version_number, ".h5")

download_from_database(source_root = original_root,
                       source_path = original_path,
                       filename = source_filename,
                       path = save_data_here)


# original data -----------------------------------------------------------

# Where is the original data downloaded from?
original_storageRootId <- new_storage_root(
  name = original_source_name,
  root = original_root,
  accessibility = 0,
  key = key)


# source data -------------------------------------------------------------

# Namespace
namespaceId <- new_namespace(name = namespace,
                             key = key)

# Where is the source data stored?
source_storageRootId <- new_storage_root(
  name = "boydorr",
  root = "ftp://boydorr.gla.ac.uk/scrc/",
  key = key)

doi_or_unique_name <- "scottish coronavirus-covid-19-management-information"
local_path <- file.path(save_location, product_path)

sourceDataURIs <- upload_source_data(
  doi_or_unique_name = doi_or_unique_name,
  original_source_id = original_sourceId,
  original_root_id = original_storageRootId,
  original_path = original_path,
  primary_not_supplement = TRUE,
  local_path = file.path(local_path, source_filename),
  storage_root_id = source_storageRootId,
  target_path = paste(product_name, source_filename, sep = "/"),
  download_date = todays_date,
  version = version_number,
  key = key)


# data products -----------------------------------------------------------

product_storageRootId <- new_storage_root(
  name = "boydorr",
  root = "ftp://boydorr.gla.ac.uk/scrc/",
  key = key)


# ambulance ---------------------------------------------------------------

static_version <- "0.1.0"
static_filename <- paste0(static_version, ".h5")

process_cam_ambulance(
  sourcefile = file.path(save_data_here, source_filename),
  filename = file.path(save_data_here, "ambulance", static_filename))

ambulanceURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = paste0(product_name, "/ambulance"),
  processed_path = file.path(save_location, product_path, "ambulance",
                             static_filename),
  product_path = paste(product_name, "ambulance", static_filename, sep = "/"),
  version = static_version,
  namespace_id = namespaceId,
  key = key)


# calls -------------------------------------------------------------------

static_version <- "0.1.0"
static_filename <- paste0(static_version, ".h5")

process_cam_calls(
  sourcefile = file.path(save_data_here, source_filename),
  filename = file.path(save_data_here, "calls", static_filename))

callsURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = paste0(product_name, "/calls"),
  processed_path = file.path(save_location, product_path, "calls",
                             static_filename),
  product_path = paste(product_name, "calls", static_filename, sep = "/"),
  version = static_version,
  namespace_id = namespaceId,
  key = key)


# carehomes ---------------------------------------------------------------

process_cam_carehomes(
  sourcefile = file.path(save_data_here, source_filename),
  filename = file.path(save_data_here, "carehomes", product_filename))

carehomesURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = paste0(product_name, "/carehomes"),
  processed_path = file.path(save_location, product_path, "carehomes",
                             product_filename),
  product_path = paste(product_name, "carehomes", product_filename, sep = "/"),
  version = version_number,
  namespace_id = namespaceId,
  key = key)


# hospital ----------------------------------------------------------------

process_cam_hospital(
  sourcefile = file.path(save_data_here, source_filename),
  filename = file.path(save_data_here, "hospital", product_filename))

hospitalURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = paste0(product_name, "/hospital"),
  processed_path = file.path(save_location, product_path, "hospital",
                             product_filename),
  product_path = paste(product_name, "hospital", product_filename, sep = "/"),
  version = version_number,
  namespace_id = namespaceId,
  key = key)


# mortality ---------------------------------------------------------------

process_cam_mortality(
  sourcefile = file.path(save_data_here, source_filename),
  filename = file.path(save_data_here, "mortality", product_filename))

mortalityURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = paste0(product_name, "/mortality"),
  processed_path = file.path(save_location, product_path, "mortality",
                             product_filename),
  product_path = paste(product_name, "mortality", product_filename, sep = "/"),
  version = version_number,
  namespace_id = namespaceId,
  key = key)


# nhsworkforce ------------------------------------------------------------

process_cam_nhsworkforce(
  sourcefile = file.path(save_data_here, source_filename),
  filename = file.path(save_data_here, "nhsworkforce", product_filename))

nhsworkforceURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = paste0(product_name, "/nhsworkforce"),
  processed_path = file.path(save_location, product_path, "nhsworkforce",
                             product_filename),
  product_path = paste(product_name, "nhsworkforce", product_filename, sep = "/"),
  version = version_number,
  namespace_id = namespaceId,
  key = key)


# schools -----------------------------------------------------------------

process_cam_schools(
  sourcefile = file.path(save_data_here, source_filename),
  filename = file.path(save_data_here, "schools", product_filename))

schoolsURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = paste0(product_name, "/schools"),
  processed_path = file.path(save_location, product_path, "schools",
                             product_filename),
  product_path = paste(product_name, "schools", product_filename, sep = "/"),
  version = version_number,
  namespace_id = namespaceId,
  key = key)


# testing -----------------------------------------------------------------

process_cam_testing(
  sourcefile = file.path(save_data_here, source_filename),
  filename = file.path(save_data_here, "testing", product_filename))

testingURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = paste0(product_name, "/testing"),
  processed_path = file.path(save_location, product_path, "testing",
                             product_filename),
  product_path = paste(product_name, "testing", product_filename, sep = "/"),
  version = version_number,
  namespace_id = namespaceId,
  key = key)


# submission script -------------------------------------------------------

submission_script <- "cases_and_management.R"

# GitHub
github_info <- get_package_info(repo = "ScottishCovidResponse/SCRCdata",
                                script_path = paste0("inst/SCRC/",
                                                     submission_script),
                                package = "SCRCdata")

repo_storageRootId <- new_storage_root(
  name = paste0(github_info$repo_storageRoot),
  root = "https://github.com/",
  key = key)

script_storageRoot <- "text_file"
submission_text <- paste("R -f", github_info$submission_script)

script_storageRootId <- new_storage_root(
  name = script_storageRoot,
  root = "https://data.scrc.uk/api/text_file/",
  key = key)

submissionScriptURIs <- upload_submission_script(
  storage_root_id = script_storageRootId,
  hash = openssl::sha1(submission_text),
  text = submission_text,
  run_date = todays_date,
  key = key)


# link objects together ---------------------------------------------------

githubRepoURIs <- upload_github_repo(
  storage_root_id = repo_storageRootId,
  repo = github_info$script_gitRepo,
  hash = github_info$github_hash,
  version = github_info$repo_version,
  key = key)

outputs <- c(ambulanceURIs$product_objectComponentId,
             callsURIs$product_objectComponentId,
             carehomesURIs$product_objectComponentId,
             hospitalURIs$product_objectComponentId,
             mortalityURIs$product_objectComponentId,
             nhsworkforceURIs$product_objectComponentId,
             schoolsURIs$product_objectComponentId,
             testingURIs$product_objectComponentId)

upload_object_links(run_date = todays_date,
                    description = paste("Script run to upload and process",
                                        doi_or_unique_name),
                    code_repo_id = githubRepoURIs$repo_objectId,
                    submission_script_id = submissionScriptURIs$script_objectId,
                    inputs = list(sourceDataURIs$source_objectComponentId),
                    outputs = outputs,
                    key = key)