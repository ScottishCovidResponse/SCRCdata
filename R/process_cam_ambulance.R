#' process_cam_ambulance
#'
#' Process a subset of the cases-and-management dataset
#'
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param filename a \code{string} specifying the local path and filename
#' associated with the processed data (the output of this function)
#'
#' @export
#'
process_cam_ambulance <- function(sourcefile, filename) {

  # Read in data
  scotMan <- read.csv(file = sourcefile) %>%
    dplyr::mutate(featurecode = gsub(
      "http://statistics.gov.scot/id/statistical-geography/",
      "", featurecode),
      featurecode = gsub(">", "", featurecode)) %>%
    dplyr::mutate(count = dplyr::case_when(count == "*" ~ "0",
                                           T ~ count)) %>%
    dplyr::mutate(count = as.numeric(count))

  # Assert that the column names in the downloaded file match what is expected
  test_cases_and_management(scotMan)

  # Extract ambulance data
  ambulance.dat <- scotMan %>%
    dplyr::filter(grepl("Ambulance attendances", variable))


  # -------------------------------------------------------------------------

  # COVID-19 suspected patients taken to hospital
  ambulance.suspected.hospital <- ambulance.dat %>%
    dplyr::filter(grepl("COVID-19 suspected patients taken to hospital",
                        variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(filename = filename,
                            component = "date-covid19_suspected_patients_taken_to_hospital",
                            array = as.matrix(ambulance.suspected.hospital),
                            dimension_names = list(
                              status = rownames(ambulance.suspected.hospital),
                              date = colnames(ambulance.suspected.hospital)))

  # COVID-19 suspected
  ambulance.suspected <- ambulance.dat %>%
    dplyr::filter(grepl("COVID-19 suspected$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(filename = filename,
                            component = "date-covid19_suspected",
                            array = as.matrix(ambulance.suspected),
                            dimension_names = list(
                              status = rownames(ambulance.suspected),
                              date = colnames(ambulance.suspected)))

  # Total
  ambulance.total <- ambulance.dat %>%
    dplyr::filter(grepl("Total", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(filename = filename,
                            component = "date-total",
                            array = as.matrix(ambulance.total),
                            dimension_names = list(
                              status = rownames(ambulance.total),
                              date = colnames(ambulance.total)))
}
