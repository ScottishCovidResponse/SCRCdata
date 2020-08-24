#' https://www.ncbi.nlm.nih.gov/research/coronavirus/#data-download
#'

library(dplyr)
data("journal_names", package = "SCRCdata")

version <- "1.0.0"
key <- readLines("token/token.txt")


# Download *.ris file and convert to dataframe
path <- "https://www.ncbi.nlm.nih.gov/research/coronavirus-api/export/ris?"
download.file(path, "data-raw/litcovid.ris")

dat <- revtools::read_bibliography("data-raw/litcovid.ris") %>%
  dplyr::rename(abbreviation = journal)

# Merge ris file data with conversion table
merge_dat <- merge(dat, journal_names, all.x = TRUE)
assertthat::assert_that(nrow(merge_dat) == nrow(dat))


# Remove entries which don't have dois
if(any(is.na(merge_dat$doi))) {
  ind <- which(is.na(merge_dat$doi))
  merge_dat <- merge_dat[-ind,]
}
assertthat::assert_that(!all(is.na(merge_dat$doi)))


# Remove entries with duplicated dois
if(any(duplicated(merge_dat$doi))) {
  ind <- which(duplicated(merge_dat$doi) |
                 duplicated(merge_dat$doi, fromLast = TRUE))
  merge_dat <- merge_dat[-ind,]
}
assertthat::assert_that(!all(duplicated(merge_dat$doi)))


# Remove entries with no author
if(any(is.na(merge_dat$author))) {
  ind <- which(is.na(merge_dat$author))
  merge_dat <- merge_dat[-ind,]
}
assertthat::assert_that(!all(is.na(merge_dat$author)))


# Remove entries with no title
if(any(is.na(merge_dat$title))) {
  ind <- which(is.na(merge_dat$title))
  merge_dat <- merge_dat[-ind,]
}
assertthat::assert_that(!all(is.na(merge_dat$title)))


# Remove entries with no journal name
if(any(is.na(merge_dat$journal))) {
  ind <- which(is.na(merge_dat$journal))
  merge_dat <- merge_dat[-ind,]
}
assertthat::assert_that(!all(is.na(merge_dat$title)))


# Remove entries with no journal abbreviation
assertthat::assert_that(!all(is.na(merge_dat$abbreviation)))

# Remove entries with years that aren't 4 characters long
assertthat::assert_that(all(nchar(merge_dat$year) == 4))

# Remove entries with titles longer than 1024 characters
if(any(nchar(merge_dat$title) > 1024)) {
  ind <- which(nchar(merge_dat$title) > 1024)
  merge_dat <- merge_dat[-ind,]
}


# Remove entries with author field == ", and ,"
if(any(merge_dat$author == ", and ,")) {
  ind <- which(merge_dat$author == ", and ,")
  merge_dat <- merge_dat[-ind,]
}

# Remove entries with no year
if(is.na(merge_dat$year)) {
  ind <- which(is.na(merge_dat$year))
  merge_dat <- merge_dat[-ind,]
}
assertthat::assert_that(!all(is.na(merge_dat$year)))


# These papers are already in the data registry
existing_papers <- get_existing("external_object", limit_results = FALSE) %>%
  dplyr::select(doi_or_unique_name)

# These papers haven't been uploaded yet ----------------------------------
ind <- which(paste0("doi://", merge_dat$doi) %in% unlist(existing_papers))
upload_these <- merge_dat[-ind,]



for(i in seq_len(nrow(upload_these))) {
  cat("\n", i, "of", nrow(upload_these))
  tmp <- upload_these[i,]

  upload_paper(title = tmp$title,
               authors = tmp$author,
               journal = tmp$journal,
               journal_abbreviation = tmp$abbreviation,
               journal_website = "",
               release_date = as.POSIXct(paste0(tmp$year, "-01-01 12:00:00"),
                                         format = "%Y-%m-%d %H:%M:%S"),
               abstract = tmp$abstract,
               keywords = tmp$keywords,
               doi = tmp$doi,
               primary_not_supplement = TRUE,
               version = version,
               key = key)
}