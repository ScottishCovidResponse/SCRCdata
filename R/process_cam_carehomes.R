#' process_cam_carehomes
#'
#' Process a subset of the cases-and-management dataset
#'
#' @param handle list
#' @param input_path a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#'
#' @export
#'
process_cam_carehomes <- function(handle, input_path) {

  data_product <- "records/SARS-CoV-2/scotland/cases-and-management/carehomes"

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

  # Extract carehomes data
  carehomes.dat <- scotMan %>%
    dplyr::filter(grepl("Adult care homes", variable))

  # -------------------------------------------------------------------------

  # Total number of staff in adult care homes which submitted a return
  carehomes.count.total.staff.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Total number of staff", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(carehomes.count.total.staff.dat),
    handle = handle,
    data_product = data_product,
    component = "date-country-staff_in_adult_carehomes_which_submitted_a_return",
    description = "staff in adult carehomes which submitted a return",
    dimension_names = list(
      date = rownames(carehomes.count.total.staff.dat)))

  # Adult care homes which submitted a return
  carehomes.count.carehomes.return.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Adult care homes which submitted a return",
                        variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(carehomes.count.carehomes.return.dat),
    handle = handle,
    data_product = data_product,
    component = "date-country-adult_carehomes_which_submitted_a_return",
    description = "adult carehomes which submitted a return",
    dimension_names = list(
      date = rownames(carehomes.count.carehomes.return.dat)))

  # Response rate
  carehomes.ratio.response.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Response rate", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(carehomes.ratio.response.dat),
    handle = handle,
    data_product = data_product,
    component = "date-country-response_rate",
    description = "response rate",
    dimension_names = list(
      date = rownames(carehomes.ratio.response.dat)))

  # Staff absence rate
  carehomes.ratio.staff.absence.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Staff absence rate", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")


  SCRCdataAPI::write_array(
    array = as.matrix(carehomes.ratio.staff.absence.dat),
    handle = handle,
    data_product = data_product,
    component = "date-country-staff_absence_rate",
    description = "staff absence rate",
    dimension_names = list(
      date = rownames(carehomes.ratio.staff.absence.dat)))

  # Number of staff reported as absent
  carehomes.count.staff.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Number of staff reported as absent", variable)) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  data_product_id <- SCRCdataAPI::write_array(
    array = as.matrix(carehomes.count.staff.dat),
    handle = handle,
    data_product = data_product,
    component = "date-country-staff_reported_absent",
    description = "staff reported absent",
    dimension_names = list(
      date = rownames(carehomes.count.staff.dat)))

  SCRCdataAPI::issue_with_dataproduct(
    data_product_id = data_product_id,
    handle = handle,
    issue = "Issue with carehomes data product (example of an issue).",
    severity = 2)
}
