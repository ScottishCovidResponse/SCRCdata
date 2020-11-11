#' process_pollution_lookup
#'
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param h5filename a \code{string} specifying the filename
#' associated with the processed data (the output of this function)
#' @param scotgov_lookup a \code{string} specifying the local path and filename
#' associated with a lookup file of UK national grid codes and administrative 
#' geographies in scotland
#' @param ukgov_engwales_lookup a \code{string} specifying the local path and 
#' filename associated with a lookup file of UK national grid codes and 
#' administrative geographies in England and Wales
#' @param storage_path a \code{string} specifying the local path associated with 
#' the processed data (the output of this function)
#'
#' @export


process_pollution_lookup <- function(sourcefile, 
                                     h5filename,
                                     scotgov_lookup, 
                                     ukgov_engwales_lookup,
                                     storage_path){
  
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
  
  # Match pollution codes to UK national grid codes
  
  # Column of the contains dataframe should represent rows of the pollution sf dataframe
  # rows of the contains dataframe represent the rows of the uk national grid shapefile
  contains.df = as.data.frame(contains.df) %>% rename("rowname" = "V1")
  pollution.sf = rownames_to_column(pollution.sf) %>% mutate("rowname" = as.numeric("rowname"))
  rownames(contains.df) = OS_Grids$GRID_NUM
  contains.df = rownames_to_column(contains.df,"GRID_NUM")
  lookup = left_join(contains.df, pollution.sf, by = "rowname") %>% select("GRID_NUM", "ukgridcode") %>% rename("grid1km_id" = "GRID_NUM","pollution_code" = "ukgridcode" )
  lookup = lookup[-which(is.na(lookup$pollution_code)),]
  
  
  # Use scottish and english conversion tables to subset out pollution codes
  # associated with each country
  
  scotgov_lookup_table = SCRCdataAPI::read_table(scotgov_lookup,"conversiontable/scotland" )
  scotland_pollution_lookup = left_join(scotgov_lookup_table, lookup, by = "grid1km_id") %>% 
    select("grid1km_id", "pollution_code")
  engwales_lookup_table = SCRCdataAPI::read_table(ukgov_engwales_lookup,"conversiontable/englandwales" )
  engwales_pollution_lookup = left_join(engwales_lookup_table, lookup, by = "grid1km_id")%>% 
    select("grid1km_id", "pollution_code")
  
  # Save new lookup files
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "conversiontable/scotland",
                            df = scotland_pollution_lookup,
                            row_names = rownames(scotland_pollution_lookup),
                            column_units = colnames(scotland_pollution_lookup))  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "conversiontable/englandwales",
                            df = engwales_pollution_lookup,
                            row_names = rownames(engwales_pollution_lookup),
                            column_units = colnames(engwales_pollution_lookup))
}
  