#' process_scotgov_lookup
#'
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param h5filename a \code{string} specifying the filename
#' associated with the processed data (the output of this function)
#' @param grid_names a \code{string} specifying the sizes of the grid squares
#'used in the conversion table in the format gridxkm
#' @param path a \code{string} specifying the local path associated 
#' with the processed data
#'
#' @export
#'
process_scotgov_lookup <- function(sourcefile,
                                   h5filename,
                                   path,
                                   grid_names) {

  simdlookup<- readxl::read_excel(
    sourcefile[["simd"]],
    sheet = 3) %>%
    dplyr::rename(AREAcode = DZ,
                  AREAname = DZname,
                  URcode = URclass) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  dzlookup <- read.csv(
    sourcefile[["dz"]]) %>%
    dplyr::rename(AREAcode = DataZone,
                  IZcode = InterZone,
                  MMWcode = MMWard,
                  SPCcode = SPC,
                  LAcode = Council,
                  HBcode = HB,
                  TTWAcode = TTWA,
                  CTRYcode = CTRY) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))%>%
    dplyr::select_if(!grepl(paste(colnames(simdlookup)[-1],collapse="|"),
                            colnames(.)))

  dzlookup$TTWAname <- dzlookup$TTWAcode
  dzlookup$CTRYname <- "Scotland"

  conversion.table <- left_join(simdlookup, dzlookup, by = "AREAcode")

  # scot_datazone_sf is installed as part of the SCRCdata package
  datazones <- SCRCdata::scot_datazone_sf

  # Create grid cell intersections
  gridsizes <- grid_names[grepl("^grid", grid_names)] %>%
    lapply(function(x) gsub("grid", "", x) %>% gsub("km", "", .)) %>%
    as.numeric()

  dz_subdivisions <- list()
  grid_matrix <- list()
  for(g in seq_along(gridsizes)) {
    tmp <- SCRCdataAPI::grid_intersection(datazones, gridsizes[g])
    tag <- paste0("grid", gridsizes[g], "km")
    dz_subdivisions[[g]] <- tmp$subdivisions
    names(dz_subdivisions)[g] <- tag
    grid_matrix[[g]] <- tmp$grid_matrix
    names(grid_matrix)[g] <- tag
    dz_subdivisions[[g]]$Datazone_component_id<-
      c(seq_along(dz_subdivisions[[g]]$grid_id))
  }

  # Make dataframes of the area of each datazone component in each grid cell
  # at both 1km and 10km
  intersection_area1km <- data.frame(
    grid1km_id = dz_subdivisions$grid1km$grid_id,
    areagrid1km = as.numeric(sf::st_area(dz_subdivisions$grid1km)),
    Datazone_component_id = dz_subdivisions$grid1km$Datazone_component_id,
    AREAcode = dz_subdivisions$grid1km$AREAcode)

  intersection_area10km <- data.frame(
    grid10km_id = dz_subdivisions$grid10km$grid_id,
    areagrid10km = as.numeric(sf::st_area(dz_subdivisions$grid10km)),
    Datazone_component_id = dz_subdivisions$grid10km$Datazone_component_id,
    AREAcode = dz_subdivisions$grid10km$AREAcode)

  # Make dataframe of datazone area
  datazone_area <- data.frame(AREAcode = datazones$AREAcode,
                              full_zone_area = as.numeric(sf::st_area(datazones)))

  # Find which 1km grid cells are in each 10km grid cell
  gridslist <- list(grid1km = vector(),
                    grid10km = vector())

  # From inside grid_intersection, get sf object of grids
  for(gridsize in gridsizes){
    # Generate grid over bounding box of datazone shapefile
    n <- gridsize*1000  # Assume gridsize given in km
    grids <- sf::st_make_grid(sf::st_as_sfc(sf::st_bbox(datazones)),
                              cellsize = c(n, n))

    width <- sf::st_bbox(datazones)$xmax - sf::st_bbox(datazones)$xmin
    height <- sf::st_bbox(datazones)$ymax - sf::st_bbox(datazones)$ymin
    num_columns <- ceiling(width / n)
    num_rows <- ceiling(height / n)
    grid_labels <- paste0(1:num_columns, "-", rep(1:num_rows,
                                                  each = num_columns))
    grid_matrix <- strsplit(grid_labels, "-") %>%
      lapply(as.numeric) %>% do.call(rbind.data.frame, .)
    colnames(grid_matrix) <- c("x", "y")

    assertthat::assert_that(max(grid_matrix$x) == num_columns)
    assertthat::assert_that(max(grid_matrix$y) == num_rows)

    this_grid <- paste0("grid", gridsize, "km")
    gridslist[[this_grid]] <- sf::st_sf(grids, grid_id = grid_labels)
  }

  # Use sf objects to map which 1km cells are inside each 10km cell
  covered_grids <- sf::st_covered_by(gridslist$grid1km, gridslist$grid10km,
                                 sparse = FALSE)

  # Extract this into a more useable format
  grids.array <- array(0, dim = c(100, length(gridslist$grid10km$grid_id)))

  for(i in seq_len(ncol(covered_grids))){
    grids.array[,i] <- gridslist$grid1km$grid_id[which(covered_grids[,i] == TRUE)]
  }
  colnames(grids.array) <- gridslist$grid10k$grid_id

  grids.array <- as.data.frame(grids.array)

  grid_lookup <- reshape2::melt(grids.array, id.vars = NULL, variable.name = "grid10km_id", 
                                value.name = "grid1km_id")
  grid_lookup$grid10km_id <- factor(grid_lookup$grid10km_id,
                                    levels = gridslist$grid10k$grid_id)
  grid_lookup <- grid_lookup[order(grid_lookup$grid10km_id), ]
  grid_lookup$grid10km_id <- as.character(grid_lookup$grid10km_id)

  # Which grid cells have datazones in them?
  present_grids_lookup <- grid_lookup[match(intersection_area1km$grid1km_id,
                                            grid_lookup$grid1km_id), ]

  # Join grids to datazone component areas
  grids_area <- left_join(present_grids_lookup, intersection_area1km,
                          by = "grid1km_id")
  grids_area <- left_join(grids_area, datazone_area, by = "AREAcode")
  grids_area$prop <- grids_area$areagrid1km / grids_area$full_zone_area
  grids_area <- grids_area[!duplicated(grids_area$Datazone_component_id), ]
  check_proportions <- grids_area %>%
    group_by(AREAcode) %>%
    summarise(total_prop = sum(prop))

  assertthat::assert_that(all((round(check_proportions$total_prop,
                                     digits = 2) != 1) == FALSE))

  grids_area <- left_join(grids_area, intersection_area10km,
                          by = c("grid10km_id","AREAcode"))

  # Find proportion of each datazone in each grid cell
  grids_area <- grids_area %>%
    dplyr::mutate(grid1km_area_proportion = areagrid1km / full_zone_area,
                  grid10km_area_proportion = areagrid10km / full_zone_area) %>%
    dplyr::select(grid1km_id, grid1km_area_proportion, grid10km_id,
                  grid10km_area_proportion, AREAcode)
  conversion.table <- left_join(grids_area, conversion.table, by="AREAcode")
  conversion.table$Datazone_component_id <- seq_along(conversion.table$grid1km_id)
  conversion.table <- conversion.table %>%
    tibble::column_to_rownames("Datazone_component_id")
  conversion.table[is.na(conversion.table)] <- 0
  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = path,
                            component = "conversiontable/scotland",
                            df = conversion.table,
                            row_names = rownames(conversion.table),
                            column_units = colnames(conversion.table))
}
