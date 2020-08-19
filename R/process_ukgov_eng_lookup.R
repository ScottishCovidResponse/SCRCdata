#' process_ukgov_eng_lookup
#'
#' @export
#'
process_ukgov_eng_lookup <- function(sourcefile, h5filename) {

  OA_EW_LA <- read.csv(sourcefile["OA_EW_LA"])  %>%
    dplyr::rename(AREAcode = OA11CD, EWcode = WD19CD, EWname = WD19NM,
                  LAcode = LAD19CD, LAname = LAD19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  OA_LSOA_MSOA_LA <- read.csv(sourcefile["OA_LSOA_MSOA_LA"])  %>%
    dplyr::rename(AREAcode = OA11CD, LSOAcode = LSOA11CD, LSOAname = LSOA11NM,
                  MSOAcode = MSOA11CD, MSOAname = MSOA11NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  LSOA_CCG <- read.csv(sourcefile["LSOA_CCG"])  %>%
    dplyr::rename(LSOAcode = LSOA11CD, CCGcode = CCG19CD, CCGname = CCG19NM,
                  STPcode = STP19CD, STP19name = STP19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  EW_UA <- read.csv(sourcefile["EW_UA"])  %>%
    dplyr::rename(EWcode = WD19CD, UAcode = UA19CD, UAname = UA19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  UA_HB <- read.csv(sourcefile["UA_HB"])  %>%
    dplyr::rename(UAcode = UA19CD, LHBcode = LHB19CD, LHBname = LHB19NM) %>%
    dplyr::select_if(grepl("name$|code$", colnames(.)))

  conversion.table <- OA_EW_LA %>%
    dplyr::left_join(.,OA_LSOA_MSOA_LA,by = "AREAcode") %>%
    dplyr::left_join(.,LSOA_CCG,by = "LSOAcode") %>%
    dplyr::left_join(.,EW_UA,by = "EWcode") %>%
    dplyr::left_join(.,UA_HB,by = "UAcode")

  conversion.table$AREAname <- conversion.table$AREAcode
  conversion.table = conversion.table %>% tibble::column_to_rownames("AREAcode")
  conversion.table[is.na(conversion.table)]=0
  SCRCdataAPI::create_table(h5filename = h5filename,
                            component = "conversiontable/englandwales",
                            df = conversion.table,
                            row_title = "outputareas",
                            row_names = rownames(conversion.table),
                            column_units = colnames(conversion.table))
}
