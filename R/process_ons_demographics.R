#' process_ons_demographics
#' 
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param h5filename a \code{string} specifying the local path and filename
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
#'
#' @export
#'
process_ons_demographics <- function (sourcefile,
                                      h5filename,
                                      conversionh5version_number,
                                      conversionh5filepath,
                                      grp.names,
                                      full.names,
                                      subgrp.names,
                                      age.classes) {
  
  
  conversion.table <- SCRCdataAPI::read_table(
    filename = paste0(conversionh5version_number,".h5"),
    path = conversionh5filepath,
    component = "conversiontable/englandwales")
  # Process raw data --------------------------------------------------------
  original.dat <- lapply(seq_along(sourcefile), function(k) {
    
    dataset <- sourcefile[k] %>%
      gsub("data-raw/england_", "", .) %>%
      gsub(".csv", "", .)
    
    sape_tmp <- read.csv(sourcefile[k])
    header_new <- read.csv(sourcefile[k])[1,]
    header_new <- header_new %>%
      names(.) %>% gsub(".", " ",., fixed=TRUE) %>%
      gsub("Age", "AGE",., fixed=TRUE) %>% gsub("AGEd", "AGE",., fixed=TRUE) %>%
      gsub("GEOGRAPHY_NAME", "AREAcode",., fixed=TRUE)
    
    original.dat <- sape_tmp
    colnames(original.dat) <- header_new
    
    # Generate data and attach to hdf5 file -----------------------------------
    transage.dat <- original.dat
    
    for (i in seq_along(grp.names)) {
      cat(paste0("\rProcessing ",
                 ": ", i, "/", length(grp.names), "..."))
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
      
      location <- file.path(grp.names[i], subgrp.names, dataset)
      tmp <- unlist(transarea.dat$grid_id)
      names(tmp) <- NULL
      dimension_names <- list(tmp,
                              colnames(transarea.dat$grid_pop))
      names(dimension_names) <- c(full.names[i], "age groups")
      
      if (grepl("grid", grp.names[i])) {
        SCRCdataAPI::create_array(
          filename = h5filename,
          component = location,
          array = transarea.dat$grid_pop,
          dimension_names = dimension_names,
          dimension_values = list(grid_matrix[[grp.names[i]]]),
          dimension_units = list(gsub("grid", "", grp.names[i])))
      }else {
        SCRCdataAPI::create_array(filename = h5filename,
                                  component = location,
                                  array = transarea.dat$grid_pop,
                                  dimension_names = dimension_names)
      }
    }
  })
}
