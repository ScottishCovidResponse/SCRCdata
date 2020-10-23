#' process_cam_testing
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
process_cam_testing <- function(sourcefile, filename) {

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

  # Extract testing data
  testing.dat <- scotMan %>% dplyr::filter(grepl("Testing", variable)) %>%
    dplyr::mutate(areatypename = dplyr::case_when(
      featurename == "Scotland" ~ "Country",
      nchar(featurecode) == 6 ~ "Special board",
      T ~ "NHS board"
    ))


  # Country -----------------------------------------------------------------

  testing.country.dat <- testing.dat %>%
    dplyr::filter(areatypename == "Country")

  # Testing - Cumulative people tested for COVID-19 - Negative
  # Testing - Cumulative people tested for COVID-19 - Positive
  # Testing - Cumulative people tested for COVID-19 - Total
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Cumulative people tested for COVID-19", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "test_result/date-people_tested_for_covid19-cumulative",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))


  # Testing - Total number of COVID-19 tests reported by NHS Labs - Cumulative
  # Testing - Total number of COVID-19 tests reported by UK Gov testing programme - Cumulative
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("- Cumulative$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "testing_location/date-covid19_tests_carried_out-cumulative",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))


  # Testing - Total number of COVID-19 tests reported by NHS Labs - Daily
  # Testing - Total number of COVID-19 tests reported by UK Gov testing programme - Daily
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("- Daily$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "testing_location/date-covid19_tests_carried_out-daily",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - New cases as percentage of people newly tested
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("New cases as percentage of people", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-new_cases_as_percentage_of_people_newly_tested",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - New cases reported
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("New cases reported", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-new_cases_reported",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - People with first test results in last 7 days
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("People with first test results", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-people_with_first_test_results_in_last_7_days",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - Positive cases reported in last 7 days
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Positive cases reported in", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-positive_cases_reported_in_last_7_days",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - Positive tests reported in last 7 days
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Positive tests reported", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-positive_tests_reported_in_last_7_days",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - Test positivity (percent of tests that are positive)
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("percent of tests that are positive", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-test_positivity_percent_of_tests_that_are_positive",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - Test positivity rate in last 7 days
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Test positivity rate in last 7 days", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-test_positivity_rate_in_last_7_days",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - Tests in last 7 days per 1000 population
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Tests in last 7 days", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-tests_in_last_7_days_per_1000_population",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - Tests reported in last 7 days
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Tests reported in last 7 days", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-tests_reported_in_last_7_days",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - Total daily number of positive tests reported
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Total daily number of positive tests", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-total_daily_number_of_positive_tests_reported",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - Total daily tests reported
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Total daily tests reported", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-total_daily_tests_reported",
    array = as.matrix(tmp),
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))
}
