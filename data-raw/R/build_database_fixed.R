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
# Last modified: June 30, 2025
#
# TODO:
# - Update as soon as China data is cleaned
# - Add Phase 2 BSID data
# - Add covariate data (e.g. child factors, antropometry)

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
require(stringr, quietly = TRUE, warn.conflicts = FALSE)

# Load dedicated package for reading GSED data
pkg <- "gsedread"
if (!requireNamespace(pkg, quietly = TRUE) && interactive()) {
  answer <- askYesNo(paste("Package", pkg, "needed. Install from GitHub?"))
  if (answer) remotes::install_github("d-score/gsedread")
}
require(gsedread, quietly = TRUE, warn.conflicts = FALSE)
if (packageVersion("gsedread") < "0.14.0") stop("Needs gsedread 0.14.0")

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

# Repair subjid number according to ISO 3166-1 numeric code
visits <- visits |>
  mutate(
    subjid = case_when(
      # Convert 1–2 digit country code to 3-digit (e.g., 11-GSED-0123 → 011-GSED-0123)
      str_detect(subjid, "^\\d{1,2}-GSED-") ~ {
        country <- str_extract(subjid, "^\\d{1,2}")
        suffix  <- str_extract(subjid, "(?<=-GSED-)\\d+")
        paste0(str_pad(country, 3, pad = "0"), "-GSED-", str_pad(suffix, 4, pad = "0"))
      },

      # Convert GSED-0123 → 528-GSED-0123
      str_detect(subjid, "^GSED-") ~ {
        suffix <- str_extract(subjid, "(?<=GSED-)\\d+")
        paste0("528-GSED-", str_pad(suffix, 4, pad = "0"))
      },

      # Already in correct format → leave unchanged
      TRUE ~ subjid
    )
  )
visits <- visits |>
  mutate(
    subjid = case_when(
      str_starts(subjid, "011-") ~ str_replace(subjid, "^011-", "050-"),
      str_starts(subjid, "017-") ~ str_replace(subjid, "^017-", "586-"),
      str_starts(subjid, "020-") ~ str_replace(subjid, "^020-", "834-"),
      TRUE ~ subjid
    )
  )
responses <- responses |>
  mutate(
    subjid = case_when(
      # Convert 1–2 digit country code to 3-digit (e.g., 11-GSED-0123 → 011-GSED-0123)
      str_detect(subjid, "^\\d{1,2}-GSED-") ~ {
        country <- str_extract(subjid, "^\\d{1,2}")
        suffix  <- str_extract(subjid, "(?<=-GSED-)\\d+")
        paste0(str_pad(country, 3, pad = "0"), "-GSED-", str_pad(suffix, 4, pad = "0"))
      },

      # Convert GSED-0123 → 528-GSED-0123
      str_detect(subjid, "^GSED-") ~ {
        suffix <- str_extract(subjid, "(?<=GSED-)\\d+")
        paste0("528-GSED-", str_pad(suffix, 4, pad = "0"))
      },

      # Already in correct format → leave unchanged
      TRUE ~ subjid
    )
  )
responses <- responses |>
  mutate(
    subjid = case_when(
      str_starts(subjid, "011-") ~ str_replace(subjid, "^011-", "050-"),
      str_starts(subjid, "017-") ~ str_replace(subjid, "^017-", "586-"),
      str_starts(subjid, "020-") ~ str_replace(subjid, "^020-", "834-"),
      TRUE ~ subjid
    )
  )

# Define GSED cohort, cohortn
visits <- visits |>
  mutate(
    isonum = as.integer(str_extract(subjid, "^\\d{3}")),
    ctry = case_when(
      isonum == 50L  ~ "BGD",
      isonum == 586L ~ "PAK",
      isonum == 834L ~ "TZA",
      isonum == 76L  ~ "BRA",
      isonum == 156L ~ "CHN",
      isonum == 384L ~ "CIV",
      isonum == 528L ~ "NLD",
      TRUE ~ NA_character_),
    cohort = paste0("GSED-", ctry),
    cohortn = case_when(
      isonum == 50L  ~ 111L,  # BGD
      isonum == 586L ~ 117L,  # PAK
      isonum == 834L ~ 120L,  # TZA
      isonum == 76L  ~ 125L,  # BRA
      isonum == 156L ~ 126L,  # CHN
      isonum == 384L ~ 127L,  # CIV
      isonum == 528L ~ 128L,  # NLD
      TRUE ~ NA_integer_)
  ) |>
  select(c("cohort", "cohortn", "subjid", "agedays", "vist_type", "phase",
           "date", "ins", "file", "parent_id", "worker_code", "location",
           "caregiver", "agedays_adj_premature", "ah01", "ah02", "ah03",
           "ah04", "ah05", "ah06", "ah07", "ah08", "m01", "m02", "m03",
           "d01", "d01_spcy", "d02", "d02_spcfy"))

# Remove duplicates
# Unique visit identifier: subjid, agedays, vist_type, ins
nvisits_before <- nrow(visits)
visits <- visits |>
  group_by(subjid, agedays, vist_type, ins) |>
  slice_head(n = 1L) |>
  ungroup() |>
  arrange(cohort, subjid, agedays, vist_type, ins)
cat("Number of visits before deduplication:", nvisits_before, "\n")
cat("Number of visits after  deduplication:", nrow(visits), "\n")

# Unique response identifier: subjid, agedays, vist_type, item
nresponses_before <- nrow(responses)
responses <- responses |>
  group_by(subjid, agedays, vist_type, item) |>
  slice_head(n = 1L) |>
  ungroup() |>
  arrange(subjid, agedays, vist_type)
cat("Number of responses before deduplication:", nresponses_before, "\n")
cat("Number of responses after  deduplication:", nrow(responses), "\n")

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
