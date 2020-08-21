#' https://www.ncbi.nlm.nih.gov/research/coronavirus/#data-download
#'

library(dplyr)


version <- "1.0.0"
key <- readLines("token/token.txt")



# Download *.ris file and convert to dataframe
path <- "https://www.ncbi.nlm.nih.gov/research/coronavirus-api/export/ris?"
download.file(path, "data-raw/litcovid.ris")

dat <- revtools::read_bibliography("litcovid.ris") %>%
  dplyr::rename(abbreviation = journal)


# Download file to convert journal titles to abbreviations
download.file(file.path("ftp://ftp.ncbi.nih.gov", "pubmed", "J_Medline.txt"),
              "conversion_table.txt")
pubmed_journals <- readLines("conversion_table.txt")


# Generate conversion table
conversion_table <- lapply(seq_len(length(pubmed_journals)/8),
                           function(i) {
                             tmp <- pubmed_journals[(1+((i-1)*8)):(i*8)]
                             journal <- gsub("JournalTitle: ", "", tmp[3])
                             abbreviation <- gsub("MedAbbr: ", "", tmp[4])
                             data.frame(journal = journal,
                                        abbreviation = abbreviation)
                           }) %>% do.call(rbind.data.frame, .) %>%
  dplyr::filter(abbreviation != "") %>%
  unique()

# Remove square brackets (the data registry doesn't like them)
conversion_table <- conversion_table %>%
  dplyr::mutate(journal = gsub("\\[", "", journal),
                journal = gsub("\\]", "", journal))


# Some abbreviations in conversion_table represent multiple journal titles
# Remove these from the conversion_table
ind <- which(duplicated(conversion_table$abbreviation) |
               duplicated(conversion_table$abbreviation, fromLast = T))
problem_abbreviations <- sort(unique(conversion_table$abbreviation[ind]))
conversion_table <- conversion_table %>%
  filter(!abbreviation %in% problem_abbreviations)


# Merge ris file data with conversion table
merge_dat <- merge(dat, conversion_table, all.x = TRUE)
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










