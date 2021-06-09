#' process_cam_mortality
#'
#' Process a subset of the cases-and-management dataset
#'
#' @param handle list
#' @param input_path a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#'
#' @export
#'
process_cam_mortality <- function(handle, input_path) {

  data_product <- "records/SARS-CoV-2/scotland/cases-and-management/mortality"

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

  # Extract mortality data
  deaths.dat <- scotMan %>%
    dplyr::filter(grepl("Number of COVID-19 confirmed deaths registered to date",
                        variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  rFDP::write_array(
    array = as.matrix(deaths.dat),
    handle = handle,
    data_product = data_product,
    component = "date-country-covid19_confirmed_deaths_registered-cumulative",
    description = "cumulative number of confirmed deaths",
    dimension_names = list(
      date = rownames(deaths.dat),
      count = colnames(deaths.dat)))
}
