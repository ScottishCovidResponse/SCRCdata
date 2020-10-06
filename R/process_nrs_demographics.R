#' process_nrs_demographics
#'
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param h5filename a \code{string} specifying the  filename
#' associated with the processed data (the output of this function)
#' @param h5path a \code{string} specifying the local path
#' associated with the processed data (the output of this function)
#' @param conversionfile a \code{data.frame} containing a spatial conversion table
#'
#' @export
#'
process_nrs_demographics <- function(sourcefile,
                                     h5filename,
                                     h5path,
                                     conversionfile) {
  # Process raw data --------------------------------------------------------

  transage.dat <- lapply(seq_along(sourcefile), function(k) {
    # Read source data
    sape_tmp <- readxl::read_excel(sourcefile[[k]], col_names = FALSE)
    # Read source header
    header <- readxl::read_excel(sourcefile[[k]], skip = 3, n_max = 2)
    header <- header %>%
      dplyr::rename_at(vars(grep("^\\...[1-3]", names(.))),
                       ~ as.character(header[2, 1:3])) %>%
      dplyr::rename(AllAges = "...4") %>%
      names()

    # Process source data into useable form, removing in-built metadata etc.
    sape_tmp %>%
      # Remove first 6 rows
      .[-c(1:6),] %>%
      # Rename columns
      dplyr::rename_all(~header) %>%
      # Remove empty columns (the 5th column)
      dplyr::select_if(~sum(!is.na(.)) > 0) %>%
      # Remove blank rows
      dplyr::filter_all(any_vars(!is.na(.))) %>%
      # Remove copyright
      dplyr::filter_at(vars(dplyr::ends_with("Code")),
                       ~!grepl("Copyright", .)) %>%
      # Remove columns 2:4
      dplyr::select_at(vars(-dplyr::ends_with("Name"),
                            -AllAges)) %>%
      dplyr::mutate_at(vars(dplyr::starts_with("AGE")), as.numeric) %>%
      dplyr::rename(AREAcode = DataZone2011Code) %>%
      as.data.frame()
  })
  names(transage.dat) <- names(sourcefile)

  # Check data
  tmp <- lapply(transage.dat, dim)
  assertthat::assert_that(all(tmp$males == tmp$females))
  assertthat::assert_that(all(tmp$males == tmp$persons))
  total_persons <- sum(transage.dat$persons[,-1])
  total_females <- sum(transage.dat$females[,-1])
  total_males <- sum(transage.dat$males[,-1])
  assertthat::assert_that(total_persons == (total_females + total_males))

  # Administrative geographies ----------------------------------------------

  admin_geo <- data.frame(
    abbreviation = c("dz", "ur", "iz", "mmw", "spc", "la", "hb", "ttwa"),
    fullname = c("datazone","urban rural classification", "intermediate zone",
                 "multi member ward", "scottish parliamentary constituency",
                 "local authority", "health board", "travel to work area"))

  for(i in seq_len(nrow(admin_geo))) {
    abbreviation <- admin_geo$abbreviation[i]
    fullname <- admin_geo$fullname[i]

    # persons
    persons <- convert_area_nrs(x = abbreviation,
                                transage.dat$persons,
                                conversionfile)

    assertthat::assert_that(total_persons == sum(persons$grid_pop))

    dimension_names <- list(unname(unlist(persons$grid_id)),
                            colnames(persons$grid_pop))
    names(dimension_names) <- c(fullname, "age groups")

    create_array(filename = h5filename,
                 path = h5path,
                 component = paste0(fullname, "/age/persons"),
                 array = persons$grid_pop,
                 dimension_names = dimension_names)

    # male and female
    males <- convert_area_nrs(x = abbreviation,
                              transage.dat$males,
                              conversionfile)$grid_pop
    females <- convert_area_nrs(x = abbreviation,
                                transage.dat$females,
                                conversionfile)$grid_pop

    assertthat::assert_that(total_females == sum(females))
    assertthat::assert_that(total_males == sum(males))
    assertthat::assert_that(all(dim(males) == dim(females)))
    assertthat::assert_that(all(dim(persons) == dim(females)))

    dimension_names$genders <- c("males", "females")

    create_array(filename = h5filename,
                 path = h5path,
                 component = paste0(fullname, "/age/genders"),
                 array = array(c(males, females), dim = c(dim(females), 2)),
                 dimension_names = dimension_names)
  }

  # Grid areas --------------------------------------------------------------

  grid_areas <- data.frame(abbreviation = c("grid1km"),
                           fullname = c("grid area"))

  for(i in seq_len(nrow(grid_areas))) {
    abbreviation <- grid_areas$abbreviation[i]
    fullname <- grid_areas$fullname[i]

    # persons
    persons <- convert_area_nrs(x = abbreviation,
                                transage.dat$persons,
                                conversionfile)

    assertthat::assert_that(total_persons == sum(persons$grid_pop))

    dimension_names <- list(unname(unlist(persons$grid_id)),
                            colnames(persons$grid_pop))
    names(dimension_names) <- c(fullname, "age groups")

    create_array(filename = h5filename,
                 path = h5path,
                 component = paste0(fullname, "/age/persons"),
                 array = persons$grid_pop,
                 dimension_names = dimension_names,
                 dimension_values = list(persons$grid_id),
                 dimension_units = list(gsub("grid", "", abbreviation)))

    # male and female
    males <- convert_area_nrs(x = abbreviation,
                              transage.dat$males,
                              conversionfile)$grid_pop
    females <- convert_area_nrs(x = abbreviation,
                                transage.dat$females,
                                conversionfile)$grid_pop

    assertthat::assert_that(total_females == sum(females))
    assertthat::assert_that(total_males == sum(males))
    assertthat::assert_that(all(dim(males) == dim(females)))
    assertthat::assert_that(all(dim(persons) == dim(females)))

    dimension_names$genders <- c("males", "females")

    create_array(filename = h5filename,
                 path = h5path,
                 component = paste0(fullname, "/age/genders"),
                 array = array(c(males, females), dim = c(dim(females), 2)),
                 dimension_names = dimension_names,
                 dimension_values = list(persons$grid_id),
                 dimension_units = list(gsub("grid", "", abbreviation)))
  }

}


convert_area_nrs <- function(x, transage.dat, conversionfile) {
  # If datazone, transform to output format
  if(x %in% "dz") {

    transformed_data <- list(data = transage.dat,
                             area.names = conversionfile %>%
                               dplyr::rename(DZcode = AREAcode,
                                             DZname = AREAname) %>%
                               dplyr::select(DZcode, DZname))
    transarea.dat <- list(
      grid_pop = as.matrix(transformed_data$data[, -1, drop = FALSE]),
      grid_id = transformed_data$data[, 1])
    area.names <- transformed_data$area.names

    # If larger geography, use converion table to convert
  } else if(x %in% c("ur","iz","mmw","spc","la", "hb", "ttwa")) {

    transformed_data <- SCRCdataAPI::convert2lower(
      dat = transage.dat,
      convert_to = x,
      conversion_table = conversionfile)
    transarea.dat <- list(grid_pop = as.matrix(transformed_data$data[, -1]),
                          grid_id = transformed_data$data[, 1])
    area.names <- transformed_data$area.names

    # If grid, use converion table to convert
  } else if(grepl("grid", x)) {

    transarea.dat <- SCRCdataAPI::convert2grid(
      dat = transage.dat,
      grid_size = x,
      conversion.table = conversionfile)

  } else
    stop("Something has gone wrong")

  transarea.dat
}
