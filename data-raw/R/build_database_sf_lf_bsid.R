# Builds database with item responses for GSED Phase 1 and 2 validation data
#
# Assumed environmental variables, specified in .Renviron:
# - ONEDRIVE_GSED
#   Must point to 'CAVALLERA, Vanessa - GSED Validation 2021_phase I'
# - LOCAL_DUCKDB
#   Must point to a directory where the DuckDB database will be written
#
# Created: Stef van Buuren, June 20, 2025
# Last modified: June 24, 2025

if (nchar(Sys.getenv("ONEDRIVE_GSED")) == 0L) {
  stop("Environmental variable ONEDRIVE_GSED not set.", call. = FALSE)
}
if (nchar(Sys.getenv("LOCAL_DUCKDB")) == 0L) {
  stop("Environmental variable LOCAL_DUCKDB not set.", call. = FALSE)
}

# Load required CRAN packages
require(duckdb, quietly = TRUE, warn.conflicts = FALSE)
require(dplyr, quietly = TRUE, warn.conflicts = FALSE)
require(tidyr, quietly = TRUE, warn.conflicts = FALSE)

# Load dedicated package for reading GSED data
pkg <- "gsedread"
if (!requireNamespace(pkg, quietly = TRUE) && interactive()) {
  answer <- askYesNo(paste("Package", pkg, "needed. Install from GitHub?"))
  if (answer) remotes::install_github("d-score/gsedread")
}
require(gsedread, quietly = TRUE, warn.conflicts = FALSE)
if (packageVersion("gsedread") < "0.10.0") stop("Needs gsedread 0.10.0")

# Set paths and filenames
onedrive <- Sys.getenv("ONEDRIVE_GSED")
path_phase1 <- file.path("GSED Phase 1 Final Analysis",
                         "GSED Final Collated Phase 1 Data Files 18_05_22")
# temporary
path_phase2 <- "GSED Final Collated Phase 2 Files 02_06_25/Temp Clean LF_ SF_ to add once China data is cleaned"
output_phase1 <- file.path(Sys.getenv("LOCAL_DUCKDB"), "phase1.duckdb")
output_phase2 <- file.path(Sys.getenv("LOCAL_DUCKDB"), "phase2.duckdb")
output_db <- file.path(Sys.getenv("LOCAL_DUCKDB"), "validation.duckdb")

# Create DuckDB database for Phase 1
gsedread:::store_as_database(onedrive = onedrive,
                             path = path_phase1,
                             output_db = output_phase1,
                              phase = 1)

# Create DuckDB database for Phase 2
gsedread:::store_as_database(onedrive = onedrive,
                             path = path_phase2,
                             output_db = output_phase2,
                             phase = 2)

