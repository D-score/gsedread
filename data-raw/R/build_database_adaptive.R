# Builds database with item responses for GSED Phase 1, adaptive design
#
# Assumed environmental variables, specified in .Renviron:
# - ONEDRIVE_GSED
#   Must point to 'CAVALLERA, Vanessa - GSED Validation 2021_phase I'
# - LOCAL_DUCKDB
#   Must point to a directory where the DuckDB database will be written
#
# Created: Stef van Buuren, June 24, 2025
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
path_adaptive <- file.path("GSED Phase 1 Final Analysis",
                           "GSED Final Collated Phase 1 Data Files 18_05_22")
output_adaptive <- file.path(Sys.getenv("LOCAL_DUCKDB"), "adaptive.duckdb")

# Read data
sf <- read_sf(onedrive = onedrive, path = path_adaptive, adm = "adaptive", warnings = FALSE)
lf <- read_lf(onedrive = onedrive, path = path_adaptive, adm = "adaptive", warnings = FALSE)

# Rename items into gsed2 lexicon
colnames(sf) <- rename_vector(colnames(sf), trim = "Ma_SF_")
colnames(lf) <- rename_vector(colnames(lf), trim = "Ma_LF_")
sf$item <- rename_vector(sf$item, "gsed", "gsed2", contains = "Ma_SF_")
lf$item <- rename_vector(lf$item, "gsed", "gsed2", contains = "Ma_LF_")

# Transformations for efficiency and clarity
sf <- sf |>
  rename(subjid = gsed_id) |>
  mutate(agedays = as.integer(dov - dob))
lf <- lf |>
  rename(subjid = gsed_id) |>
  mutate(agedays = as.integer(dov - dob))

# Remove duplicates and sort
sf <- sf |>
  dplyr::distinct(across(-file), .keep_all = TRUE) |>
  arrange(subjid, agedays, order)
lf <- lf |>
  dplyr::distinct(across(-file), .keep_all = TRUE) |>
  arrange(subjid, agedays, order)

# Extract item responses
sf_responses <- sf |>
  rename(response = scores) |>
  select(subjid, timestamp, agedays, p, order, item, response, d, sem)
lf_responses <- lf |>
  rename(response = scores) |>
  select(subjid, timestamp, agedays, p, order, item, response, d, sem)

# Extact visit tables
sf_visits <- sf |>
  select(all_of(c("file", "subjid", "parent_study_id", "dob", "dov",
                  "location", "ma_age_year", "agedays"))) |>
  dplyr::distinct(subjid, agedays, .keep_all = TRUE)
lf_visits <- lf |>
  select(all_of(c("file", "subjid", "parent_study_id", "dob", "dov",
                  "location", "ma_age_year", "agedays"))) |>
  dplyr::distinct(subjid, agedays, .keep_all = TRUE)

# Combine all responses
responses <- bind_rows(
  sf_responses,
  lf_responses)

# Combine all visits
visits <- bind_rows(
  sf_visits,
  lf_visits)

# Data edits

# EDIT 1 Remove item because it identifies abnormality (Melissa 22020807)
# cromoc001	gpamoc008 Clench fist
responses <- responses |>
  filter(!item == "gpamoc008")

# EDIT 2 Responses not relevant for older children, remove
# gtolgd002	13,22	B2. Smiles in response
# gtolgd003	 5,33 B3. Calms and quiets with caregivers
# gtolgd004	19,12	B4. Happy vocalizing or making sounds
# gtolgd006	24,62	B6. Laughs
# gtolgd007	23,47	B7. Vocalises when spoken to
# gtolgd008	35,25	B8. Repeats syllables

vars <- c("gtolgd002", "gtolgd003", "gtolgd004", "gtolgd006", "gtolgd007", "gtolgd008")
responses <- responses |>
  filter(!(agedays > 182 & item %in% vars))

# EDIT 3 Remove responses that are not 0 or 1
responses <- responses |>
  filter(response %in% c(0, 1))

#--- Write to DuckDB ---
message("Writing to DuckDB...")
if (file.remove(output_adaptive)) message("Removed database: ", output_adaptive)
con <- dbConnect(duckdb(), dbdir = output_adaptive, read_only = FALSE)

dbWriteTable(con, "responses", responses, overwrite = TRUE)
dbWriteTable(con, "visits", visits, overwrite = TRUE)

dbDisconnect(con)
message("Database written to: ", output_adaptive)

