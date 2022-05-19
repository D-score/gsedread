#' Read fixed type sf data
#'
#' @param type Character, either "fixed" or "adaptive"
#' @param onedrive Character, the location of the local OneDrive sync
#' @param path Character, path name within the OneDrive
#' @return A tibble with the original data and one new column named `file`
#' containing the original file name. If `type == "fixed"` a tibble with 159
#' columns, with one test administration per row. If `type == "adaptive"`, a tibble
#' with 14 columns, with one item administration per row.
#' @export
read_sf <- function(
  type = c("fixed", "adaptive"),
  onedrive = Sys.getenv("ONEDRIVE_GSED"),
  path = "GSED Final Collated Phase 1 Data Files 18_05_22") {

  stopifnot(nchar(onedrive) > 0L)
  type <- match.arg(type)

  if (type == "fixed") {
    return(read_sf_fixed(onedrive, path))
  } else {
    return(read_sf_adaptive(onedrive, path))
  }
}

read_sf_fixed <- function(onedrive, path) {
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
    "pak/pak_sf_new_enrollment_2022_05_17.csv")

  # read
  files <- file.path(onedrive, path, files_fixed)
  data <- vector(mode = "list", length = length(files))
  nm <- tolower(gsub("-", "_", basename(files)))
  names(data) <- unlist(lapply(strsplit(nm, split = "\\."), `[`, 1L))
  date_formats <- c("%Y-%m-%d", "%d-%m-%Y", "%d-%m-%Y",
                    "%d/%m/%Y", "%d/%m/%Y", "%d/%m/%Y",
                    "%m/%d/%Y", "%m/%d/%Y", "%m/%d/%Y")
  for (i in 1:length(files)) {
    spec <- define_col_type("sf", "fixed", date_formats[i])
    data[[i]] <- readr::read_csv(files[i],
                                 col_types = spec,
                                 na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                                 show_col_types = FALSE)
  }

  # bind
  return(dplyr::bind_rows(data, .id = "file"))
}

read_sf_adaptive <- function(onedrive, path) {

  # hardcode adaptive sf files names
  files_adaptive <- c(
    "tan/tza_sf_adaptive_10_05_2022.csv",
    "tan/tza_sf_new_adaptive_10_05_2022.csv",
    "ban/ban_sf_adaptive_17_05_2022.csv",
    "ban/ban_sf_new_adaptive_17_05_2022.csv",
    "pak/pak_sf_adaptive_2022_05_17.csv",
    "pak/pak_sf_new_adaptive_2022_05_17.csv")
  files <- file.path(onedrive, path, files_adaptive)
  data <- vector(mode = "list", length = length(files))
  nm <- tolower(gsub("-", "_", basename(files)))
  names(data) <- unlist(lapply(strsplit(nm, split = "\\."), `[`, 1L))
  date_formats <- c("%d-%m-%Y", "%d-%m-%Y",
                    "%d-%m-%Y", "%d/%m/%Y",
                    "%m/%d/%Y", "%m/%d/%Y")
  datetime_formats <- c("%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M",
                        "%d-%m-%Y %H:%M:%S", "%d/%m/%Y %H:%M",
                        "%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M:%S")
  for (i in 1:length(files)) {
    spec <- define_col_type("sf", "adaptive", date_formats[i],
                            datetime_format = datetime_formats[i])
    data[[i]] <- readr::read_csv(files[i],
                                 col_types = spec,
                                 na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                                 show_col_types = FALSE)
  }

  # repair mixed time stamp format in pak_sf_adaptive_2022_05_17 and
  # pak_sf_new_adaptive_2022_05_17 (about 15% of the values).
  for (i in 5:6) {
    spec <- define_col_type("sf", "adaptive", date_formats[i],
                            datetime_format = "%m/%d/%Y %H:%M")
    tmp <- readr::read_csv(files[i],
                           col_types = spec,
                           na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                           show_col_types = FALSE)
    z <- data[[i]]$Ma_SF_timestamp
    z[is.na(z)] <- tmp$Ma_SF_timestamp[!is.na(tmp$Ma_SF_timestamp)]
    data[[i]]$Ma_SF_timestamp <- z
  }

  # bind
  return(dplyr::bind_rows(data, .id = "file"))
}
