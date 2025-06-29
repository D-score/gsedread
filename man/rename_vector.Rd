% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rename_vector.R
\name{rename_vector}
\alias{rename_vector}
\title{Rename character vector}
\usage{
rename_vector(
  input,
  lexin = c("original", "original_phase2", "sequential", "gsed", "gsed2"),
  lexout = c("gsed2", "original", "original_phase2", "sequential", "gsed"),
  notfound = "copy",
  contains = c("", "Ma_SF_", "Ma_LF_", "bsid_"),
  underscore = TRUE,
  trim = "Ma_",
  lowercase = TRUE,
  force_subjid_agedays = FALSE
)
}
\arguments{
\item{input}{A character vector with names to be translated}

\item{lexin}{A string indicating the input lexicon. One of "original",
"original_phase2", "sequential", "gsed" or "gsed2". Default is "original".}

\item{lexout}{A string indicating the output lexicon. One of "original",
"original_phase2", "sequential", "gsed" or "gsed2". Default is "gsed2".}

\item{notfound}{A string indicating what to do some input value is not found}

\item{contains}{A string to filter the translation table prior to matching.
Needed to prevent double matches. The default ("") does not filter.}

\item{underscore}{Replaces space (" ") and dash ("-") by underscore ("_")}

\item{trim}{A substring to be removed from `input`. Defaults to "Ma_".}

\item{lowercase}{Sets all variables in lower case.
in `lexin`? The default `notfound = "copy"` copies the input values into the
output value. In other cases (e.g. `""` or `NA_character_`), the function
uses the string specified in `notfound` as a replacement value.}

\item{force_subjid_agedays}{If `TRUE`, forces the output to have `"subjid"`
and `"agedays"` as names for the `"ID"` and `"age"`, respectively.}
}
\value{
A character vector of the same length as `input` with processed
names.
}
\description{
Translates names between different lexicons (naming schema).
}
\examples{
input <- c("file", "GSED_ID", "Ma_SF_Parent ID", "Ma_SF_C01", "Ma_SF_C02")
rename_vector(input)
rename_vector(input, lexout = "sequential", lowercase = FALSE)
rename_vector(input, lexout = "gsed", trim = "Ma_SF_")

# SF/LF phase 2 names to default names
input <- c("file", "GSED_ID", "Ma_SF_Parent ID", paste0("Ma_SF_C00", 1:9))
rename_vector(input, lexin = "original_phase2", lowercase = TRUE)
}
