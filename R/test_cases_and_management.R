#' test_cases_and_management
#'
#' @param df dataframe
#'
test_cases_and_management <- function(df) {
  # Check column names match
  assertthat::assert_that(
    all(unique(df$variable) %in%
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
}