#' The Scottish Index of Multiple Deprivation (SIMD) provides a relative
#' ranking of the data zones in Scotland from 1 (most deprived) to 6,976
#' (least deprived) based on a weighted combination of data in the domains
#' of Income; Employment; Health; Education, Skills and Training; Geographic
#' Access to Services; Crime; and Housing. (From: https://statistics.gov.scot/resource?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fscottish-index-of-multiple-deprivation)
#' Only income has been included in this dataset.
#'

library(SCRCdata)
library(SCRCdataAPI)
library(SPARQL)

# Download source data
# Rank
query <- "PREFIX qb: <http://purl.org/linked-data/cube#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX data: <http://statistics.gov.scot/data/>
PREFIX sdmxd: <http://purl.org/linked-data/sdmx/2009/dimension#>
PREFIX dim: <http://statistics.gov.scot/def/dimension/>
PREFIX dom: <http://statistics.gov.scot/def/concept/simd-domain/>
PREFIX ref: <http://reference.data.gov.uk/id/year/>
PREFIX stat: <http://statistics.data.gov.uk/def/statistical-entity#>
PREFIX mp: <http://statistics.gov.scot/def/measure-properties/>
SELECT ?featurecode ?featurename ?areatypename ?date ?measuretype ?values
WHERE {
  ?indicator qb:dataSet data:scottish-index-of-multiple-deprivation;
              mp:rank ?values;
              qb:measureType ?measure;
              dim:simdDomain dom:income;
              sdmxd:refArea ?featurecode;
              sdmxd:refPeriod ?period.

              ?featurecode stat:code ?areatype;
                rdfs:label ?featurename.
              ?areatype rdfs:label ?areatypename.
              ?period rdfs:label ?date.
              ?measure rdfs:label ?measuretype.
}"

fn <- "scottish-index-of-multiple-deprivation-income-rank.csv"
download_from_db(url = "https://statistics.gov.scot/sparql",
                 path = query,
                 local = "data-raw",
                 filename = fn)

# Quintile
query <- "PREFIX qb: <http://purl.org/linked-data/cube#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX data: <http://statistics.gov.scot/data/>
PREFIX sdmxd: <http://purl.org/linked-data/sdmx/2009/dimension#>
PREFIX dim: <http://statistics.gov.scot/def/dimension/>
PREFIX dom: <http://statistics.gov.scot/def/concept/simd-domain/>
PREFIX ref: <http://reference.data.gov.uk/id/year/>
PREFIX stat: <http://statistics.data.gov.uk/def/statistical-entity#>
PREFIX mp: <http://statistics.gov.scot/def/measure-properties/>
SELECT ?featurecode ?featurename ?areatypename ?date ?measuretype ?values
WHERE {
  ?indicator qb:dataSet data:scottish-index-of-multiple-deprivation;
              mp:quintile ?values;
              qb:measureType ?measure;
              dim:simdDomain dom:income;
              sdmxd:refArea ?featurecode;
              sdmxd:refPeriod ?period.

              ?featurecode stat:code ?areatype;
                rdfs:label ?featurename.
              ?areatype rdfs:label ?areatypename.
              ?period rdfs:label ?date.
              ?measure rdfs:label ?measuretype.

}"

fn <- "scottish-index-of-multiple-deprivation-income-quintile.csv"
download_from_db(url = "https://statistics.gov.scot/sparql",
                 path = query,
                 local = "data-raw",
                 filename = fn)

# Decile
query <- "PREFIX qb: <http://purl.org/linked-data/cube#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX data: <http://statistics.gov.scot/data/>
PREFIX sdmxd: <http://purl.org/linked-data/sdmx/2009/dimension#>
PREFIX dim: <http://statistics.gov.scot/def/dimension/>
PREFIX dom: <http://statistics.gov.scot/def/concept/simd-domain/>
PREFIX ref: <http://reference.data.gov.uk/id/year/>
PREFIX stat: <http://statistics.data.gov.uk/def/statistical-entity#>
PREFIX mp: <http://statistics.gov.scot/def/measure-properties/>
SELECT ?featurecode ?featurename ?areatypename ?date ?measuretype ?values
WHERE {
  ?indicator qb:dataSet data:scottish-index-of-multiple-deprivation;
              mp:decile ?values;
              qb:measureType ?measure;
              dim:simdDomain dom:income;
              sdmxd:refArea ?featurecode;
              sdmxd:refPeriod ?period.

              ?featurecode stat:code ?areatype;
                rdfs:label ?featurename.
              ?areatype rdfs:label ?areatypename.
              ?period rdfs:label ?date.
              ?measure rdfs:label ?measuretype.
}"

fn <- "scottish-index-of-multiple-deprivation-income-decile.csv"
download_from_db(url = "https://statistics.gov.scot/sparql",
                 path = query,
                 local = "data-raw",
                 filename = fn)

# Vigintile
query <- "PREFIX qb: <http://purl.org/linked-data/cube#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX data: <http://statistics.gov.scot/data/>
PREFIX sdmxd: <http://purl.org/linked-data/sdmx/2009/dimension#>
PREFIX dim: <http://statistics.gov.scot/def/dimension/>
PREFIX dom: <http://statistics.gov.scot/def/concept/simd-domain/>
PREFIX ref: <http://reference.data.gov.uk/id/year/>
PREFIX stat: <http://statistics.data.gov.uk/def/statistical-entity#>
PREFIX mp: <http://statistics.gov.scot/def/measure-properties/>
SELECT ?featurecode ?featurename ?areatypename ?date ?measuretype ?values
WHERE {
  ?indicator qb:dataSet data:scottish-index-of-multiple-deprivation;
              mp:vigintile ?values;
              qb:measureType ?measure;
              dim:simdDomain dom:income;
              sdmxd:refArea ?featurecode;
              sdmxd:refPeriod ?period.

              ?featurecode stat:code ?areatype;
                rdfs:label ?featurename.
              ?areatype rdfs:label ?areatypename.
              ?period rdfs:label ?date.
              ?measure rdfs:label ?measuretype.
}"

fn <- "scottish-index-of-multiple-deprivation-income-vigintile.csv"
download_from_db(url = "https://statistics.gov.scot/sparql",
                 path = query,
                 local = "data-raw",
                 filename = fn)


# Process data and generate hdf5 file
sourcefile <- c(file.path(
  "data-raw", "scottish-index-of-multiple-deprivation-income-rank.csv"),
  file.path(
    "data-raw", "scottish-index-of-multiple-deprivation-income-quintile.csv"),
  file.path(
    "data-raw", "scottish-index-of-multiple-deprivation-income-vigintile.csv"),
  file.path(
    "data-raw", "scottish-index-of-multiple-deprivation-income-decile.csv"))

h5filename <- "scottish-index-of-multiple-deprivation-income.h5"
process_scotgov_simd_income(sourcefile = sourcefile,
                            h5filename = h5filename)

openssl::sha256(file(h5filename))
