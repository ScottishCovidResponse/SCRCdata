#' meanSymptomDelay
#'

library(SCRCdataAPI)
library(dplyr)
library(devtools)



# initialise --------------------------------------------------------------

key <- read.table("token.txt")

# Data product

dataset <- "symptom-delay"
productStorageRoot <- "github"
path <- file.path("master", "SCRC", "human", "infection", "SARS-CoV-2",
                  "symptom-delay")
namespace <- "SCRC"
productVersion <- "0.1.0"
filename <- "0.1.0.toml"


# check -------------------------------------------------------------------

# Check whether productStorageRoot exists in the registry
if(!check_exists("storage_root", list(name = productStorageRoot))) {
  storage_rootId <- new_storage_root(
    name = productStorageRoot,
    root = file.path("https://raw.githubusercontent.com",
                     "ScottishCovidResponse", "DataRepository", ""),
    key = key)
}

# Check whether namespace exists in the registry
if(!check_exists("namespace", list(name = namespace))) {
  namespaceId <- new_namespace(name = namespace,
                               key = key)
}



create_distribution(filename = filename,
                    path = file.path("data-raw", path),
                    descriptor = dataset,
                    distribution = "Gaussian",
                    parameters = list(mean = -16.08,
                                      SD = 30))



# data product ------------------------------------------------------------

upload_data_product(storage_root = productStorageRoot,
                    path = path,
                    dataset = dataset,
                    filename = filename,
                    version = productVersion,
                    key = key)


