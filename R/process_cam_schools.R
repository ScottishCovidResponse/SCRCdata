#' process_cam_schools
#'
#' Process a subset of the cases-and-management dataset
#'
#' @param handle list
#' @param input_path a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#'
#' @export
#'
process_cam_schools <- function(handle, input_path) {

  data_product <- "records/SARS-CoV-2/scotland/cases-and-management/schools"

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
  schools.dat <- scotMan %>%
    dplyr::filter(grepl("Schools", variable))

  sort(unique(schools.dat$variable))

  # -------------------------------------------------------------------------

  # Schools - Percentage absence - Not due to COVID-19 related reasons
  school.percentage.absent.noncovid <- schools.dat %>%
    dplyr::filter(grepl("Schools - Percentage absence - Not due to COVID-19 related reasons",
                        variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(school.percentage.absent.noncovid),
    handle = handle,
    data_product = data_product,
    component = "date-country-percentage_absence_for_noncovid_reasons",
    dimension_names = list(
      date = rownames(school.percentage.absent.noncovid)))

  # Schools - Number of pupils absent due to COVID-19 related reasons
  school.number.absent.covid <- schools.dat %>%
    dplyr::filter(grepl("Schools - Number of pupils absent due to COVID-19 related reasons",
                        variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(school.number.absent.covid),
    handle = handle,
    data_product = data_product,
    component = "date-country-pupils_absent_for_covid_reasons",
    dimension_names = list(
      date = rownames(school.number.absent.covid)))

  # Schools - Percentage absence - Due to COVID-19 related reasons
  school.percentage.absent.covid <- schools.dat %>%
    dplyr::filter(grepl("Schools - Percentage absence - Due to COVID-19 related reasons",
                        variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(school.percentage.absent.covid),
    handle = handle,
    data_product = data_product,
    component = "date-country-percentage_absent_for_covid_reasons",
    dimension_names = list(
      date = rownames(school.percentage.absent.covid)))

  # Schools - Percentage attendance - All
  school.percentage.attendance <- schools.dat %>%
    dplyr::filter(grepl("Schools - Percentage attendance - All",
                        variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(school.percentage.attendance),
    handle = handle,
    data_product = data_product,
    component = "date-country-percentage_attendance",
    dimension_names = list(
      date = rownames(school.percentage.attendance)))

  # "Schools - Percentage attendance - Primary"
  # "Schools - Percentage attendance - Secondary"
  # "Schools - Percentage attendance - Special"


}
