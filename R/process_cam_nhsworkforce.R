#' process_cam_nhsworkforce
#'
#' Process a subset of the cases-and-management dataset
#'
#' @param handle list
#' @param input_path a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#'
#' @export
#'
process_cam_nhsworkforce <- function(handle, input_path) {

  data_product <- "records/SARS-CoV-2/scotland/cases-and-management/nhsworkforce"

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

  # Extract nhs workforce data
  nhsworkforce.dat <- scotMan %>%
    dplyr::filter(grepl("NHS workforce COVID-19 absences", variable))

  sort(unique(nhsworkforce.dat$variable))

  # -------------------------------------------------------------------------

  # Other staff
  nhs.other <- nhsworkforce.dat %>%
    dplyr::filter(grepl("Other staff", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  rFDP::write_array(
    array = as.matrix(nhs.other),
    handle = handle,
    data_product = data_product,
    component = "date-country-covid_related_absences-other_staff",
    description = "COVID-related absences for other staff",
    dimension_names = list(
      date = rownames(nhs.other),
      count = colnames(nhs.other)))

  # Medical and dental staff
  nhs.medical.dental <- nhsworkforce.dat %>%
    dplyr::filter(grepl("Medical and dental staff", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  rFDP::write_array(
    array = as.matrix(nhs.medical.dental),
    handle = handle,
    data_product = data_product,
    component = "date-country-covid_related_absences-medical_and_dental_staff",
    description = "COVID-related absences for medical and dental staff",
    dimension_names = list(
      date = rownames(nhs.medical.dental),
      count = colnames(nhs.medical.dental)))

  # All staff
  nhs.all <- nhsworkforce.dat %>%
    dplyr::filter(grepl("All staff", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  rFDP::write_array(
    array = as.matrix(nhs.all),
    handle = handle,
    data_product = data_product,
    component = "date-country-covid_related_absences-all_staff",
    description = "COVID-related absences for all staff",
    dimension_names = list(
      date = rownames(nhs.all),
      count = colnames(nhs.all)))

  # Nursing and midwifery staff
  nhs.nursing.midwifery <- nhsworkforce.dat %>%
    dplyr::filter(grepl("Nursing and midwifery staff", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  rFDP::write_array(
    array = as.matrix(nhs.nursing.midwifery),
    handle = handle,
    data_product = data_product,
    component = "date-country-covid_related_absences-nursing_and_midwifery_staff",
    description = "COVID-related absences for nursing and midwifery staff",
    dimension_names = list(
      date = rownames(nhs.nursing.midwifery),
      count = colnames(nhs.nursing.midwifery)))
}
