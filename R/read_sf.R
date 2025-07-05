#' Read sf data
#'
#' @inheritParams read_lf
#' @return A tibble with the original data and two column names: `file`
#' (containing the original file name) and `adm` (fixed or adaptive).
#' If `adm == "fixed"` a tibble with 159
#' columns, with one test administration per row. If `adm == "adaptive"`, a tibble
#' with 14 columns, with one item administration per row.
#' @export
read_sf <- function(adm = c("fixed", "adaptive"),
                    onedrive = Sys.getenv("ONEDRIVE_GSED"),
                    path = NULL,
                    verbose = FALSE,
                    progress = FALSE,
                    warnings = FALSE) {
  if (nchar(onedrive) == 0L) {
    stop("Environmental variable ONEDRIVE_GSED not set.", call. = FALSE)
  }
  if (is.null(path)) {
    stop("Argument `path` not set", call. = FALSE)
  }
  adm <- match.arg(adm)

  if (adm == "fixed") {
    return(read_sf_fixed(onedrive, path, verbose, progress, warnings))
  } else {
    return(read_sf_adaptive(onedrive, path, verbose, progress, warnings))
  }
}

read_sf_fixed <- function(onedrive, path, verbose, progress, warnings) {
  # hardcode fixed sf files names
  files_fixed <- c(
    "tan/tza-sf-2021-11-01.csv",
    "tan/tza_sf_predictive_10_05_2022.csv",
    "tan/tza_sf_new_enrollment_10_05_2022.csv",
    "ban/ban-sf-2021-11-03.csv",
    "ban/ban_sf_predictive_17_05_2022.csv",
    "ban/ban_sf_new_enrollment_17_05_2022.csv",
    "pak/pak_sf_2022_05_17.csv",
    "pak/pak_sf_predictive_2022_05_17.csv",
    "pak/pak_sf_new_enrollment_2022_05_17.csv",
    "bra/br-sf-2025-06-23.csv",
    "chn/chn-sf-2025-06-23.csv",
    "civ/cdi-sf-2025-06-23.csv",
    "nld/nl-sf-2025-06-23.csv")

  # read
  files <- file.path(onedrive, path, files_fixed)
  date_formats <- c("%Y-%m-%d", "%d-%m-%Y", "%d-%m-%Y",
                    "%d/%m/%Y", "%d/%m/%Y", "%d/%m/%Y",
                    "%m/%d/%Y", "%m/%d/%Y", "%m/%d/%Y",
                    "%d/%m/%Y",
                    "%Y/%m/%d",
                    "%d/%m/%Y",
                    "%d-%m-%Y")
  data <- read_files("sf", "fixed", files, 1:length(files),
                     date_formats, NULL,
                     verbose, progress, warnings)

  # bind
  # remove orphan records without a GSED_ID
  data |>
    bind_rows(.id = "file") |>
    filter(!is.na(.data$GSED_ID)) |>
    mutate(adm = "fixed")
}

read_sf_adaptive <- function(onedrive, path, verbose, progress, warnings) {

  # hardcode adaptive sf files names
  files_adaptive <- c(
    "tan/tza_sf_adaptive_10_05_2022.csv",
    "tan/tza_sf_new_adaptive_10_05_2022.csv",
    "ban/ban_sf_adaptive_17_05_2022.csv",
    "ban/ban_sf_new_adaptive_17_05_2022.csv",
    "pak/pak_sf_adaptive_2022_05_17.csv",
    "pak/pak_sf_new_adaptive_2022_05_17.csv"
    )
  files <- file.path(onedrive, path, files_adaptive)
  date_formats <- c("%d-%m-%Y", "%d-%m-%Y",
                    "%d-%m-%Y", "%d/%m/%Y",
                    "%m/%d/%Y", "%m/%d/%Y")
  datetime_formats <- c("%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M",
                        "%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M",
                        "%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M:%S")
  data <- read_files("sf", "adaptive", files, 1:length(files),
                     date_formats, datetime_formats,
                     verbose, progress, warnings)

  # repair mixed time stamp format in pak_sf_adaptive_2022_05_17 and
  # pak_sf_new_adaptive_2022_05_17 (about 15% of the values).
  idx <- 5:6
  datetime_formats <- rep("%m/%d/%Y %H:%M", 6)
  tmp <- read_files("sf", "adaptive", files, idx,
                    date_formats, datetime_formats,
                    verbose, progress, warnings)
  for (i in idx) {
    z <- data[[i]]$Ma_SF_timestamp
    z[is.na(z)] <- tmp[[i]]$Ma_SF_timestamp[!is.na(tmp[[i]]$Ma_SF_timestamp)]
    data[[i]]$Ma_SF_timestamp <- z
  }

  # bind
  # remove orphan records without a GSED_ID
  data |>
    bind_rows(.id = "file") |>
    filter(!is.na(.data$GSED_ID)) |>
    mutate(adm = "adaptive")
}
