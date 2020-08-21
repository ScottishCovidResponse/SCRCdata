
library(SCRCdata)
library(SCRCdataAPI)

# Download source data
download_source_version(dataset = "ons_demographics")

# Process data and generate hdf5 file
sourcefile <- c("data-raw/england_Females.csv",
                "data-raw/england_Males.csv",
                "data-raw/england_Persons.csv")

h5filename <- "england_population.h5"

output_area_sf <- file.path("data-raw", "outputarea_shapefile",
                            "Output_Areas__December_2011__Boundaries_EW_BFC.shp")

conversionh5filepath <- file.path("data-raw", "geography", "lookup_table", "gridcell_admin_area", "england")
conversionh5version_number = "1.0.0"
grp.names <- c("OA", "EW", "LA", "LSOA", "MSOA", "CCG", "STP", "UA","LHB",
               "grid1km", "grid10km")

full.names <- c("output area", "electoral ward",
                "local authority", "lower super output area",
                "mid-layer super output area",
                "clinical commissioning group",
                "sustainability and transformation partnership",
                "unitary authority", "local health board",
                "grid area", "grid area")

subgrp.names <- c("total", "1year", "5year", "10year",
                  "sg_deaths_scheme")
age.classes <- list("total", 0:90, seq(0, 90, 5), seq(0, 90, 10),
                    c(0, 1, 15, 45, 65, 75, 85))

process_ons_demographics(sourcefile = sourcefile,
                         h5filename = h5filename,
                         output_area_sf = output_area_sf,
                         conversionh5version_number = conversionh5version_number,
                         conversionh5filepath = conversionh5filepath,
                         grp.names = grp.names,
                         full.names = full.names,
                         subgrp.names = subgrp.names,
                         age.classes = age.classes)
