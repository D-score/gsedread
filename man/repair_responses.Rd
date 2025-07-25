% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/repair_responses.R
\name{repair_responses}
\alias{repair_responses}
\title{Repair and standardize responses data}
\usage{
repair_responses(responses, mode_s = FALSE, quiet = FALSE)
}
\arguments{
\item{responses}{A data frame containing responses data with required columns.}

\item{mode_s}{Logical, if \code{TRUE}, assigns mode self-report to items of the SF
for the Netherlands.}

\item{quiet}{Logical, if \code{TRUE}, suppresses output messages.}
}
\value{
A data frame with repaired and standardized responses data.
}
\description{
This function repairs and standardizes \code{responses} data after being read by
\code{read_gsed_fixed()} to ensure that the \code{responses} data is in a consistent
format.
}
\details{
The function performs several operations:
\itemize{
\item Converts 1–2 digit country codes to 3-digit format
(e.g., \code{11-GSED-0123} → \code{011-GSED-0123}).
\item Converts \code{GSED-0123} to \code{528-GSED-0123}.
\item Standardizes specific country codes (e.g., \verb{011-} to \verb{050-},
\verb{017-} to \verb{586-}, \verb{020-} to \verb{834-}).
\item Deduplicates responses based on a unique identifier consisting of
\code{subjid}, \code{agedays}, \code{vist_type}, and \code{item}.
}

The function is to be run after \code{read_gsed_fixed()}

A unique response identifier consists of: \code{subjid}, \code{agedays}, \code{vist_type}, \code{item}
}
