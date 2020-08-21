# https://github.com/JabRef/abbrv.jabref.org/tree/master/journals
# https://www.library.caltech.edu/journal-title-abbreviations

# usethis::use_data_raw()

files <- c("acs.csv", "ams.csv", "annee-philologique.csv", "dainst.csv",
           "entrez.csv", "general.csv", "geology_physics.csv",
           "geology_physics_variations.csv", "ieee.csv", "ieee_strings.csv",
           "lifescience.csv", "mathematics.csv", "mechanical.csv",
           "medicus.csv", "meteorology.csv", "sociology.csv",
           "webofscience-dots.csv", "webofscience.csv")

journal_names <- lapply(seq_along(files), function(i) {
  path <- paste0(file.path("https://raw.githubusercontent.com", "JabRef",
                           "abbrv.jabref.org", "master", "journals",
                           "journal_abbreviations_"), files[i])
  download.file(path, file.path("data-raw", files[i]))
  tmp <- read.csv(file.path("data-raw", files[i]), sep = ";")
  names(tmp)[1:2] <- c("journal_name", "abbreviation")

  # i == 14 has an additional two empty columns
  # i == 17 has html character encoding
  # tmp %>% dplyr::filter(grepl("&[a-z]+;", journal_name))

  output <- tmp %>%
    dplyr::na_if("") %>%
    dplyr::na_if(".") %>%
    dplyr::na_if("d&gt") %>%
    dplyr::select_if(~ !(all(is.na(.)))) %>%
    dplyr::mutate(journal_name = gsub("&lt;", "<", journal_name),
                  journal_name = gsub("&gt;", ">", journal_name),
                  journal_name = gsub("<d>", "", journal_name),
                  journal_name = gsub(" $", "", journal_name)) %>%
    dplyr::mutate(abbreviation = gsub(" &lt", "", abbreviation),
                  abbreviation = gsub("&lt$", "", abbreviation)) %>%
    dplyr::mutate(journal_name = dplyr::case_when(
      journal_name == "After The Dark Ages: When Galaxies Were Young (the Universe At 2<z<5)" ~ "After The Dark Ages: When Galaxies Were Young (the Universe At 2)",
      journal_name == "Workshop On Observing Giant Cosmic Ray Air Showers From >10(20) Ev Particles From Space" ~ "Workshop On Observing Giant Cosmic Ray Air Showers From >10 20 Ev Particles From Space",
      T ~ journal_name)) %>%
    dplyr::mutate(abbreviation = dplyr::case_when(
      journal_name == "Advances in Atomic Molecular and Optical Physics" ~
        "Adv. Atom. Mol. Opt. Phy.",
      journal_name == "Reviews of Environmental Contamination and Toxicology" ~
        "Rev. Environ. Contam. T.",
      T ~ abbreviation))
}) %>% do.call(rbind.data.frame, .)


usethis::use_data(journal_names, overwrite = T)




