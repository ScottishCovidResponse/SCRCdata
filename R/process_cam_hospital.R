#' process_cam_hospital
#'
#' Process a subset of the cases-and-management dataset
#'
#' @param handle list
#' @param input_path a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#'
#' @export
#'
process_cam_hospital <- function(handle, input_path) {

  data_product <- "records/SARS-CoV-2/scotland/cases-and-management/hospital"

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
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(array = as.matrix(discharges.dat),
                           handle = handle,
                           data_product = data_product,
                           component = "date-delayed_discharges",
                           description = "delayed discharges",
                           dimension_names = list(
                             date = rownames(discharges.dat)))


  # Country -----------------------------------------------------------------

  hosp.country.dat <- hospital.dat %>%
    dplyr::filter(areatypename == "Country")

  sort(unique(hosp.country.dat$variable))

  # COVID-19 patients in hospital - Total (archived)
  # COVID-19 patients in hospital - Confirmed (archived)
  # COVID-19 patients in hospital - Suspected (archived)
  patients.in.hospital.dat <- hosp.country.dat %>%
    dplyr::filter(grepl("hospital", variable) & grepl("archived", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  component_id <- SCRCdataAPI::write_array(
    array = as.matrix(patients.in.hospital.dat),
    handle = handle,
    data_product = data_product,
    component = "total_suspected_confirmed/date-country-covid19_patients_in_hospital-archived",
    description = "total, suspected, and confirmed COVID patients in hospital (archived)",
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

  component_id <- SCRCdataAPI::write_array(
    array = as.matrix(patients.in.icu.dat),
    handle = handle,
    data_product = data_product,
    component = "total_suspected_confirmed/date-country-covid19_patients_in_icu-archived",
    description = "total, suspected, and confirmed COVID patients in ICU (archived)",
    dimension_names = list(
      status = rownames(patients.in.icu.dat),
      date = colnames(patients.in.icu.dat)))

  # "COVID-19 patients in hospital - Confirmed - Length of stay 28 days or less"
  # "COVID-19 patients in ICU - Confirmed - Length of stay 28 days or less"
  # "COVID-19 patients in ICU - Confirmed - Length of stay more than 28 days"


  # Special health board ----------------------------------------------------

  hosp.special.dat <- hospital.dat %>%
    dplyr::filter(areatypename == "Special board")

  sort(unique(hosp.special.dat$variable))

  assert_that(length(unique(hosp.special.dat$featurename)) == 1)

  # COVID-19 patients in hospital - Suspected (archived)
  # COVID-19 patients in hospital - Confirmed (archived)
  special.patients.in.hosp.dat <- hosp.special.dat %>%
    dplyr::filter(grepl("hospital", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::write_array(
    array = as.matrix(special.patients.in.hosp.dat),
    handle = handle,
    data_product = data_product,
    component = "confirmed_suspected/date-golden_jubilee-covid19_patients_in_hospital-archived",
    description = "confirmed and suspected COVID patients in special boards (archived)",
    dimension_names = list(
      status = rownames(special.patients.in.hosp.dat),
      date = colnames(special.patients.in.hosp.dat)))

  # "COVID-19 patients in hospital - Confirmed"
  # "COVID-19 patients in hospital - Confirmed"
  # "COVID-19 patients in ICU - Confirmed"
  # "COVID-19 patients in ICU - Confirmed (archived)"
  # "COVID-19 patients in ICU - Total (archived)"


  # NHS health board --------------------------------------------------------

  hosp.nhs.dat <- hospital.dat %>%
    dplyr::filter(areatypename == "NHS board")

  sort(unique(hosp.nhs.dat$variable))

  # COVID-19 patients in ICU - Total (archived)
  hosp.nhs.total.dat <- hosp.nhs.dat %>%
    dplyr::filter(grepl("ICU - Total \\(archived\\)", variable)) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(hosp.nhs.total.dat),
    handle = handle,
    data_product = data_product,
    component = "nhs_health_board/date-covid19_patients_in_icu-total-archived",
    description = "total COVID patients in ICU by NHS health board (archived)",
    dimension_names = list(
      `health board` = rownames(hosp.nhs.total.dat),
      date = colnames(hosp.nhs.total.dat)))

  # COVID-19 patients in hospital - Suspected (archived)
  hosp.nhs.suspected.dat <- hosp.nhs.dat %>%
    dplyr::filter(grepl("hospital - Suspected \\(archived\\)", variable)) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(hosp.nhs.suspected.dat),
    handle = handle,
    data_product = data_product,
    component = "nhs_health_board/date-covid19_patients_in_hospital-suspected-archived",
    description = "suspected COVID patients in hospital by NHS health board (archived)",
    dimension_names = list(
      `health board` = rownames(hosp.nhs.suspected.dat),
      date = colnames(hosp.nhs.suspected.dat)))

  # COVID-19 patients in hospital - Confirmed (archived)
  hosp.nhs.confirmed.dat <- hosp.nhs.dat %>%
    dplyr::filter(grepl("hospital - Confirmed \\(archived\\)", variable)) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(hosp.nhs.confirmed.dat),
    handle = handle,
    data_product = data_product,
    component = "nhs_health_board/date-covid19_patients_in_hospital-confirmed-archived",
    description = "confirmed COVID patients in hospital by NHS health board (archived)",
    dimension_names = list(
      `health board` = rownames(hosp.nhs.confirmed.dat),
      date = colnames(hosp.nhs.confirmed.dat)))

  # COVID-19 patients in ICU - Confirmed (archived)
  tmp <- hosp.nhs.dat %>%
    dplyr::filter(grepl("ICU - Confirmed \\(archived\\)", variable)) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "nhs_health_board/date-covid19_patients_in_icu-confirmed-archived",
    description = "confirmed COVID patients in ICU by NHS health board (archived)",
    dimension_names = list(
      `health board` = rownames(tmp),
      date = colnames(tmp)))

  # COVID-19 patients in hospital - Confirmed
  tmp <- hosp.nhs.dat %>%
    dplyr::filter(grepl("hospital - Confirmed$", variable)) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "nhs_health_board/date-covid19_patients_in_hospital-confirmed",
    description = "confirmed COVID patients in hospital",
    dimension_names = list(
      `health board` = rownames(tmp),
      date = colnames(tmp)))

  # COVID-19 patients in ICU - Confirmed
  tmp <- hosp.nhs.dat %>%
    dplyr::filter(grepl("ICU - Confirmed$", variable)) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(tmp),
    handle = handle,
    data_product = data_product,
    component = "nhs_health_board/date-covid19_patients_in_icu-confirmed",
    description = "confirmed COVID patients in ICU by NHS health board",
    dimension_names = list(
      `health board` = rownames(tmp),
      date = colnames(tmp)))
}
