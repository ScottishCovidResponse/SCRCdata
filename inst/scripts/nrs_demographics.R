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
genderbreakdown = list("persons"="persons",
                       "genders"=c("females","males"))
h5filename <- "demographics.h5"
datazone_sf <- file.path("data-raw", "datazone_shapefile",
                         "SG_DataZone_Bdry_2011.shp")
grp.names <- c("dz","ur", "iz","mmw","spc","la", "hb", "ttwa"
               , "grid1km",  "grid10km"
               )
full.names <- c("datazone","urban rural classification", "intermediate zone", "multi member ward",
                "scottish parliamentary constituency", 
                "local authority", 
                "health board",
                "travel to work area",
                 "grid area",
                "grid area")
age.classes <- list(0:90)
conversionh5filepath = paste("data-raw", "geography", "lookup_table", "gridcell_admin_area", "scotland",sep = "/")
conversionh5version_number = "1.0.0.h5"

process_nrs_demographics(sourcefile = sourcefile,
                         h5filename = h5filename,
                         grp.names = grp.names,
                         full.names = full.names,
                         age.classes = age.classes,
                         conversionh5filename = conversionh5filename,
                         genderbreakdown = genderbreakdown)
