library(devtools)

tmp <- readLines("/home/soniamitchell/scrc_cron_scripts/token/GITHUB_CRON_PAT.txt.txt")
Sys.setenv(GITHUB_PAT = tmp)

# Download and install the new versions of SCRCdataAPI and SCRCdata
install_github("ScottishCovidResponse/SCRCdataAPI")
install_github("ScottishCovidResponse/SCRCdata")
library(SCRCdataAPI)
library(SCRCdata)

# Find submission script
submission_script <- system.file(file.path("SCRC", "scotgov_deaths.R"),
                                 package = "SCRCdata")

# Run submission script
source(submission_script)

# # Get file names
# path <- file.path("srv", "ftp", "scrc", "records", "SARS-CoV-2",
#                   "scotland", "human-mortality")
# files <- dir(path, full.names = TRUE)
#
# # Move files
# for(i in seq_along(files)) {
#   file.copy(from = files[i], to = file.path("/", path))
#   file.remove(path[i])
# }
