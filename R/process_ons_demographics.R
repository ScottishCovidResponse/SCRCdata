#' process_ons_demographics
#'
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param h5filename a \code{string} specifying the local path and filename
#' associated with the processed data (the output of this function)
#' @param h5path a \code{string} specifying the local path
#' associated with the processed data (the output of this function)
#' @param conversionfile a \code{data.frame} containing a spatial conversion table
#'
#' @export
#'
process_ons_demographics <- function(sourcefile,
                                     h5filename,
                                     h5path,
                                     conversionfile) {
  # Process raw data --------------------------------------------------------

  transage.dat <- lapply(seq_along(sourcefile), function(k) {
    # Read source data
    tmp <- read.csv(sourcefile[k])
    # Read source header
    header_new <- read.csv(sourcefile[k])[1,]
    header_new <- header_new %>%
      names(.) %>% gsub(".", " ",., fixed=TRUE) %>%
      gsub("Age", "AGE", ., fixed = TRUE) %>%
      gsub("AGEd", "AGE", ., fixed = TRUE) %>%
      gsub("GEOGRAPHY_NAME", "AREAcode", ., fixed = TRUE)

    colnames(tmp) <- header_new
    tmp
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

  # Generate data and attach to hdf5 file -----------------------------------

  admin_geo <- data.frame(
    abbreviation = c("OA", "EW", "LA", "LSOA", "MSOA", "CCG", "STP", "UA",
                     "LHB"),
    fullname = c("output area", "electoral ward", "local authority",
                 "lower super output area", "mid-layer super output area",
                 "clinical commissioning group",
                 "sustainability and transformation partnership",
                 "unitary authority", "local health board"))

  for(i in seq_len(nrow(admin_geo))) {
    cat(paste0("\rRunning: ", admin_geo$fullname[i], ". Administrative area: ",
               i, " of ", nrow(admin_geo)))
    abbreviation <- admin_geo$abbreviation[i]
    fullname <- admin_geo$fullname[i]

    # persons
    persons <- convert_area_ons(x =abbreviation,
                                transage.dat$persons,
                                conversionfile)

    assertthat::assert_that(total_persons == sum(persons$grid_pop))

    tmp <- unlist(persons$grid_id)
    names(tmp) <- NULL
    dimension_names <- list(tmp,
                            colnames(persons$grid_pop))
    names(dimension_names) <- c(fullname, "age groups")

    create_array(filename = h5filename,
                 path = h5path,
                 component = paste0(fullname, "/age/persons"),
                 array = persons$grid_pop,
                 dimension_names = dimension_names)

    # male and female
    males <- convert_area_ons(x = abbreviation,
                              transage.dat$males,
                              conversionfile)$grid_pop
    females <- convert_area_ons(x = abbreviation,
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

  grid_area <- data.frame(abbreviation = c("grid1km"),
                          fullname = c("grid area"))

  for(i in seq_len(nrow(grid_area))) {
    cat(paste0("\rRunning: ", grid_area, ". Administrative area: ",
               i, " of ", nrow(grid_area)))
    abbreviation <- grid_area$abbreviation[i]
    fullname <- grid_area$fullname[i]

    # persons
    persons <- convert_area_ons(x = abbreviation,
                                transage.dat$persons,
                                conversionfile)

    assertthat::assert_that(total_persons == sum(persons$grid_pop))

    tmp <- unlist(persons$grid_id)
    names(tmp) <- NULL
    dimension_names <- list(tmp,
                            colnames(persons$grid_pop))

    names(dimension_names) <- c(fullname, "age groups")

    create_array(
      filename = h5filename,
      path = h5path,
      component = paste0(fullname, "/age/persons"),
      array = persons$grid_pop,
      dimension_names = dimension_names,
      dimension_values = list(persons$grid_id),
      dimension_units = list(gsub("grid", "", abbreviation)))

    # male and female
    males <- convert_area_ons(x = abbreviation,
                              transage.dat$males,
                              conversionfile)$grid_pop
    females <- convert_area_ons(x = abbreviation,
                                transage.dat$females,
                                conversionfile)$grid_pop

    assertthat::assert_that(total_females == sum(females))
    assertthat::assert_that(total_males == sum(males))
    assertthat::assert_that(all(dim(males) == dim(females)))
    assertthat::assert_that(all(dim(persons) == dim(females)))

    dimension_names$genders <- c("males", "females")

    create_array(
      filename = h5filename,
      path = h5path,
      component = paste0(fullname, "/age/persons"),
      array = array(c(males, females), dim = c(dim(females), 2)),
      dimension_names = dimension_names,
      dimension_values = list(persons$grid_id),
      dimension_units = list(gsub("grid", "", abbreviation)))
  }
}


convert_area_ons <- function(x, transage.dat, conversionfile) {
  # If ouput area transform to output format
  if (x %in% "OA"){
    transformed_data <- list(data = transage.dat,
                             area.names = conversionfile %>%
                               dplyr::rename(OAcode = AREAcode,
                                             OAname = AREAname) %>%
                               dplyr::select(OAcode, OAname))
    transarea.dat <- list(
      grid_pop = as.matrix(transformed_data$data[, -1, drop = FALSE]),
      grid_id = transformed_data$data[, 1])
    area.names <- transformed_data$area.names



    # If larger geography, use converion table to convert
  } else if (x %in%
             c("EW", "LA", "LSOA", "MSOA", "CCG", "STP", "UA","LHB")) {

    # Transformed data (non-grid transformed)
    transformed_data <- SCRCdataAPI::convert2lower(
      dat = transage.dat,
      convert_to = x,
      conversion_table = conversionfile)
    transarea.dat <- list(grid_pop = as.matrix(transformed_data$data[,  -1]),
                          grid_id = transformed_data$data[, 1])
    area.names <- transformed_data$area.names

    # If grid, use converion table to convert
  } else if (grepl("grid", x)) {

    # Transformed data (grid transformed)
    transarea.dat <- SCRCdataAPI::convert2grid(
      dat = transage.dat,
      conversion.table = conversionfile,
      grid_size = x)

  }
  stop("Something has gone wrong")

  transarea.dat
}