#' process_ons_demographics
#' 
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param h5filename a \code{string} specifying the local path and filename
#' associated with the processed data (the output of this function)
#' @param h5path a \code{string} specifying the local path 
#' associated with the processed data (the output of this function)
#' @param grp.names a \code{string} specifying the shortened names of the 
#' administrative geographies which should match those in the conversion table
#'  and the sizes of the grid squares used in the conversion table in the 
#'  format gridxkm
#' @param full.names a \code{string} specifying the full names of the 
#'  administrative geographies to which the data is converted to.
#' @param age.classes a \code{string} specifying the lower bounds of the age 
#'  classes to which the data should be assigned.
#' @param subgrp.names a \code{string} specifying the human readable names of 
#' the age classes to which the data should be assigned.
#' @param conversionh5filepath a \code{string} specifying the local path 
#'  associated with the conversion table
#' @param conversionh5version_number a \code{string} specifying the filename 
#'  associated with the conversion table
#' @param  genderbreakdown a \code{string} specifying the names which should
#'  be assigned to gender categories in the output file and the gender files
#'  from the input which should be used in each categotry
#'
#' @export
#'
process_ons_demographics <- function (sourcefile,
                                      h5filename,
                                      h5path,
                                      conversionh5version_number,
                                      conversionh5filepath,
                                      grp.names,
                                      full.names,
                                      subgrp.names,
                                      age.classes,
                                      genderbreakdown) {
  
  
  conversion.table <- SCRCdataAPI::read_table(
    filename = paste0(conversionh5version_number,".h5"),
    path = conversionh5filepath,
    component = "conversiontable/englandwales")
  
  
  # Process raw data --------------------------------------------------------
  original.dat <- lapply(seq_along(sourcefile), function(k) {
    
    # Which gender category? (persons, females, males)
    dataset <-  names(sourcefile)[k]
    
    # Read source data
    sape_tmp <- read.csv(sourcefile[k])
    # Read source header
    header_new <- read.csv(sourcefile[k])[1,]
    header_new <- header_new %>%
      names(.) %>% gsub(".", " ",., fixed=TRUE) %>%
      gsub("Age", "AGE",., fixed=TRUE) %>% gsub("AGEd", "AGE",., fixed=TRUE) %>%
      gsub("GEOGRAPHY_NAME", "AREAcode",., fixed=TRUE)
    
    original.dat <- sape_tmp
    colnames(original.dat) <- header_new
    
    transage.dat <- original.dat
    
    # Generate data and attach to hdf5 file -----------------------------------
    
    # For each geography category
    for (i in seq_along(grp.names)) {
      cat(paste0("\rProcessing ",
                 ": ", i, "/", length(grp.names), "..."))
      
      # If ouput area transform to output format
      if (grp.names[i] %in% "OA"){
        tmp.dat <- list(data = transage.dat,
                        area.names = conversion.table %>%
                          dplyr::rename(OAcode = AREAcode,
                                        OAname = AREAname) %>%
                          dplyr::select(OAcode, OAname))
        transarea.dat <- list(
          grid_pop = as.matrix(tmp.dat$data[, -1, drop = FALSE]),
          grid_id = tmp.dat$data[, 1])
        area.names <- tmp.dat$area.names
        
        
        
        # If larger geography use converion table to convert
      } else if (grp.names[i] %in%
                 c("EW", "LA", "LSOA", "MSOA", "CCG", "STP", "UA","LHB")) {
        
        # Transformed data (non-grid transformed)
        tmp.dat <- SCRCdataAPI::convert2lower(
          dat = transage.dat,
          convert_to = grp.names[i],
          conversion_table = conversion.table)
        transarea.dat <- list(grid_pop = as.matrix(tmp.dat$data[,  -1]),
                              grid_id = tmp.dat$data[, 1])
        area.names <- tmp.dat$area.names
        
        # If grid:
      } else if (grepl("grid", grp.names[i])) {
        
        # Transformed data (grid transformed)
        transarea.dat <- SCRCdataAPI::convert2grid(
          dat = transage.dat,
          conversion.table = conversion.table,
          grid_size = grp.names[i])
        
      }
      else {
        stop("OMG! - grpnames")
      }
      
      tmp <- unlist(transarea.dat$grid_id)
      names(tmp) <- NULL
      dimension_names <- list(tmp,
                              colnames(transarea.dat$grid_pop))
      names(dimension_names) <- c(full.names[i], "age groups")
      
      
      # If grid
      if(grepl("grid",  grp.names[i])) {
        location <- file.path(gsub(" ","_",grp.names[i]), "age",
                              names(genderbreakdown)[grepl(dataset,
                                                           genderbreakdown)])
        
        # If file already exists read table, make array, delete table and resave array
        if(check_for_hdf5(filename = file.path(h5path,h5filename),
                          component = location)){
          previous_table <- read_array(filename = h5filename,
                                       path = h5path,
                                       component = location)
          delete_hdf5_link(filename = file.path(h5path,h5filename),
                           component = location)
          
          combined_array <- array(c(as.matrix(previous_table),
                                    as.matrix(transarea.dat$grid_pop)),
                                  dim=c(dim(transarea.dat$grid_pop),2))
          dimension_names$genders=genderbreakdown$genders
          create_array(
            filename = h5filename,
            component = location,
            array = combined_array,
            dimension_names = dimension_names,
            dimension_values = list(transarea.dat$grid_id),
            dimension_units = list(gsub("grid", "", grp.names[i])))
          
        }else{# Else save table
          create_array(
            filename = h5filename,
            path = h5path,
            component = location,
            array = transarea.dat$grid_pop,
            dimension_names = dimension_names,
            dimension_values = list(transarea.dat$grid_id),
            dimension_units = list(gsub("grid", "", grp.names[i])))
        }
        # If administrative geography:
      } else {
        location <- file.path(gsub(" ","_",full.names[i]), "age",
                              names(genderbreakdown)[grepl(dataset,genderbreakdown)])
        # If file already exists read table, make array, delete table and resave array
        if(check_for_hdf5(filename = file.path(h5path,h5filename),
                          component = location)){
          previous_table=read_array(filename = h5filename,
                                    path = h5path,
                                    component = location)
          delete_hdf5_link(filename = file.path(h5path,h5filename),
                           component=location)
          
          combined_array=array(c(as.matrix(previous_table),
                                 as.matrix(transarea.dat$grid_pop)),
                               dim=c(dim(transarea.dat$grid_pop),2))
          dimension_names$genders=genderbreakdown$genders
          create_array(filename = h5filename,
                       path = h5path,
                       component = location,
                       array = combined_array,
                       dimension_names = dimension_names)
          
        }else{# Else save table
          create_array(filename = h5filename,
                       path = h5path,
                       component = location,
                       array = transarea.dat$grid_pop,
                       dimension_names = dimension_names)
        }
      }
    }
  })
}