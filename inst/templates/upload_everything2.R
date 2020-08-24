#' dataset-name
#'
#' The following script assumes:
#' (1) your source data will be downloaded to data-raw/[product_name]
#' (2) your source data will be saved as [version_number].csv
#' (3) your data product will be saved to data-raw/[product_name]
#' (4) your data product will be saved as [version_number].h5
#' (5) you will upload your source data to the Boydorr FTP server
#' (6) you will upload your data product to the Boydorr FTP server
#' (7) you will store your submission script in ScottishCovidResponse/SCRCdata
#'

library(SCRCdataAPI)
library(SCRCdata)


# Go to data.scrc.uk, click on Links, then Generate API Token, and save your
# token in your working directory as token.txt. If the following returns an
# error, then save a carriage return after the token.
key <- readLines("token/token.txt")


# Define data set ---------------------------------------------------------

# doi_or_unique_name is a free text field specifying the name of your dataset
doi_or_unique_name <- "Scottish small area population estimates"

# version_number is used to generate the source data and data product
# filenames, e.g. 0.20200716.0.csv and 0.20200716.0.h5 for data that is
# downloaded daily, or 0.1.0.csv and 0.1.0.h5 for data that is downloaded once
version_number <- "0.1.0"
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
product_name <- "human/demographics/population/scotland"
namespace <- "SCRC"


# Where was the data download from? (original source) ---------------------

original_source_name <- "National Records of Scotland"

# Add the website to the data registry (e.g. home page of the database)
original_sourceId <- new_source(
  name = original_source_name,
  abbreviation = "National Records of Scotland",
  website = "https://www.nrscotland.gov.uk",
  key = key)

# Note that file.path(original_root, original_path) is the download link.
# Examples of downloading data from a database rather than a link, can be
# found in the scotgov_deaths or scotgov_management scripts
original_root <- "https://www.nrscotland.gov.uk"
original_path <- paste0("files", "statistics", "population-estimates",
                        "sape-time-series", "persons",
                        "sape-2018-persons.xlsx", sep = "/")


# Where is the submission script stored? ----------------------------------

# This template is an example of a submission script.
# The submission script should download the source data, generate a data
# product, and upload all associated metadata to the data registry.
# This script assumes you will store your submission script in the
# ScottishCovidResponse/SCRCdata repository within the inst/[namespace]/
# directory

submission_script <- "nrs_demographics.R"


# download source data ----------------------------------------------------

download_from_url(source_root = original_root,
                  source_path = original_path,
                  path = file.path("data-raw", product_name),
                  filename = source_filename)


# convert source data into a data product ---------------------------------

process_scotgov_management(
  sourcefile = file.path("data-raw", product_name, source_filename),
  filename = file.path("data-raw", product_name, product_filename))


# register metadata with the data registry --------------------------------

register_everything(product_name,
                    version_number,
                    doi_or_unique_name,
                    namespace = namespace,
                    submission_script = submission_script,
                    key)
