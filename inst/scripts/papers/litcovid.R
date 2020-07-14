#' https://www.ncbi.nlm.nih.gov/research/coronavirus/#data-download
#'

library(dplyr)

path <- "https://www.ncbi.nlm.nih.gov/research/coronavirus-api/export/ris?"
download.file(path, "litcovid.ris")

dat <- revtools::read_bibliography("litcovid.ris")

lit_refs <- dat %>%
  dplyr::select(-type, -accession) %>%
  dplyr::mutate(link = NA)


write.csv(lit_refs, file.path("data-raw", "ncbi_papers.csv"), row.names = FALSE)