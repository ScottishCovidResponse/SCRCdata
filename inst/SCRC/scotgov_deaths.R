#' scottish deaths-involving-coronavirus-covid-19
#'
#' This dataset presents the weekly, and year to date, provisional number of
#' deaths associated with coronavirus (COVID-19) alongside the total number
#' of deaths registered in Scotland, broken down by age, sex.
#' (From: https://statistics.gov.scot/data/deaths-involving-coronavirus-covid-19)
#'

library(SCRCdata)
library(SCRCdataAPI)

# TODO: what about code repo version?

# `fdp run`:
# - validate config.yaml file
# - read config.yaml and generate a working-config.yaml with specific
#   version numbers and no aliases
# - save working-config.yaml in local data store
# - save path to working-config.yaml in global environment in $wconfig

fdp_run("config.yaml")

# Open the connection to the local registry with a given config file
h <- initialise()
# Download data source, save it in the local data store, and register
# metadata in the local registry
add_to_register(h, "raw-mortality-data")

# Return location of file stored in the pipeline
input_path <- read_link(h, "raw-mortality-data")

h <- process_scotgov_deaths(h, input_path)

finalise(h)
