#' parameter-name
#'
#' Add a point-estimate to the data registry
#'

library(SCRCdataAPI)



# Go to data.scrc.uk, click on Links, then Generate API Token, and save your
# token in your working directory as token.txt. If the following returns an
# error, then save a carriage return after the token.
key <- read.table("token.txt")
namespace <- "SCRC"

# The product_name is used to identify the data product and will be used to
# generate various file locations:
# (1) data product is saved locally (after processing) to data-raw/[product_name]
# (2) data product is stored on the Boydorr server at
# ../../srv/ftp/scrc/[product_name]



filename <- "anothertest.toml"
path <- "data-raw/example"
dat <- configr::read.config(file.path(path, filename))

component_names <- names(dat)
product_name <- paste0("human/test/test/cases_and_management")

# The version number of the data product
productVersion <- "0.1.0"




# ******************************************************
# Now run the code below and push your toml file to the
# ScottishCovidResponse/DataRepository GitHub repository
# ******************************************************




# default data that should be in database ---------------------------------

# Assuming the toml will be stored in the ScottishCovidResponse/DataRepository
# GitHub repository
productStorageRoot <- "DataRepository"

storage_rootId <- new_storage_root(
  name = productStorageRoot,
  root = "https://raw.githubusercontent.com/ScottishCovidResponse/DataRepository/",
  key = key)

namespaceId <- new_namespace(name = namespace,
                             key = key)


# upload data product metadata to database --------------------------------


upload_data_product(storage_root_id = storage_rootId,
                    name = product_name,
                    component_name = component_names,
                    processed_path = file.path(path, filename), # local
                    product_path = file.path(path, filename), # ftp
                    version = productVersion,
                    namespace_id = namespaceId,
                    key = key)





