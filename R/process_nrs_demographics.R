#' process_nrs_demographics
#'
#' @export
#'
process_nrs_demographics <- function(sourcefile, h5filename,
                                     grp.names, full.names, subgrp.names,
                                     age.classes,conversionh5filename,genderbreakdown) {
  
  # Prepare conversion table
  conversion.table <- SCRCdataAPI::read_table(filename = conversionh5filename, 
                                              component = "conversiontable/scotland")
  
  
  # Process raw data --------------------------------------------------------
  for(gbreak in seq_along(genderbreakdown)){
    if(grepl("persons",genderbreakdown[gbreak])){
      k=1
        dataset <- sourcefile[k] %>%
          gsub("data-raw/sape-2018-", "", .) %>%
          gsub(".xlsx", "", .)
        
        sape_tmp <- readxl::read_excel(sourcefile[k], col_names = FALSE)
        header <- readxl::read_excel(sourcefile[k], skip = 3, n_max = 2)
        header <- header %>%
          dplyr::rename_at(vars(grep("^\\...[1-3]", names(.))),
                           ~ as.character(header[2, 1:3])) %>%
          dplyr::rename(AllAges = "...4") %>%
          names()
        
        original.dat <- sape_tmp %>%
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
        
        for(j in seq_along(subgrp.names)) {
          
          # Aggregate age classes
          if(subgrp.names[j] == "1year") {
            transage.dat <- original.dat
            
          } else if(subgrp.names[j] == "total") {
            transage.dat <- SCRCdataAPI::bin_ages(original.dat, age.classes[[j]])
            
          } else {
            transage.dat <- SCRCdataAPI::bin_ages(original.dat, age.classes[[j]])
          }
          
          for(i in seq_along(grp.names)) {
            cat(paste0("\rProcessing ", j, "/", length(subgrp.names), ": ",
                       i, "/", length(grp.names), "..."))
            
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
              
            } else if(grp.names[i] %in% c("ur","iz","mmw","spc","la", "hb", "ttwa")) {
              
              # Transformed data (non-grid transformed)
              tmp.dat <- SCRCdataAPI::convert2lower(
                dat = transage.dat,
                convert_to = grp.names[i],
                conversion_table = conversion.table)
              transarea.dat <- list(grid_pop = as.matrix(tmp.dat$data[, -1]),
                                    grid_id = tmp.dat$data[, 1])
              area.names <- tmp.dat$area.names
              
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
            
            if(grepl("grid",  grp.names[i])) {
              location <- file.path(gsub(" ","_",grp.names[i]), "age", names(genderbreakdown)[grepl(dataset,genderbreakdown)])
              paste0(location)
              SCRCdataAPI::create_array(
                  filename = h5filename,
                  component = location,
                  array = transarea.dat$grid_pop,
                  dimension_names = dimension_names,
                  dimension_values = list(transarea.dat$grid_id),
                  dimension_units = list(gsub("grid", "", grp.names[i])))
                
              } else {
                location <- file.path(gsub(" ","_",full.names[i]), "age", names(genderbreakdown)[grepl(dataset,genderbreakdown)])
                paste0(location)
                SCRCdataAPI::create_array(filename = h5filename,
                                          component = location,
                                          array = transarea.dat$grid_pop,
                                          dimension_names = dimension_names)
              }
            }
          }
    }else{
      for(j in seq_along(subgrp.names)) {
        # Generate data and attach to hdf5 file ---------------------------------
        
        for(i in seq_along(grp.names)) {
          cat(paste0("\rProcessing ", j, "/", length(subgrp.names), ": ",
                     i, "/", length(grp.names), "..."))
          dat.store=list("males_pop"=c(),
                         "males_id"=c(),
                         "females_pop"=c(),
                         "females_id=c()")
          if(grp.names[i] %in% "dz") {
            for(k in seq_along(unlist(genderbreakdown[2]))){
              source.k=sourcefile[grepl(paste0("\\b",unlist(genderbreakdown[2])[k]),sourcefile)]
              dataset <- source.k %>%
                gsub("data-raw/sape-2018-", "", .) %>%
                gsub(".xlsx", "", .)
              
              sape_tmp <- readxl::read_excel(source.k, col_names = FALSE)
              header <- readxl::read_excel(sourcefile[k], skip = 3, n_max = 2)
              header <- header %>%
                dplyr::rename_at(vars(grep("^\\...[1-3]", names(.))),
                                 ~ as.character(header[2, 1:3])) %>%
                dplyr::rename(AllAges = "...4") %>%
                names()
              
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
              # Transformed data (non-grid transformed)
              tmp.dat <- list(data = transage.dat,
                              area.names = conversion.table %>%
                                dplyr::rename(DZcode = AREAcode,
                                              DZname = AREAname) %>%
                                dplyr::select(DZcode, DZname))
              dat.store[[paste0(dataset, "pop")]]= as.matrix(tmp.dat$data[, -1, drop = FALSE])
              dat.store[[paste0(dataset, "id")]]= tmp.dat$data[, 1]
              area.names <- tmp.dat$area.names
              
            }
          } else if(grp.names[i] %in% c("ur","iz","mmw","spc","la", "hb", "ttwa")) {
            for(k in seq_along(unlist(genderbreakdown[2]))){
              source.k=sourcefile[grepl(paste0("\\b",unlist(genderbreakdown[2])[k]),sourcefile)]
              dataset <- source.k %>%
                gsub("data-raw/sape-2018-", "", .) %>%
                gsub(".xlsx", "", .)
              
              sape_tmp <- readxl::read_excel(source.k, col_names = FALSE)
              header <- readxl::read_excel(sourcefile[k], skip = 3, n_max = 2)
              header <- header %>%
                dplyr::rename_at(vars(grep("^\\...[1-3]", names(.))),
                                 ~ as.character(header[2, 1:3])) %>%
                dplyr::rename(AllAges = "...4") %>%
                names()
              
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
              # Transformed data (non-grid transformed)
              tmp.dat <- SCRCdataAPI::convert2lower(
                dat = transage.dat,
                convert_to = grp.names[i],
                conversion_table = conversion.table)
              dat.store[[paste0(dataset, "pop")]]= as.matrix(tmp.dat$data[, -1, drop = FALSE])
              dat.store[[paste0(dataset, "id")]]= tmp.dat$data[, 1]
              area.names <- tmp.dat$area.names
            }
            
          } else if(grepl("grid",  grp.names[i])) {
            for(k in seq_along(unlist(genderbreakdown[2]))){
              source.k=sourcefile[grepl(paste0("\\b",unlist(genderbreakdown[2])[k]),sourcefile)]
              dataset <- source.k %>%
                gsub("data-raw/sape-2018-", "", .) %>%
                gsub(".xlsx", "", .)
              
              sape_tmp <- readxl::read_excel(source.k, col_names = FALSE)
              header <- readxl::read_excel(sourcefile[k], skip = 3, n_max = 2)
              header <- header %>%
                dplyr::rename_at(vars(grep("^\\...[1-3]", names(.))),
                                 ~ as.character(header[2, 1:3])) %>%
                dplyr::rename(AllAges = "...4") %>%
                names()
              
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
              # Transformed data (grid transformed)
              transarea.dat <- SCRCdataAPI::convert2grid(
                dat = transage.dat,
                grid_size=grp.names[i],
                conversion.table = conversion.table)
              dat.store[[paste0(dataset, "pop")]]= transarea.dat$grid_pop
              dat.store[[paste0(dataset, "id")]]= transarea.dat$grid_id
            }
          } else {
            stop("OMG! - grpnames")
          }
          

          tmp.m <- unlist(dat.store$malesid)
          tmp.f <- unlist(dat.store$femalesid)
          assertthat::assert_that(all(tmp.m==tmp.f))
          tmp=tmp.m
          names(tmp) <- NULL
          cols.m <- colnames(dat.store$malespop)
          cols.f <- colnames(dat.store$femalespop)
          assertthat::assert_that(all(cols.m==cols.f))
          dimension_names <- list(tmp,
                                  colnames(dat.store$malespop),
                                  unlist(genderbreakdown[2]))
          names(dimension_names) <- c(full.names[i], "age groups", "gender")
          
          if(grepl("grid",  grp.names[i])) {
            location <- file.path(gsub(" ","_",grp.names[i]), "age", names(genderbreakdown)[grepl(dataset,genderbreakdown)])
            paste0(location)
            SCRCdataAPI::create_array(
              filename = h5filename,
              component = location,
              array =  array(c(dat.store$malespop,
                               dat.store$femalespop),
                             dim = c(dim(dat.store$malespop),2)),
                             dimension_names = dimension_names,
                             dimension_values = list(transarea.dat$grid_id),
                             dimension_units = list(gsub("grid", "", grp.names[i])))
            
          } else {
            location <- file.path(gsub(" ","_",full.names[i]), "age", names(genderbreakdown)[grepl(dataset,genderbreakdown)])
            paste0(location)
            SCRCdataAPI::create_array(filename = h5filename,
                                      component = location,
                                      array = array(c(dat.store$malespop,
                                                      dat.store$femalespop),
                                                    dim = c(dim(dat.store$malespop),2)),
                                      dimension_names = dimension_names)
          }
        }
      }
    }
  }
}

