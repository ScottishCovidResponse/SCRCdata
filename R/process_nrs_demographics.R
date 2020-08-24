#' process_nrs_demographics
#' 
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param h5filename a \code{string} specifying the local path and filename
#' associated with the processed data (the output of this function)
#' @param grp.names a \code{string} specifying the shortened names of the 
#' administrative geographies - which should match those in the conversion table
#'  - and the sizes of the grid squares used in the conversion table in the 
#'  format gridxkm
#' @param full.names a \code{string} specifying the full names of the 
#'  administrative geographies to which the data is converted to.
#' @param age.classes a \code{string} specifying the lower bounds of the age 
#'  classes to which the data should be assigned.
#' @param conversionh5filename a \code{string} specifying the local path and 
#'  filename associated with the conversion table
#' @param  genderbreakdown a \code{string} specifying the names which should 
#'  be assigned to gender categories in the output file and the gender files 
#'  from the input which should be used in each categotry
#'
#' @export
#'
process_nrs_demographics <- function(sourcefile, 
                                     h5filename,
                                     grp.names, 
                                     full.names,
                                     age.classes,
                                     conversionh5filename,
                                     genderbreakdown) {
  
  # Prepare conversion table
  conversion.table <- SCRCdataAPI::read_table(filename = conversionh5version_number, 
                                              path = conversionh5filepath,
                                              component = "conversiontable/scotland")
  
  
  # Process raw data --------------------------------------------------------
  original.dat <- lapply(seq_along(sourcefile), function(k) {
    # Which gender category? (persons, females, males)
        dataset <- sourcefile[k] %>%
          gsub("data-raw/sape-2018-", "", .) %>%
          gsub(".xlsx", "", .)
        
        # Read source data
        sape_tmp <- readxl::read_excel(sourcefile[k], col_names = FALSE)
        # Read source header
        header <- readxl::read_excel(sourcefile[k], skip = 3, n_max = 2)
        header <- header %>%
          dplyr::rename_at(vars(grep("^\\...[1-3]", names(.))),
                           ~ as.character(header[2, 1:3])) %>%
          dplyr::rename(AllAges = "...4") %>%
          names()
        
        # Process source data into useable form, removing in-built metadata etc.
        transage.dat <- sape_tmp %>%
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
        
        
        # Generate data and attach to hdf5 file ---------------------------------
        
        # For each geography category
          for(i in seq_along(grp.names)) {
            cat(paste0("\rProcessing",": ",
                       i, "/", length(grp.names), "..."))
            
            # If datazone transform to output format
            if(grp.names[i] %in% "dz") {
              
              # Transformed data (non-grid transformed)
              tmp.dat <- list(data = transage.dat,
                              area.names = conversion.table %>%
                                dplyr::rename(DZcode = AREAcode,
                                              DZname = AREAname) %>%
                                dplyr::select(DZcode, DZname))
              transarea.dat <- list(
                grid_pop = as.matrix(tmp.dat$data[, -1, drop = FALSE]),
                grid_id = tmp.dat$data[, 1])
              area.names <- tmp.dat$area.names
              
              
              #If larger geography use converion table to convert 
            } else if(grp.names[i] %in% c("ur","iz","mmw","spc","la", "hb", "ttwa")) {
              
              # Transformed data (non-grid transformed)
              tmp.dat <- SCRCdataAPI::convert2lower(
                dat = transage.dat,
                convert_to = grp.names[i],
                conversion_table = conversion.table)
              transarea.dat <- list(grid_pop = as.matrix(tmp.dat$data[, -1]),
                                    grid_id = tmp.dat$data[, 1])
              area.names <- tmp.dat$area.names
              
              
              # If grid:
            } else if(grepl("grid",  grp.names[i])) {
              
              # Transformed data (grid transformed)
              transarea.dat <- SCRCdataAPI::convert2grid(
                dat = transage.dat,
                grid_size=grp.names[i],
                conversion.table = conversion.table)
              
            } else {
              stop("OMG! - grpnames")
            }
            
            tmp <- unlist(transarea.dat$grid_id)
            names(tmp) <- NULL
            dimension_names <- list(tmp,
                                    colnames(transarea.dat$grid_pop))
            names(dimension_names) <- c(full.names[i], "age groups")
            
            # If grid
            if(grepl("grid",  grp.names[i])) {
              location <- file.path(gsub(" ","_",grp.names[i]), "age", names(genderbreakdown)[grepl(dataset,genderbreakdown)])
              # If file already exists read table, make array, delete table and resave array
              if(check_for_hdf5(filename = h5filename,
                                component = location)){
                previous_table=read_array(filename = h5filename, 
                                          component = location)
                delete_hdf5_link(filename = h5filename,
                                 component=location)
                
                combined_array=array(c(as.matrix(previous_table),as.matrix(transarea.dat$grid_pop)),
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
                  component = location,
                  array = transarea.dat$grid_pop,
                  dimension_names = dimension_names,
                  dimension_values = list(transarea.dat$grid_id),
                  dimension_units = list(gsub("grid", "", grp.names[i])))
              }
                # If administrative geography:
              } else {
                location <- file.path(gsub(" ","_",full.names[i]), "age", names(genderbreakdown)[grepl(dataset,genderbreakdown)])
                # If file already exists read table, make array, delete table and resave array
                if(check_for_hdf5(filename = h5filename,
                                  component = location)){
                  previous_table=read_array(filename = h5filename, 
                                            component = location)
                  delete_hdf5_link(filename = h5filename,
                                   component=location)
                  
                  combined_array=array(c(as.matrix(previous_table),as.matrix(transarea.dat$grid_pop)),
                                       dim=c(dim(transarea.dat$grid_pop),2))
                  dimension_names$genders=genderbreakdown$genders
                  create_array(filename = h5filename,
                               component = location,
                               array = combined_array,
                               dimension_names = dimension_names)
                  
                }else{# Else save table
                  create_array(filename = h5filename,
                               component = location,
                               array = transarea.dat$grid_pop,
                               dimension_names = dimension_names)
                }
              }
            }
          })
  }