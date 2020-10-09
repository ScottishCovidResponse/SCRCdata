
library(SCRCdata)
library(SCRCdataAPI)

product_name <- "human/demographics/population/england"
product_path <- file.path("data-raw","human", "demographics","population","england")
product_filename <- "0.1.0.h5"
source_path <- "api/v01/dataset/NM_2010_1.data.csv?measures=20100&time=latest&geography=TYPE299&gender=%d&c_age=%d&RecordLimit=24000&RecordOffset=%d"
genders <- c("Persons", "Males", "Females")

# Download source data ----------------------------------------------------

# 15.4 GB
for (sex in 1:3) {
  # for (age in 101:191) {
  for (age in 150:191) {
    for (step in seq(0, 168000, 24000)) {
      # Download file
      if(!file.exists(file.path("data-raw", product_name, genders[sex],
                                sprintf("populationstore_g%d_a%d_s%d.csv",
                                        sex-1, age, step))))
        download_from_url(source_root = "https://www.nomisweb.co.uk/",
                          source_path = sprintf(source_path, sex-1, age, step),
                          path = file.path("data-raw", product_name,genders[sex]),
                          filename = sprintf("populationstore_g%d_a%d_s%d.csv",
                                             sex-1, age, step))
    }}}

for (sex in c(2,3)) {
  for (age in 101:191) {
    for (step in seq(0, 168000, 24000)) {
      # Read file
      temp_pop_table <- read.csv(
        file.path("data-raw", product_name, genders[sex],
                  sprintf("populationstore_g%d_a%d_s%d.csv",
                          sex-1, age, step))) %>%
        dplyr::select(DATE, GEOGRAPHY_NAME, GEOGRAPHY_CODE,
                      GEOGRAPHY_TYPE, GENDER_NAME, C_AGE_NAME,
                      MEASURES_NAME, OBS_VALUE)

      # Delete original file
      # file.remove(file.path("data-raw", product_name, genders[sex],
      #                       sprintf("populationstore_g%d_a%d_s%d.csv",
      #                               sex-1, age, step)))

      # Make some edits
      names(temp_pop_table)[8] <- unique(temp_pop_table$C_AGE_NAME)
      geography_value <- temp_pop_table[, c(2, 8)]

      if(step == 0) {
        temp_population_table <- geography_value
      } else {
        temp_population_table <- rbind(temp_population_table, geography_value)
      }
    } # end of step loop

    if (age == 101) {
      population_table <- temp_population_table
    } else {
      population_table <- left_join(population_table, temp_population_table,
                                    by = "GEOGRAPHY_NAME")
    }
  } # end of age loop

  # Save file
  write.csv(population_table, file.path("data-raw", product_name, genders[sex],
                                        paste0("england_", genders[sex], ".csv")),
            row.names = F)
}


# Process data and generate hdf5 file -------------------------------------

save_location <- "data-raw"
save_data_here <- file.path(save_location, product_path)

# Download latest conversion table
download_dataproduct(name = "geography/lookup_table/gridcell_admin_area/england",
                     data_dir = "data-raw/conversion_table_eng")
filename <- dir("data-raw/geography/lookup_table/gridcell_admin_area/england",
                full.names = TRUE)
conversion_table <- SCRCdataAPI::read_table(filepath = filename,
                                            component = "conversiontable/englandwales")

# Source file locations
sourcefiles <- c("data-raw/human/demographics/population/england/Females/england_Females.csv",
                 "data-raw/human/demographics/population/england/Males/england_Males.csv",
                 "data-raw/human/demographics/population/england/Persons/england_Persons.csv")
names(sourcefiles) <- c("females", "males", "persons")

process_ons_demographics(sourcefile = sourcefiles,
                         h5filename = product_filename,
                         h5path = save_data_here,
                         conversionfile = conversion_table)
