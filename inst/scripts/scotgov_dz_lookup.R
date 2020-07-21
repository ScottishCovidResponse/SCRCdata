#' Data Zone Lookup Table
#'
#' Geography lookup tables used for aggregation, from 2011 data zones to higher
#' level geographies. (From: https://statistics.gov.scot/resource?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fdata-zone-lookup)
#'

library(SCRCdataAPI)

# Download source data
download_source_version(dataset = "scotgov_dz_lookup")
sourcefile=list("simd"= "data-raw/scotgov_simd_lookup.xlsx",
                "dz"="data-raw/scotgov_dz_lookup.csv")
grid_names=c("grid1km","grid10km")
h5filename="scotgov_lookup.h5"
datazone_sf <- file.path("data-raw", "datazone_shapefile",
                         "SG_DataZone_Bdry_2011.shp")
process_scotgov_lookup(sourcefile,h5filename,grid_names,datazone_sf)

