% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/process_pollution_lookup.R
\name{process_pollution_lookup}
\alias{process_pollution_lookup}
\title{process_pollution_lookup}
\usage{
process_pollution_lookup(
  sourcefile,
  h5filename,
  scotgov_lookup,
  ukgov_engwales_lookup,
  storage_path
)
}
\arguments{
\item{sourcefile}{a \code{string} specifying the local path and filename
associated with the source data (the input of this function)}

\item{h5filename}{a \code{string} specifying the filename
associated with the processed data (the output of this function)}

\item{scotgov_lookup}{a \code{string} specifying the local path and filename
associated with a lookup file of UK national grid codes and administrative 
geographies in scotland}

\item{ukgov_engwales_lookup}{a \code{string} specifying the local path and 
filename associated with a lookup file of UK national grid codes and 
administrative geographies in England and Wales}

\item{storage_path}{a \code{string} specifying the local path associated with 
the processed data (the output of this function)}
}
\description{
process_pollution_lookup
}
