#' coronavirus-covid-19-management-information ambulance data
#'
#' This dataset presents Management Information, which is collected and
#' distributed each day in order to support understanding of the progress
#' of the outbreak in Scotland. (From: https://statistics.gov.scot/data/coronavirus-covid-19-management-information)
#'
#' Definitions found here:
#' https://www.gov.scot/publications/coronavirus-covid-19-data-definitions-and-sources/
#'

library(SCRCdata)
library(SCRCdataAPI)


fdp_pull("config.yaml")
fdp_run("config.yaml", skip = TRUE)


# Open the connection to the local registry with a given config file
h <- initialise()

# Return location of file stored in the pipeline
input_path <- link_read(h, "management-data")

process_cam_ambulance(h, input_path)
process_cam_calls(h, input_path)
process_cam_carehomes(h, input_path)
process_cam_hospital(h, input_path)
process_cam_mortality(h, input_path)
process_cam_nhsworkforce(h, input_path)
process_cam_schools(h, input_path)
process_cam_testing(h, input_path)

finalise(h)
