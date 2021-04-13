#' COVID-19 SARS-CoV-2 preprints from medRxiv and bioRxiv
#' https://connect.medrxiv.org/relate/content/181

library(dplyr)

version <- "0.1.0"
key <- readLines("token/token.txt")

# How many COVID-19 SARS-CoV-2 preprints are on medrXiv / bioarXiv?
tmp <- httr::GET("https://api.biorxiv.org/covid19/0") %>%
  httr::content(as = "text", encoding = "UTF-8") %>%
  jsonlite::fromJSON(simplifyVector = FALSE)
total <- tmp$messages[[1]]$total

# How many loops should we run through if we're downloading in batches of 30?
count <- tmp$messages[[1]]$count
loops <- ceiling(total / count)
index <- seq(31, loops*30, 30)
index <- c(0, index)

# Download metadata associated with COVID-19 SARS-CoV-2 preprints
# (this has to be done in batches of 30)
medrxiv <- list()
for (x in seq_along(index)) {
  out <- httr::GET(paste0("https://api.biorxiv.org/covid19/", index[x])) %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON(simplifyVector = FALSE)
  medrxiv <- c(medrxiv, out$collection)
}

# Reformat as dataframe
medrxiv <- lapply(seq_along(medrxiv), function(y) {
  # If the author has more than one name, put the family name first, followed
  # by a comma. Separate all author names by " and "
  authors <- lapply(medrxiv[[y]]$rel_authors, function(z) {
    if(grepl(" ", z$author_name)) {
      sort_names <- strsplit(z$author_name, " ")[[1]]
      out <- paste0(tail(sort_names, 1), ", ",
                    paste(head(sort_names, length(sort_names)-1),
                          collapse = " "))
    } else {
      out <- z$author_name
    }
    out
  }) %>%
    paste(collapse = " and ")

  # Output information required by the data registry
  data.frame(abbreviation = medrxiv[[y]]$rel_site,
             title = medrxiv[[y]]$rel_title,
             author = authors,
             abstract = medrxiv[[y]]$rel_abs,
             doi = medrxiv[[y]]$rel_doi,
             date = as.POSIXct(paste0(medrxiv[[y]]$rel_date, " 12:00:00"),
                               format = "%Y-%m-%d %H:%M:%S"),
             journal = medrxiv[[y]]$rel_site)
})
medrxiv <- do.call(rbind.data.frame, medrxiv)

# Check that all data has been collected. For some reason we're missing one,
# but N - 1 is pretty good!
assertthat::assert_that(total - 1 == nrow(medrxiv))

# These papers are already in the data registry:
existing_papers <- get_existing("external_object", limit_results = FALSE) %>%
  dplyr::select(doi_or_unique_name)

# Compare the downloaded list with those currenrly in the data registry.
# These papers haven't been uploaded yet:
ind <- which(paste0("doi://", medrxiv$doi) %in% unlist(existing_papers))

if(length(ind) > 0) {
  upload_these <- medrxiv[-ind,]
} else {
  upload_these <- medrxiv
}

# Upload metadata to the data registry

for(i in seq_len(nrow(upload_these))) {
  # for(i in 8127:nrow(upload_these)) {
  cat("\n", i, "of", nrow(upload_these))
  tmp <- upload_these[i,]

  upload_paper(title = tmp$title,
               authors = tmp$author,
               journal = tmp$journal,
               journal_abbreviation = tmp$abbreviation,
               journal_website = "https://www.medrxiv.org",
               release_date = tmp$date,
               abstract = tmp$abstract,
               keywords = NA,
               doi = tmp$doi,
               primary_not_supplement = TRUE,
               version = version,
               key = key)
}
