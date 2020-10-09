#' process_cam_hospital
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
process_cam_hospital <- function(sourcefile, filename) {

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

  # Extract hospital data
  hospital.dat <- scotMan %>%
    dplyr::filter(grepl("COVID-19 patients", variable) |
                    grepl("Delayed discharges", variable)) %>%
    dplyr::mutate(areatypename = dplyr::case_when(
      featurename == "Scotland" ~ "Country",
      nchar(featurecode) == 6 ~ "Special board",
      T ~ "NHS board"
    ))

  # -------------------------------------------------------------------------

  # Delayed discharges
  discharges.dat <- hospital.dat %>%
    dplyr::filter(grepl("Delayed discharges", variable)) %>%
    reshape2::dcast(1 ~ date, value.var = "count") %>%
    dplyr::select(-"1")

  SCRCdataAPI::create_array(filename = filename,
                            path = path,
                            component = "date-delayed_discharges",
                            array = as.matrix(discharges.dat),
                            dimension_names = list(
                              delayed = rownames(discharges.dat),
                              date = colnames(discharges.dat)))


  # Country -----------------------------------------------------------------

  hosp.country.dat <- hospital.dat %>%
    dplyr::filter(areatypename == "Country")

  # COVID-19 patients in hospital - Total (archived)
  # COVID-19 patients in hospital - Confirmed (archived)
  # COVID-19 patients in hospital - Suspected (archived)
  patients.in.hospital.dat <- hosp.country.dat %>%
    dplyr::filter(grepl("hospital", variable) & grepl("archived", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "test_result/date-country-covid19_patients_in_hospital-archived",
    array = as.matrix(patients.in.hospital.dat),
    dimension_names = list(
      status = rownames(patients.in.hospital.dat),
      date = colnames(patients.in.hospital.dat)))

  # COVID-19 patients in hospital - Confirmed
  patients.in.hospital.dat <- hosp.country.dat %>%
    dplyr::filter(grepl("hospital - Confirmed$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "test_result/date-country-covid19_patients_in_hospital",
    array = as.matrix(patients.in.hospital.dat),
    dimension_names = list(
      status = rownames(patients.in.hospital.dat),
      date = colnames(patients.in.hospital.dat)))

  # COVID-19 patients in ICU - Total (archived)
  # COVID-19 patients in ICU - Suspected (archived)
  # COVID-19 patients in ICU - Confirmed (archived)
  patients.in.icu.dat <- hosp.country.dat %>%
    dplyr::filter(grepl("ICU", variable) & grepl("archived", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "total_suspected_confirmed/date-country-covid19_patients_in_icu-archived",
    array = as.matrix(patients.in.icu.dat),
    dimension_names = list(
      status = rownames(patients.in.icu.dat),
      date = colnames(patients.in.icu.dat)))

  # COVID-19 patients in ICU - Confirmed
  patients.in.icu.dat <- hosp.country.dat %>%
    dplyr::filter(grepl("ICU - Confirmed$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "total_suspected_confirmed/date-country-covid19_patients_in_icu",
    array = as.matrix(patients.in.icu.dat),
    dimension_names = list(
      status = rownames(patients.in.icu.dat),
      date = colnames(patients.in.icu.dat)))


  # Special health board ----------------------------------------------------

  hosp.special.dat <- hospital.dat %>%
    dplyr::filter(areatypename == "Special board")

  assert_that(length(unique(hosp.special.dat$featurename)) == 1)

  # COVID-19 patients in hospital - Suspected (archived)
  # COVID-19 patients in hospital - Confirmed (archived)
  special.patients.in.hosp.dat <- hosp.special.dat %>%
    dplyr::filter(grepl("hospital", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "confirmed_suspected/date-golden_jubilee-covid19_patients_in_hospital",
    array = as.matrix(special.patients.in.hosp.dat),
    dimension_names = list(
      status = rownames(special.patients.in.hosp.dat),
      date = colnames(special.patients.in.hosp.dat)))

  # COVID-19 patients in ICU - Total
  special.patients.in.icu.dat <- hosp.special.dat %>%
    dplyr::filter(grepl("ICU", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "date-golden_jubilee-covid19_patients_in_icu-total",
    array = as.matrix(special.patients.in.icu.dat),
    dimension_names = list(
      status = rownames(special.patients.in.icu.dat),
      date = colnames(special.patients.in.icu.dat)))


  # NHS health board --------------------------------------------------------

  hosp.nhs.dat <- hospital.dat %>%
    dplyr::filter(areatypename == "NHS board")

  # COVID-19 patients in ICU - Total
  hosp.nhs.total.dat <- hosp.nhs.dat %>%
    dplyr::filter(grepl("Total", variable)) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::create_array(filename = filename,
                            path = path,
                            component = "nhs_health_board/date-covid19_patients_in_icu-total",
                            array = as.matrix(hosp.nhs.total.dat),
                            dimension_names = list(
                              `health board` = rownames(hosp.nhs.total.dat),
                              date = colnames(hosp.nhs.total.dat)))

  # COVID-19 patients in hospital - Suspected
  hosp.nhs.suspected.dat <- hosp.nhs.dat %>%
    dplyr::filter(grepl("Suspected", variable)) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "nhs_health_board/date-covid19_patients_in_hospital-suspected",
    array = as.matrix(hosp.nhs.suspected.dat),
    dimension_names = list(
      `health board` = rownames(hosp.nhs.suspected.dat),
      date = colnames(hosp.nhs.suspected.dat)))

  # COVID-19 patients in hospital - Confirmed
  hosp.nhs.confirmed.dat <- hosp.nhs.dat %>%
    dplyr::filter(grepl("Confirmed", variable)) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::create_array(
    filename = filename,
    path = path,
    component = "nhs_health_board/date-covid19_patients_in_hospital-confirmed",
    array = as.matrix(hosp.nhs.confirmed.dat),
    dimension_names = list(
      `health board` = rownames(hosp.nhs.confirmed.dat),
      date = colnames(hosp.nhs.confirmed.dat)))
}
