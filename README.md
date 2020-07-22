# SCRCdata

Processing scripts for the SCRC data pipeline

* [Installation](#installation)
* [Templates](#templates)
* [Datasets](#datasets)



## Installation

This package is dependent on the SCRCdataAPI package being installed:

```{r}
library(devtools)
install_github("ScottishCovidResponse/SCRCdataAPI")
```

To install the package itself:

```{r}
install_github("ScottishCovidResponse/SCRCdata")
```

and load it into R:

```{r}
library(SCRCdata)
```


## Templates

The following templates are available in the `inst/templates` directory. These templates are used to upload metadata to the data repository. Depending on what you have, you need to use a different template.

| Template                  | What do you have?                                                                            | 
| ---                       | ---                                                                                          |
| upload_parameter          | A toml file (\*1), but no original source and no processing file                             |
| upload_data_product       | An h5 file (\*2), but no original source (\*3), no raw data (\*4), and no processing file    |
| upload_dataset            | An original source, a raw data file, a processing script, and a data product                 |

\*1 point-estimate or distribution  
\*2 array or table  
\*3 e.g. website  
\*4 e.g. csv file  


## Datasets

The following datasets are available in the `inst/scripts` directory.

| Dataset                   | Description                                    | Uploaded |
| ---                       | ---                                            | |
| nrs_demographics          | Small area population estimates (2018) by age, sex, data zone (2011), and council area (2018) | |
| ors_demographics          |                                                | |
| scotgov_deaths            | Number of deaths (weekly) associated with Covid-19 and the total number of deaths registered in Scotland, broken down by age and sex | ✔︎ |
| scotgov_dz_lookup         | Geography lookup tables used for aggregation, from data zones (2011) to higher level geographies | |
| scotgov_management        | Management Information, collected and distributed each day in order to support understanding of the progress of the outbreak in Scotland | ✔︎ |
| scotgov_simd_income       | The Scottish Index of Multiple Deprivation (2020; income) | |
| scotgov_ur_classification | Urban Rural Classification                     | |
| ukgov_eng_lookup          |                                                | |
| ukgov_eng_oa_shapefile    |                                                | |
| ukgov_scot_dz_shapefile   | Data zone boundaries 2011                      | |
