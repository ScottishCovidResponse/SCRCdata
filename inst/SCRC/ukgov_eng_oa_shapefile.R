#' ukgov_eng_oa_shapefile
#'

library(SCRCdataAPI)

# Download source data
download_from_url(url = "https://opendata.arcgis.com/datasets",
                  path = "ff8151d927974f349de240e7c8f6c140_0.zip?outSR=%7B%22latestWkid%22%3A3857%2C%22wkid%22%3A102100%7D",
                  local = "data-raw/outputarea_shapefile",
                  filename = "ff8151d927974f349de240e7c8f6c140_0.zip")