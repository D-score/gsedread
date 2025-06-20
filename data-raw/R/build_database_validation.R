# Builds database with item responses for GSED Phase 1 and 2 validation data
#
# Assumed environmental variables:
# - ONEDRIVE_GSED_PHASE1
#   Example: 'localpath/GSED Phase 1 Final Analysis'. This will read data from
#   its subdirectory "GSED Final Collated Phase 1 Data Files 18_05_22"
# - ONEDRIVE_GSED_PHASE2
#   Not yet implemented
#
# Created: Stef van Buuren, June 20, 2025
# Last modified: June 20, 2025

if (nchar(Sys.getenv("ONEDRIVE_GSED_PHASE1")) == 0L) {
  stop("Environmental variable ONEDRIVE_GSED_PHASE1 not set.", call. = FALSE)
}
if (nchar(Sys.getenv("ONEDRIVE_GSED_PHASE2")) == 0L) {
  stop("Environmental variable ONEDRIVE_GSED_PHASE2 not set.", call. = FALSE)
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
input_phase1 <- Sys.getenv("ONEDRIVE_GSED_PHASE1")
output_db <- file.path(Sys.getenv("DUCKPATH_GSED"), "validation.duckdb")

# Read data
sf <- read_sf(onedrive = input_phase1, adm = "fixed", warnings = TRUE)
lf <- read_lf(onedrive = input_phase1, adm = "fixed", warnings = TRUE)
bsid <- read_bsid(onedrive = input_phase1, warnings = TRUE)

# Rename items into gsed2 lexicon
colnames(sf) <- rename_vector(colnames(sf),
                              trim = "Ma_SF_",
                              force_subjid_agedays = TRUE)
colnames(lf) <- rename_vector(colnames(lf),
                              trim = "Ma_LF_",
                              force_subjid_agedays = TRUE)
colnames(bsid) <- rename_vector(colnames(bsid),
                                contains = "bsid_",
                                force_subjid_agedays = TRUE)

# vist_type
# 1=Part/visit 1;
# 2=Part/visit 2;
# 3=Combined Parts 1 and 2;
# 4=Face-to-face visit;
# 5=Inter-rater;
# 6=Test- Retest reliability;
# 7=Concurrent validity;
# 8=6-month Predictive validity
# 12=Rescheduled visit;

# Type transformations for efficiency and clarity
sf <- sf |>
  mutate(agedays = as.integer(agedays),
         vist_type = as.integer(vist_type),
         ins = "sf")
lf <- lf |>
  mutate(agedays = as.integer(agedays),
         vist_type = as.integer(vist_type),
         ins = "lf")
bsid <- bsid |>
  mutate(agedays = as.integer(agedays),
         ins = "bsid")

# Remove duplicates and sort
sf <- sf |>
  distinct(across(-file), .keep_all = TRUE) |>
  arrange(subjid, agedays, vist_type)
lf <- lf |>
  distinct(across(-file), .keep_all = TRUE) |>
  arrange(subjid, agedays, vist_type)
bsid <- bsid |>
  distinct(across(-file), .keep_all = TRUE)  |>
  arrange(subjid, agedays)

# Extract item responses
sf_responses <- sf |>
  pivot_longer(
    cols = starts_with("gpa"),
    names_to = "item",
    values_to = "response",
    values_drop_na = TRUE
  ) |>
  select(subjid, agedays, vist_type, item, response)
lf_responses <- lf |>
  pivot_longer(
    cols = starts_with("gto"),
    names_to = "item",
    values_to = "response",
    values_drop_na = TRUE
  ) |>
  select(subjid, agedays, vist_type, item, response)
bsid_responses <- bsid |>
  pivot_longer(
    cols = starts_with("by3"),
    names_to = "item",
    values_to = "response",
    values_drop_na = TRUE
  ) |>
  select(subjid, agedays, item, response)

# Extact visit tables
sf_visits <- sf |>
  select(-starts_with("gpa"))
lf_visits <- lf |>
  select(-starts_with("gto"))
bsid_visits <- bsid |>
  select(-starts_with("by3"))

# Combine all responses
responses <- bind_rows(
  sf_responses,
  lf_responses,
  bsid_responses)

# Combine all visits
visits <- bind_rows(
  sf_visits,
  lf_visits,
  bsid_visits)

# Hard data edits

# EDIT 1 Remove item because it identifies abnormality (Melissa 22020807)
#
# cromoc001	gpamoc008 Clench fist
responses <- responses |>
  filter(!item == "gpamoc008")

# EDIT 2 Remove responses not relevant for older children
#
# gtolgd002	13,22	B2. Smiles in response
# gtolgd003	 5,33 B3. Calms and quiets with caregivers
# gtolgd004	19,12	B4. Happy vocalizing or making sounds
# gtolgd006	24,62	B6. Laughs
# gtolgd007	23,47	B7. Vocalises when spoken to
# gtolgd008	35,25	B8. Repeats syllables

vars <- c("gtolgd002", "gtolgd003", "gtolgd004", "gtolgd006",
          "gtolgd007", "gtolgd008")
responses <- responses |>
  filter(!(agedays > 182 & item %in% vars))

#--- Write to DuckDB ---
message("Writing to DuckDB...")
if (file.remove(output_db)) message("Removed database: ", output_db)
con <- dbConnect(duckdb(), dbdir = output_db, read_only = FALSE)

dbWriteTable(con, "responses", responses, overwrite = TRUE)
dbWriteTable(con, "visits", visits,  overwrite = TRUE)

dbDisconnect(con)
message("Database written to: ", output_db)
