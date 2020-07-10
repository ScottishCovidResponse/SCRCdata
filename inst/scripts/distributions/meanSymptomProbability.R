#' meanSymptomProbability
#'

library(SCRCdataAPI)
library(dplyr)
library(devtools)



# initialise --------------------------------------------------------------

key <- read.table("token.txt")

# Data product

dataset <- "meanSymptomProbability"
productStorageRoot <- "boydorr"
path <- file.path("parameters", "meanSymptomProbability", "meanSymptomProbability.toml")
namespace <- "SCRC"
productVersion <- "0.1.0"
filename <- "meanSymptomProbability.toml"


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



create_distribution(filename = "meanSymptomProbability.toml",
                    descriptor = "meanSymptomProbability",
                    distribution = "bernoulli",
                    parameters = list(prob = 0.692))


# data product ------------------------------------------------------------

upload_data_product(storage_root = productStorageRoot,
                    path = path,
                    dataset = dataset,
                    filename = filename,
                    version = productVersion,
                    key = key)


