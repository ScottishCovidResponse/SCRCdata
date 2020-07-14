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
h5filename="scotgov_lookup.h5"
process_scotgov_lookup(sourcefile,h5filename)

