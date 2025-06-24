read_gsed_fixed <- function(onedrive, path, phase) {

  # Read data
  sf <- read_sf(onedrive = onedrive, path = path, adm = "fixed", warnings = TRUE)
  lf <- read_lf(onedrive = onedrive, path = path, adm = "fixed", warnings = TRUE)
  if (phase == 1) {
    bsid <- read_bsid(onedrive = onedrive, path = path, warnings = TRUE)
  }

  # Rename items into gsed2 lexicon
  lexin <- ifelse(phase == 1, "original", "original_phase2")
  colnames(sf) <- rename_vector(colnames(sf), lexin = lexin, trim = "Ma_SF_",
                                force_subjid_agedays = TRUE)
  colnames(lf) <- rename_vector(colnames(lf), lexin = lexin, trim = "Ma_LF_",
                                force_subjid_agedays = TRUE)
  if (phase == 1) {
  colnames(bsid) <- rename_vector(colnames(bsid), lexin = lexin,
                                  contains = "bsid_", force_subjid_agedays = TRUE)
  }

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

  if (phase == 1) {
  bsid <- bsid |>
    mutate(agedays = as.integer(agedays),
           ins = "bsid")
  }

  # Remove duplicates and sort
  sf <- sf |>
    distinct(across(-file), .keep_all = TRUE) |>
    arrange(subjid, agedays, vist_type)
  lf <- lf |>
    distinct(across(-file), .keep_all = TRUE) |>
    arrange(subjid, agedays, vist_type)

  if (phase == 1) {
  bsid <- bsid |>
    distinct(across(-file), .keep_all = TRUE)  |>
    arrange(subjid, agedays)
  }

  if (phase == 2) {
    bsid_responses <- NULL
    bsid_visits <- NULL
  }

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
  if (phase == 1) {
  bsid_responses <- bsid |>
    pivot_longer(
      cols = starts_with("by3"),
      names_to = "item",
      values_to = "response",
      values_drop_na = TRUE
    ) |>
    select(subjid, agedays, item, response)
  }

  # Extact visit tables
  sf_visits <- sf |>
    select(-starts_with("gpa"))
  lf_visits <- lf |>
    select(-starts_with("gto"))

  if (phase == 1) {
  bsid_visits <- bsid |>
    select(-starts_with("by3"))
  }

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

  # EDIT 3 Remove responses that are not 0 or 1
  responses <- responses |>
    filter(response %in% c(0, 1))

  return(list(responses = responses, visits = visits))
}
