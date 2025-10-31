#' Read data from Bayley Scales of Infant Development III
#'
#' @inheritParams read_lf
#' @return A tibble with the original data and two column names: `file`
#' (containing the original file name) and `adm` (fixed or adaptive).
#' @examples
#' onedrive <- Sys.getenv("ONEDRIVE_GSED")
#' 
#' @export
read_bsid <- function(
  onedrive = Sys.getenv("ONEDRIVE_GSED"),
  path = NULL,
  verbose = FALSE,
  progress = FALSE,
  warnings = FALSE
) {
  if (nchar(onedrive) == 0L) {
    stop("Environmental variable ONEDRIVE_GSED not set.", call. = FALSE)
  }
  if (is.null(path)) {
    stop("Argument `path` not set", call. = FALSE)
  }

  # hardcode files names
  files_fixed <- c(
    "tan/tza-bsid-iii-2021-11-07.csv",
    "pak/pak_bsid-iii_2022_05_17.csv",
    "ban/ban-bsid-iii-2022-05-17.csv",
    "BRA/br-bsid-2025-07-04.csv",
    "CIV/cdi-bsid-2025-07-04.csv",
    # "Griffiths.xlsx",
    "NLD/nl-bsid-2025-10-31.csv"
  )

  # read
  files <- file.path(onedrive, path, files_fixed)
  date_formats <- c(
    "%d-%m-%Y",
    "%d/%m/%Y",
    "%Y-%m-%d",
    "%Y-%m-%d", # bra
    "%Y-%m-%d", # cdi as.Date(45019, origin = "1899-12-30")
    "%Y-%m-%d"
  ) # nl
  types <- c("tan", "pak", "ban", "bra", "cdi", "nld")
  data <- read_files(
    "bsid",
    types,
    files,
    1:length(files),
    date_formats,
    NULL,
    verbose,
    progress,
    warnings
  )

  # post-process to consistent names

  if (!is.null(data[[1]])) {
    data[[1]] <- data[[1]] |>
      rename(
        Study_Country = .data$st_country___bsid,
        date_of_visit = .data$screen_id_bsid,
        Parent_study_ID = .data$screen_no__bsid
      )
  }
  if (!is.null(data[[2]])) {
    data[[2]] <- data[[2]] |>
      rename(
        ra_code_bsid = .data$Researcher_Code,
        date_of_visit = .data$DATE_OF_VISIT,
        visit_age_bsid = .data$Age_at_assessment
      )
  }
  if (!is.null(data[[3]])) {
    data[[3]] <- data[[3]] |>
      rename(
        Study_Country = .data$st_country___bsid,
        Parent_study_ID = .data$screen_no__bsid
      )
    nm3 <- names(data[[3]])
    nm3[8:339] <- tolower(nm3[8:339])
    nm3[8:16] <- paste0("bsid_cog0", 1:9)
    nm3[99:107] <- paste0("bsid_rc0", 1:9)
    nm3[148:156] <- paste0("bsid_ec0", 1:9)
    nm3[196:204] <- paste0("bsid_fm0", 1:9)
    nm3[262:270] <- paste0("bsid_gsm0", 1:9)
    names(data[[3]]) <- nm3
  }

  # bind
  # remove orphan records without a GSED_ID
  data |>
    bind_rows(.id = "file") |>
    filter(!is.na(.data$GSED_ID)) |>
    rename(
      age = .data$visit_age_bsid,
      date = .data$date_of_visit,
      worker_code = .data$ra_code_bsid,
      parent_id = .data$Parent_study_ID
    ) |>
    mutate(adm = "fixed") |>
    select(
      .data$GSED_ID,
      .data$age,
      .data$file,
      .data$adm,
      .data$parent_id,
      .data$worker_code,
      .data$date,
      .data$age_adj_premature,
      contains("bsid"),
      -contains("raw"),
      -contains("comment")
    ) |>
    arrange(.data$GSED_ID, .data$age)
}
