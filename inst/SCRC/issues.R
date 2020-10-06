
key <- readLines("token/token.txt")

my_fun <- function(description, severity, dp_name, versions, components) {
  entries <- lapply(versions, function(this_version) {
    object_id <- get_entry("data_product",
                           list(name = dp_name,
                                version = this_version))[[1]]$object
    object_id <- gsub("https://data.scrc.uk/api/object/", "", object_id)
    object_id <- gsub("/", "", object_id)

    lapply(components, function(this_component) {
      attach_issue(description = description,
                   severity = severity,
                   namespace = "SCRC",
                   data_product = dp_name,
                   component = this_component,
                   version = this_version,
                   key = key)
    })
  })
}


# -------------------------------------------------------------------------

description <- "Data dump caused a spike on the 15th of June"
severity <- 19

dp_name <- "records/SARS-CoV-2/scotland/cases-and-management/testing"
versions <- list("0.20200923.0", "0.20200922.0", "0.20200921.0", "0.20200920.0",
                 "0.20200919.0", "0.20200916.0", "0.20200915.0", "0.20200914.0",
                 "0.20200910.0", "0.20200909.0", "0.20200908.0")
components <- list("date-country-people_tested-last_7_days")

my_fun(description, severity, dp_name, versions, components)


# -------------------------------------------------------------------------

description <- "COVID-19 data by NHS Board contains *s which represent a count of <5 (?). These have been changed to 0 in the dataset."
severity <- 10

# "Testing - Cumulative people tested for COVID-19 - Positive"
dp_name <- "records/SARS-CoV-2/scotland/cases-and-management/testing"
versions <- list("0.20200923.0", "0.20200922.0", "0.20200921.0", "0.20200920.0",
                 "0.20200919.0", "0.20200916.0", "0.20200915.0", "0.20200914.0",
                 "0.20200910.0", "0.20200909.0", "0.20200908.0")
components <- list("test_result/date-people_tested_for_covid19-cumulative")

my_fun(description, severity, dp_name, versions, components)

# "COVID-19 patients in ICU - Total"
dp_name <- "records/SARS-CoV-2/scotland/cases-and-management/hospital"
versions <- list("0.20200923.0", "0.20200922.0", "0.20200921.0", "0.20200920.0",
                 "0.20200919.0", "0.20200916.0", "0.20200915.0", "0.20200914.0",
                 "0.20200910.0", "0.20200909.0", "0.20200908.0")
components <- list("total_suspected_confirmed/date-country-covid19_patients_in_icu")

my_fun(description, severity, dp_name, versions, components)

# "COVID-19 patients in hospital - Confirmed"
# "COVID-19 patients in hospital - Suspected"
dp_name <- "records/SARS-CoV-2/scotland/cases-and-management/hospital"
versions <- list("0.20200923.0", "0.20200922.0", "0.20200921.0", "0.20200920.0",
                 "0.20200919.0", "0.20200916.0", "0.20200915.0", "0.20200914.0",
                 "0.20200910.0", "0.20200909.0", "0.20200908.0")
components <- list("test_result/date-country-covid19_patients_in_hospital")

my_fun(description, severity, dp_name, versions, components)


# -------------------------------------------------------------------------

description <- "Copy and paste error. This is the date-country-people_found_positive-daily component"
severity <- 19

dp_name <- "records/SARS-CoV-2/scotland/cases-and-management/testing"
versions <- list("0.20200922.0", "0.20200921.0", "0.20200920.0", "0.20200919.0",
                 "0.20200916.0", "0.20200915.0", "0.20200914.0", "0.20200910.0",
                 "0.20200909.0", "0.20200908.0")
components <- list("date-country-people_tested-last_7_days",
                   "date-country-positive_cases-last_7_days",
                   "date-country-tests-daily",
                   "date-country-tests-last_7_days")

my_fun(description, severity, dp_name, versions, components)
