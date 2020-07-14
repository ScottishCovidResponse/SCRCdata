#' infectious-duration
#'

library(SCRCdataAPI)
library(dplyr)
library(devtools)


# initialise --------------------------------------------------------------

key <- read.table("token.txt")

namespace <- "SCRC"
name <- "human/infection/SARS-CoV-2/infectious-duration"
component_name <- gsub("^.*/([^/]*)$", "\\1", name)
productVersion <- "0.1.0"
component_value <- 321.6
productStorageRoot <- "DataRepository"


# default data that should be in database ---------------------------------

storage_rootId <- new_storage_root(
  name = productStorageRoot,
  root = "https://raw.githubusercontent.com/ScottishCovidResponse/DataRepository/",
  key = key)

namespaceId <- new_namespace(name = namespace,
                             key = key)


# generate toml -----------------------------------------------------------

path <- paste("master", namespace, name, sep = "/")
filename <- paste0(productVersion, ".toml")

create_estimate(filename = filename,
                path = file.path("data-raw", path),
                value = component_value,
                name = component_name)


# data product ------------------------------------------------------------

upload_data_product(storage_root_id = storage_rootId,
                    path = path,
                    component_name = component_name,
                    filename = filename,
                    version = productVersion,
                    namespace_id = namespaceId,
                    key = key)



