library(devtools)

# write GitHub PAT to .Renviron
tmp <- readLines(file.path("", "home", "soniamitchell", "scrc_cron_scripts",
                           "token", "GITHUB_CRON_PAT.txt"))
Sys.setenv(GITHUB_PAT = tmp)

# Download and install the new versions of SCRCdataAPI and SCRCdata
install_github("ScottishCovidResponse/SCRCdataAPI")
install_github("ScottishCovidResponse/SCRCdata")
library(SCRCdataAPI)
library(SCRCdata)

# Find submission script
submission_script <- system.file(file.path("SCRC", "cases_and_management.R"),
                                 package = "SCRCdata")

# Run submission script
source(submission_script)

