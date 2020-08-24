#' process_scotgov_simd_income
#'
#' @param sourcefile a \code{string} specifying the local path and filename
#' associated with the source data (the input of this function)
#' @param filename a \code{string} specifying the local path and filename
#' associated with the processed data (the output of this function)
#'
#' @export
#'
process_scotgov_simd_income <- function(sourcefile, filename) {

  scotSIMDinc <- lapply(seq_along(sourcefile), function(i) {
    read.csv(file = sourcefile[i]) %>%
      dplyr::select(-X) %>%
      dplyr::mutate(featurecode = gsub(
        "<http://statistics.gov.scot/id/statistical-geography/", "",
        featurecode),
        featurecode = gsub(">", "", featurecode))
  }) %>% do.call(rbind.data.frame, .) %>%
    dplyr::select_if(~ length(unique(.)) != 1) %>%
    reshape2::dcast(featurecode ~ measuretype, value.var = "values") %>%
    tibble::column_to_rownames("featurecode")

  colnames(scotSIMDinc) <- tolower(colnames(scotSIMDinc))

  SCRCdataAPI::create_table(h5filename = filename,
                            component = "simd/income",
                            df = scotSIMDinc,
                            row_title = "datazones",
                            row_names = rownames(scotSIMDinc),
                            column_units = colnames(scotSIMDinc))
}
