#' symptom-delay
#'

library(SCRCdataAPI)
library(dplyr)
library(devtools)


# initialise --------------------------------------------------------------

key <- readLines("token.txt")

namespace <- "SCRC"
name <- "human/infection/SARS-CoV-2/symptom-delay"
component_name <- gsub("^.*/([^/]*)$", "\\1", name)
productVersion <- "0.1.0"
distribution <- "Gaussian"
parameters <- list(mean = -16.08,
                   SD = 30)
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

create_distribution(filename = filename,
                    path = file.path("data-raw", path),
                    name = component_name,
                    distribution = distribution,
                    parameters = parameters)


# data product ------------------------------------------------------------

upload_data_product(storage_root_id = storage_rootId,
                    name = name,
                    component_name = component_name,
                    processed_path = file.path("data-raw", path, filename),
                    product_path = file.path(path, filename),
                    version = productVersion,
                    namespace_id = namespaceId,
                    key = key)


