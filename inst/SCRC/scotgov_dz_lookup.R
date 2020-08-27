#' Data Zone Lookup Table
#'
#' Geography lookup tables used for aggregation, from 2011 data zones to higher
#' level geographies. (From: https://statistics.gov.scot/resource?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fdata-zone-lookup)
#'

key <- readLines("token/token.txt")


# Define data set ---------------------------------------------------------

# doi_or_unique_name is a free text field specifying the name of your dataset
doi_or_unique_name <- "Scottish spatial lookup table"

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
product_name <- "geography/scotland/lookup_table"
# Construct the path to a file in a platform independent way
product_path <- do.call(file.path, as.list(strsplit(product_name, "/")[[1]]))
namespace <- "SCRC"


# Where was the data download from? (original source) ---------------------

original_source_name1 <- "Scottish Government"
original_source_name2 <- "Scottish Government Open Data Repository downloadable file"

original_source_name <- list(simd = original_source_name1,
                             dz = original_source_name2)

# Add the website to the data registry (e.g. home page of the database)

# - Dataset 1 (simd)
original_sourceId1 <- new_source(
  name = original_source_name1,
  abbreviation = "Scottish Government",
  website = "https://www.gov.scot/",
  key = key)

# - Dataset 2 (dz)
original_sourceId2 <- new_source(
  name = original_source_name2,
  abbreviation = "Scottish Government Open Data Repository downloadable file",
  website = "https://statistics.gov.scot/",
  key = key)

original_sourceId <- list(simd = original_sourceId1,
                          dz = original_sourceId2)

# Note that file.path(original_root, original_path) is the download link and
# original_root MUST have a trailing slash. Here, two datasets are being
# downloaded, so original_root and original_path are lists of length two,
# with the name of each element identifying each dataset.
# Examples of downloading data from a database rather than a link, can be
# found in the scotgov_deaths or scotgov_management scripts
original_root <- list(simd = "https://www.gov.scot/",
                      dz = "http://statistics.gov.scot/")
original_path <- list(simd = "binaries/content/documents/govscot/publications/statistics/2020/01/scottish-index-of-multiple-deprivation-2020-data-zone-look-up-file/documents/scottish-index-of-multiple-deprivation-data-zone-look-up/scottish-index-of-multiple-deprivation-data-zone-look-up/govscot%3Adocument/SIMD%2B2020v2%2B-%2Bdatazone%2Blookup.xlsx?forceDownload=true",
                      dz = "downloads/file?id=5a9bf61e-7571-45e8-a307-7c1218d5f6b5%2FDatazone2011Lookup.csv")

for (x in seq_along(original_root)) {
  download_from_url(source_root = original_root[[x]],
                    source_path = original_path[[x]],
                    path = file.path("data-raw", product_name,
                                     names(original_root)[x]),
                    filename = source_filename)
}


# Where is the submission script stored? ----------------------------------

# This template is an example of a submission script.
# The submission script should download the source data, generate a data
# product, and upload all associated metadata to the data registry.
# This script assumes you will store your submission script in the
# ScottishCovidResponse/SCRCdata repository within the inst/[namespace]/
# directory

submission_script <- "scotgov_dz_lookup.R"


# convert source data into a data product ---------------------------------

sourcefiles <- lapply(seq_along(original_root), function(x)
  file.path("data-raw", product_name, names(original_root)[x], source_filename))
names(sourcefiles) <- c("simd", "dz")

process_scotgov_lookup(
  sourcefile = sourcefiles,
  h5filename = file.path("data-raw", product_name, product_filename),
  grid_names = c("grid1km","grid10km"))


# register metadata with the data registry --------------------------------

register_everything(product_name = product_name,
                    version_number = version_number,
                    doi_or_unique_name = doi_or_unique_name,
                    namespace = namespace,
                    submission_script = submission_script,
                    original_source_name = original_source_name,
                    original_sourceId = original_sourceId,
                    original_root = original_root,
                    original_path = original_path,
                    accessibility = 0,
                    key = key)

