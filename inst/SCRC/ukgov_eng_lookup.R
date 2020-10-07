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
version_number <- "1.0.1"
source_filename <- list(OA_EW_LA =paste0(version_number, ".csv"),
                        OA_LSOA_MSOA_LA = paste0(version_number, ".csv"),
                        LSOA_CCG = paste0(version_number, ".csv"),
                        EW_UA = paste0(version_number, ".csv"),
                        UA_HB = paste0(version_number, ".csv")
                        ,grid_shapefile = "shapefiles.zip"
                        )
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

original_source_name1 <- "Office for National Statistics Open Georaphy Portal"
original_source_name2 <- "Github repo - charlesroper/OSGB_Grids"

original_source_name <- list(ons = original_source_name1,
                             grid_shapefile = original_source_name2)

# Add the website to the data registry (e.g. home page of the database)

# - Dataset
original_sourceId1 <- new_source(
  name = original_source_name1,
  abbreviation = "ONS Open Portal",
  website = "https://geoportal.statistics.gov.uk/",
  key = key)

# Dataset 2 (grid_shapefile)
original_sourceId2 <- new_source(
  name = original_source_name2,
  abbreviation = "Github/charlesroper/OSGB_Grids",
  website = "https://github.com/Github/charlesroper",
  key = key)

original_sourceId <- list(OA_EW_LA = original_sourceId1,
                          OA_LSOA_MSOA_LA = original_sourceId1,
                          LSOA_CCG =original_sourceId1,
                          EW_UA = original_sourceId1,
                          UA_HB = original_sourceId1
                          ,grid_shapefile = original_sourceId2
                          )
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
                      UA_HB = "https://opendata.arcgis.com/datasets/"
                      ,grid_shapefile = "https://github.com/"
                      )
original_path <-  list(OA_EW_LA = "c721b6da8ea04f189baa27a1f3e32e06_0.csv",
                       OA_LSOA_MSOA_LA = "6ecda95a83304543bc8feedbd1a58303_0.csv",
                       LSOA_CCG = "520e9cd294c84dfaaf97cc91494237ac_0.csv",
                       EW_UA = "e6d0a1c8ce3344a7b79ce1c24e3174c9_0.csv",
                       UA_HB = "680c9b730655473787cb594f328a86fa_0.csv"
                       ,grid_shapefile = "charlesroper/OSGB_Grids/archive/master.zip"
                       )

save_location <- "data-raw"
save_data_here <- file.path(save_location, product_path)

for (x in seq_along(original_root)) {
  download_from_url(source_root = original_root[[x]],
                    source_path = original_path[[x]],
                    path = file.path(save_data_here,
                                     names(original_root)[x]),
                    filename = source_filename[[x]],
                    unzip = if(grepl("zip",source_filename[[x]])){TRUE}else{FALSE})
  
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
source_filename$grid_shapefile = file.path("OSGB_Grids-master","Shapefile","OSGB_Grid_1km.shp")

sourcefiles <- lapply(seq_along(original_root), function(x)
  file.path("data-raw", product_name, names(original_root)[x], source_filename[x]))
names(sourcefiles) <- c("OA_EW_LA", "OA_LSOA_MSOA_LA","LSOA_CCG","EW_UA",
                        "UA_HB","grid_shapefile")


process_ukgov_eng_lookup(sourcefile = sourcefiles,
                         h5filename = product_filename,
                         output_area_sf = "data-raw/Output_Areas__December_2011__Boundaries_EW_BFC.shp",
                         path = file.path("data-raw","geography","england","lookup_table"))
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