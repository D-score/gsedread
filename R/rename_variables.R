#' Rename variables
#'
#' @param from     A character vector with column names
#' @param trans    One of "original", "sequence", "connect" or "extend". Desired
#' transformation of `from`. "original" and "sequence" preserve the original item
#' names or sequence. "connect" and "extend" translate items names to the 9-position
#' GSED lexicon. "connect" uses existing item names (useful for joint analysis with
#' existing data), whereas "extend" defines new 9-position names for the item names
#' in `from`.
#' @param lowercase Sets all variables in lower case.
#' @param underscore Replaces space (" ") and dash ("-") by underscore ("_")
#' @param trim Removes the "Ma_" string
#' @return A character vector of the same length as `from` with processed
#' names.
#' @examples
#' data <- read_sf()
#' from <- colnames(data)
#' idx <- c(1:3, 19, 21:23)
#' from[idx]
#' to <- rename_variables(from)
#' to[idx]
#' to <- rename_variables(from, "sequence", lowercase = FALSE)
#' to[idx]
#' @export
rename_variables <- function(from,
                             trans = c("extend", "original", "sequence", "connect"),
                             lowercase = TRUE,
                             underscore = TRUE,
                             trim = TRUE) {
  trans <- match.arg(trans)
  to <- from

  # rename itemnames
  fn <- system.file("extdata", "itemnames_translate.tsv", package = "gsedread")
  mt <- readr::read_tsv(fn, col_types = "cccccc")
  col <- switch(trans,
                original = "local_name",
                sequence = "local_number",
                connect = "connect_name",
                extend = "extend_name")
  v <- mt[match(from, mt$local_name), col, drop = TRUE]
  to[!is.na(v)] <- v[!is.na(v)]

  # prettify
  if (underscore) {
    to <- sub(" ", "_", to)
    to <- sub("-", "_", to)
  }
  if (trim) to <- sub("Ma_", "", to)
  if (lowercase) to <- tolower(to)

  to
}
