#' table-name
#'
#' Add a table (as an h5 data product) to the data registry
#'

library(SCRCdataAPI)
library(SCRCdata)


# Go to data.scrc.uk, click on Links, then Generate API Token, and save your
# token in your working directory as token.txt. If the following returns an
# error, then save a carriage return after the token.
key <- readLines("token.txt")
namespace <- "SCRC"

# The product_name is used to identify the data product and will be used to
# generate various file locations:
# (1) data product is stored on the Boydorr server at
# ../../srv/ftp/scrc/[product_name]
product_name <- paste("human", "infection", "scotland", sep = "/")

# The following information is used to generate the source data and data
# product filenames, e.g. 0.20200716.0.csv and 0.20200716.0.h5 for data that
# is downloaded daily, or 0.1.0.csv and 0.1.0.h5 for data that is downloaded
# once
todays_date <- Sys.time()
tmp <- as.Date(todays_date, format = "%Y-%m-%d")
version_number <- paste("0", gsub("-", "", tmp), "0" , sep = ".")

# This is the name of your dataset
doi_or_unique_name <- "test table"


# Additional parameters ---------------------------------------------------
# The following parameters are automatically generated and assume the following:
# (1) your version_number will be 1.[date].[version].h5
# (2) your data product filename will be [version_number].h5
# (3) you will upload your data product to the Boydorr server

# where is the data product saved? (locally, before being stored)
product_filename <- paste0(version_number, ".h5")

# where is the data product stored?
product_storageRoot <- "boydorr"
product_path <- product_name


# The following example assumes a single component (data.frame) in the
# h5 file. If multiple tables are extracted from the same dataset, you can use
# these tables to create a multi-component h5 file.
data <- data.frame(Week1 = 1:2, Week2 = 3:2)
rownames(data) <- c("Glasgow", "Edinburgh")

# Use create_table() to generate the h5 file in processed_path (note that if a
# file already exists you'll get an error). If you have multiple components in
# your h5 file, you will need to call create_table() multiple times with the
# same filename. If your h5 file contains a single component, name it "table",
# otherwise each component should have a distinct name,
# https://github.com/ScottishCovidResponse/SCRCdata/wiki/HDF5-components
components <- "table"
create_table(filename = product_filename,
             path = product_name,
             component = components,
             df = data)



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
  processed_path = file.path(product_name, product_filename),
  product_path = paste(product_name, product_filename, sep = "/"),
  version = version_number,
  namespace_id = namespaceId,
  key = key)


