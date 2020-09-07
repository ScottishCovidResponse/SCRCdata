#' process_cam_mortality
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
process_cam_mortality <- function(sourcefile, filename) {

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

  # Extract mortality data
  deaths.dat <- scotMan %>%
    dplyr::filter(grepl("Number of COVID-19 confirmed deaths registered to date",
                        variable)) %>%
    reshape2::dcast(1 ~ date, value.var = "count") %>%
    dplyr::select(-"1")

  SCRCdataAPI::create_array(filename = filename,
                            component = "date-country-covid19_confirmed_deaths_registered-cumulative",
                            array = as.matrix(deaths.dat),
                            dimension_names = list(
                              delayed = rownames(deaths.dat),
                              date = colnames(deaths.dat)))
}
