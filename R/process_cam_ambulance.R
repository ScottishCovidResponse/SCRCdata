#' process_cam_ambulance
#'
#' Process a subset of the cases-and-management dataset
#'
#' @param handle list
#' @param input_path a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#'
#' @export
#'
process_cam_ambulance <- function(handle, input_path) {

  data_product <- "records/SARS-CoV-2/scotland/cases-and-management/ambulance"

  # Read in data
  scotMan <- read.csv(file = input_path, stringsAsFactors = F) %>%
    dplyr::mutate(featurecode = gsub(
      "http://statistics.gov.scot/id/statistical-geography/",
      "", featurecode),
      featurecode = gsub(">", "", featurecode)) %>%
    dplyr::mutate(count = dplyr::case_when(count == "*" ~ "0",
                                           T ~ count)) %>%
    dplyr::mutate(count = as.numeric(count))

  # # Assert that the column names in the downloaded file match what is expected
  # test_cases_and_management(scotMan)

  # Extract ambulance data
  ambulance.dat <- scotMan %>%
    dplyr::filter(grepl("Ambulance attendances", variable))


  # -------------------------------------------------------------------------

  # COVID-19 suspected patients taken to hospital
  ambulance.suspected.hospital <- ambulance.dat %>%
    dplyr::filter(grepl("COVID-19 suspected patients taken to hospital",
                        variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  rFDP::write_array(
    array = as.matrix(ambulance.suspected.hospital),
    handle = handle,
    data_product = data_product,
    component = "date-covid19_suspected_patients_taken_to_hospital",
    description = "suspected patients taken to hospital",
    dimension_names = list(
      date = rownames(ambulance.suspected.hospital)))

  # COVID-19 suspected
  ambulance.suspected <- ambulance.dat %>%
    dplyr::filter(grepl("COVID-19 suspected$", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  rFDP::write_array(array = as.matrix(ambulance.suspected),
                           handle = handle,
                           data_product = data_product,
                           component = "date-covid19_suspected",
                           description = "suspected",
                           dimension_names = list(
                             date = rownames(ambulance.suspected)))

  # Total
  ambulance.total <- ambulance.dat %>%
    dplyr::filter(grepl("Total", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  rFDP::write_array(array = as.matrix(ambulance.total),
                    handle = handle,
                    data_product = data_product,
                    component = "date-total",
                    description = "total",
                    dimension_names = list(
                      date = rownames(ambulance.total)))
}
