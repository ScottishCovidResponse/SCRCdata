library(devtools)

# write GitHub PAT to .Renviron
tmp <- readLines("/home/soniamitchell/scrc_cron_scripts/token/GITHUB_CRON_PAT.txt")
Sys.setenv(GITHUB_PAT = tmp)

# SCRC token
tmp <- readLines("/home/soniamitchell/scrc_cron_scripts/token/token.txt")
Sys.setenv(SCRC_TOKEN = tmp)

# Download and install the new versions of SCRCdataAPI and SCRCdata
install_github("ScottishCovidResponse/SCRCdataAPI")
install_github("ScottishCovidResponse/SCRCdata")
library(SCRCdataAPI)
library(SCRCdata)


# Make a separate h5 file for each of these data sets
datasets <- c("carehomes", "hospital", "mortality",
              "nhsworkforce", "schools", "testing")

for(i in seq_along(datasets)) {
  # Find submission script
  filename <- paste0("cam_", datasets[i], ".R")
  submission_script <- system.file(file.path("SCRC", filename),
                                   package = "SCRCdata")

  # Run submission script
  source(submission_script)

  # # Get file names
  # path <- file.path("srv", "ftp", "scrc", "records", "SARS-CoV-2",
  #                   "scotland", "cases-and-management", datasets[i])
  # files <- dir(path, full.names = TRUE)
  #
  # # Move files
  # for(j in seq_along(files)) {
  #   file.copy(from = files[j], to = file.path("/", path))
  #   file.remove(path[j])
  # }
}
