library(SCRCdataAPI)

# Download shape file
download_from_url(
  source_root = "http://sedsh127.sedsh.gov.uk",
  source_path = "Atom_data/ScotGov/ZippedShapefiles/SG_DataZoneBdry_2011.zip",
  path = file.path("data-raw", "datazone_shapefile"),
  filename = "SG_DataZoneBdry_2011.zip",
  unzip = TRUE)

# Read in shape file and check for non-intersecting geometries
scot_datazone_sf <- sf::st_read(file.path("data-raw", "datazone_shapefile",
                                          "SG_DataZone_Bdry_2011.shp"),
                                quiet = TRUE) %>%
  sf::st_make_valid() %>%
  dplyr::rename(AREAcode = DataZone)

# Check that object is a shape file
assertthat::assert_that(all(class(scot_datazone_sf) == c("sf", "data.frame")))

# Convert attributes of geometry column to UTF-8 (to satisfy R CMD check)
tmp <- attributes(scot_datazone_sf$geometry)$crs$wkt
Encoding(tmp) <- "latin1"
levels(tmp) <- iconv(levels(tmp), "latin1", "UTF-8")
attributes(scot_datazone_sf$geometry)$crs$wkt <- tmp

# Add object to the SCRCdata package
usethis::use_data(scot_datazone_sf, overwrite = T)