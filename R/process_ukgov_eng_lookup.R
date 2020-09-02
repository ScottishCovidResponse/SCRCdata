#' process_ukgov_eng_lookup
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param h5filename a \code{string} specifying the local path and filename
#' associated with the processed data (the output of this function)
#' @param grid_names a \code{string} specifying the sizes of the grid squares 
#'used in the conversion table in the format gridxkm
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
                                     grid_names,
                                     path) {
  
  OA_EW_LA <- read.csv(sourcefile[["OA_EW_LA"]])  %>%
    dplyr::rename(AREAcode = OA11CD, EWcode = WD19CD, EWname = WD19NM,
                  LAcode = LAD19CD, LAname = LAD19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))
  
  OA_LSOA_MSOA_LA <- read.csv(sourcefile[["OA_LSOA_MSOA_LA"]])  %>%
    dplyr::rename(AREAcode = `ï..OA11CD`, LSOAcode = LSOA11CD, LSOAname = LSOA11NM,
                  MSOAcode = MSOA11CD, MSOAname = MSOA11NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))
  
  LSOA_CCG <- read.csv(sourcefile[["LSOA_CCG"]])  %>%
    dplyr::rename(LSOAcode = LSOA11CD, CCGcode = CCG19CD, CCGname = CCG19NM,
                  STPcode = STP19CD, STPname = STP19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))
  
  EW_UA <- read.csv(sourcefile[["EW_UA"]])  %>%
    dplyr::rename(EWcode = WD19CD, UAcode = UA19CD, UAname = UA19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))
  
  UA_HB <- read.csv(sourcefile[["UA_HB"]])  %>%
    dplyr::rename(UAcode = UA19CD, LHBcode = LHB19CD, LHBname = LHB19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))
  
  conversion.table <- OA_EW_LA %>% left_join(.,OA_LSOA_MSOA_LA,by = "AREAcode") %>%
    left_join(.,LSOA_CCG,by = "LSOAcode") %>%
    left_join(.,EW_UA,by = "EWcode") %>%
    left_join(.,UA_HB,by = "UAcode")
  
  conversion.table$AREAname <- conversion.table$AREAcode
  conversion.table=as.data.frame(conversion.table)
  
  # Remove special characters
  name_columns=colnames(conversion.table[,grepl("name",colnames(conversion.table))])
  for(col in seq_along(name_columns)){
    conversion.table[,which(colnames(conversion.table)==name_columns[col])]=iconv(conversion.table[,which(colnames(conversion.table)==name_columns[col])], to='ASCII//TRANSLIT')
  }
  
  # Get shapefile if not already downloaded by user -------------------------
  if (!file.exists(output_area_sf)) {
    SCRCdataAPI::download_from_url(source_root="https://opendata.arcgis.com/datasets/",
                                   source_path = "09b58d063d4e421a9cad16ba5419a6bd_0.zip?outSR=%7B%22latestWkid%22%3A27700%2C%22wkid%22%3A27700%7D",
                                   path=file.path(strsplit(output_area_sf, "/")[[1]][1]),
                                   filename = "Output_Areas__December_2011__Boundaries_EW_BFC.zip",
                                   unzip = TRUE)
  }
  # Prepare dz2grid ---------------------------------------------------------
  
  # Read in datazone shapefile and check for non-intersecting geometries
  output_areas <- sf::st_read(output_area_sf, quiet = TRUE) %>%
    sf::st_make_valid() %>% rename(AREAcode=OA11CD)
  
  # Create grid cell intersections
  gridsizes <- grid_names[grepl("^grid", grid_names)] %>%
    lapply(function(x) gsub("grid", "", x) %>% gsub("km", "", .)) %>%
    as.numeric()
  
  oa_subdivisions <- list()
  grid_matrix <- list()
  for (g in seq_along(gridsizes)) {
    tmp <- SCRCdataAPI::grid_intersection(output_areas, gridsizes[g])
    tag <- paste0("grid", gridsizes[g], "km")
    oa_subdivisions[[g]] <- tmp$subdivisions
    names(oa_subdivisions)[g] <- tag
    grid_matrix[[g]] <- tmp$grid_matrix
    names(grid_matrix)[g] <- tag
    oa_subdivisions[[g]]$Datazone_component_id<-
      c(seq_along(oa_subdivisions[[g]]$grid_id))
  }
  
  # Make dataframes of the area of each datazone comoonent in each grid cell
  # at both 1km and 10km
  intersection_area1km <- data.frame(
    grid1km_id = oa_subdivisions$grid1km$grid_id,
    areagrid1km = as.numeric(sf::st_area(oa_subdivisions$grid1km)),
    Datazone_component_id = oa_subdivisions$grid1km$Datazone_component_id,
    AREAcode = oa_subdivisions$grid1km$AREAcode)
  intersection_area10km <- data.frame(
    grid10km_id = oa_subdivisions$grid10km$grid_id,
    areagrid10km = as.numeric(sf::st_area(oa_subdivisions$grid10km)),
    Datazone_component_id = oa_subdivisions$grid10km$Datazone_component_id,
    AREAcode = oa_subdivisions$grid10km$AREAcode)
  
  
  #Make dataframe of datazone area
  oa_area <- data.frame(AREAcode = output_areas$AREAcode,
                        full_zone_area = as.numeric(sf::st_area(output_areas)))
  
  #Find which 1km grid cells are in each 10km grid cell
  
  gridslist=list(grid1km=vector(),
                 grid10km=vector())
  
  #From inside grid_intersection, get sf object of grids
  for(gridsize in gridsizes){
    # Generate grid over bounding box of datazone shapefile
    n <- gridsize*1000  # Assume gridsize given in km
    grids <- sf::st_make_grid(sf::st_as_sfc(sf::st_bbox(output_areas)),
                              cellsize = c(n, n))
    
    width <- sf::st_bbox(output_areas)$xmax - sf::st_bbox(output_areas)$xmin
    height <- sf::st_bbox(output_areas)$ymax - sf::st_bbox(output_areas)$ymin
    num_columns <- ceiling(width / n)
    num_rows <- ceiling(height / n)
    grid_labels <- paste0(1:num_columns, "-", rep(1:num_rows, each = num_columns))
    
    grid_matrix <- strsplit(grid_labels, "-") %>% lapply(as.numeric) %>% do.call(rbind.data.frame, .)
    colnames(grid_matrix) <- c("x", "y")
    
    assertthat::assert_that(max(grid_matrix$x) == num_columns)
    assertthat::assert_that(max(grid_matrix$y) == num_rows)
    
    gridslist[[paste0("grid",gridsize,"km")]] <- sf::st_sf(grids, grid_id = grid_labels)
  }
  
  #Use sf objects to map which 1km cells are inside each 10km cell
  covered_grids=st_covered_by(gridslist$grid1km,gridslist$grid10km,
                              sparse = FALSE)
  
  #Extract this into a more useable format
  grids.array=array(0, dim = c(100,length(gridslist$grid10km$grid_id)))
  
  for(i in seq_len(ncol(covered_grids))){
    if(length(gridslist$grid1km$grid_id[which(covered_grids[,i]==TRUE)])<100){
      grids.array[,i]=c(gridslist$grid1km$grid_id[which(covered_grids[,i]==TRUE)], rep(0, 100-length(gridslist$grid1km$grid_id[which(covered_grids[,i]==TRUE)])))
    }else{
      grids.array[,i]=gridslist$grid1km$grid_id[which(covered_grids[,i]==TRUE)]
      
    }
  }
  
  colnames(grids.array)=gridslist$grid10k$grid_id
  
  grids.array = as.data.frame(grids.array)
  
  grid_lookup=reshape2::melt(grids.array, id.vars = NULL, variable.name = "grid10km_id", 
                             value.name = "grid1km_id")
  grid_lookup=grid_lookup[-which(grid_lookup$grid1km_id==0),]
  grid_lookup$grid10km_id=factor(grid_lookup$grid10km_id,
                                 levels=gridslist$grid10k$grid_id)
  grid_lookup=grid_lookup[order(grid_lookup$grid10km_id),]
  grid_lookup$grid10km_id=as.character(grid_lookup$grid10km_id)
  
  #Which grid cells have output_areas in them?
  present_grids_lookup=grid_lookup[match(intersection_area1km$grid1km_id,
                                         grid_lookup$grid1km_id),]
  
  #Join grids to datazone component areas
  grids_area=left_join(present_grids_lookup,intersection_area1km,
                       by="grid1km_id")
  grids_area = left_join(grids_area, oa_area, by="AREAcode")
  grids_area$prop=grids_area$areagrid1km/grids_area$full_zone_area
  grids_area=grids_area[!duplicated(grids_area$Datazone_component_id),]
  check_proportions=grids_area %>% 
    group_by(AREAcode) %>% 
    summarise(total_prop=sum(prop))
  
  assertthat::assert_that(all((round(check_proportions$total_prop,
                                     digits=2)!=1)==FALSE))
  
  grids_area=left_join(grids_area,intersection_area10km,
                       by=c("grid10km_id","AREAcode"))
  
  #Find proportion of each datazone in each grid cell
  grids_area = grids_area %>%
    dplyr::mutate("grid1km_area_proportion" = areagrid1km / full_zone_area,
                  "grid10km_area_proportion" = areagrid10km / full_zone_area)%>%
    dplyr::select(grid1km_id, grid1km_area_proportion, 
                  grid10km_id,grid10km_area_proportion,AREAcode)
  
  conversion.table = left_join(grids_area,conversion.table, by="AREAcode")
  conversion.table$oa_component_id=c(seq_along(conversion.table$grid1km_id))
  conversion.table = conversion.table %>% tibble::column_to_rownames("oa_component_id")
  conversion.table[is.na(conversion.table)]=0
  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = path,
                            component = "conversiontable/englandwales",
                            df = conversion.table,
                            row_names = rownames(conversion.table),
                            column_units = colnames(conversion.table))
}
