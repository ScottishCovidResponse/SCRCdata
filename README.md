# SCRCdata

This is a git repository to store data processing scripts for the SCRC data pipeline. Processing functions used to convert raw data (e.g. csv files) into data products (e.g. h5 files) are stored in the `R` directory. Scripts used submit metadata associated with each dataset (original source, raw data location, processing script location, and data product location) to the data respository are stored in `inst/scripts`. Templates that can used to generate more of these scripts are stored in `inst/templates`.

* [Installation](#installation)
* [Templates](#templates)
* [Datasets](#datasets)

**For more examples and useful information, please look at the Wiki (scroll back up, fifth tab from the left).**


## Installation

This package is dependent on the SCRCdataAPI package being installed:

```{r}
library(devtools)
install_github("ScottishCovidResponse/SCRCdataAPI")
```

To install the package itself and load it into R:

```{r}
install_github("ScottishCovidResponse/SCRCdata")
library(SCRCdata)
```


## Templates

The following templates are available in the `inst/templates` directory. These templates are used to upload metadata to the data registry. Depending on what you have, you need to use a different template.

| Template                  | What do you have?                                                                            | 
| ---                       | ---                                                                                          |
| upload_parameter          | A toml file (\*1), but no original source and no processing file                             |
| upload_data_product       | An h5 file (\*2), but no original source (\*3), no raw data (\*4), and no processing file    |
| upload_dataset            | An original source, a raw data file, a processing script, and a data product                 |

\*1 point-estimate or distribution  
\*2 array or table  
\*3 e.g. website  
\*4 e.g. csv file  


