#' Output area Lookup Table
#'
#' Geography lookup tables used for aggregation, from 2011 output areas to higher
#' level geographies. (From: https://geoportal.statistics.gov.uk/)
#'

key <- readLines("token/token.txt")


# Define data set ---------------------------------------------------------

# doi_or_unique_name is a free text field specifying the name of your dataset
doi_or_unique_name <- "Enlgand/Wales spatial lookup table"

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
product_name <- "geography/england/lookup_table"
# Construct the path to a file in a platform independent way
product_path <- do.call(file.path, as.list(strsplit(product_name, "/")[[1]]))
namespace <- "SCRC"

# Where was the data download from? (original source) ---------------------

original_source_name <- "Office for National Statistics Open Georaphy Portal"

# Add the website to the data registry (e.g. home page of the database)

# - Dataset 
original_sourceId <- new_source(
  name = original_source_name,
  abbreviation = "ONS Open Portal",
  website = "https://geoportal.statistics.gov.uk/",
  key = key)

# Note that file.path(original_root, original_path) is the download link and
# original_root MUST have a trailing slash. Here, two datasets are being
# downloaded, so original_root and original_path are lists of length two,
# with the name of each element identifying each dataset.
# Examples of downloading data from a database rather than a link, can be
# found in the scotgov_deaths or scotgov_management scripts
original_root <- list(OA_EW_LA = "http://geoportal1-ons.opendata.arcgis.com/datasets/",
                      OA_LSOA_MSOA_LA = "http://geoportal1-ons.opendata.arcgis.com/datasets/",
                      LSOA_CCG = "https://opendata.arcgis.com/datasets/",
                      EW_UA = "http://geoportal1-ons.opendata.arcgis.com/datasets/",
                      UA_HB = "https://opendata.arcgis.com/datasets/")
original_path <-  list(OA_EW_LA = "c721b6da8ea04f189baa27a1f3e32e06_0.csv",
                       OA_LSOA_MSOA_LA = "6ecda95a83304543bc8feedbd1a58303_0.csv",
                       LSOA_CCG = "520e9cd294c84dfaaf97cc91494237ac_0.csv",
                       EW_UA = "e6d0a1c8ce3344a7b79ce1c24e3174c9_0.csv",
                       UA_HB = "680c9b730655473787cb594f328a86fa_0.csv")
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

submission_script <- "ukgov_eng_lookup.R"

# convert source data into a data product ---------------------------------

sourcefiles <- lapply(seq_along(original_root), function(x)
  file.path("data-raw", product_name, names(original_root)[x], source_filename))
names(sourcefiles) <- c("OA_EW_LA", "OA_LSOA_MSOA_LA","LSOA_CCG","EW_UA","UA_HB")


process_ukgov_eng_lookup(sourcefile = sourcefiles,
                         h5filename = product_filename, 
                         output_area_sf = "data-raw/Output_Areas__December_2011__Boundaries_EW_BFC.shp", 
                         grid_names =  c("grid1km","grid10km"),
                         path = file.path("data-raw","geography","lookup_table","gridcell_admin_area","england"))
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
source_filename <- list(simd = paste0(version_number, ".xlsx"),
                        dz = paste0(version_number, ".csv"))
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
                    filename = source_filename[[x]])
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
  file.path("data-raw", product_name, names(original_root)[x], source_filename[[x]]))
names(sourcefiles) <- c("simd", "dz")

process_scotgov_lookup(
  sourcefile = sourcefiles,
  h5filename = product_filename,
  path = file.path("data-raw", product_name),
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
                    source_filename = source_filename,
                    accessibility = 0,
                    key = key)



0library(SCRCdata)
library(SCRCdataAPI)

# Download source data
download_from_url(url = "http://geoportal1-ons.opendata.arcgis.com/datasets",
                  path = "c721b6da8ea04f189baa27a1f3e32e06_0.csv",
                  local = "data-raw/england_lookup",
                  filename = "output_to_ward_to_LA.csv")

download_from_url(url = "http://geoportal1-ons.opendata.arcgis.com/datasets",
                  path = "6ecda95a83304543bc8feedbd1a58303_0.csv",
                  local = "data-raw/england_lookup",
                  filename = "output_to_LSOA_MSOA_to_LA.csv")

download_from_url(url = "https://opendata.arcgis.com/datasets",
                  path = "520e9cd294c84dfaaf97cc91494237ac_0.csv",
                  local = "data-raw/england_lookup",
                  filename = "LSOA_to_CCG.csv")

download_from_url(url = "http://geoportal1-ons.opendata.arcgis.com/datasets",
                  path = "e6d0a1c8ce3344a7b79ce1c24e3174c9_0.csv",
                  local = "data-raw/england_lookup",
                  filename = "ward_to_UA_wales.csv")

download_from_url(url = "https://opendata.arcgis.com/datasets",
                  path = "680c9b730655473787cb594f328a86fa_0.csv",
                  local = "data-raw/england_lookup",
                  filename = "UA_to_healthboard_wales.csv")

sourcefile <- c(OA_EW_LA = file.path("data-raw", "england_lookup",
                                     "output_to_ward_to_LA.csv"),
                OA_LSOA_MSOA_LA = file.path("data-raw", "england_lookup",
                                            "output_to_LSOA_MSOA_to_LA.csv"),
                LSOA_CCG = file.path("data-raw", "england_lookup",
                                     "LSOA_to_CCG.csv"),
                EW_UA = file.path("data-raw", "england_lookup",
                                  "ward_to_UA_wales.csv"),
                UA_HB = file.path("data-raw", "england_lookup",
                                  "UA_to_healthboard_wales.csv"))

h5filename <- c("uk_gov_eng_lookup.h5")

process_ukgov_eng_lookup(sourcefile = sourcefile,
                         h5filename = "1.0.2.h5", 
                         output_area_sf = "data-raw/outputarea_shapefile/Output_Areas__December_2011__Boundaries_EW_BFC.shp", 
                         grid_names =  c("grid1km","grid10km"),
                         path = file.path("data-raw","geography","lookup_table","gridcell_admin_area","england"))
