#' https://arxiv.org/covid19search
#' missing 11
#'

library(dplyr)

dat <- aRxiv::arxiv_search(query = 'terms AND title="COVID-19" OR abstract="SARS-CoV-2" OR abstract="COVID-19" OR title="SARS-CoV-2" OR title="coronavirus" OR abstract="coronavirus"', limit = 15000)

if(dat == 15000) stop("Limit reached. Please check code.")

arxiv_refs <- dat %>%
  dplyr::select(id = id,
                title = title,
                journal = journal_ref,
                author = authors,
                abstract = abstract,
                doi = link_doi,
                year = submitted,
                link = link_pdf) %>%
  dplyr::mutate(keywords = NA) %>%
  dplyr::select(id, title, journal, author, abstract, doi,
                keywords, everything())


write.csv(arxiv_refs, file.path("data-raw", "arxiv_papers.csv"), row.names = FALSE)