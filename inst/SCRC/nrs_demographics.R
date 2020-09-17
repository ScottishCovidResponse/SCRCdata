#' Small Area Population Estimates 2018. Estimated population by sex,
#' single year of age, 2011 Data Zone area, and council area: 30 June 2018.
#' (From: https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/2011-based-special-area-population-estimates/small-area-population-estimates/time-series)
#'

#' Data Zone Lookup Table
#'
#' Geography lookup tables used for aggregation, from 2011 data zones to higher
#' level geographies. (From: https://statistics.gov.scot/resource?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fdata-zone-lookup)
#'

key <- readLines("token/token.txt")


# Define data set ---------------------------------------------------------

# doi_or_unique_name is a free text field specifying the name of your dataset
doi_or_unique_name <- "demographic-population-Scotland"

# version_number is used to generate the source data and data product
# filenames, e.g. 0.20200716.0.csv and 0.20200716.0.h5 for data that is
# downloaded daily, or 0.1.0.csv and 0.1.0.h5 for data that is downloaded once
version_number <- "1.0.1"
source_filename <- list(males = paste0(version_number, ".xlsx"),
                        females = paste0(version_number, ".xlsx"),
                        persons = paste0(version_number, ".xlsx"))
product_filename <- paste0(version_number, ".h5")

# product_name is used to identify the data product as well as being used to
# generate various file locations:
# (1) source data is downloaded, then saved locally to data-raw/[product_name]
# (2) source data should be stored on the Boydorr server at
# ../../srv/ftp/scrc/[product_name]
# (3) data product is processed, then saved locally to data-raw/[product_name]
# (4) data product should be stored on the Boydorr server at
# ../../srv/ftp/scrc/[product_name]
product_name <-"human/demographics/population/scotland"

# Construct the path to a file in a platform independent way
product_path <- do.call(file.path, as.list(strsplit(product_name, "/")[[1]]))
namespace <- "SCRC"


# Where was the data download from? (original source) ---------------------

original_source_name1 <- "National Records of Scotland"

original_source_name <- list(males = original_source_name1,
                             females = original_source_name1,
                             persons = original_source_name1)

# Add the website to the data registry (e.g. home page of the database)

# - Dataset 1
original_sourceId1 <- new_source(
  name = original_source_name1,
  abbreviation = "NRS",
  website = "https://www.nrscotland.gov.uk/",
  key = key)

original_sourceId <- list(males = original_sourceId1,
                          females = original_sourceId1,
                          persons = original_sourceId1)

# Note that file.path(original_root, original_path) is the download link and
# original_root MUST have a trailing slash. Here, two datasets are being
# downloaded, so original_root and original_path are lists of length two,
# with the name of each element identifying each dataset.
# Examples of downloading data from a database rather than a link, can be
# found in the scotgov_deaths or scotgov_management scripts
original_root <- list(males = "https://www.nrscotland.gov.uk/",
                      females = "https://www.nrscotland.gov.uk/",
                      persons = "https://www.nrscotland.gov.uk/")
original_path <- list(
  males = paste0("files//statistics/population-estimates/",
                 "sape-time-series/males/sape-2018-males.xlsx"),
  females = paste0("files//statistics/population-estimates/",
                   "sape-time-series/females/sape-2018-females.xlsx"),
  persons = paste0("files//statistics/population-estimates/",
                   "sape-time-series/persons/sape-2018-persons.xlsx"))

for (x in seq_along(original_root)) {
  download_from_url(source_root = original_root[[x]],
                    source_path = original_path[[x]],
                    path = file.path("data-raw", product_name,
                                     names(original_root)[x]),
                    filename = source_filename[[x]])
}


# Where is the submission script stored? ----------------------------------

# This template is an example of a submission script.
# The submission script should download the source data, generate a data
# product, and upload all associated metadata to the data registry.
# This script assumes you will store your submission script in the
# ScottishCovidResponse/SCRCdata repository within the inst/[namespace]/
# directory

submission_script <- "nrs_demographics.R"


# convert source data into a data product ---------------------------------

save_location <- "data-raw"
save_data_here <- file.path(save_location, product_path)

# Download latest conversion table
download_dataproduct(name = "geography/lookup_table/gridcell_admin_area/scotland",
                     data_dir = "data-raw/conversion_table")
filename <- dir("data-raw/conversion_table", full.names = TRUE)
conversion_table <- SCRCdataAPI::read_table(filepath = filename,
                                            component = "conversiontable/scotland")

# Source file locations
sourcefiles <- lapply(seq_along(original_root), function(x)
  file.path("data-raw", product_name, names(original_root)[x], source_filename[x]))
names(sourcefiles) <- c("males", "females", "persons")

process_nrs_demographics(sourcefile = sourcefiles,
                         h5filename = product_filename,
                         h5path = save_data_here,
                         conversion_table = conversion_table)


# register metadata with the data registry --------------------------------

github_info <- get_package_info(repo = "ScottishCovidResponse/SCRCdata",
                                script_path = paste0("inst/SCRC/",
                                                     submission_script),
                                package = "SCRCdata")

register_everything(product_name = product_name,
                    version_number = version_number,
                    doi_or_unique_name = doi_or_unique_name,
                    save_location = save_location,
                    namespace = namespace,
                    original_source_name = original_source_name,
                    original_sourceId = original_sourceId,
                    original_root = original_root,
                    original_path = original_path,
                    source_filename = source_filename,
                    submission_script = submission_script,
                    github_info = github_info,
                    accessibility = 0,
                    key = key)
