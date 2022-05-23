read_files <- function(test, types, files, idx,
                       date_formats, datetime_formats,
                       verbose, progress, warnings) {
  stopifnot(length(files) == length(date_formats))
  if (is.null(datetime_formats)) datetime_formats <- rep("", length(files))
  stopifnot(length(files) == length(datetime_formats))

  if (length(types) == 1L) types <- rep(types, length(files))

  data <- vector(mode = "list", length = length(files))
  nm <- tolower(gsub("-", "_", basename(files)))
  names(data) <- unlist(lapply(strsplit(nm, split = "\\."), `[`, 1L))

  for (i in idx) {
    fn <- files[i]
    type <- types[i]
    if (!file.exists(fn)) stop("File not found:", fn)
    spec <- define_col(test, type,
                       date_formats[i],
                       datetime_format = datetime_formats[i])
    if (!warnings) {
      suppressWarnings(
        data[[i]] <- readr::read_csv(fn,
                                     col_types = spec,
                                     na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                                     show_col_types = verbose,
                                     progress = progress)
      )
    } else {
      data[[i]] <- readr::read_csv(fn,
                                   col_types = spec,
                                   na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                                   show_col_types = verbose,
                                   progress = progress)
    }
  }
  data
}
