#' process_cam_testing
#'
#' Process a subset of the cases-and-management dataset
#'
#' @param handle list
#' @param input_path a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#'
#' @export
#'
process_cam_testing <- function(handle, input_path) {

  data_product <- "records/SARS-CoV-2/scotland/cases-and-management/testing"

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

  sort(unique(testing.country.dat$variable))

  # Testing - Cumulative people tested for COVID-19 - Negative
  # Testing - Cumulative people tested for COVID-19 - Positive
  # Testing - Cumulative people tested for COVID-19 - Total
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Cumulative people tested for COVID-19", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "test_result/date-people_tested_for_covid19-cumulative",
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))


  # Testing - Total number of COVID-19 tests reported by NHS Labs - Cumulative
  # Testing - Total number of COVID-19 tests reported by UK Gov testing programme - Cumulative
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("- Cumulative$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "testing_location/date-covid19_tests_carried_out-cumulative",
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))


  # Testing - Total number of COVID-19 tests reported by NHS Labs - Daily
  # Testing - Total number of COVID-19 tests reported by UK Gov testing programme - Daily
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("- Daily$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "testing_location/date-covid19_tests_carried_out-daily",
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))

  # Testing - New cases as percentage of people newly tested
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("New cases as percentage of people", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-new_cases_as_percentage_of_people_newly_tested",
    dimension_names = list(date = rownames(tmp)))

  # Testing - New cases reported
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("New cases reported", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-new_cases_reported",
    dimension_names = list(date = rownames(tmp)))

  # Testing - People with first test results in last 7 days
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("People with first test results", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-people_with_first_test_results_in_last_7_days",
    dimension_names = list(date = rownames(tmp)))

  # Testing - Positive cases reported in last 7 days
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Positive cases reported in", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-positive_cases_reported_in_last_7_days",
    dimension_names = list(date = rownames(tmp)))

  # Testing - Positive tests reported in last 7 days
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Positive tests reported", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-positive_tests_reported_in_last_7_days",
    dimension_names = list(date = rownames(tmp)))

  # Testing - Test positivity (percent of tests that are positive)
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("percent of tests that are positive", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-test_positivity_percent_of_tests_that_are_positive",
    dimension_names = list(date = rownames(tmp)))

  # Testing - Test positivity rate in last 7 days
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Test positivity rate in last 7 days", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-test_positivity_rate_in_last_7_days",
    dimension_names = list(date = rownames(tmp)))

  # Testing - Tests in last 7 days per 1000 population
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Tests in last 7 days", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-tests_in_last_7_days_per_1000_population",
    dimension_names = list(date = rownames(tmp)))

  # Testing - Tests reported in last 7 days
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Tests reported in last 7 days", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-tests_reported_in_last_7_days",
    dimension_names = list(date = rownames(tmp)))

  # Testing - Total daily number of positive tests reported
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Total daily number of positive tests", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-total_daily_number_of_positive_tests_reported",
    dimension_names = list(date = rownames(tmp)))

  # Testing - Total daily tests reported
  tmp <- testing.country.dat %>%
    dplyr::filter(grepl("Total daily tests reported", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "date-country-total_daily_tests_reported",
    dimension_names = list(date = rownames(tmp)))

  # Not country -------------------------------------------------------------

  # "Testing - Cumulative people tested for COVID-19 - Positive"
  testing.notcountry.dat <- testing.dat %>%
    dplyr::filter(areatypename != "Country")

  unique(testing.notcountry.dat$variable)

  tmp <- testing.notcountry.dat %>%
    dplyr::filter(grepl("Testing - Cumulative people tested", variable)) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "nhsboard/date-total_daily_tests_reported",
    dimension_names = list(delayed = rownames(tmp),
                           date = colnames(tmp)))
}
