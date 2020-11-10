#' process_pollution_data
#'
#' @param source_filename a \code{string} specifying the local path associated 
#' with the folders containing the pollution source data (the input of this function)
#' which is separated by year
#' @param h5filename a \code{string} specifying the filename
#' associated with the processed data (the output of this function)
#' @param storage_path a \code{string }specifying the local path associated 
#' with the processed data (the output of this function)
#' @param conversion_table a \code{string} specifying the local path and filename
#' associated with a lookup file of UK national grid codes and UKAIR pollution codes
#' @param years a \code{string} specifying the years of pollution data which are 
#' to be collated
#'
#' @export


process_pollution_data <- function(source_filename, years, conversion_table, storage_path, h5filename){
  conversion_table_scot <- SCRCdataAPI::read_table(filepath = conversion_table,
                                                   component = "conversiontable/scotland") %>% select(grid1km_id, "pollution_code")
  conversion_table_eng <- SCRCdataAPI::read_table(filepath = conversion_table,
                                                  component = "conversiontable/england/wales")%>% select(grid1km_id, "pollution_code")
  
  
  
  ##pm10
  for(year in seq_along(years)){
    poll_file_tmp = read.csv(file.path("data-raw", "pollution", source_filename[["pm10"]], paste0(years[[year]],".csv")),skip = 5) %>% select(-"x",-"y")
    colnames(poll_file_tmp)[grepl("pm10",colnames(poll_file_tmp) )] = substr(colnames(poll_file_tmp)[grepl("pm10",colnames(poll_file_tmp) )], 5,8)
    if(years[[year]] ==min(years)){
      poll_file = poll_file_tmp
    }else{
      poll_file = left_join(poll_file, poll_file_tmp, by = "ukgridcode")
    }
  }
  scot_poll_file = convert_to_OSgrid(poll_file, conversion_table = conversion_table_scot) %>% column_to_rownames(grid1km_id)
  eng_poll_file =convert_to_OSgrid(poll_file, conversion_table = conversion_table_eng) %>% column_to_rownames(grid1km_id)
  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "scotland/pm10",
                            df = scot_poll_file,
                            row_names = rownames(scot_poll_file),
                            column_units = colnames(scot_poll_file)) 
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "england/pm10",
                            df = eng_poll_file,
                            row_names = rownames(eng_poll_file),
                            column_units = colnames(eng_poll_file)) 
  
  ## pm2.5
  for(year in seq_along(years)){
    poll_file_tmp = read.csv(file.path("data-raw", "pollution", source_filename[["pm2.5"]], paste0(years[[year]],".csv")),skip = 5) %>% select(-"x",-"y")
    colnames(poll_file_tmp)[grepl("pm25",colnames(poll_file_tmp) )] = substr(colnames(poll_file_tmp)[grepl("pm25",colnames(poll_file_tmp) )], 5,8)
    if(years[[year]] ==min(years)){
      poll_file = poll_file_tmp
    }else{
      poll_file = left_join(poll_file, poll_file_tmp, by = "ukgridcode")
    }
  }
  scot_poll_file = convert_to_OSgrid(poll_file, conversion_table = conversion_table_scot) %>% column_to_rownames(grid1km_id)
  eng_poll_file =convert_to_OSgrid(poll_file, conversion_table = conversion_table_eng) %>% column_to_rownames(grid1km_id)
  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "scotland/pm2.5",
                            df = scot_poll_file,
                            row_names = rownames(scot_poll_file),
                            column_units = colnames(scot_poll_file)) 
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "england/pm2.5",
                            df = eng_poll_file,
                            row_names = rownames(eng_poll_file),
                            column_units = colnames(eng_poll_file)) 
  ##NO2
  for(year in seq_along(years)){
    poll_file_tmp = read.csv(file.path("data-raw", "pollution", source_filename[["NO2"]], paste0(years[[year]],".csv")),skip = 5) %>% select(-"x",-"y")
    colnames(poll_file_tmp)[grepl("no2",colnames(poll_file_tmp) )] = substr(colnames(poll_file_tmp)[grepl("no2",colnames(poll_file_tmp) )], 4,8)
    if(years[[year]] ==min(years)){
      poll_file = poll_file_tmp
    }else{
      poll_file = left_join(poll_file, poll_file_tmp, by = "ukgridcode")
    }
  }
  scot_poll_file = convert_to_OSgrid(poll_file, conversion_table = conversion_table_scot) %>% column_to_rownames(grid1km_id)
  eng_poll_file =convert_to_OSgrid(poll_file, conversion_table = conversion_table_eng) %>% column_to_rownames(grid1km_id)
  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "scotland/NO2",
                            df = scot_poll_file,
                            row_names = rownames(scot_poll_file),
                            column_units = colnames(scot_poll_file)) 
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "england/NO2",
                            df = eng_poll_file,
                            row_names = rownames(eng_poll_file),
                            column_units = colnames(eng_poll_file)) 
  
  #NOx
  for(year in seq_along(years)){
    poll_file_tmp = read.csv(file.path("data-raw", "pollution", source_filename[["NOx"]], paste0(years[[year]],".csv")),skip = 5) %>% select(-"x",-"y")
    colnames(poll_file_tmp)[grepl("nox",colnames(poll_file_tmp) )] = substr(colnames(poll_file_tmp)[grepl("nox",colnames(poll_file_tmp) )], 4,8)
    if(years[[year]] ==min(years)){
      poll_file = poll_file_tmp
    }else{
      poll_file = left_join(poll_file, poll_file_tmp, by = "ukgridcode")
    }
  }
  scot_poll_file = convert_to_OSgrid(poll_file, conversion_table = conversion_table_scot) %>% column_to_rownames(grid1km_id)
  eng_poll_file =convert_to_OSgrid(poll_file, conversion_table = conversion_table_eng) %>% column_to_rownames(grid1km_id)
  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "scotland/NOx",
                            df = scot_poll_file,
                            row_names = rownames(scot_poll_file),
                            column_units = colnames(scot_poll_file)) 
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "england/NOx",
                            df = eng_poll_file,
                            row_names = rownames(eng_poll_file),
                            column_units = colnames(eng_poll_file)) 
  
  ## SO2
  for(year in seq_along(years)){
    poll_file_tmp = read.csv(file.path("data-raw", "pollution", source_filename[["SO2"]], paste0(years[[year]],".csv")),skip = 5) %>% select(-"x",-"y")
    colnames(poll_file_tmp)[grepl("so2",colnames(poll_file_tmp) )] = substr(colnames(poll_file_tmp)[grepl("so2",colnames(poll_file_tmp) )], 4,8)
    if(years[[year]] ==min(years)){
      poll_file = poll_file_tmp
    }else{
      poll_file = left_join(poll_file, poll_file_tmp, by = "ukgridcode")
    }
    
  }
  colnames(poll_file)[-1] = 2007:2019
  
  scot_poll_file = convert_to_OSgrid(poll_file, conversion_table = conversion_table_scot) %>% column_to_rownames(grid1km_id)
  eng_poll_file =convert_to_OSgrid(poll_file, conversion_table = conversion_table_eng) %>% column_to_rownames(grid1km_id)
  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "scotland/SO2",
                            df = scot_poll_file,
                            row_names = rownames(scot_poll_file),
                            column_units = colnames(scot_poll_file)) 
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "england/SO2",
                            df = eng_poll_file,
                            row_names = rownames(eng_poll_file),
                            column_units = colnames(eng_poll_file)) 
  # Ozone
  for(year in seq_along(years)){
    poll_file_tmp = read.csv(file.path("data-raw", "pollution", source_filename[["Ozone"]], paste0(years[[year]],".csv")),skip = 5) %>% select(-"x",-"y")
    if(years[[year]]<2013){
      colnames(poll_file_tmp)[grepl("dgt1",colnames(poll_file_tmp) )] = paste0(substr(colnames(poll_file_tmp)[grepl("dgt1",colnames(poll_file_tmp) )], 5,6), 
                                                                               substr(colnames(poll_file_tmp)[grepl("dgt1",colnames(poll_file_tmp) )], 8,9))
    }else{
      colnames(poll_file_tmp)[grepl("dgt1",colnames(poll_file_tmp) )] = substr(colnames(poll_file_tmp)[grepl("dgt1",colnames(poll_file_tmp) )], 5,8)
    }
    if(years[[year]] ==min(years)){
      poll_file = poll_file_tmp
    }else{
      poll_file = left_join(poll_file, poll_file_tmp, by = "ukgridcode")
    }
  }
  scot_poll_file = convert_to_OSgrid(poll_file, conversion_table = conversion_table_scot) %>% column_to_rownames(grid1km_id)
  eng_poll_file =convert_to_OSgrid(poll_file, conversion_table = conversion_table_eng) %>% column_to_rownames(grid1km_id)
  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "scotland/ozone",
                            df = scot_poll_file,
                            row_names = rownames(scot_poll_file),
                            column_units = colnames(scot_poll_file)) 
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "england/ozone",
                            df = eng_poll_file,
                            row_names = rownames(eng_poll_file),
                            column_units = colnames(eng_poll_file)) 
  
  ## Benzene
  
  for(year in seq_along(years)){
    poll_file_tmp = read.csv(file.path("data-raw", "pollution", source_filename[["Benzene"]], paste0(years[[year]],".csv")),skip = 5) %>% select(-"x",-"y")
    colnames(poll_file_tmp)[grepl("bz",colnames(poll_file_tmp) )] = substr(colnames(poll_file_tmp)[grepl("bz",colnames(poll_file_tmp) )], 3,8)
    if(years[[year]] ==min(years)){
      poll_file = poll_file_tmp
    }else{
      poll_file = left_join(poll_file, poll_file_tmp, by = "ukgridcode")
    }
  }
  scot_poll_file = convert_to_OSgrid(poll_file, conversion_table = conversion_table_scot) %>% column_to_rownames(grid1km_id)
  eng_poll_file =convert_to_OSgrid(poll_file, conversion_table = conversion_table_eng) %>% column_to_rownames(grid1km_id)
  
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "scotland/benzene",
                            df = scot_poll_file,
                            row_names = rownames(scot_poll_file),
                            column_units = colnames(scot_poll_file)) 
  SCRCdataAPI::create_table(filename = h5filename,
                            path = storage_path,
                            component = "england/benzene",
                            df = eng_poll_file,
                            row_names = rownames(eng_poll_file),
                            column_units = colnames(eng_poll_file)) 
}


convert_to_OSgrid <- function(poll_file, conversion_table){
  poll_file = poll_file %>% rename("pollution_code" = "ukgridcode")
  poll_file <- left_join(conversion_table, poll_file, by = "pollution_code") %>% select(-"pollution_code")
  poll_file
}

