#' process_cam_calls
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
process_cam_calls <- function(sourcefile, filename) {

  # Extract directory and filename
  path <- dirname(filename)
  filename <- basename(filename)

  # Read in data
  scotMan <- read.csv(file = sourcefile, stringsAsFactors = F) %>%
    dplyr::mutate(featurecode = gsub(
      "http://statistics.gov.scot/id/statistical-geography/",
      "", featurecode),
      featurecode = gsub(">", "", featurecode)) %>%
    dplyr::mutate(count = dplyr::case_when(count == "*" ~ "0",
                                           T ~ count)) %>%
    dplyr::mutate(count = as.numeric(count))

  # Assert that the column names in the downloaded file match what is expected
  test_cases_and_management(scotMan)

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

  SCRCdataAPI::create_array(filename = filename,
                            path = path,
                            component = "call_centre/date-number_of_calls",
                            array = as.matrix(calls.dat),
                            dimension_names = list(
                              helpline = rownames(calls.dat),
                              date = colnames(calls.dat)))
}
