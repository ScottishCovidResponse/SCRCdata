#' Small Area Population Estimates 2018. Estimated population by sex,
#' single year of age, 2011 Data Zone area, and council area: 30 June 2018.
#' (From: https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/population/population-estimates/2011-based-special-area-population-estimates/small-area-population-estimates/time-series)
#'

library(SCRCdata)
library(SCRCdataAPI)

# Download source data
download_source_version(dataset = "nrs_demographics")

# Process data and generate hdf5 file
sourcefile <- c("data-raw/sape-2018-persons.xlsx",
                "data-raw/sape-2018-females.xlsx",
                "data-raw/sape-2018-males.xlsx")
h5filename <- "demographics.h5"
datazone_sf <- file.path("data-raw", "datazone_shapefile",
                         "SG_DataZone_Bdry_2011.shp")
grp.names <- c("dz","ur", "iz","mmw","spc","la", "hb", "ttwa", "grid1km",
               "grid10km")
full.names <- c("data zone","urban rural classification", "intermediate zone", "multi member ward",
                "scottish parliamentary constituency", 
                "local authority", 
                "health board",
                "travel to work area",
                 "grid area",
                "grid area")
subgrp.names <- c("total", "1year", "5year", "10year",
                  "sg_deaths_scheme")
age.classes <- list("total", 0:90, seq(0, 90, 5), seq(0, 90, 10),
                    c(0, 1, 15, 45, 65, 75, 85))
conversionh5filename = "scotgov_lookup.h5"
devtools::load_all(path="/Users/ciaranmcmonagle/r_projects/SCRCdataAPI")
process_nrs_demographics(sourcefile = sourcefile,
                         h5filename = h5filename,
                         datazone_sf = datazone_sf,
                         grp.names = grp.names,
                         full.names = full.names,
                         subgrp.names = subgrp.names,
                         age.classes = age.classes,
                         conversionh5filename = conversionh5filename)

