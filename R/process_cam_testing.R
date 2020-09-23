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
  testing.country.cumulative <- testing.country.dat %>%
    dplyr::filter(grepl("Cumulative people tested for COVID-19", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "test_result/date-people_tested_for_covid19-cumulative",
    array = as.matrix(testing.country.cumulative),
    dimension_names = list(
      delayed = rownames(testing.country.cumulative),
      date = colnames(testing.country.cumulative)))

  # Testing - Daily people found positive
  testing.daily.positive <- testing.country.dat %>%
    dplyr::filter(grepl("Daily people found positive", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-people_found_positive-daily",
    array = as.matrix(testing.daily.positive),
    dimension_names = list(
      delayed = rownames(testing.daily.positive),
      date = colnames(testing.daily.positive)))

  # Testing - Total number of COVID-19 tests carried out by NHS Labs -
  # Cumulative
  # Testing - Total number of COVID-19 tests carried out by Regional Testing
  # Centres - Cumulative
  testing.cumulative <- testing.country.dat %>%
    dplyr::filter(grepl("- Cumulative$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "testing_location/date-covid19_tests_carried_out-cumulative",
    array = as.matrix(testing.cumulative),
    dimension_names = list(
      delayed = rownames(testing.cumulative),
      date = colnames(testing.cumulative)))

  # Testing - Total number of COVID-19 tests carried out by NHS Labs - Daily
  # Testing - Total number of COVID-19 tests carried out by Regional Testing
  # Centres - Daily
  testing.daily <- testing.country.dat %>%
    dplyr::filter(grepl("- Daily$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "testing_location/date-covid19_tests_carried_out-daily",
    array = as.matrix(testing.daily),
    dimension_names = list(
      delayed = rownames(testing.daily),
      date = colnames(testing.daily)))

  # Testing - Positive cases in last 7 days
  testing.7days.positive <- testing.country.dat %>%
    dplyr::filter(grepl("Positive cases in last 7 days", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-positive_cases-last_7_days",
    array = as.matrix(testing.7days.positive),
    dimension_names = list(
      delayed = rownames(testing.7days.positive),
      date = colnames(testing.7days.positive)))

  # Testing - People tested in last 7 days
  testing.7days.people <- testing.country.dat %>%
    dplyr::filter(grepl("People tested in last 7 days", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-people_tested-last_7_days",
    array = as.matrix(testing.7days.people),
    dimension_names = list(
      delayed = rownames(testing.7days.people),
      date = colnames(testing.7days.people)))

  # Testing - Total daily tests
  testing.7days.total <- testing.country.dat %>%
    dplyr::filter(grepl("Total daily tests", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-tests-daily",
    array = as.matrix(testing.7days.total),
    dimension_names = list(
      delayed = rownames(testing.7days.total),
      date = colnames(testing.7days.total)))

  # Testing - Tests in last 7 days
  testing.7days.tests <- testing.country.dat %>%
    dplyr::filter(grepl("Tests in last 7 days", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-country-tests-last_7_days",
    array = as.matrix(testing.7days.tests),
    dimension_names = list(
      delayed = rownames(testing.7days.tests),
      date = colnames(testing.7days.tests)))


  # Special health board ----------------------------------------------------

  assertthat::assert_that(!"Special board" %in% testing.dat$areatypename)


  # NHS health board --------------------------------------------------------

  testing.area.dat <- testing.dat %>%
    dplyr::filter(areatypename == "NHS board")

  # Testing - Cumulative people tested for COVID-19 - Positive
  testing.area.dat <- testing.area.dat %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "nhs_health_board/date-people_tested_positive_for_covid19-cumulative",
    array = as.matrix(testing.area.dat),
    dimension_names = list(
      delayed = rownames(testing.area.dat),
      date = colnames(testing.area.dat)))
}
