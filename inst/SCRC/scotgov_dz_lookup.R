#' Data Zone Lookup Table
#'
#' Geography lookup tables used for aggregation, from 2011 data zones to higher
#' level geographies. (From: https://statistics.gov.scot/resource?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fdata-zone-lookup)
#'

library(SCRCdataAPI)

# Download source data
download_from_url(source_root = "http://statistics.gov.scot",
                  source_path = "downloads/file?id=5a9bf61e-7571-45e8-a307-7c1218d5f6b5%2FDatazone2011Lookup.csv",
                  path = "data-raw",
                  filename = "scotgov_dz_lookup.csv")
download_from_url(source_root = "https://www.gov.scot",
                  source_path = "binaries/content/documents/govscot/publications/statistics/2020/01/scottish-index-of-multiple-deprivation-2020-data-zone-look-up-file/documents/scottish-index-of-multiple-deprivation-data-zone-look-up/scottish-index-of-multiple-deprivation-data-zone-look-up/govscot%3Adocument/SIMD%2B2020v2%2B-%2Bdatazone%2Blookup.xlsx?forceDownload=true",
                  path = "data-raw",
                  filename = "scotgov_simd_lookup.xlsx")

process_scotgov_lookup(
  sourcefile = list(simd = "data-raw/scotgov_simd_lookup.xlsx",
                    dz = "data-raw/scotgov_dz_lookup.csv"),
  h5filename = "scotgov_lookup.h5",
  grid_names = c("grid1km","grid10km"))

