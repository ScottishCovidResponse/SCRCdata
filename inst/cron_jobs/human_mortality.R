library(devtools)

# Download and install the new versions of SCRCdataAPI and SCRCdata
install_github("ScottishCovidResponse/SCRCdataAPI")
install_github("ScottishCovidResponse/SCRCdata")
library(SCRCdataAPI)
library(SCRCdata)

# Find submission script
submission_script <- system.file("SCRC/scotgov_deaths.R",
                                 package = "SCRCdata")

# Run submission script
source(submission_script)
