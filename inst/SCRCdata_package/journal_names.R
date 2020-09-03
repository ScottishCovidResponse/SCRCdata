# Download file to convert journal titles to abbreviations
download.file("ftp://ftp.ncbi.nih.gov/pubmed/J_Medline.txt",
              "conversion_table.txt")
pubmed_journals <- readLines("conversion_table.txt")
file.remove("conversion_table.txt")

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


# Convert journal column to UTF-8 (to satisfy R CMD check)
tmp <- conversion_table
Encoding(tmp$journal) <- "latin1"
levels(tmp$journal) <- iconv(
  levels(tmp$journal),
  "latin1",
  "UTF-8"
)

# Convert abbreviation column to UTF-8 (to satisfy R CMD check)
Encoding(tmp$abbreviation) <- "latin1"
levels(tmp$abbreviation) <- iconv(
  levels(tmp$abbreviation),
  "latin1",
  "UTF-8"
)

assertthat::assert_that(all(tmp$journal == conversion_table$journal))
assertthat::assert_that(all(tmp$abbreviation == conversion_table$abbreviation))

journal_names <- tmp
usethis::use_data(journal_names, overwrite = T)
