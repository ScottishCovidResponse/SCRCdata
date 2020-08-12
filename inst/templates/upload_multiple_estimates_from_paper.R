#' If you want to add multiple parameters from a paper, they can either be
#' multiple clones of the original paper external object (with different
#' titles), or they can be a single object if that makes sense with multiple
#' components. Which you choose depends on taste or more likely whether they
#' are different concepts in the namespace.
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

# Add parameters
parameter1 <- list(
  # The product_name is used to identify the data product and will be used to
  # generate various file locations:
  # (1) data product is saved locally (after processing) to data-raw/[product_name]
  # (2) data product is stored on the Boydorr server at
  # ../../srv/ftp/scrc/[product_name]
  product_name = "test/parameter-name",
  # The component_name is taken as the last part of the product_name
  component_name = gsub("^.*/([^/]*)$", "\\1", product_name),
  # The value of the point-estimate
  component_value = 999.99)

parameter2 <- list(
  product_name = "test/another-parameter",
  component_name = gsub("^.*/([^/]*)$", "\\1", product_name),
  component_value = 100.01)

parameters <- list(parameter1, parameter2)

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



# upload metadata to database ---------------------------------------------

for(i in seq_along(parameters)) {
  # generate toml
  path <- paste("master", namespace, parameters[[i]]$product_name, sep = "/")
  filename <- paste0(productVersion, ".toml")

  create_estimate(filename = filename,
                  path = file.path("data-raw", path),
                  parameters = as.list(setNames(parameters[[i]]$component_value,
                                                parameters[[i]]$component_name)))

  # upload data product metadata to database
  dataProductURIs <- upload_data_product(
    storage_root_id = storage_rootId,
    name = parameters[[i]]$product_name,
    component_name = parameters[[i]]$component_name,
    processed_path = file.path("data-raw", path, filename),
    product_path = file.path(path, filename),
    version = productVersion,
    namespace_id = namespaceId,
    key = key)

  # Attach source (paper) metadata
  existing_paper <- get_entry("external_object",
                              list(doi_or_unique_name = paste0("doi://", doi)))

  website <- ifelse(is.null(existing_paper$original_store), "",
                    existing_paper$original_store)

  new_external_object(doi_or_unique_name = existing_paper$doi_or_unique_name,
                      primary_not_supplement = FALSE,
                      release_date = existing_paper$release_date,
                      title = parameters[[i]]$product_name, # name of data product
                      description = existing_paper$description,
                      version = existing_paper$version,
                      object_id = dataProductURIs$product_objectId, # data product id
                      source_id = existing_paper$source,
                      original_store_id = website,
                      key = key)
}
