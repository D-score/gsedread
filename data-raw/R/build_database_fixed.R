# Builds database with item responses for GSED Phase 1 and 2 validation data
# Fixed administration only
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
if (packageVersion("gsedread") < "0.12.0") stop("Needs gsedread 0.12.0")

# Set paths and filenames
onedrive <- Sys.getenv("ONEDRIVE_GSED")
path_phase1 <- file.path("GSED Phase 1 Final Analysis",
                         "GSED Final Collated Phase 1 Data Files 18_05_22")
path_phase2 <- "GSED Final Collated Phase 2 Files 02_06_25/Temp Clean LF_ SF_ to add once China data is cleaned" # temporary
output_fixed <- file.path(Sys.getenv("LOCAL_DUCKDB"), "fixed.duckdb")

# Read Phase 1 data
phase1 <- gsedread:::read_gsed_fixed(onedrive = onedrive,
                                     path = path_phase1,
                                     phase = 1)

# Read Phase 2 data
phase2 <- gsedread:::read_gsed_fixed(onedrive = onedrive,
                                     path = path_phase2,
                                     phase = 2)

# Combine Phase 1 and Phase 2 data
responses <- bind_rows(phase1$responses, phase2$responses)
visits <- bind_rows(
  phase1$visits |> mutate(phase = 1L),
  phase2$visits |> mutate(phase = 2L)) |>
  select(subjid, agedays, vist_type, phase, date, ins, adm,
         file, parent_id, worker_code, location, caregiver,
         agedays_adj_premature, everything())

#--- Write to DuckDB ---
message("Writing to DuckDB...")
if (file.exists(output_fixed)) {
  message("Removing existing database: ", output_fixed)
  file.remove(output_fixed)
}
con <- dbConnect(duckdb(), dbdir = output_fixed, read_only = FALSE)

dbWriteTable(con, "responses", responses, overwrite = TRUE)
dbWriteTable(con, "visits", visits,  overwrite = TRUE)

dbDisconnect(con)
message("Database written to: ", output_fixed)
