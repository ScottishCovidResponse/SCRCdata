

get_existing("storage_location")
delete_entry("http://data.scrc.uk/api/source_type/1/", key)



source_data <- list(
  storage_type = "ftp",
  storage_root = "Boydorr",
  storage_location = "deaths-involving-coronavirus-covid-19.csv",
  source_type = "database",
  source = "statistics.gov.scot",
  accessibility = "public",
  source_version = "0.1.0",
  target_path = file.path(
    "human", "infection", "SARS-CoV-2", "scotland", "mortality",
    "deaths-involving-coronavirus-covid-19.csv"),
  hash = get_file_hash(file.path("data-raw",
                            "deaths-involving-coronavirus-covid-19.csv")))

data_product <- list(
  storage_type = "ftp",
  storage_root = "Boydorr",
  storage_location = "deaths-involving-coronavirus-covid-19.h5",
  data_product_type = "dataset",
  data_product = "deaths-involving-coronavirus-covid-19",
  data_product_version = "0.1.0",
  data_product_components = file_structure(
    "deaths-involving-coronavirus-covid-19.h5"),
  target_path = file.path("human", "infection", "SARS-CoV-2", "scotland",
                          "mortality", "deaths-involving-coronavirus-covid-19.h5"),
  hash = get_file_hash("deaths-involving-coronavirus-covid-19.h5"))

processing_script <- list(
  storage_type = "GitHub",
  storage_root = "SCRCdataAPI",
  storage_location = "process_scotgov_deaths.R",
  processing_script = "process_scotgov_deaths.R",
  processing_script_version = "0.1.0",
  target_path = file.path("R", "process_scotgov_deaths.R"),
  hash = get_file_hash(file.path("R", "process_scotgov_deaths.R"))
)

get_existing("storage_type")

post_data <- function(source_data = source_data,
                      data_product = list(),
                      processing_script = list(),
                      responsible_person = "Sonia Mitchell",
                      key = read.table("token.txt")) {

  # deaths-involving-coronavirus-covid-19.csv -------------------------------

  source_data$storage_type %in% get_existing("storage_type")$name
  new_storage_type(name = source_data$storage_type,
                   description = "File Transfer Protocol",
                   key = key)

  new_storage_root(name = source_data$storage_root,
                   description = "Boydorr server",
                   uri = "ftp://srv/ftp/scrc",
                   type = source_data$storage_type,
                   key = key)

  new_storage_location(
    name = source_data$storage_location,
    description = paste("Storage on", data_product$storage_root,
                        data_product$storage_type, "for",
                        data_product$data_product,
                        "source data"),
    path = source_data$target_path,
    hash = source_data$hash,
    local_cache_url = "",
    responsible_person = responsible_person,
    storage_root = source_data$storage_root,
    key = key)

  new_source_type(name = source_data$source_type,
                  description = "database",
                  key = key)

  new_source(name = source_data$source,
             description = "Scottish government open data portal",
             responsible_person = responsible_person,
             store = source_data$storage_location,
             source_type = source_data$source_type,
             key = key)
  get_existing("source")

  new_accessibility(name = source_data$accessibility,
                    description = "accessible to everyone",
                    access_info = "public",
                    key = key)

  new_source_version(version_identifier = source_data$source_version,
                     description = paste(data_product$data_product, "dataset"),
                     responsible_person = responsible_person,
                     supercedes = "",
                     source = source_data$source,
                     store = source_data$storage_location,
                     accessibility = source_data$accessibility,
                     key = key)




  # deaths-involving-coronavirus-covid-19.h5 -------------------------------

  new_storage_type(name = data_product$storage_type,
                   description = "File Transfer Protocol",
                   key = key)

  new_storage_root(name = data_product$storage_root,
                   description = "Boydorr server",
                   uri = "ftp://srv/ftp/scrc",
                   type = data_product$storage_type,
                   key = key)

  new_storage_location(
    name = storage_location,
    description = paste("Storage on", data_product$storage_root,
                        data_product$storage_type, "for",
                        data_product$data_product, "processed data"),
    path = data_product$target_path,
    hash = data_product$hash,
    local_cache_url = "",
    responsible_person = responsible_person,
    storage_root = data_product$storage_root,
    key = key)


  new_data_product_type(name = data_product$data_product_type,
                        description = "processed dataset",
                        key = key)

  dp_url <- new_data_product(name = data_product$data_product,
                             description = paste(data_product$data_product,
                                                 "dataset"),
                             responsible_person = responsible_person,
                             type = data_product$data_product_type,
                             versions = list(), # data product version (done)
                             key = key)

  dpv_url <- new_data_product_version(
    version_identifier = data_product$data_product_version,
    description = paste(data_product$data_product, "dataset version",
                        data_product$data_product_version),
    responsible_person = responsible_person,
    supercedes = "",
    data_product = data_product$data_product,
    store = data_product$storage_location,
    accessibility = data_product$accessibility,
    processing_script_version = "", # processing script version (done)
    source_versions = list(),
    components = list(), # data product version components (done)
    model_runs = list(),
    key = key)

  # Patch data product version (all of them) to data_product
  patch_data(dp_url, key, list(versions = list(dpv_url)))

  # Add data product version components
  for(i in seq_len(nrow(data_product$data_product_components))) {
    new_data_product_version_component(
      name = data_product$data_product_components$name[i],
      responsible_person = responsible_person,
      data_product_version = dpv_url,
      model_runs = list(),
      key = key)
  }

  # Patch components to data product version
  components <- unlist(data_product$data_product_components) %>%
    lapply(function(x) get_url("data_product_version_component",
                               list(name = x)))

  patch_data(dpv_url, key, list(components = components))


  # process_scotgov_deaths.R ------------------------------------------------


  new_storage_location(
    name = processing_script$storage_location,
    description = "GitHub repo containing deaths-involving-coronavirus-covid-19.csv processing script",
    path = processing_script$target_path,
    hash = processing_script$hash,
    local_cache_url = "",
    responsible_person = responsible_person,
    storage_root = processing_script$storage_root,
    key = key)

  new_processing_script(name = processing_script$processing_script,
                        responsible_person = responsible_person,
                        store = processing_script$storage_location,
                        versions = list(),
                        key = key)

  # data_product_url <- get_url("data_product",
  #                             list(name = data_product$data_product))
  # ind <- lapply(get_existing("data_product_version"), function(x)
  #   x$data_product == data_product_url &
  #     x$version_identifier == data_product_version) %>% unlist() %>% which()
  # data_product_version_url <- lapply(ind, function(x)
  #   get_existing("data_product_version")[[x]]$url)

  new_psv <- new_processing_script_version(
    version_identifier = processing_script$processing_script_version,
    responsible_person = responsible_person,
    supercedes = "",
    processing_script = processing_script$processing_script,
    store = processing_script$storage_location,
    accessibility = processing_script$accessibility,
    data_product_versions = list(dpv_url),
    key = key)



  # Patch processing script version to data_product_version


}







