#' dataset-name
#'
#' Dataset description and link to source
#'

library(SCRCdataAPI)
library(SCRCdata)


# Download a key from https://data.scrc.uk and store it somewhere safe!
key <- read.table("token.txt")


# The product_name is used to identify the data product and will be used to
# generate various file locations:
# (1) data product is stored on the Boydorr server at
# ../../srv/ftp/scrc/[product_name]
product_name <- paste("human", "infection", "SARS-CoV-2", "scotland",
                      "mortality", sep = "/")

# The following information is used to generate the source data and data
# product filenames, e.g. 20200716.0.0.csv and 20200716.0.0.h5
todays_date <- Sys.time()
version <- 0

# This is the name of your dataset
doi_or_unique_name <- "scottish scottish deaths-involving-coronavirus-covid-19"

# Additional parameters ---------------------------------------------------
# The following parameters are automatically generated and assume the following:
# (1) your version_number will be 1.[date].[version].h5
# (2) your data product filename will be [version_number].h5
# (3) you will upload your data product to the Boydorr server

namespace <- "SCRC"

# create version number (this is used to generate the *.csv and *.h5 filenames)
tmp <- as.Date(todays_date, format = "%Y-%m-%d")
version_number <- paste("1", gsub("-", "", tmp), version , sep = ".")

# where is the data product saved? (locally, before being stored)
processed_path <- file.path("data-raw", product_name)
product_filename <- paste0(version_number, ".h5")

# where is the data product stored?
product_storageRoot <- "boydorr"
product_path <- file.path(product_name, product_filename)


# default data that should be in database ---------------------------------

# data product storage root
product_storageRootId <- new_storage_root(name = product_storageRoot,
                                          root = "ftp://boydorr.gla.ac.uk/scrc/",
                                          key = key)

# namespace
namespaceId <- new_namespace(name = namespace,
                             key = key)




# upload data product metadata to the registry ----------------------------

dataProductURIs <- upload_data_product(
  storage_root_id = product_storageRootId,
  name = product_name,
  processed_path = file.path(processed_path, product_filename),
  product_path = paste(product_path, product_filename, sep = "/"),
  version = version_number,
  namespace_id = namespaceId,
  key = key)


