#' Read the GSED data for SF, LF and BSID (fixed form)
#'
#' This function reads the GSED fixed administration data from the specified
#' OneDrive path. It processes the data to extract item responses and visit
#' information, renaming columns according to the GSED2 lexicon. The function
#' also applies specific data edits to ensure the integrity of the dataset.
#'
#' @md
#'
#' @details
#' **Requirements:**
#'
#' - You must have access to the OneDrive path where the GSED data is stored.
#' - The `gsedread` package must be installed.
#' - The system variable `ONEDRIVE_GSED` must be set correctly.
#'
#' **Note:** The file names of the source data are hard-coded within this function.
#'
#' @param onedrive The OneDrive path where the data is stored.
#' @param path The path to the GSED fixed administration data.
#' @param phase Either 1 or 2, indicating the phase of the GSED data to read.
#' It is important to specify this correctly as it accounts for the different
#' item orders between phase 1 and phase 2 for SF and LF.
#' @param lexout The lexicon to use for renaming columns. Default is `"gsed3"`.
#' See `rename_vector()` for available lexicons.
#' @param hard_edits Logical, if `TRUE`, applies hard edits to the data.
#' @return A list containing two data frames: `responses` and `visits`.
#' @examples
#' onedrive <- Sys.getenv("ONEDRIVE_GSED")
#' path <- file.path(
#'   "GSED Phase 1 Final Analysis",
#'   "GSED Final Collated Phase 1 Data Files 18_05_22")
#' phase1 <- read_gsed_fixed(onedrive, path, phase = 1)
#' @export
read_gsed_fixed <- function(onedrive, path, phase,
                            lexout = "gsed4", hard_edits = TRUE) {

  # Read data
  sf <- read_sf(onedrive = onedrive, path = path, adm = "fixed", warnings = TRUE)
  lf <- read_lf(onedrive = onedrive, path = path, adm = "fixed", warnings = TRUE)
  bsid <- read_bsid(onedrive = onedrive, path = path, warnings = TRUE)

  # Rename items into gsed2 lexicon
  lexin <- switch(as.character(phase),
                  "1" = "phase1",
                  "2" = "phase2",
                  stop("Invalid phase. Use 1 or 2.")
  )
  colnames(sf) <- rename_vector(colnames(sf), lexin = lexin, lexout = lexout,
                                trim = "Ma_SF_", force_subjid_agedays = TRUE)
  colnames(lf) <- rename_vector(colnames(lf), lexin = lexin, lexout = lexout,
                                trim = "Ma_LF_", force_subjid_agedays = TRUE)
  colnames(bsid) <- rename_vector(colnames(bsid), lexin = lexin, lexout = lexout,
                                  contains = "bsid_", force_subjid_agedays = TRUE)

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
    mutate(agedays = as.integer(.data$agedays),
           vist_type = as.integer(.data$vist_type),
           ins = "sf")
  lf <- lf |>
    mutate(agedays = as.integer(.data$agedays),
           vist_type = as.integer(.data$vist_type),
           ins = "lf")
  bsid <- bsid |>
    mutate(agedays = as.integer(.data$agedays),
           ins = "bsid")

  # Remove duplicates and sort
  sf <- sf |>
    distinct(across(-file), .keep_all = TRUE) |>
    arrange(.data$subjid, .data$agedays, .data$vist_type)
  lf <- lf |>
    distinct(across(-file), .keep_all = TRUE) |>
    arrange(.data$subjid, .data$agedays, .data$vist_type)
  bsid <- bsid |>
    distinct(across(-file), .keep_all = TRUE)  |>
    arrange(.data$subjid, .data$agedays)

  # Extract item responses
  sf_responses <- sf |>
    pivot_longer(
      cols = starts_with("sf"),
      names_to = "item",
      values_to = "response",
      values_drop_na = TRUE
    ) |>
    select(.data$subjid, .data$agedays, .data$vist_type, .data$item, .data$response)
  lf_responses <- lf |>
    pivot_longer(
      cols = starts_with("lf"),
      names_to = "item",
      values_to = "response",
      values_drop_na = TRUE
    ) |>
    select(.data$subjid, .data$agedays, .data$vist_type, .data$item, .data$response)
  bsid_responses <- bsid |>
    pivot_longer(
      cols = starts_with("by3"),
      names_to = "item",
      values_to = "response",
      values_drop_na = TRUE
    ) |>
    select(.data$subjid, .data$agedays, .data$item, .data$response)

  # Extact visit tables
  sf_visits <- sf |>
    select(-starts_with("sf"))
  lf_visits <- lf |>
    select(-starts_with("lf"))
  bsid_visits <- bsid |>
    select(-starts_with("bsid"), -starts_with("by3"))

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

  # Remove responses that are not 0 or 1
  responses <- responses |>
    filter(.data$response %in% c(0, 1))

  # Return if no hard edits are required
  if (!hard_edits) {
    return(list(responses = responses, visits = visits))
  }

  # Hard data edits

  # EDIT 1 Remove item because it identifies abnormality (Melissa 22020807)
  #
  # cromoc001	gpamoc008 Clench fist
  responses <- responses |>
  #  filter(!.data$item == "gpamoc008")
  #  filter(!.data$item == "gs1moc028")
  filter(!.data$item == "sf_moc028")

  # EDIT 2 Remove responses not relevant for children > 6,12,9,18 mo
  #
  # gtolgd001	 1, 2	B1. Reacts when spoken to
  # gtolgd002	13,22	B2. Smiles in response
  # gtolgd003	 5,33 B3. Calms and quiets with caregivers
  # gtolgd004	19,12	B4. Happy vocalizing or making sounds
  #
  # gtolgd006	24,62	B6. Laughs
  # gtolgd007	23,47	B7. Vocalises when spoken to
  #
  # gtolgd008	35,25	B8. Repeats syllables
  # gtofmd009 trunc at 12 mo Pulls string to get object
  #
  # gtolgd012 trunc at 18 mo Uses gestures to communicate

  # vars <- c("gtolgd001", "gtolgd002", "gtolgd003", "gtolgd004")
  # vars <- c("gl1lgd002", "gl1lgd003", "gl1lgd005", "gl1lgd001")
  vars <- c("lfblgd002", "lfblgd003", "lfblgd005", "lfblgd001")
  responses <- responses |>
    filter(!(.data$agedays > 182 & .data$item %in% vars))
  # vars <- c("gtolgd006", "gtolgd007")
  # vars <- c("gl1lgd004", "gl1lgd006")
  vars <- c("lfblgd004", "lfblgd006")
  responses <- responses |>
    filter(!(.data$agedays > 274 & .data$item %in% vars))
  # vars <- c("gtolgd008", "gtofmd009")
  # vars <- c("gl1lgd009", "gl1fmd010")
  vars <- c("lfblgd009", "lfcfmd010")
  responses <- responses |>
    filter(!(.data$agedays > 365 & .data$item %in% vars))
  # vars <- c("gtolgd012")
  # vars <- c("gl1lgd010")
  vars <- c("lfblgd010")
  responses <- responses |>
    filter(!(.data$agedays > 548 & .data$item %in% vars))

  return(list(responses = responses, visits = visits))
}
