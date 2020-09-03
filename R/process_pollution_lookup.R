#' process_pollution_lookup
#'
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param filename a \code{string} specifying the local path and filename
#' associated with the processed data (the output of this function)
#' @param output_area_sf a \code{string} specifying the local path and filename
#' associated with a shapefile of England/Wales output areas
#'
#' @export


process_pollution_lookup <- function(sourcefile, filename,output_area_sf){
  
  # Read in UK national grid shapefile
  OS_Grids = sf::st_read(sourcefile[["shapefile"]], quiet = TRUE) %>%
    sf::st_make_valid() %>% rename("GRID_NUM" = "PLAN_NO")
  
  # Read in example pollution data, the datapoint locations are consistent
  # across different pollution data.
  pollution.sf = read.csv(sourcefile[["pollution/example"]], skip = 5)%>%
    sf::st_as_sf(coords = c("x","y"), crs="EPSG:27700")
  
  # Use st_contains to find which OS grid the centre point of the pollution
  # grid is in
  grids_contain = sf::st_contains(OS_Grids, pollution.sf)
  
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
  
  # Join tables together to get matching codes
  
  #Join covered by dataframe to OS_grid shapefile
  contains.df = as.data.frame(contains.df)
  contains.df$newcode = 1:nrow(contains.df)
  OS_Grids$newcode = 1:nrow(OS_Grids)
  OS_Grids = left_join(OS_Grids, contains.df, by = "newcode")
  # Join pollution data to shapefile
  OS_Grids$newcode = OS_Grids$V1
  pollution.join = pollution.sf
  pollution.join$newcode = 1:nrow(pollution.join)
  pollution.join$geometry=NULL
  OS_Grids = left_join(OS_Grids, pollution.join, by = "newcode")
  pollution_to_grids = OS_Grids[,c(1,4)]
  pollution_to_grids$geometry = NULL
  pollution_to_grids = left_join(pollution.sf, pollution_to_grids, by = "ukgridcode")
  
  #Make lookup table by removing geometry attributes and save
  lookup_file = pollution_to_grids[,c("ukgridcode","GRID_NUM")] %>% rename(Pollution_grid = "ukgridcode", OS_NationalGrid = "GRID_NUM")
  lookup_file$geometry = NULL
  lookup_file = lookup_file[!is.na(lookup_file$OS_NationalGrid),]
  rownames(lookup_file) = NULL
  lookup_file = lookup_file %>% column_to_rownames("Pollution_grid")
  grid_codes = rownames(lookup_file)
  
  SCRCdataAPI::create_table(filename = filename,
                            path = "data-raw/geography/national_grid/pollution/lookup",
                            component = "UK_national_grid1km",
                            df = lookup_file,
                            row_names = grid_codes,
                            column_units = "Pollution Grid Codes")
  
  ## DATAZONES
  # Open datazone shapefile sf object
  datazone_shp = SCRCdata::scot_datazone_sf
  
  # Find which pollution data location points are in each datazone
  datazone_coveredby = st_contains(datazone_shp,pollution.sf)
  
  # Use this to make dataframe of datazones to pollution grid points
  first=TRUE
  for(row in seq_len(length(datazone_coveredby))){
    cat(paste0("\rDatazone ", row, " of ", length(datazone_coveredby)))
    if(first == TRUE){
      if(length(datazone_coveredby[[row]]>0)){
        datazone_pollution = data.frame("AREAcode" = datazone_shp$AREAcode[row], "Grid_code" = pollution.join$ukgridcode[datazone_coveredby[[row]]])
        first = FALSE
      } 
      
    }else{
      if(length(datazone_coveredby[[row]]>0)){
        datazone_pollution = rbind(datazone_pollution, data.frame("AREAcode" = datazone_shp$AREAcode[row], "Grid_code" = pollution.join$ukgridcode[datazone_coveredby[[row]]]))
      }
      
    }
  }

  datazone_pollution = datazone_pollution %>% column_to_rownames("Grid_code")
  AREAcodes = rownames(datazone_pollution)
  SCRCdataAPI::create_table(filename = filename,
                            path = "data-raw/geography/national_grid/pollution/lookup",
                            component = "scotland_datazone",
                            df = datazone_pollution,
                            row_names = AREAcodes,
                            column_units = "Pollution Grid Codes")
  
  # OUTPUT AREAS
  # Open output area shapefile
  if (!file.exists(output_area_sf)) {
    SCRCdataAPI::download_from_url(source_root="https://opendata.arcgis.com/datasets/",
                                   source_path = "09b58d063d4e421a9cad16ba5419a6bd_0.zip?outSR=%7B%22latestWkid%22%3A27700%2C%22wkid%22%3A27700%7D",
                                   path=file.path(str_split(output_area_sf, "/")[[1]][1]),
                                   filename = str_split(output_area_sf, "/")[[1]][3])
  }
  oa_shp <- sf::st_read(output_area_sf, quiet = TRUE) %>%
    sf::st_make_valid() %>% rename(AREAcode=OA11CD)
  
  # Find which pollution data location points are in each datazone
  oa_coveredby = st_contains(oa_shp,pollution.sf)
  
  # Use this to make dataframe of output areas to pollution grid points
  first=TRUE
  for(row in seq_len(length(oa_coveredby))){
    cat(paste0("\rOutput Area: ", row, " of ", length(oa_coveredby)))
    if(first == TRUE){
      if(length(oa_coveredby[[row]]>0)){
        oa_pollution = data.frame("AREAcode" = oa_shp$AREAcode[row], "Grid_code" = pollution.join$ukgridcode[oa_coveredby[[row]]])
        first = FALSE
      } 
      
      
    }else{
      if(length(oa_coveredby[[row]]>0)){
        oa_pollution = rbind(oa_pollution, data.frame("AREAcode" = oa_shp$AREAcode[row], "Grid_code" = pollution.join$ukgridcode[oa_coveredby[[row]]]))
      }
      
    }
  }
  oa_pollution = oa_pollution %>% column_to_rownames("Grid_code")
  AREAcodes = rownames(oa_pollution)
  SCRCdataAPI::create_table(filename = filename,
                            path = "data-raw/geography/national_grid/pollution/lookup",
                            component = "england_output_area",
                            df = oa_pollution,
                            row_names = AREAcodes,
                            column_units = "Pollution Grid Codes")
}

