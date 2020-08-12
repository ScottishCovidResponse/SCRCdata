#' parameter-name
#'
#' Add a point-estimate from a paper to the data registry
#'

library(SCRCdataAPI)

# Go to data.scrc.uk, click on Links, then Generate API Token, and save your
# token in your working directory as token.txt. If the following returns an
# error, then save a carriage return after the token.
key <- readLines("token.txt")
namespace <- "SCRC"

# What is the doi of the paper?
doi <- "10.1016/j.ijid.2020.03.007"
# Is it in the data registry? (If FALSE, contact Sonia Mitchell or a member
# of the data team)
paper_exists(doi)

# The product_name is used to identify the data product and will be used to
# generate various file locations:
# (1) data product is saved locally (after processing) to data-raw/[product_name]
# (2) data product is stored on the Boydorr server at
# ../../srv/ftp/scrc/[product_name]
product_name <- "test/parameter-name"
# The component_name is taken as the last part of the product_name
component_name <- gsub("^.*/([^/]*)$", "\\1", product_name)
# The value of the point-estimate
component_value <- 999.99
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


# generate toml -----------------------------------------------------------

path <- paste("master", namespace, product_name, sep = "/")
filename <- paste0(productVersion, ".toml")

create_estimate(filename = filename,
                path = file.path("data-raw", path),
                parameters = as.list(setNames(component_value, component_name)))


# upload data product metadata to database --------------------------------

dataProductURIs <- upload_data_product(
  storage_root_id = storage_rootId,
  name = product_name,
  component_name = component_name,
  processed_path = file.path("data-raw", path, filename),
  product_path = file.path(path, filename),
  version = productVersion,
  namespace_id = namespaceId,
  key = key)


# Attach source (paper) metadata ------------------------------------------

existing_paper <- get_entry("external_object",
                            list(doi_or_unique_name = paste0("doi://", doi)))

website <- ifelse(is.null(existing_paper$original_store), "",
                  existing_paper$original_store)

new_external_object(doi_or_unique_name = existing_paper$doi_or_unique_name,
                    primary_not_supplement = FALSE,
                    release_date = existing_paper$release_date,
                    title = product_name, # name of data product
                    description = existing_paper$description,
                    version = existing_paper$version,
                    object_id = dataProductURIs$product_objectId, # data product id
                    source_id = existing_paper$source,
                    original_store_id = website,
                    key = key)










