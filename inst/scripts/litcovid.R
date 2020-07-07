#' https://www.ncbi.nlm.nih.gov/research/coronavirus/#data-download
#'

path <- "https://www.ncbi.nlm.nih.gov/research/coronavirus-api/export/ris?"
download.file(path, "litcovid.ris")

dat <- revtools::read_bibliography("litcovid.ris")

lit_refs <- dat %>%
  dplyr::select(-type, -accession) %>%
  dplyr::mutate(link = NA)


