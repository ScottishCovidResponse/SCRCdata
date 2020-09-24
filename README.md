# SCRCdata

[![test-build](https://github.com/ScottishCovidResponse/SCRCdata/workflows/build/badge.svg)](https://github.com/ScottishCovidResponse/SCRCdata/actions)
[![CodeFactor](https://www.codefactor.io/repository/github/scottishcovidresponse/scrcdata/badge)](https://www.codefactor.io/repository/github/scottishcovidresponse/scrcdata)
[![License: GPL-3.0](https://img.shields.io/badge/licence-GPL--3-yellow)](https://opensource.org/licenses/GPL-3.0)

This is a git repository to store data processing scripts for the SCRC data pipeline. Processing functions used to convert raw data (e.g. csv files) into data products (e.g. h5 files) are stored in the `R` directory. Submission scripts used upload metadata associated with each dataset (original source, raw data location, processing script location, and data product location) to the data registry are stored in `inst/scripts`. Templates that can used to generate more of these scripts are stored in `inst/templates`.

For more information, please go to https://scottishcovidresponse.github.io/
