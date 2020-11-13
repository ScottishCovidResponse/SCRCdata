#' process_scotgov_lookup
#'
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param h5filename a \code{string} specifying the filename
#' associated with the processed data (the output of this function)
#' @param path a \code{string} specifying the local path associated
#' with the processed data
#' @param grid_names a \code{string} specifying the sizes of the grid squares
#'used in the conversion table in the format gridxkm
#' @param scot_datazone_sf Scottish shapefile
#'
#' @export
#'
process_scotgov_lookup <- function(sourcefile,
                                   h5filename,
                                   path,
                                   grid_names,
                                   scot_datazone_sf) {
  # ADMIN AREAS -------------------------------------------------
  
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

  # GRIDS -------------------------------------------------
  
  # Check for non-intersecting geometries
  datazones <- scot_datazone_sf %>%
    sf::st_make_valid() %>%
    dplyr::rename(AREAcode = DataZone)

  # Create grid cell intersections
  # Read in UK national grid shapefile
  grid_shp = sf::st_read(sourcefile[["grid_shapefile"]], quiet = TRUE) %>%
    sf::st_make_valid() %>% rename("grid_id" = "PLAN_NO")

  sh_unit <- sf::st_crs(datazones, parameters = TRUE)$units_gdal
  assertthat::assert_that(sh_unit == "metre",
                          msg = "Unexpected CRS: shapefile distances should be in metres")

  ## From inside grid_intersection()
  subdivisions <- sf::st_intersection(grid_shp, datazones)

  # Remove cells which intersect simply because they touch the shapefile
  # - These are reduced to lines or points in the intersection
  is_polygon <- sapply(subdivisions$grids, function(x)
    any(grepl("LINE|POINT", class(x))))
  if(length(is_polygon)>0){
    subdivisions <- subdivisions[!is_polygon, , drop = FALSE]
  }

  # A couple of small islands around Iona/Mull arent caught by thre grid and cause
  # an error later this removes these islands. This is a short term fix, the
  # long term fix is to have a better shapefile of the UK national grid.
  mull_iona_grids = subdivisions[which(subdivisions$AREAcode=="S01007287"),]
  datazones[which(datazones$AREAcode=="S01007287"),] <- st_crop(datazones[which(datazones$AREAcode=="S01007287"),], mull_iona_grids)

  #Check that datazone components add up to same area as original datazone
  subdivision_area = data.frame(AREAcode = subdivisions$AREAcode,
                                subd_area = st_area(subdivisions))
  subdivision_area = subdivision_area %>%
    group_by(.data$AREAcode) %>%
    summarise(subd_area=sum(.data$subd_area))
  datazone_area = data.frame(AREAcode = datazones$AREAcode,
                             dz_area = st_area(datazones))
  subdivision_area = subdivision_area %>%
    left_join(datazone_area, by = "AREAcode")
  subdivision_area$difference = subdivision_area$subd_area - subdivision_area$dz_area
  assertthat::assert_that(all(round(as.numeric(subdivision_area$difference)) == 0))
  subdivisions$Datazone_component_id = c(1:nrow(subdivisions))


  # Make dataframes of the area of each datazone component in each grid cell
  # at both 1km and 10km
  intersection_area <- data.frame(
    grid1km_id = subdivisions$grid_id,
    areagrid1km = as.numeric(sf::st_area(subdivisions)),
    Datazone_component_id = subdivisions$Datazone_component_id,
    AREAcode = subdivisions$AREAcode)

  datazone_area$dz_area <- as.numeric(datazone_area$dz_area)
  intersection_area <- intersection_area %>% left_join(datazone_area, "AREAcode")
  conversion.table <- intersection_area %>%
    mutate(grid1km_area_proportion=intersection_area$areagrid1km/intersection_area$dz_area)%>%
    select("Datazone_component_id", "grid1km_area_proportion", "grid1km_id", "AREAcode")%>%
    left_join(conversion.table, "AREAcode")
  conversion.table <- conversion.table %>%
    tibble::column_to_rownames("Datazone_component_id")
  conversion.table[is.na(conversion.table)] <- 0

  # POLLUTION -------------------------------------------------
  # Read in example pollution data, the datapoint locations are consistent
  # across different pollution data.
  grid_shp  = grid_shp %>% rename("GRID_NUM" = "grid_id")
  pollution.sf = read.csv(sourcefile[["pollution/example"]], skip = 5)%>%
    sf::st_as_sf(coords = c("x","y"), crs="EPSG:27700")
  
  # Use st_contains to find which OS grid the centre point of the pollution
  # grid is in
  grids_contain = sf::st_contains(grid_shp, pollution.sf)
  
  #Convert the list produced to a dataframe
  contains.df = matrix(0, nrow = length(grids_contain))
  for(i in 1:length(grids_contain)){
    if(length(grids_contain[[i]])==1){
      contains.df[i,1]=grids_contain[[i]]
    }else
      if(length(grids_contain[[i]])==0){
        contains.df[i,1]=0
      }else{
        stop("More than 1 point in cell!!")
        #Stop here as this shouldnt be possible - both systems are 1km grids
      }
    
  }
  
  # Match pollution codes to UK national grid codes
  
  # Column of the contains dataframe should represent rows of the pollution sf dataframe
  # rows of the contains dataframe represent the rows of the uk national grid shapefile
  contains.df = as.data.frame(contains.df) %>% rename("rowname" = "V1")
  pollution.sf = rownames_to_column(pollution.sf) 
  pollution.sf =   pollution.sf %>% mutate("rowname" = as.numeric(pollution.sf$rowname))
  rownames(contains.df) = grid_shp$GRID_NUM
  contains.df = rownames_to_column(contains.df,"GRID_NUM")
  lookup = left_join(contains.df, pollution.sf, by = "rowname") %>% select("GRID_NUM", "ukgridcode") %>% rename("grid1km_id" = "GRID_NUM","pollution_code" = "ukgridcode" )
  lookup = lookup[-which(is.na(lookup$pollution_code)),]
  
  
  
  conversion.table = left_join(conversion.table, lookup, by = "grid1km_id") 
  
  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = path,
                            component = "conversiontable/scotland",
                            df = conversion.table,
                            row_names = rownames(conversion.table),
                            column_units = colnames(conversion.table))


}
