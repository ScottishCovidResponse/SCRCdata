#'
#'

library(SCRCdata)
library(SCRCdataAPI)

# Download source data
download_source_version(dataset = "ukgov_eng_lookup")

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
output_area_sf <- file.path("data-raw", "outputarea_shapefile",
                            "Output_Areas__December_2011__Boundaries_EW_BFC.shp")
grp.names=c("grid1km","grid10km")

h5filename =conversionh5filepath = paste("data-raw", "geography", "lookup_table", "gridcell_admin_area", "england", "1.0.0.h5",sep = "/")


process_ukgov_eng_lookup(sourcefile, h5filename, output_area_sf, grp.names)

