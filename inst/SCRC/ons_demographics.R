
library(SCRCdata)
library(SCRCdataAPI)

product_name <-"human/demographics/population/england"

# Download source data
genders <- c("Persons", "Males", "Females")
for (sex in c(2,3)
     # seq_along(genders)
     ) {
  for (age in 101:191) {
    for (step in c(0,((24000*c(1:7))))){
      download_from_url(source_root="https://www.nomisweb.co.uk/", 
                        source_path=sprintf("api/v01/dataset/NM_2010_1.data.csv?measures=20100&time=latest&geography=TYPE299&gender=%d&c_age=%d&RecordLimit=24000&RecordOffset=%d", sex-1,age, step ), 
                        path=file.path("data-raw",product_name,genders[sex]), 
                        filename=sprintf("populationstore_g%d_a%d_s%d.csv", sex-1,age, step ))
      temp_pop_table <-read.csv(file.path("data-raw",product_name,genders[sex],sprintf("populationstore_g%d_a%d_s%d.csv", sex-1,age, step ))) %>%
        dplyr::select(DATE, GEOGRAPHY_NAME, GEOGRAPHY_CODE, 
                      GEOGRAPHY_TYPE, GENDER_NAME, C_AGE_NAME, 
                      MEASURES_NAME, OBS_VALUE)
      file.remove(file.path("data-raw",product_name,genders[sex],sprintf("populationstore_g%d_a%d_s%d.csv", sex-1,age, step )))
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
  write.csv(population_table, file.path("data-raw",product_name,genders[sex],paste0("england_",genders[sex],".csv")),row.names = F)
}

# Process data and generate hdf5 file
sourcefiles <- c("data-raw/england_Females.csv",
                "data-raw/england_Males.csv",
                "data-raw/england_Persons.csv")
names(sourcefiles) = c("females", "males", "persons")


process_ons_demographics(sourcefile = sourcefiles,
                         h5filename = product_filename,
                         h5path =  file.path("data-raw", product_name),
                         conversionh5version_number =  "1.0.2",
                         conversionh5filepath = file.path("data-raw", "geography", "lookup_table", "gridcell_admin_area", "england"),
                         grp.names = c("OA", "EW", "LA", "LSOA", "MSOA", "CCG", "STP", "UA","LHB",
                                       "grid1km", "grid10km"),
                         subgrp.names = "1year",
                         full.names =  c("output area", "electoral ward",
                                         "local authority", "lower super output area",
                                         "mid-layer super output area",
                                         "clinical commissioning group",
                                         "sustainability and transformation partnership",
                                         "unitary authority", "local health board",
                                         "grid area", "grid area"),
                         age.classes = list(0:90),
                         genderbreakdown = list(persons = "persons",
                                                genders = c("males", "females")))
