#' process_ukgov_eng_lookup
#'
#' @export
#'
process_scotgov_lookup <- function(sourcefile,h5filename) {
  
    simdlookup<- readxl::read_excel(
    sourcefile[["simd"]],
    sheet=3) %>%
    dplyr::rename(AREAcode = DZ,
                  AREAname = DZname,
                  URcode = URclass) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))
    dzlookup <- readr::read_csv(
    sourcefile[["dz"]]) %>%
    dplyr::rename(AREAcode = DataZone,
                  IZcode=InterZone,
                  MMWcode=MMWard,
                  SPCcode=SPC,
                  LAcode=Council,
                  HBcode=HB,
                  TTWAcode=TTWA,
                  CTRYcode=CTRY) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))%>%
      dplyr::select_if(!grepl(paste(colnames(simdlookup)[-1],collapse="|"), colnames(.)))
    dzlookup$TTWAname=dzlookup$TTWAcode
    dzlookup$CTRYname="Scotland"

    
    conversion.table = left_join(simdlookup, dzlookup, by="AREAcode")
    conversion.table = conversion.table %>% tibble::column_to_rownames("AREAcode")
    conversion.table[is.na(conversion.table)]=0
    SCRCdataAPI::create_table(filename = h5filename,
                              component = "conversiontable/scotland",
                              df = conversion.table,
                              row_title = "datazones",
                              row_names = rownames(conversion.table),
                              column_units = colnames(conversion.table))
}    
