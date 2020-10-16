# SCRCdata

[![test-build](https://github.com/ScottishCovidResponse/SCRCdata/workflows/build/badge.svg)](https://github.com/ScottishCovidResponse/SCRCdata/actions)
[![CodeFactor](https://www.codefactor.io/repository/github/scottishcovidresponse/scrcdata/badge)](https://www.codefactor.io/repository/github/scottishcovidresponse/scrcdata)
[![License: GPL-3.0](https://img.shields.io/badge/licence-GPL--3-yellow)](https://opensource.org/licenses/GPL-3.0)

This is a git repository to store data processing scripts for the SCRC data pipeline. Processing functions used to convert raw data (e.g. csv files) into data products (e.g. h5 files) are stored in the `R` directory. Submission scripts used upload metadata associated with each dataset (original source, raw data location, processing script location, and data product location) to the data registry are stored in `inst/scripts`. Templates that can used to generate more of these scripts are stored in `inst/templates`.edit

**Please read the [Wiki pages](https://github.com/ScottishCovidResponse/SCRCdata/wiki)
 (scroll back up, fifth tab from the left) for more information, including:**

* [Installation instructions](https://github.com/ScottishCovidResponse/SCRCdata/wiki)
* [Datasets](https://github.com/ScottishCovidResponse/SCRCdata/wiki/Datasets)
* [Submission scipt templates](https://github.com/ScottishCovidResponse/SCRCdata/wiki/Submission-script-templates)
* [Example workflow (how to upload metadata to the data registry)](https://github.com/ScottishCovidResponse/SCRCdata/wiki/Workflow)
* [Versioning and filenames](https://github.com/ScottishCovidResponse/SCRCdata/wiki/Versioning-and-filenames)
* [SCRCdataAPI::download_from_database() example](https://github.com/ScottishCovidResponse/SCRCdata/wiki/download_from_database()-example)
* [SCRCdataAPI::download_from_url() example](https://github.com/ScottishCovidResponse/SCRCdata/wiki/download_from_url()-example)
* [Useful links](https://github.com/ScottishCovidResponse/SCRCdata/wiki/Useful-links)

NEW!

* [HDF5 components](https://github.com/ScottishCovidResponse/SCRCdata/wiki/HDF5-components)
* [toml components](https://github.com/ScottishCovidResponse/SCRCdata/wiki/TOML-components)
