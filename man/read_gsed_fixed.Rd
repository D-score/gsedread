% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_gsed_fixed.R
\name{read_gsed_fixed}
\alias{read_gsed_fixed}
\title{Read the GSED data for SF, LF and BSID (fixed form)}
\usage{
read_gsed_fixed(onedrive, path, phase, lexout = "gsed4", hard_edits = TRUE)
}
\arguments{
\item{onedrive}{The OneDrive path where the data is stored.}

\item{path}{The path to the GSED fixed administration data.}

\item{phase}{Either 1 or 2, indicating the phase of the GSED data to read.
It is important to specify this correctly as it accounts for the different
item orders between phase 1 and phase 2 for SF and LF.}

\item{lexout}{The lexicon to use for renaming columns. Default is \code{"gsed3"}.
See \code{rename_vector()} for available lexicons.}

\item{hard_edits}{Logical, if \code{TRUE}, applies hard edits to the data.}
}
\value{
A list containing two data frames: \code{responses} and \code{visits}.
}
\description{
This function reads the GSED fixed administration data from the specified
OneDrive path. It processes the data to extract item responses and visit
information, renaming columns according to the GSED2 lexicon. The function
also applies specific data edits to ensure the integrity of the dataset.
}
\details{
\strong{Requirements:}
\itemize{
\item You must have access to the OneDrive path where the GSED data is stored.
\item The \code{gsedread} package must be installed.
\item The system variable \code{ONEDRIVE_GSED} must be set correctly.
}

\strong{Note:} The file names of the source data are hard-coded within this function.
}
\examples{
onedrive <- Sys.getenv("ONEDRIVE_GSED")
path <- file.path(
  "GSED Phase 1 Final Analysis",
  "GSED Final Collated Phase 1 Data Files 18_05_22")
phase1 <- read_gsed_fixed(onedrive, path, phase = 1)
}
