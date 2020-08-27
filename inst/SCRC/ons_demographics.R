
library(SCRCdata)
library(SCRCdataAPI)

# Download source data
genders <- c("Persons", "Males", "Females")
for (sex in seq_along(genders)) {
  for (age in 101:191) {
    for (step in c(0,((c(24000)*c(1:7))))){
      download_from_url(url="https://www.nomisweb.co.uk"
                        , path=sprintf("api/v01/dataset/NM_2010_1.data.csv?measures=20100&time=latest&geography=TYPE299&gender=%d&c_age=%d&RecordLimit=24000&RecordOffset=%d", sex-1,age, step ), 
                        local="data-raw", filename=sprintf("populationstore_g%d_a%d_s%d.csv", sex-1,age, step ))
      temp_pop_table <-read.csv(sprintf("data-raw/populationstore_g%d_a%d_s%d.csv", sex-1,age, step )) %>%
        dplyr::select(DATE, GEOGRAPHY_NAME, GEOGRAPHY_CODE, 
                      GEOGRAPHY_TYPE, GENDER_NAME, C_AGE_NAME, 
                      MEASURES_NAME, OBS_VALUE)
      file.remove(sprintf("data-raw/populationstore_g%d_a%d_s%d.csv", sex-1,age, step ))
      names(temp_pop_table)[8] <- unique(temp_pop_table$C_AGE_NAME)
      geography_value <- temp_pop_table[, c(2, 8)]
      
      if(step==0){
        temp_population_table=geography_value
      }else{
        temp_population_table=rbind(temp_population_table,geography_value)
      }
    }
    if (age == 101) {
      population_table = temp_population_table
    }
    else {
      population_table = left_join(population_table, 
                                   temp_population_table, by = "GEOGRAPHY_NAME")
    }
  }
  write.csv(population_table, paste0("data-raw/england_", genders[sex], 
                                     ".csv"),row.names = F)
}

# Process data and generate hdf5 file
sourcefile <- c("data-raw/england_Females.csv",
                "data-raw/england_Males.csv",
                "data-raw/england_Persons.csv")

h5filename <- "england_population.h5"

output_area_sf <- file.path("data-raw", "outputarea_shapefile",
                            "Output_Areas__December_2011__Boundaries_EW_BFC.shp")

conversionh5filepath <- file.path("data-raw", "geography", "lookup_table", "gridcell_admin_area", "england")
conversionh5version_number = "1.0.2"
grp.names <- c("OA", "EW", "LA", "LSOA", "MSOA", "CCG", "STP", "UA","LHB",
               "grid1km", "grid10km")

full.names <- c("output area", "electoral ward",
                "local authority", "lower super output area",
                "mid-layer super output area",
                "clinical commissioning group",
                "sustainability and transformation partnership",
                "unitary authority", "local health board",
                "grid area", "grid area")

subgrp.names <- c("1year")
age.classes <- list(0:90)

process_ons_demographics(sourcefile = sourcefile,
                         h5filename = h5filename,
                         conversionh5version_number = conversionh5version_number,
                         conversionh5filepath = conversionh5filepath,
                         grp.names = grp.names,
                         subgrp.names = subgrp.names,
                         full.names = full.names,
                         age.classes = age.classes)
