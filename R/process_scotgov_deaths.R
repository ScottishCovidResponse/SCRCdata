#' process_scotgov_deaths
#'
#' @export
#'
process_scotgov_deaths <- function(sourcefile, filename) {

  scotDeaths <- read.csv(file = sourcefile) %>%
    dplyr::mutate(featurecode = gsub(
      "<http://statistics.gov.scot/id/statistical-geography/", "",
      featurecode),
      featurecode = gsub("http://statistics.gov.scot/id/statistical-geography/",
                         "", featurecode))

  covid_deaths <- scotDeaths %>%
    dplyr::filter(cause == "COVID-19 related") %>%
    dplyr::select(-type)

  cd_week <- covid_deaths %>%
    dplyr::filter(date != "2020") %>%
    dplyr::mutate(date = gsub("^w/c ", "", date))

  cd_total <- covid_deaths %>%
    dplyr::filter(date == "2020") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # dataset 1 - Covid related deaths per week by NHS Health Board Area
  covid_deaths_per_week_by_nhsboard <- cd_week %>%
    dplyr::filter(areatypename == "Health Board Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurecode ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "nhs_health_board/week-covid_related_deaths",
    array = as.matrix(covid_deaths_per_week_by_nhsboard),
    dimension_names = list(
      `health board` = rownames(covid_deaths_per_week_by_nhsboard),
      `week commencing` = colnames(
        covid_deaths_per_week_by_nhsboard)))

  # don't include
  covid_deaths_by_nhsboard <- cd_total %>%
    dplyr::filter(areatypename == "Health Board Areas",
                  location == "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # dataset 2 - covid_deaths_per_week_by_councilarea
  covid_deaths_per_week_by_councilarea <- cd_week %>%
    dplyr::filter(areatypename == "Council Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurecode ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "council_area/week-covid_related_deaths",
    array = as.matrix(covid_deaths_per_week_by_councilarea),
    dimension_names = list(
      `council area` = rownames(
        covid_deaths_per_week_by_councilarea),
      `week commencing` = colnames(
        covid_deaths_per_week_by_councilarea)))

  # don't include
  covid_deaths_by_councilarea <- cd_total %>%
    dplyr::filter(areatypename == "Council Areas",
                  location == "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  cd_week_country <- cd_week %>%
    dplyr::filter(areatypename == "Country") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  covid_deaths_per_week_by_agegroup <- cd_week_country %>%
    dplyr::filter(age != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # dataset 3 - covid_deaths_per_week_by_agegroup_f -------------------------

  covid_deaths_per_week_by_agegroup_f <- covid_deaths_per_week_by_agegroup %>%
    dplyr::filter(gender == "Female") %>%
    reshape2::dcast(age ~ date, value.var = "count") %>%
    tibble::column_to_rownames("age")

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

  SCRCdataAPI::create_array(
    filename = filename,
    component = "age_group/week/gender-country-covid_related_deaths",
    array = array(c(female, male), dim = c(dim(female), 2)),
    dimension_names = list(
      `age group` = rownames(covid_deaths_per_week_by_agegroup_f),
      `week commencing` = colnames(
        covid_deaths_per_week_by_agegroup_f)))

  # dataset 5 - covid_deaths_per_week_by_agegroup_all -----------------------

  covid_deaths_per_week_by_agegroup_all <- covid_deaths_per_week_by_agegroup %>%
    dplyr::filter(gender == "All") %>%
    reshape2::dcast(age ~ date, value.var = "count") %>%
    tibble::column_to_rownames("age")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "age_group/week-persons-country-covid_related_deaths",
    array = as.matrix(covid_deaths_per_week_by_agegroup_all),
    dimension_names = list(
      `age group` = rownames(covid_deaths_per_week_by_agegroup_all),
      `week commencing` = colnames(
        covid_deaths_per_week_by_agegroup_all)))

  cd_week_allages <- cd_week_country %>%
    dplyr::filter(age == "All")

  # dataset 6 - covid_deaths_per_week_by_location ---------------------------

  covid_deaths_per_week_by_location <- cd_week_allages %>%
    dplyr::filter(location != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(location ~ date, value.var = "count") %>%
    tibble::column_to_rownames("location")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "location_type/week-covid_related_deaths",
    array = as.matrix(covid_deaths_per_week_by_location),
    dimension_names = list(
      `location` = rownames(covid_deaths_per_week_by_location),
      `week commencing` = colnames(
        covid_deaths_per_week_by_location)))

  # don't include
  covid_deaths_per_week <- cd_week_allages %>%
    dplyr::filter(location == "All")

  # don't include
  covid_deaths_year_to_date <- cd_total %>%
    dplyr::filter(areatypename == "Country") %>%
    dplyr::select_if(~ length(unique(.)) != 1)


  # All deaths --------------------------------------------------------------

  all_deaths <- scotDeaths %>%
    dplyr::filter(cause != "COVID-19 related") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  ad_week <- all_deaths %>%
    dplyr::filter(date != "2020") %>%
    dplyr::mutate(date = gsub("^w/c ", "", date))

  ad_total <- all_deaths %>%
    dplyr::filter(date == "2020") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # dataset 7 - all_deaths_per_week_by_nhsboard -----------------------------

  all_deaths_per_week_by_nhsboard <- ad_week %>%
    dplyr::filter(areatypename == "Health Board Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurecode ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "nhs_health_board/week-all_deaths",
    array = as.matrix(all_deaths_per_week_by_nhsboard),
    dimension_names = list(
      `health board` = rownames(all_deaths_per_week_by_nhsboard),
      `week commencing` = colnames(all_deaths_per_week_by_nhsboard)))

  # don't include
  all_deaths_by_nhsboard <- ad_total %>%
    dplyr::filter(areatypename == "Health Board Areas",
                  location == "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # dataset 8 - all_deaths_per_week_by_councilarea --------------------------

  all_deaths_per_week_by_councilarea <- ad_week %>%
    dplyr::filter(areatypename == "Council Areas") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurecode ~ date, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "council_area/week-all_deaths",
    array = as.matrix(all_deaths_per_week_by_councilarea),
    dimension_names = list(
      `council area` = rownames(all_deaths_per_week_by_councilarea),
      `week commencing` = colnames(
        all_deaths_per_week_by_councilarea)))

  # don't include
  all_deaths_by_councilarea <- ad_total %>%
    dplyr::filter(areatypename == "Council Areas",
                  location == "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  ad_week_country <- ad_week %>%
    dplyr::filter(areatypename == "Country") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  all_deaths_per_week_by_agegroup <- ad_week_country %>%
    dplyr::filter(age != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # dataset 9 - all_deaths_per_week_by_agegroup_f ---------------------------

  all_deaths_per_week_by_agegroup_f <- all_deaths_per_week_by_agegroup %>%
    dplyr::filter(gender == "Female") %>%
    reshape2::dcast(age ~ date, value.var = "count") %>%
    tibble::column_to_rownames("age")

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

  SCRCdataAPI::create_array(
    filename = filename,
    component = "age_group/week/gender-country-all_deaths",
    array = array(c(female, male), dim = c(dim(female), 2)),
    dimension_names = list(
      `age group` = rownames(all_deaths_per_week_by_agegroup_f),
      `week commencing` = colnames(
        all_deaths_per_week_by_agegroup_f)))


  # dataset 11 - all_deaths_per_week_by_agegroup_all ------------------------

  all_deaths_per_week_by_agegroup_all <- all_deaths_per_week_by_agegroup %>%
    dplyr::filter(gender == "All") %>%
    reshape2::dcast(age ~ date, value.var = "count") %>%
    tibble::column_to_rownames("age")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "age_group/week-persons-country-all_deaths",
    array = as.matrix(all_deaths_per_week_by_agegroup_all),
    dimension_names = list(
      `age group` = rownames(all_deaths_per_week_by_agegroup_all),
      `week commencing` = colnames(
        all_deaths_per_week_by_agegroup_all)))


  ad_week_allages <- ad_week_country %>%
    dplyr::filter(age == "All")

  # dataset 12 - all_deaths_per_week_by_location ----------------------------

  all_deaths_per_week_by_location <- ad_week_allages %>%
    dplyr::filter(location != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(location ~ date, value.var = "count") %>%
    tibble::column_to_rownames("location")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "location_type/week-all_deaths",
    array = as.matrix(all_deaths_per_week_by_location),
    dimension_names = list(
      `location` = rownames(all_deaths_per_week_by_location),
      `week commencing` = colnames(all_deaths_per_week_by_location)))

  # don't include
  all_deaths_per_week <- ad_week_allages %>%
    dplyr::filter(location == "All",
                  cause == "All causes") %>%
    dplyr::select_if(~ length(unique(.)) != 1)

  # dataset 13 - all_deaths_per_week_averaged_over_5years -------------------

  tmp <- "All causes - average of corresponding week over previous 5 years"
  all_deaths_per_week_averaged_over_5years <- ad_week_allages %>%
    dplyr::filter(location == "All",
                  cause == tmp) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(. ~ date, value.var = "count") %>%
    dplyr::select(-`.`)

  SCRCdataAPI::create_array(
    filename = filename,
    component = "week-persons-scotland-all_deaths-averaged_over_5years",
    array = as.matrix(all_deaths_per_week_averaged_over_5years),
    dimension_names = list(
      `total` = rownames(
        all_deaths_per_week_averaged_over_5years),
      `week commencing` = colnames(
        all_deaths_per_week_averaged_over_5years)))

  # don't include
  all_deaths_year_to_date <- ad_total %>%
    dplyr::filter(areatypename == "Country") %>%
    dplyr::select_if(~ length(unique(.)) != 1)



  # Deaths by location ------------------------------------------------------

  # dataset 14 - covid_deaths_by_nhsboard_and_location ----------------------

  covid_deaths_by_nhsboard_and_location <- cd_total %>%
    dplyr::filter(areatypename == "Health Board Areas",
                  location != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurecode ~ location, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "nhs_health_board/location_type-covid_related_deaths",
    array = as.matrix(covid_deaths_by_nhsboard_and_location),
    dimension_names = list(
      `health board` = rownames(
        covid_deaths_by_nhsboard_and_location),
      `location` = colnames(
        covid_deaths_by_nhsboard_and_location)))

  # dataset 15 - all_deaths_by_nhsboard_and_location ------------------------

  all_deaths_by_nhsboard_and_location <- ad_total %>%
    dplyr::filter(areatypename == "Health Board Areas",
                  location != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurecode ~ location, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "nhs_health_board/location_type-all_deaths",
    array = as.matrix(all_deaths_by_nhsboard_and_location),
    dimension_names = list(
      `health board` = rownames(
        all_deaths_by_nhsboard_and_location),
      `location` = colnames(
        all_deaths_by_nhsboard_and_location)))

  # dataset 16 - covid_deaths_by_councilarea_and_location
  covid_deaths_by_councilarea_and_location <- cd_total %>%
    dplyr::filter(areatypename == "Council Areas",
                  location != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurecode ~ location, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "council_area/location_type-covid_related_deaths",
    array = as.matrix(covid_deaths_by_councilarea_and_location),
    dimension_names = list(
      `council area` = rownames(
        covid_deaths_by_councilarea_and_location),
      `location` = colnames(
        covid_deaths_by_councilarea_and_location)))

  # dataset 17 - all_deaths_by_councilarea_and_location
  all_deaths_by_councilarea_and_location <- ad_total %>%
    dplyr::filter(areatypename == "Council Areas",
                  location != "All") %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurecode ~ location, value.var = "count") %>%
    tibble::column_to_rownames("featurecode")

  SCRCdataAPI::create_array(
    filename = filename,
    component = "council_area/location_type-all_deaths",
    array = as.matrix(all_deaths_by_councilarea_and_location),
    dimension_names = list(
      `council area` = rownames(
        all_deaths_by_councilarea_and_location),
      `location` = colnames(
        all_deaths_by_councilarea_and_location)))

}
