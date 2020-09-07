#' process_cam_carehomes
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
process_cam_carehomes <- function(sourcefile, filename) {

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

  # Extract carehomes data
  carehomes.dat <- scotMan %>%
    dplyr::filter(grepl("Adult care homes", variable))


  # -------------------------------------------------------------------------

  # Total number of staff in adult care homes which submitted a return
  carehomes.count.total.staff.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Total number of staff", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-staff_in_adult_carehomes_which_submitted_a_return",
    array = as.matrix(carehomes.count.total.staff.dat),
    dimension_names = list(
      delayed = rownames(carehomes.count.total.staff.dat),
      date = colnames(carehomes.count.total.staff.dat)))

  # Adult care homes which submitted a return
  carehomes.count.carehomes.return.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Adult care homes which submitted a return",
                        variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-adult_carehomes_which_submitted_a_return",
    array = as.matrix(carehomes.count.carehomes.return.dat),
    dimension_names = list(
      delayed = rownames(carehomes.count.carehomes.return.dat),
      date = colnames(carehomes.count.carehomes.return.dat)))

  # Response rate
  carehomes.ratio.response.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Response rate", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-response_rate",
    array = as.matrix(carehomes.ratio.response.dat),
    dimension_names = list(
      delayed = rownames(carehomes.ratio.response.dat),
      date = colnames(carehomes.ratio.response.dat)))

  # Staff absence rate
  carehomes.ratio.staff.absence.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Staff absence rate", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-staff_absence_rate",
    array = as.matrix(carehomes.ratio.staff.absence.dat),
    dimension_names = list(
      delayed = rownames(carehomes.ratio.staff.absence.dat),
      date = colnames(carehomes.ratio.staff.absence.dat)))

  # Number of staff reported as absent
  carehomes.count.staff.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Number of staff reported as absent", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-staff_reported_absent",
    array = as.matrix(carehomes.count.staff.dat),
    dimension_names = list(
      delayed = rownames(carehomes.count.staff.dat),
      date = colnames(carehomes.count.staff.dat)))
}
