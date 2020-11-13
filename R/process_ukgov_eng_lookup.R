#' process_ukgov_eng_lookup
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param h5filename a \code{string} specifying the local path and filename
#' associated with the processed data (the output of this function)
#' @param output_area_sf a \code{string} specifying the local path and filename
#' associated with the UK government output area shapefile
#' @param path a \code{string} specifying the local path associated
#' with the processed data
#'
#' @export
#'
process_ukgov_eng_lookup <- function(sourcefile,
                                     h5filename,
                                     output_area_sf,
                                     path) {

  OA_EW_LA <- read.csv(sourcefile[["OA_EW_LA"]], fileEncoding="UTF-8-BOM") %>%
    dplyr::rename(AREAcode = OA11CD, EWcode = WD19CD, EWname = WD19NM,
                  LAcode = LAD19CD, LAname = LAD19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  OA_LSOA_MSOA_LA <- read.csv(sourcefile[["OA_LSOA_MSOA_LA"]],
                              fileEncoding = "UTF-8-BOM") %>%
    dplyr::rename(AREAcode = OA11CD, LSOAcode = LSOA11CD, LSOAname = LSOA11NM,
                  MSOAcode = MSOA11CD, MSOAname = MSOA11NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  LSOA_CCG <- read.csv(sourcefile[["LSOA_CCG"]], fileEncoding="UTF-8-BOM") %>%
    dplyr::rename(LSOAcode = LSOA11CD, CCGcode = CCG19CD, CCGname = CCG19NM,
                  STPcode = STP19CD, STPname = STP19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  EW_UA <- read.csv(sourcefile[["EW_UA"]], fileEncoding="UTF-8-BOM") %>%
    dplyr::rename(EWcode = WD19CD, UAcode = UA19CD, UAname = UA19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  UA_HB <- read.csv(sourcefile[["UA_HB"]], fileEncoding="UTF-8-BOM") %>%
    dplyr::rename(UAcode = UA19CD, LHBcode = LHB19CD, LHBname = LHB19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  conversion.table <- OA_EW_LA %>%
    dplyr::left_join(., OA_LSOA_MSOA_LA,by = "AREAcode") %>%
    dplyr::left_join(., LSOA_CCG,by = "LSOAcode") %>%
    dplyr::left_join(., EW_UA,by = "EWcode") %>%
    dplyr::left_join(., UA_HB,by = "UAcode")

  conversion.table$AREAname <- conversion.table$AREAcode
  conversion.table <- as.data.frame(conversion.table)

  # Remove special characters
  ind <- grepl("name", colnames(conversion.table))
  name_columns <- colnames(conversion.table[, ind])

  for(col in seq_along(name_columns)){
    another_ind <- which(colnames(conversion.table)==name_columns[col])
    conversion.table[,another_ind] <- iconv(conversion.table[, another_ind],
                                            to = 'ASCII//TRANSLIT')
  }

  # Get shapefile if not already downloaded by user -------------------------
  if (!file.exists(output_area_sf)) {
    SCRCdataAPI::download_from_url(
      source_root="https://opendata.arcgis.com/datasets/",
      source_path = "09b58d063d4e421a9cad16ba5419a6bd_0.zip?outSR=%7B%22latestWkid%22%3A27700%2C%22wkid%22%3A27700%7D",
      path=file.path(strsplit(output_area_sf, "/")[[1]][1]),
      filename = "Output_Areas__December_2011__Boundaries_EW_BFC.zip",
      unzip = TRUE)
  }

  # Prepare dz2grid ---------------------------------------------------------

  # Read in datazone shapefile and check for non-intersecting geometries
  output_areas <- sf::st_read(output_area_sf, quiet = TRUE) %>%
    sf::st_make_valid() %>%
    dplyr::rename(AREAcode=OA11CD)
  # Read in UK national grid shapefile
  grid_shp <- sf::st_read(sourcefile[["grid_shapefile"]], quiet = TRUE) %>%
    sf::st_make_valid() %>%
    dplyr::rename("grid_id" = "PLAN_NO")

  sh_unit <- sf::st_crs(output_areas, parameters = TRUE)$units_gdal
  assertthat::assert_that(sh_unit == "metre",
                          msg = "Unexpected CRS: shapefile distances should be in metres")

  # From inside grid_intersection()
  subdivisions <- sf::st_intersection(grid_shp, output_areas)

  # Remove cells which intersect simply because they touch the shapefile
  # - These are reduced to lines or points in the intersection
  is_polygon <- sapply(subdivisions$grids, function(x)
    any(grepl("LINE|POINT", class(x))))
  if(length(is_polygon) > 0) {
    subdivisions <- subdivisions[!is_polygon, , drop = FALSE]
  }

  # Check that datazone components add up to same area as original datazone
  subdivision_area <- data.frame(AREAcode = subdivisions$AREAcode,
                                subd_area = sf::st_area(subdivisions))
  subdivision_area <- subdivision_area %>%
    dplyr::group_by(.data$AREAcode) %>%
    dplyr::summarise(subd_area = sum(.data$subd_area))
  datazone_area <- data.frame(AREAcode = output_areas$AREAcode,
                             dz_area = sf::st_area(output_areas))
  subdivision_area <- subdivision_area %>%
    dplyr::left_join(datazone_area, by = "AREAcode")
  subdivision_area$difference <- subdivision_area$subd_area -
    subdivision_area$dz_area
  assertthat::assert_that(all(round(as.numeric(subdivision_area$difference)) == 0))
  subdivisions$Datazone_component_id <- seq_len(nrow(subdivisions))

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
    dplyr::mutate(grid1km_area_proportion = .data[["areagrid1km"]] /
                    .data[["dz_area"]]) %>%
    dplyr::select("Datazone_component_id", "grid1km_area_proportion",
                  "grid1km_id", "AREAcode") %>%
    dplyr::left_join(conversion.table, "AREAcode")
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
                            component = "conversiontable/englandwales",
                            df = conversion.table,
                            row_names = rownames(conversion.table),
                            column_units = colnames(conversion.table))
}
