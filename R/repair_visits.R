#' Repair and standardize visit data
#'
#' This function repairs and standardizes `visit` data after being read by
#' `read_gsed_fixed()` to ensure that the `visit` data is in a consistent
#' format.
#'
#' @details
#' The function performs several operations:
#'
#' - Ensuring required columns are present
#' - Repairing `subjid` according to ISO 3166-1 numeric code
#' - Defining GSED cohort and cohort number
#' - Removing duplicate visits based on unique identifiers
#' - Sorting the data by `cohort`, `subjid`, `agedays`, `vist_type`, and `ins`
#'
#' The function is to be run after `read_gsed_fixed()`
#'
#' A unique visit identifier consists of: `subjid`, `agedays`, `vist_type`, `ins`
#'
#' @param visits A data frame containing visit data with required columns.
#' @param quiet Logical, if `TRUE`, suppresses output messages.
#' @return A data frame with repaired and standardized visit data.
#' @export
repair_visits <- function(visits, quiet = FALSE) {

  # Check if required columns are present
  required_columns <- c("subjid", "agedays", "vist_type", "ins", "phase",
                        "date", "file", "parent_id", "worker_code", "location",
                        "caregiver", "agedays_adj_premature", "ah01", "ah02",
                        "ah03", "ah04", "ah05", "ah06", "ah07", "ah08",
                        "m01", "m02", "m03", "d01", "d01_spcy", "d02",
                        "d02_spcfy")
  missing_columns <- setdiff(required_columns, names(visits))
  if (length(missing_columns) > 0) {
    stop(paste("Missing required columns:", paste(missing_columns, collapse = ", ")))
  }

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
    select(all_of(c("cohort", "cohortn", required_columns)))

  # Remove duplicates
  # Unique visit identifier: subjid, agedays, vist_type, ins
  nvisits_before <- nrow(visits)
  visits <- visits |>
    group_by(subjid, agedays, vist_type, ins) |>
    slice_head(n = 1L) |>
    ungroup() |>
    arrange(cohort, subjid, agedays, vist_type, ins)
  if (!quiet) {
    cat("Number of visits before deduplication:", nvisits_before, "\n")
    cat("Number of visits after  deduplication:", nrow(visits), "\n")
  }

  return(visits)
}
