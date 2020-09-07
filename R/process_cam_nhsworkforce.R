#' process_cam_nhsworkforce
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
process_cam_nhsworkforce <- function(sourcefile, filename) {

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

  # Extract nhs workforce data
  nhsworkforce.dat <- scotMan %>%
    dplyr::filter(grepl("NHS workforce COVID-19 absences", variable))


  # -------------------------------------------------------------------------

  # Other staff
  nhs.other <- nhsworkforce.dat %>%
    dplyr::filter(grepl("Other staff", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-covid_related_absences-other_staff",
    array = as.matrix(nhs.other),
    dimension_names = list(
      delayed = rownames(nhs.other),
      date = colnames(nhs.other)))

  # Medical and dental staff
  nhs.medical.dental <- nhsworkforce.dat %>%
    dplyr::filter(grepl("Medical and dental staff", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-covid_related_absences-medical_and_dental_staff",
    array = as.matrix(nhs.medical.dental),
    dimension_names = list(
      delayed = rownames(nhs.medical.dental),
      date = colnames(nhs.medical.dental)))

  # All staff
  nhs.all <- nhsworkforce.dat %>%
    dplyr::filter(grepl("All staff", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-covid_related_absences-all_staff",
    array = as.matrix(nhs.all),
    dimension_names = list(
      delayed = rownames(nhs.all),
      date = colnames(nhs.all)))

  # Nursing and midwifery staff
  nhs.nursing.midwifery <- nhsworkforce.dat %>%
    dplyr::filter(grepl("Nursing and midwifery staff", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-covid_related_absences-nursing_and_midwifery_staff",
    array = as.matrix(nhs.nursing.midwifery),
    dimension_names = list(
      delayed = rownames(nhs.nursing.midwifery),
      date = colnames(nhs.nursing.midwifery)))
}
