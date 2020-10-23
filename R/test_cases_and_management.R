#' test_cases_and_management
#'
#' @param df dataframe
#'
test_cases_and_management <- function(df) {
  # Check column names match
  assertthat::assert_that(
    all(sort(unique(df$variable)) %in%
          c("Adult care homes - Adult care homes which submitted a return",
            "Adult care homes - Number of staff reported as absent",
            "Adult care homes - Response rate",
            "Adult care homes - Staff absence rate",
            "Adult care homes - Total number of staff in adult care homes which submitted a return",
            "Ambulance attendances - COVID-19 suspected",
            "Ambulance attendances - COVID-19 suspected patients taken to hospital",
            "Ambulance attendances - Total",
            "Calls - Coronavirus helpline",
            "Calls - NHS24 111",
            "COVID-19 patients in hospital - Confirmed",
            "COVID-19 patients in hospital - Confirmed (archived)",
            "COVID-19 patients in hospital - Suspected (archived)",
            "COVID-19 patients in hospital - Total (archived)",
            "COVID-19 patients in ICU - Confirmed",
            "COVID-19 patients in ICU - Confirmed (archived)",
            "COVID-19 patients in ICU - Suspected (archived)",
            "COVID-19 patients in ICU - Total (archived)",
            "Delayed discharges",
            "NHS workforce COVID-19 absences - All staff",
            "NHS workforce COVID-19 absences - Medical and dental staff",
            "NHS workforce COVID-19 absences - Nursing and midwifery staff",
            "NHS workforce COVID-19 absences - Other staff",
            "Number of COVID-19 confirmed deaths registered to date",
            "School education - Number of pupils absent due to COVID-19 related reasons",
            "School education - Percentage absence due to COVID-19 related reasons",
            "School education - Percentage absence for non COVID-19 related reasons",
            "School education - Percentage attendance",
            "Testing - Cumulative people tested for COVID-19 - Negative",
            "Testing - Cumulative people tested for COVID-19 - Positive",
            "Testing - Cumulative people tested for COVID-19 - Total",

            "Testing - New cases as percentage of people newly tested",
            "Testing - New cases reported",
            "Testing - People with first test results in last 7 days",
            "Testing - Positive cases reported in last 7 days",
            "Testing - Positive tests reported in last 7 days",
            "Testing - Test positivity (percent of tests that are positive)",
            "Testing - Test positivity rate in last 7 days",
            "Testing - Tests in last 7 days per 1000 population",
            "Testing - Tests reported in last 7 days",
            "Testing - Total daily number of positive tests reported",
            "Testing - Total daily tests reported",
            "Testing - Total number of COVID-19 tests reported by NHS Labs - Cumulative",
            "Testing - Total number of COVID-19 tests reported by NHS Labs - Daily",
            "Testing - Total number of COVID-19 tests reported by UK Gov testing programme - Cumulative",
            "Testing - Total number of COVID-19 tests reported by UK Gov testing programme - Daily")
    ))
}
