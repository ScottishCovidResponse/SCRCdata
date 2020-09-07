#' process_cam_schools
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
process_cam_schools <- function(sourcefile, filename) {

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

  # Extract testing data
  schools.dat <- scotMan %>%
    dplyr::filter(grepl("School education", variable))


  # -------------------------------------------------------------------------

  # Percentage absence for non COVID-19 related reasons
  school.percentage.absent.noncovid <- schools.dat %>%
    dplyr::filter(grepl("Percentage absence for non COVID-19 related reasons",
                        variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(filename = filename,
                            component = "date-country-percentage_absence_for_noncovid_reasons",
                            array = as.matrix(school.percentage.absent.noncovid),
                            dimension_names = list(
                              delayed = rownames(school.percentage.absent.noncovid),
                              date = colnames(school.percentage.absent.noncovid)))

  # Number of pupils absent due to COVID-19 related reasons
  school.number.absent.covid <- schools.dat %>%
    dplyr::filter(grepl("Number of pupils absent due to COVID-19 related reasons",
                        variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(filename = filename,
                            component = "date-country-pupils_absent_for_covid_reasons",
                            array = as.matrix(school.number.absent.covid),
                            dimension_names = list(
                              delayed = rownames(school.number.absent.covid),
                              date = colnames(school.number.absent.covid)))

  # Percentage absence due to COVID-19 related reasons
  school.percentage.absent.covid <- schools.dat %>%
    dplyr::filter(grepl("Percentage absence due to COVID-19 related reasons",
                        variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(filename = filename,
                            component = "date-country-percentage_absent_for_covid_reasons",
                            array = as.matrix(school.percentage.absent.covid),
                            dimension_names = list(
                              delayed = rownames(school.percentage.absent.covid),
                              date = colnames(school.percentage.absent.covid)))

  # Percentage attendance
  school.percentage.attendance <- schools.dat %>%
    dplyr::filter(grepl("Percentage attendance",
                        variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(filename = filename,
                            component = "date-country-percentage_attendance",
                            array = as.matrix(school.percentage.attendance),
                            dimension_names = list(
                              delayed = rownames(school.percentage.attendance),
                              date = colnames(school.percentage.attendance)))
}
