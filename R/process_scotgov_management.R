#' process_scotgov_management
#'
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param filename a \code{string} specifying the local path and filename
#' associated with the processed data (the output of this function)
#'
#' @export
#'
process_scotgov_management <- function(sourcefile, filename) {

  scotMan <- read.csv(file = sourcefile) %>%
    dplyr::mutate(featurecode = gsub(
      "http://statistics.gov.scot/id/statistical-geography/",
      "", featurecode),
      featurecode = gsub(">", "", featurecode)) %>%
    dplyr::mutate(count = dplyr::case_when(count == "*" ~ "0",
                                           T ~ count)) %>%
    dplyr::mutate(count = as.numeric(count))

  variables <- scotMan %>% select(variable) %>% unique()

  assertthat::assert_that(
    all(unique(scotMan$variable) %in%
      c("Testing - Cumulative people tested for COVID-19 - Negative",
        "Testing - Cumulative people tested for COVID-19 - Positive",
        "Testing - Cumulative people tested for COVID-19 - Total",
        "Testing - Daily people found positive",
        "Delayed discharges",
        "Number of COVID-19 confirmed deaths registered to date",
        "Calls - NHS24 111",
        "Calls - Coronavirus helpline",
        "COVID-19 patients in ICU - Total",
        "Ambulance attendances - COVID-19 suspected",
        "Ambulance attendances - Total",
        "COVID-19 patients in hospital - Total",
        "Ambulance attendances - COVID-19 suspected patients taken to hospital",
        "COVID-19 patients in hospital - Suspected",
        "COVID-19 patients in hospital - Confirmed",
        "COVID-19 patients in ICU - Suspected",
        "COVID-19 patients in ICU - Confirmed",
        "NHS workforce COVID-19 absences - Nursing and midwifery staff",
        "Testing - Total daily tests",
        "Testing - Total number of COVID-19 tests carried out by NHS Labs - Daily",
        "Testing - Total number of COVID-19 tests carried out by NHS Labs - Cumulative",
        "Testing - Positive cases in last 7 days",
        "Testing - People tested in last 7 days",
        "NHS workforce COVID-19 absences - All staff",
        "NHS workforce COVID-19 absences - Other staff",
        "NHS workforce COVID-19 absences - Medical and dental staff",
        "Testing - Total number of COVID-19 tests carried out by Regional Testing Centres - Daily",
        "Testing - Total number of COVID-19 tests carried out by Regional Testing Centres - Cumulative",
        "Testing - Tests in last 7 days",
        "Adult care homes - Number of staff reported as absent",
        "Adult care homes - Response rate",
        "Adult care homes - Total number of staff in adult care homes which submitted a return",
        "Adult care homes - Adult care homes which submitted a return",
        "Adult care homes - Staff absence rate",
        "School education - Number of pupils absent due to COVID-19 related reasons",
        "School education - Percentage absence due to COVID-19 related reasons",
        "School education - Percentage absence for non COVID-19 related reasons",
        "School education - Percentage attendance")))

  # 1 -----------------------------------------------------------------------
  # Numbers of calls to NHS 111 and the coronavirus helpline
  calls.dat <- scotMan %>% dplyr::filter(grepl("Calls", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    dplyr::mutate(variable = gsub("Calls - ", "", variable)) %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(filename = filename,
                            component = "call_centre/date-number_of_calls",
                            array = as.matrix(calls.dat),
                            dimension_names = list(
                              helpline = rownames(calls.dat),
                              date = colnames(calls.dat)))

  variables <- filter(variables, !grepl("Calls", variable))

  # 2 -----------------------------------------------------------------------
  # Numbers of people in hospital and in ICU with confirmed or suspected COVID-19
  hospital.dat <- scotMan %>%
    dplyr::filter(grepl("COVID-19 patients", variable)) %>%
    dplyr::mutate(
      featurecode = gsub("http://statistics.gov.scot/id/statistical-geography/",
                         "", featurecode),
      areatypename = dplyr::case_when(
        featurename == "Scotland" ~ "Country",
        nchar(featurecode) == 6 ~ "Special board",
        T ~ "NHS board"
      ))

  # unique(hospital.dat$variable)

  # Country
  hosp.country.dat <- hospital.dat %>%
    dplyr::filter(areatypename == "Country")

  patients.in.hospital.dat <- hosp.country.dat %>%
    dplyr::filter(grepl("hospital", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "confirmed_suspected_total/date-country-hospital",
    array = as.matrix(patients.in.hospital.dat),
    dimension_names = list(
      status = rownames(patients.in.hospital.dat),
      date = colnames(patients.in.hospital.dat)))

  patients.in.icu.dat <- hosp.country.dat %>%
    dplyr::filter(grepl("ICU", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "confirmed_suspected_total/date-country-icu",
    array = as.matrix(patients.in.icu.dat),
    dimension_names = list(
      status = rownames(patients.in.icu.dat),
      date = colnames(patients.in.icu.dat)))

  # Special health board
  hosp.special.dat <- hospital.dat %>%
    dplyr::filter(areatypename == "Special board")

  special.patients.in.hosp.dat <- hosp.special.dat %>%
    dplyr::filter(grepl("hospital", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "confirmed_suspected/date-country-hospital-special_health_board",
    array = as.matrix(special.patients.in.hosp.dat),
    dimension_names = list(
      status = rownames(special.patients.in.hosp.dat),
      date = colnames(special.patients.in.hosp.dat)))

  special.patients.in.icu.dat <- hosp.special.dat %>%
    dplyr::filter(grepl("ICU", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-icu-special_health_board-total",
    array = as.matrix(special.patients.in.icu.dat),
    dimension_names = list(
      status = rownames(special.patients.in.icu.dat),
      date = colnames(special.patients.in.icu.dat)))

  # NHS health board
  hosp.nhs.dat <- hospital.dat %>%
    dplyr::filter(areatypename == "NHS board")

  hosp.nhs.total.dat <- hosp.nhs.dat %>%
    dplyr::filter(grepl("Total", variable)) %>%
    reshape2::dcast(featurecode ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(filename = filename,
                            component = "nhs_health_board/date-icu-total",
                            array = as.matrix(hosp.nhs.total.dat),
                            dimension_names = list(
                              `health board` = rownames(hosp.nhs.total.dat),
                              date = colnames(hosp.nhs.total.dat)))

  hosp.nhs.suspected.dat <- hosp.nhs.dat %>%
    dplyr::filter(grepl("Suspected", variable)) %>%
    reshape2::dcast(featurecode ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "nhs_health_board/date-hospital-suspected",
    array = as.matrix(hosp.nhs.suspected.dat),
    dimension_names = list(
      `health board` = rownames(hosp.nhs.suspected.dat),
      date = colnames(hosp.nhs.suspected.dat)))

  hosp.nhs.confirmed.dat <- hosp.nhs.dat %>%
    dplyr::filter(grepl("Confirmed", variable)) %>%
    reshape2::dcast(featurecode ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "nhs_health_board/date-hospital-confirmed",
    array = as.matrix(hosp.nhs.confirmed.dat),
    dimension_names = list(
      `health board` = rownames(hosp.nhs.confirmed.dat),
      date = colnames(hosp.nhs.confirmed.dat)))

  variables <- filter(variables, !grepl("COVID-19 patients", variable))

  # 3 -----------------------------------------------------------------------
  # Numbers of ambulance attendances (total and COVID-19 suspected) and number of
  # people taken to hospital with suspected COVID-19
  ambulance.dat <- scotMan %>%
    dplyr::filter(grepl("Ambulance attendances", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(filename = filename,
                            component = "ambulance_attendances/date",
                            array = as.matrix(ambulance.dat),
                            dimension_names = list(
                              status = rownames(ambulance.dat),
                              date = colnames(ambulance.dat)))

  variables <- filter(variables, !grepl("Ambulance attendances", variable))

  # 4 -----------------------------------------------------------------------
  # Number of people delayed in hospital
  discharges.dat <- scotMan %>%
    dplyr::filter(grepl("Delayed discharges", variable)) %>%
    reshape2::dcast(1 ~ date, value.var = "count") %>%
    dplyr::select(-"1")

  SCRCdataAPI::create_array(filename = filename,
                            component = "date-delayed_discharges",
                            array = as.matrix(discharges.dat),
                            dimension_names = list(
                              delayed = rownames(discharges.dat),
                              date = colnames(discharges.dat)))

  variables <- filter(variables, !grepl("Delayed discharges", variable))

  # 5 -----------------------------------------------------------------------
  # Numbers of people tested to date, numbers with positive and negative results,
  # and numbers of tests carried out
  testing.dat <- scotMan %>% dplyr::filter(grepl("Testing", variable)) %>%
    dplyr::mutate(areatypename = dplyr::case_when(
      featurename == "Scotland" ~ "Country",
      nchar(featurecode) == 6 ~ "Special board",
      T ~ "NHS board"
    ))

  # unique(testing.dat$variable)

  # Country
  testing.country.dat <- testing.dat %>%
    dplyr::filter(areatypename == "Country")

  testing.daily.positive <- testing.country.dat %>%
    dplyr::filter(grepl("Daily people found positive", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-tested_positive",
    array = as.matrix(testing.daily.positive),
    dimension_names = list(
      delayed = rownames(testing.daily.positive),
      date = colnames(testing.daily.positive)))

  testing.cumulative <- testing.country.dat %>%
    dplyr::filter(grepl("- Cumulative$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "testing_location/date-cumulative",
    array = as.matrix(testing.cumulative),
    dimension_names = list(
      delayed = rownames(testing.cumulative),
      date = colnames(testing.cumulative)))

  testing.daily <- testing.country.dat %>%
    dplyr::filter(grepl("- Daily$", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "testing_location/date",
    array = as.matrix(testing.daily),
    dimension_names = list(
      delayed = rownames(testing.daily),
      date = colnames(testing.daily)))

  testing.country.cumulative <- testing.country.dat %>%
    dplyr::filter(grepl("Cumulative people tested", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "test_result/date-cumulative",
    array = as.matrix(testing.country.cumulative),
    dimension_names = list(
      delayed = rownames(testing.country.cumulative),
      date = colnames(testing.country.cumulative)))

  # Special health board
  assertthat::assert_that(!"Special board" %in% testing.dat$areatypename)

  # NHS health board
  testing.area.dat <- testing.dat %>%
    dplyr::filter(areatypename == "NHS board") %>%
    reshape2::dcast(featurecode ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "nhs_health_board/date-testing-cumulative",
    array = as.matrix(testing.area.dat),
    dimension_names = list(
      delayed = rownames(testing.area.dat),
      date = colnames(testing.area.dat)))

  variables <- filter(variables, !grepl("Testing", variable))

  # 6 -----------------------------------------------------------------------
  # Numbers of NHS workforce reporting as absent due to a range of reasons
  # related to Covid-19
  nhs.dat <- scotMan %>% dplyr::filter(grepl("NHS workforce", variable)) %>%
    dplyr::mutate(variable = gsub("NHS workforce COVID-19 absences - ", "",
                                  variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "nhs_workforce/date-country-covid_related_absences",
    array = as.matrix(nhs.dat),
    dimension_names = list(
      delayed = rownames(nhs.dat),
      date = colnames(nhs.dat)))

  variables <- filter(variables, !grepl("NHS workforce", variable))

  # 7 -----------------------------------------------------------------------
  # Number of care homes where suspected COVID-19 has been reported to date
  carehomes.dat <- scotMan %>%
    dplyr::filter(grepl("Adult care homes", variable))

  unique(carehomes.dat$variable)[-c(1,3,4)]

  carehomes.ratio.response.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Response rate", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-carehomes-response_rate",
    array = as.matrix(carehomes.ratio.response.dat),
    dimension_names = list(
      delayed = rownames(carehomes.ratio.response.dat),
      date = colnames(carehomes.ratio.response.dat)))

  carehomes.ratio.staff.absence.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Staff absence rate", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-carehomes-staff_absence_rate",
    array = as.matrix(carehomes.ratio.staff.absence.dat),
    dimension_names = list(
      delayed = rownames(carehomes.ratio.staff.absence.dat),
      date = colnames(carehomes.ratio.staff.absence.dat)))

  carehomes.count.staff.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Number of staff reported as absent", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-carehomes-staff_reported_absent",
    array = as.matrix(carehomes.count.staff.dat),
    dimension_names = list(
      delayed = rownames(carehomes.count.staff.dat),
      date = colnames(carehomes.count.staff.dat)))

  carehomes.count.carehomes.return.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Adult care homes which submitted a return",
                        variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-carehomes-carehomes_submitted_return",
    array = as.matrix(carehomes.count.carehomes.return.dat),
    dimension_names = list(
      delayed = rownames(carehomes.count.carehomes.return.dat),
      date = colnames(carehomes.count.carehomes.return.dat)))

  carehomes.count.total.staff.dat <- carehomes.dat %>%
    dplyr::filter(grepl("Total number of staff", variable)) %>%
    reshape2::dcast(variable ~ date, value.var = "count") %>%
    tibble::column_to_rownames("variable")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "date-country-carehomes-staff_submitted_return",
    array = as.matrix(carehomes.count.total.staff.dat),
    dimension_names = list(
      delayed = rownames(carehomes.count.total.staff.dat),
      date = colnames(carehomes.count.total.staff.dat)))


  # 8 -----------------------------------------------------------------------
  # Number of COVID-19 confirmed deaths registered to date
  deaths.dat <- scotMan %>%
    dplyr::filter(grepl("deaths registered", variable)) %>%
    reshape2::dcast(1 ~ date, value.var = "count") %>%
    dplyr::select(-"1")

  SCRCdataAPI::create_array(filename = filename,
                            component = "date-country-deaths_registered",
                            array = as.matrix(deaths.dat),
                            dimension_names = list(
                              delayed = rownames(deaths.dat),
                              date = colnames(deaths.dat)))

}
