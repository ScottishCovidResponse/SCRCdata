#' Data Zone Boundaries 2011
#'
#' Data zones are the key geography for the dissemination of small area
#' statistics in Scotland and are widely used across the public and private
#' sector. Composed of aggregates of Census Output Areas, data zones are large
#' enough that statistics can be presented accurately without fear of
#' disclosure and yet small enough that they can be used to represent
#' communities. They are designed to have roughly standard populations of
#' 500 to 1,000 household residents, nest within Local Authorities, have
#' compact shapes that respect physical boundaries where possible, and to
#' contain households with similar social characteristics. Aggregations of
#' data zones are often used to approximate a larger area of interest or a
#' higher level geography that statistics wouldn’t normally be available for.
#' Data zones also represent a relatively stable geography that can be used
#' to analyse change over time, with changes only occurring after a Census.
#' Following the update to data zones using 2011 Census data, there are now
#' 6,976 data zones covering the whole of Scotland.
#'
#' https://data.gov.uk/dataset/ab9f1f20-3b7f-4efa-9bd2-239acf63b540/data-zone-boundaries-2011
#'

library(SCRCdataAPI)

key <- readLines("token/token.txt")

product_name <- "geography/shapefile/scotland/datazone_boundary/2011"
save_to <- do.call(file.path, as.list(strsplit(product_name, "/")[[1]]))

original_source_name <- "Scottish Government Open Data"

original_sourceId <- new_source(
  name = original_source_name,
  abbreviation = "Scottish Government Open Data",
  website = "https://data.gov.uk",
  key = key)

original_root <- "http://sedsh127.sedsh.gov.uk/"
original_path <- "Atom_data/ScotGov/ZippedShapefiles/SG_DataZoneBdry_2011.zip"

original_rootId <- new_storage_root(name = original_source_name,
                                    root = original_root,
                                    accessibility = 0,
                                    key = key)

# Download shape file
todays_date <- Sys.time()
version_number <- "1.0.0"
filename <- paste0(version_number, ".zip")

download_from_url(source_root = original_root,
                  source_path = original_path,
                  path = file.path("data-raw", save_to),
                  filename = filename,
                  unzip = TRUE)

source_storageRootId <- new_storage_root(
  name = "boydorr",
  root = "ftp://boydorr.gla.ac.uk/scrc/",
  key = key)

upload_source_data(doi_or_unique_name = "Scottish datazone shapefile",
                   original_source_id = original_sourceId,
                   original_root_id = original_rootId,
                   original_path = original_path,
                   primary_not_supplement = TRUE,
                   local_path = file.path("data-raw", save_to, filename),
                   storage_root_id = source_storageRootId,
                   target_path = file.path(save_to, filename),
                   download_date = todays_date,
                   version = version_number,
                   key = key)
