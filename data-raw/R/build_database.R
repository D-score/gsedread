# Assumed environmental variables:
# - ONEDRIVE_GSED_PHASE1
# - ONEDRIVE_GSED_PHASE2
if (nchar(Sys.getenv("ONEDRIVE_GSED_PHASE1")) == 0L) {
  stop("Environmental variable ONEDRIVE_GSED_PHASE1 not set.", call. = FALSE)
}
if (nchar(Sys.getenv("ONEDRIVE_GSED_PHASE2")) == 0L) {
  warning("Environmental variable ONEDRIVE_GSED_PHASE2 not set.")
}

# Load required packages
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
# if (packageVersion("gsedread") < "0.10.0") stop("Needs gsedread 0.10.0")

# Set paths and filenames
phase1 <- Sys.getenv("ONEDRIVE_GSED_PHASE1")
phase2 <- Sys.getenv("ONEDRIVE_GSED_PHASE2")
output_db <- "duckdb/gsed.duckdb"

# Read data
sf_f1 <- read_sf(onedrive = phase1, adm = "fixed") |>
  mutate(adm = "fixed")
lf_f1 <- read_lf(onedrive = phase1, adm = "fixed")
bsid1 <- read_bsid(onedrive = phase1)
sf_a1 <- read_sf(onedrive = phase1, adm = "adaptive")
lf_a1 <- read_lf(onedrive = phase1, adm = "adaptive")

# Rename items into gsed2 lexicon
colnames(sf_f1) <- rename_vector(colnames(sf_f1), trim = "Ma_SF_")
colnames(lf_f1) <- rename_vector(colnames(lf_f1), trim = "Ma_LF_")
colnames(sf_a1) <- rename_vector(colnames(sf_a1), trim = "Ma_SF_")
colnames(lf_a1) <- rename_vector(colnames(lf_a1), trim = "Ma_LF_")
sf_a1$item <- rename_vector(sf_a1$item, "gsed", "gsed2", contains = "Ma_SF_")
lf_a1$item <- rename_vector(lf_a1$item, "gsed", "gsed2", contains = "Ma_LF_")
colnames(bsid1) <- rename_vector(colnames(bsid1), contains = "bsid_")

# Type transformations for efficiency and clarity
sf_f1 <- sf_f1 |>
  mutate(age = as.integer(age),
         vist_type = as.integer(vist_type)) |>
  rename(agedays = age)
lf_f1 <- lf_f1 |>
  mutate(age = as.integer(age),
         vist_type = as.integer(vist_type)) |>
  rename(agedays = age)
bsid1 <- bsid1 |>
  mutate(age = as.integer(age)) |>
  rename(agedays = age)
sf_a1 <- sf_a1 |>
  mutate(agedays = as.integer(dov - dob))
lf_a1 <- lf_a1 |>
  mutate(agedays = as.integer(dov - dob))

# Remove duplicates and sort
sf_f1 <- sf_f1 |>
  distinct(gsed_id, agedays, vist_type, .keep_all = TRUE) |>
  arrange(gsed_id, agedays, vist_type)
lf_f1 <- lf_f1 |>
  distinct(gsed_id, agedays, vist_type, .keep_all = TRUE)  |>
  arrange(gsed_id, agedays, vist_type)
bsid1 <- bsid1 |>
  distinct(gsed_id, agedays, .keep_all = TRUE)  |>
  arrange(gsed_id, agedays)
sf_a1 <- sf_a1 |>
  dplyr::distinct(gsed_id, agedays, order, .keep_all = TRUE) |>
  arrange(gsed_id, agedays, order)
lf_a1 <- lf_a1 |>
  dplyr::distinct(gsed_id, agedays, order, .keep_all = TRUE) |>
  arrange(gsed_id, agedays, order)

# Extract item responses
sf_f1_responses <- sf_f1 |>
  pivot_longer(
    cols = starts_with("gpa"),
    names_to = "item",
    values_to = "response",
    values_drop_na = TRUE
  ) |>
  select(gsed_id, vist_type, agedays, item, response)
lf_f1_responses <- lf_f1 |>
  pivot_longer(
    cols = starts_with("gto"),
    names_to = "item",
    values_to = "response",
    values_drop_na = TRUE
  ) |>
  select(gsed_id, agedays, vist_type, item, response)
bsid1_responses <- bsid1 |>
  pivot_longer(
    cols = starts_with("by3"),
    names_to = "item",
    values_to = "response",
    values_drop_na = TRUE
  ) |>
  select(gsed_id, agedays, item, response)
sf_a1_responses <- sf_a1 |>
  rename(response = scores) |>
  select(gsed_id, timestamp, agedays, p, order, item, response, d, sem)
lf_a1_responses <- lf_a1 |>
  rename(response = scores) |>
  select(gsed_id, timestamp, agedays, p, order, item, response, d, sem)

# Extact visit tables
sf_f1_visits <- sf_f1 |>
  select(-starts_with("gpa"))
lf_f1_visits <- lf_f1 |>
  select(-starts_with("gto"))
bsid1_visits <- bsid1 |>
  select(-starts_with("by3"))
sf_a1_visits <- sf_a1 |>
  select(all_of(c("file", "gsed_id", "parent_study_id", "dob", "dov",
                  "location", "ma_age_year", "agedays"))) |>
  dplyr::distinct(gsed_id, agedays, .keep_all = TRUE)
lf_a1_visits <- lf_a1 |>
  select(all_of(c("file", "gsed_id", "parent_study_id", "dob", "dov",
                  "location", "ma_age_year", "agedays"))) |>
  dplyr::distinct(gsed_id, agedays, .keep_all = TRUE)

# Combine all responses
responses_fixed <- bind_rows(
  sf_f1_responses,
  lf_f1_responses,
  bsid1_responses)
responses_adaptive <- bind_rows(
  sf_a1_responses,
  lf_a1_responses)

# Combine all visits
visits_fixed <- bind_rows(
  sf_f1_visits,
  lf_f1_visits,
  bsid1_visits)
visits_adaptive <- bind_rows(
  sf_a1_visits,
  lf_a1_visits)

# Data edits

# EDIT 1 Remove item because it identifies abnormality (Melissa 22020807)
# cromoc001	gpamoc008 Clench fist
responses_fixed <- responses_fixed |>
  filter(!item == "gpamoc008")
responses_adaptive <- responses_adaptive |>
  filter(!item == "gpamoc008")

# EDIT 2 Responses not relevant for older children, remove
# gtolgd002	13,22	B2. Smiles in response
# gtolgd003	 5,33 B3. Calms and quiets with caregivers
# gtolgd004	19,12	B4. Happy vocalizing or making sounds
# gtolgd006	24,62	B6. Laughs
# gtolgd007	23,47	B7. Vocalises when spoken to
# gtolgd008	35,25	B8. Repeats syllables

vars <- c("gtolgd002", "gtolgd003", "gtolgd004", "gtolgd006", "gtolgd007", "gtolgd008")
responses_fixed <- responses_fixed |>
  filter(!(agedays > 182 & item %in% vars))
responses_adaptive <- responses_adaptive |>
  filter(!(agedays > 182 & item %in% vars))

#--- Write to DuckDB ---
message("Writing to DuckDB...")
con <- dbConnect(duckdb(), dbdir = output_db, read_only = FALSE)

dbWriteTable(con, "responses_fixed", responses_fixed, overwrite = TRUE)
dbWriteTable(con, "responses_adaptive", responses_adaptive, overwrite = TRUE)
dbWriteTable(con, "visits_fixed", visits_fixed,  overwrite = TRUE)
dbWriteTable(con, "visits_adaptive", visits_adaptive, overwrite = TRUE)

dbDisconnect(con)
message("Database written to: ", output_db)

