#' Repair and standardize responses data
#'
#' This function repairs and standardizes `responses` data after being read by
#' `read_gsed_fixed()` to ensure that the `responses` data is in a consistent
#' format.
#'
#' @details
#' The function performs several operations:
#'
#' - Converts 1–2 digit country codes to 3-digit format
#'   (e.g., `11-GSED-0123` → `011-GSED-0123`).
#' - Converts `GSED-0123` to `528-GSED-0123`.
#' - Standardizes specific country codes (e.g., `011-` to `050-`,
#'   `017-` to `586-`, `020-` to `834-`).
#' - Deduplicates responses based on a unique identifier consisting of
#'   `subjid`, `agedays`, `vist_type`, and `item`.
#'
#' The function is to be run after `read_gsed_fixed()`
#'
#' A unique response identifier consists of: `subjid`, `agedays`, `vist_type`, `item`
#'
#' @param responses A data frame containing responses data with required columns.
#' @param mode_s Logical, if `TRUE`, assigns mode self-report to items of the SF
#' for the Netherlands.
#' @param quiet Logical, if `TRUE`, suppresses output messages.
#' @return A data frame with repaired and standardized responses data.
#' @export
repair_responses <- function(responses, mode_s = FALSE, quiet = FALSE) {

  # Check if required columns are present
  required_columns <- c("subjid", "agedays", "vist_type", "item", "response")
  missing_columns <- setdiff(required_columns, names(responses))
  if (length(missing_columns) > 0) {
    stop("The following required columns are missing from the responses data: ",
         paste(missing_columns, collapse = ", "))
  }

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

  # Assign mode self-report to items of the SF measured in NLD
  if (mode_s) {
    responses <- responses |>
      mutate(
        item = case_when(
          str_starts(subjid, "528") & str_starts(item, "sf_") ~
            str_c(str_sub(item, 1, 5), "s", str_sub(item, 7)),
          TRUE ~ item
        )
      )
  }

  # Unique response identifier: subjid, agedays, vist_type, item
  nresponses_before <- nrow(responses)
  responses <- responses |>
    group_by(subjid, agedays, vist_type, item) |>
    slice_head(n = 1L) |>
    ungroup() |>
    arrange(subjid, agedays, vist_type)
  if (!quiet) {
    cat("Number of responses before deduplication:", nresponses_before, "\n")
    cat("Number of responses after  deduplication:", nrow(responses), "\n")
  }

  return(responses)
}
