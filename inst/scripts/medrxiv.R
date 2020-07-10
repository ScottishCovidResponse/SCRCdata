#' COVID-19 SARS-CoV-2 preprints from medRxiv and bioRxiv
#' https://connect.medrxiv.org/relate/content/181
#' missing 1

library(dplyr)

dat <- rjson::fromJSON(file = file.path("https://connect.medrxiv.org",
                                        "relate",
                                        "collection_json.php?grp=181"))


medrxiv_refs <- lapply(dat$rels, function(x) {

  authors <- lapply(x$rel_authors, function(y) y$author_name) %>%
    unlist() %>% paste(collapse = " and ")

    data.frame(id = x$rel_doi,
             title = x$rel_title,
             journal = x$rel_site,
             author = authors,
             abstract = x$rel_abs,
             doi = x$rel_doi,
             keywords = NA,
             year = x$rel_date,
             link = x$rel_link)

}) %>% do.call(rbind.data.frame, .)

write.csv(medrxiv_refs, file.path("data-raw", "medrxiv_papers.csv"), row.names = FALSE)