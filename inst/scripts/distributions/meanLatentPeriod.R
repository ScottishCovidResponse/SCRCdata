#' meanLatentPeriod
#'

library(SCRCdataAPI)
library(dplyr)
library(devtools)



# initialise --------------------------------------------------------------

key <- read.table("token.txt")

# Data product

dataset <- "meanLatentPeriod"
productStorageRoot <- "boydorr"
path <- file.path("parameters", "meanLatentPeriod", "meanLatentPeriod.toml")
namespace <- "SCRC"
productVersion <- "0.1.0"
filename <- "meanLatentPeriod.toml"


# check -------------------------------------------------------------------

# Check whether productStorageRoot exists in the registry
if(!check_exists("storage_root", list(name = productStorageRoot))) {
  storage_rootId <- new_storage_root(name = productStorageRoot,
                                     root = "ftp://boydorr.gla.ac.uk/scrc/",
                                     key = key)
}

# Check whether namespace exists in the registry
if(!check_exists("namespace", list(name = namespace))) {
  namespaceId <- new_namespace(name = namespace,
                               key = key)
}





# Process data and generate toml file
create_distribution(filename = filename,
                    descriptor = "meanLatentPeriod",
                    distribution = "Lognormal",
                    parameters = list(meanlog = 123.12))



# data product ------------------------------------------------------------

upload_data_product(storage_root = productStorageRoot,
                    path = path,
                    dataset = dataset,
                    filename = filename,
                    version = productVersion,
                    key = key)



