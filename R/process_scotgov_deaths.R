#' process_scotgov_deaths
#'
#' @param handle list
#' @param input_path a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#'
#' @export
#'
process_scotgov_deaths <- function(handle, input_path) {

  # Extract directory and filename
  # path <- dirname(output_file)
  # output_file <- basename(output_file)

  scotDeaths <- read.csv(file = input_path, stringsAsFactors = F) %>%
    dplyr::mutate(featurename = gsub(
      "<http://statistics.gov.scot/id/statistical-geography/", "",
      featurename),
      featurename = gsub("http://statistics.gov.scot/id/statistical-geography/",
                         "", featurename))

  assertthat::assert_that(
    all(unique(scotDeaths$cause) %in%
          c("COVID-19 related", "All causes",
            "All causes - average of corresponding week over previous 5 years")))

  # COVID-19 related --------------------------------------------------------

  covid_deaths <- scotDeaths %>%
    dplyr::filter(cause == "COVID-19 related") %>%
    dplyr::select(-type)

  # Per week ----
  cd_week <- covid_deaths %>%
    dplyr::filter(nchar(date) != 4) %>%
    dplyr::mutate(date = gsub("^w/c ", "", date))

  assertthat::assert_that(
    all(unique(cd_week$areatypename) %in% c("Health Board Areas",
                                            "Council Areas", "Country")))

  # Per week / Health Board Areas
  covid_deaths_per_week_by_nhsboard <- cd_week %>%
    dplyr::filter(areatypename == "Health Board Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(covid_deaths_per_week_by_nhsboard),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "nhs_health_board/week-covid_related_deaths",
    dimension_names = list(
      `health board` = rownames(covid_deaths_per_week_by_nhsboard),
      `week commencing` = colnames(
        covid_deaths_per_week_by_nhsboard)))

  # Per week / Council Areas
  covid_deaths_per_week_by_councilarea <- cd_week %>%
    dplyr::filter(areatypename == "Council Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(covid_deaths_per_week_by_councilarea),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "council_area/week-covid_related_deaths",
    dimension_names = list(
      `council area` = rownames(
        covid_deaths_per_week_by_councilarea),
      `week commencing` = colnames(
        covid_deaths_per_week_by_councilarea)))

  # Per week / Country / Per age group
  cd_week_country <- cd_week %>%
    dplyr::filter(areatypename == "Country") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  covid_deaths_per_week_by_agegroup <- cd_week_country %>%
    dplyr::filter(age != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # Per week / Country / Per age group / Female
  covid_deaths_per_week_by_agegroup_f <- covid_deaths_per_week_by_agegroup %>%
    dplyr::filter(gender == "Female") %>%
    reshape2::dcast(age ~ date, value.var = "count") %>%
    tibble::column_to_rownames("age")

  # Per week / Country / Per age group / Male
  covid_deaths_per_week_by_agegroup_m <- covid_deaths_per_week_by_agegroup %>%
    dplyr::filter(gender == "Male") %>%
    reshape2::dcast(age ~ date, value.var = "count") %>%
    tibble::column_to_rownames("age")

  female <- as.matrix(covid_deaths_per_week_by_agegroup_f)
  male <- as.matrix(covid_deaths_per_week_by_agegroup_m)

  assertthat::assert_that(all(dim(female) == dim(male)))
  assertthat::assert_that(all(rownames(covid_deaths_per_week_by_agegroup_f) ==
                                rownames(covid_deaths_per_week_by_agegroup_m)))
  assertthat::assert_that(all(colnames(
    covid_deaths_per_week_by_agegroup_f) == colnames(
      covid_deaths_per_week_by_agegroup_m)))

  SCRCdataAPI::write_array(
    array = array(c(female, male),
                  dim = c(dim(female), 2)),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "age_group/week/gender-country-covid_related_deaths",
    dimension_names = list(
      `age group` = rownames(covid_deaths_per_week_by_agegroup_f),
      `week commencing` = colnames(covid_deaths_per_week_by_agegroup_f),
      gender = c("female", "male")))

  # Per week / Country / Per age group / All genders
  covid_deaths_per_week_by_agegroup_all <- covid_deaths_per_week_by_agegroup %>%
    dplyr::filter(gender == "All") %>%
    reshape2::dcast(age ~ date, value.var = "count") %>%
    tibble::column_to_rownames("age")

  SCRCdataAPI::write_array(
    array = as.matrix(covid_deaths_per_week_by_agegroup_all),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "age_group/week-persons-country-covid_related_deaths",
    dimension_names = list(
      `age group` = rownames(covid_deaths_per_week_by_agegroup_all),
      `week commencing` = colnames(
        covid_deaths_per_week_by_agegroup_all)))

  # Per week / Country / All ages
  cd_week_allages <- cd_week_country %>%
    dplyr::filter(age == "All")

  # Per week / Country / All ages / Per location
  covid_deaths_per_week_by_location <- cd_week_allages %>%
    dplyr::filter(location != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(location ~ date, value.var = "count") %>%
    tibble::column_to_rownames("location")

  SCRCdataAPI::write_array(
    array = as.matrix(covid_deaths_per_week_by_location),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "location_type/week-covid_related_deaths",
    dimension_names = list(
      `location` = rownames(covid_deaths_per_week_by_location),
      `week commencing` = colnames(
        covid_deaths_per_week_by_location)))

  covid_deaths_per_week <- cd_week_allages %>%
    dplyr::filter(location == "All") # don't include

  # All weeks ----
  cd_total <- covid_deaths %>%
    dplyr::filter(nchar(date) == 4) %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # All weeks / Health Board Areas / Per locations
  covid_deaths_total_by_nhsboard <- cd_total %>%
    dplyr::filter(areatypename == "Health Board Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(covid_deaths_total_by_nhsboard),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "nhs_health_board/year-covid_related_deaths",
    dimension_names = list(
      `health board` = rownames(covid_deaths_total_by_nhsboard),
      year = colnames(covid_deaths_total_by_nhsboard)))

  # All weeks / Council Areas / Per locations
  covid_deaths_by_councilarea <- cd_total %>%
    dplyr::filter(areatypename == "Council Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(covid_deaths_by_councilarea),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "council_area/year-covid_related_deaths",
    dimension_names = list(
      `council area` = rownames(covid_deaths_by_councilarea),
      year = colnames(covid_deaths_by_councilarea)))

  # All weeks / Country / All locations
  covid_deaths_year_to_date_allloc <- cd_total %>%
    dplyr::filter(areatypename == "Country",
                  location == "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) # don't include

  # All weeks / Country / Per location
  covid_deaths_year_to_date_loc <- cd_total %>%
    dplyr::filter(areatypename == "Country",
                  location != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) # don't include



  # All casuses --------------------------------------------------------------

  all_deaths <- scotDeaths %>%
    dplyr::filter(grepl("All causes$", cause)) %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # Per week
  ad_week <- all_deaths %>%
    dplyr::filter(nchar(date) != 4) %>%
    dplyr::mutate(date = gsub("^w/c ", "", date))

  assertthat::assert_that(
    all(unique(ad_week$areatypename) %in% c("Health Board Areas",
                                            "Council Areas", "Country")))

  # Per week / Health Board Areas
  all_deaths_per_week_by_nhsboard <- ad_week %>%
    dplyr::filter(areatypename == "Health Board Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(all_deaths_per_week_by_nhsboard),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "nhs_health_board/week-all_deaths",
    dimension_names = list(
      `health board` = rownames(all_deaths_per_week_by_nhsboard),
      `week commencing` = colnames(all_deaths_per_week_by_nhsboard)))

  # Per week / Council Areas
  all_deaths_per_week_by_councilarea <- ad_week %>%
    dplyr::filter(areatypename == "Council Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(all_deaths_per_week_by_councilarea),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "council_area/week-all_deaths",
    dimension_names = list(
      `council area` = rownames(all_deaths_per_week_by_councilarea),
      `week commencing` = colnames(
        all_deaths_per_week_by_councilarea)))

  # Per week / Country
  ad_week_country <- ad_week %>%
    dplyr::filter(areatypename == "Country") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  all_deaths_per_week_by_agegroup <- ad_week_country %>%
    dplyr::filter(age != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # Per week / Country / Female
  all_deaths_per_week_by_agegroup_f <- all_deaths_per_week_by_agegroup %>%
    dplyr::filter(gender == "Female") %>%
    reshape2::dcast(age ~ date, value.var = "count") %>%
    tibble::column_to_rownames("age")

  # Per week / Country / Male
  all_deaths_per_week_by_agegroup_m <- all_deaths_per_week_by_agegroup %>%
    dplyr::filter(gender == "Male") %>%
    reshape2::dcast(age ~ date, value.var = "count") %>%
    tibble::column_to_rownames("age")

  female <- as.matrix(all_deaths_per_week_by_agegroup_f)
  male <- as.matrix(all_deaths_per_week_by_agegroup_m)

  assertthat::assert_that(all(dim(female) == dim(male)))
  assertthat::assert_that(all(rownames(all_deaths_per_week_by_agegroup_f) ==
                                rownames(all_deaths_per_week_by_agegroup_m)))
  assertthat::assert_that(all(colnames(
    all_deaths_per_week_by_agegroup_f) == colnames(
      all_deaths_per_week_by_agegroup_m)))

  SCRCdataAPI::write_array(
    array = array(c(female, male),
                  dim = c(dim(female), 2)),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "age_group/week/gender-country-all_deaths",
    dimension_names = list(
      `age group` = rownames(all_deaths_per_week_by_agegroup_f),
      `week commencing` = colnames(all_deaths_per_week_by_agegroup_f),
      gender = c("female", "male")))

  # Per week / Country / All genders
  all_deaths_per_week_by_agegroup_all <- all_deaths_per_week_by_agegroup %>%
    dplyr::filter(gender == "All") %>%
    reshape2::dcast(age ~ date, value.var = "count") %>%
    tibble::column_to_rownames("age")

  SCRCdataAPI::write_array(
    array = as.matrix(all_deaths_per_week_by_agegroup_all),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "age_group/week-persons-country-all_deaths",
    dimension_names = list(
      `age group` = rownames(all_deaths_per_week_by_agegroup_all),
      `week commencing` = colnames(
        all_deaths_per_week_by_agegroup_all)))

  # Per week / Country / All ages
  ad_week_allages <- ad_week_country %>%
    dplyr::filter(age == "All")

  # Per week / Country / All ages / Per location
  all_deaths_per_week_by_location <- ad_week_allages %>%
    dplyr::filter(location != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(location ~ date, value.var = "count") %>%
    tibble::column_to_rownames("location")

  SCRCdataAPI::write_array(
    array = as.matrix(all_deaths_per_week_by_location),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "location_type/week-all_deaths",
    dimension_names = list(
      `location` = rownames(all_deaths_per_week_by_location),
      `week commencing` = colnames(all_deaths_per_week_by_location)))

  # Per week / Country / All ages / All locations
  all_deaths_per_week <- ad_week_allages %>%
    dplyr::filter(location == "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) # don't include

  # All weeks
  ad_total <- all_deaths %>%
    dplyr::filter(nchar(date) == 4) %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # All weeks / Health Board Areas / All locations
  all_deaths_by_nhsboard <- ad_total %>%
    dplyr::filter(areatypename == "Health Board Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(all_deaths_by_nhsboard),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "nhs_health_board/year-all_deaths",
    dimension_names = list(
      `health board` = rownames(all_deaths_by_nhsboard),
      year = colnames(all_deaths_by_nhsboard)))

  # All weeks / Council Areas / All locations
  all_deaths_by_councilarea <- ad_total %>%
    dplyr::filter(areatypename == "Council Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1)%>%
    reshape2::dcast(featurename ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurename")

  SCRCdataAPI::write_array(
    array = as.matrix(all_deaths_by_councilarea),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "council_area/year-all_deaths",
    dimension_names = list(
      `council area` = rownames(all_deaths_by_councilarea),
      year = colnames(all_deaths_by_councilarea)))


  # All causes - average of corresponding week over previous 5 year ---------
  all_deaths_averaged <- scotDeaths %>%
    dplyr::filter(grepl("All causes - average of corresponding", cause)) %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # All weeks
  all_deaths_averaged_total <- all_deaths_averaged %>%
    dplyr::filter(nchar(date) == 4) # don't include

  # Per week
  all_deaths_averaged_date <- all_deaths_averaged %>%
    dplyr::filter(nchar(date) != 4) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    tibble::column_to_rownames("date")

  SCRCdataAPI::write_array(
    array = as.matrix(all_deaths_averaged_date),
    handle = handle,
    data_product = "records/SARS-CoV-2/scotland/human-mortality",
    component = "week-persons-scotland-all_deaths-averaged_over_5years",
    dimension_names = list(
      `week commencing` = rownames(all_deaths_averaged_date)))
}
