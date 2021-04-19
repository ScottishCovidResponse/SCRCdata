#' process_cam_calls
#'
#' Process a subset of the cases-and-management dataset
#'
#' @param handle list
#' @param input_path a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#'
#' @export
#'
process_cam_calls <- function(handle, input_path) {

  data_product <- "records/SARS-CoV-2/scotland/cases-and-management/calls"

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

  # Extract calls data
  calls.dat <- scotMan %>%
    dplyr::filter(grepl("Calls", variable))


  # -------------------------------------------------------------------------

  # NHS24 111
  # Coronavirus helpline
  calls.dat <- calls.dat %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    dplyr::mutate(variable = gsub("Calls - ", "", variable)) %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::write_array(array = as.matrix(calls.dat),
                            handle = handle,
                            data_product = data_product,
                            component = "call_centre/date-number_of_calls",
                            dimension_names = list(
                              helpline = rownames(calls.dat),
                              date = colnames(calls.dat)))
}
