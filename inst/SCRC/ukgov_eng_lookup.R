#'
#'

library(SCRCdata)
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
                         h5filename = "1.0.1.h5", 
                         output_area_sf = "data-raw/outputarea_shapefile/Output_Areas__December_2011__Boundaries_EW_BFC.shp", 
                         grid_names =  c("grid1km","grid10km"),
                         path = file.path("data-raw","geography","lookup_table","gridcell_admin_area","england"))
