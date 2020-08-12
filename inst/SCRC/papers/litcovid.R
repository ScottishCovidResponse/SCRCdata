#' https://www.ncbi.nlm.nih.gov/research/coronavirus/#data-download
#'

library(dplyr)


version <- "1.0.0"
key <- readLines("token.txt")



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
ind <- which(is.na(merge_dat$doi))
merge_dat <- merge_dat[-ind,]
assertthat::assert_that(!all(is.na(merge_dat$doi)))


# Remove entries with duplicated dois
ind <- which(duplicated(merge_dat$doi) | duplicated(merge_dat$doi, fromLast = TRUE))
merge_dat <- merge_dat[-ind,]
assertthat::assert_that(!all(duplicated(merge_dat$doi)))


# Remove entries with no journal title
ind <- which(is.na(merge_dat$title))
merge_dat <- merge_dat[-ind,]
assertthat::assert_that(!all(is.na(merge_dat$title)))


# Remove entries with no author
ind <- which(is.na(merge_dat$author))
merge_dat <- merge_dat[-ind,]
assertthat::assert_that(!all(is.na(merge_dat$author)))


# Remove entries with no title
ind <- which(is.na(merge_dat$title))
merge_dat <- merge_dat[-ind,]
assertthat::assert_that(!all(is.na(merge_dat$title)))


# Remove entries with no journal name
ind <- which(is.na(merge_dat$journal))
merge_dat <- merge_dat[-ind,]
assertthat::assert_that(!all(is.na(merge_dat$title)))


# Remove entries with no journal abbreviation
assertthat::assert_that(!all(is.na(merge_dat$abbreviation)))



unique(merge_dat$year)
assertthat::assert_that(all(nchar(merge_dat$year) == 4))


#' skipped due to null author family name: 914, 1250, 1891, 3386, 3416, 3471,
#' 3841, 3842, 4601, 5124, 5873, 7021, 7507, 7592, 8395, 8461, 8827, 8907, 9101,
#' 9993, 10514, 10958, 11298, 11301, 11303, 11304, 11318, 11345, 11349, 11355,
#' 11357, 11361, 11366, 11367, 11369, 11370, 11373, 11378, 12293, 13432, 13546,
#' 14009, 14312, 14422, 14526, 14697, 14745, 15077, 16523, 16848, 17047, 17065,
#' 17981, 18656, 18918, 19297, 19616, 20492, 22330, 22335, 22346, 22353, 22354,
#' 22381, 22401, 22416, 22418, 22435, 22438, 22488, 22513, 22520, 22521, 22522,
#' 22533, 22554, 22582, 22583, 22592, 22593, 22636, 22650, 22654, 22682, 22702,
#' 22749, 22766, 22770, 22771, 22773, 22774, 22803, 22862, 22906, 22927, 22956,
#' 22958, 22967, 22970, 22978, 23010, 23037, 23044, 23048, 23074, 23101, 23105,
#' 23141, 23174, 23196, 23200, 23281, 24164, 24253, 24261, 24263, 24264, 24268,
#' 24269, 24271, 24275, 24278, 24495, 26574, 26941, 26959, 27679, 27740, 28317,
#' 29189, 29212, 29237, 29263, 29799, 29923, 29936, 29943, 29952, 30443, 30671,
#' 30969, 30973, 30977, 31018, 31419, 31649
#'
#' skipped due to weird Curl error: 966
#'
#' doi error: 21974, 27108
#'
#' skipped due to 400 error, invalid characters: 3203:3206, 5615, 7478,
#' 13871:13877, 13927:13931, 13933:13947, 13950, 13952:13959, 13962, 14950,
#' 19117, 19118, 26399, 26610:26617, 29812, 29813, 31612:31620, 31678:31685,
#' 31687, 31704:31738
#'
#' json error: 12487, 12499,
#'
#' misc error: 12508, 12510, 12623, 12684, 12730, 15240, 17670, 19137, 20190,
#' 20550, 21330, 23490, 23813, 25464, 25544, 26309, 26321, 26358, 26359, 26361,
#' 26364, 26373, 26377, 26378, 26379, 28720, 28820, 29740, 30690, 30692, 30697
#'
#'

# for(i in seq_len(nrow(merge_dat))) {
for(i in 14746:14762) {
  tmp <- merge_dat[i,]

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










