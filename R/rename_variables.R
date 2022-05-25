#' Rename variables
#'
#' Supports translation of item names for SF, LF and BSID.
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
#' \dontrun{
#' from <- c("file", "GSED_ID", "Ma_SF_Parent ID", "Ma_SF_C01", "Ma_SF_C02")
#' rename_variables(from)
#' rename_variables(from, "sequence", lowercase = FALSE)
#' }
#' @export
rename_variables <- function(from,
                             trans = c("extend", "original", "sequence", "connect"),
                             lowercase = TRUE,
                             underscore = TRUE,
                             trim = TRUE) {
  .Deprecated("rename_vector", msg = "Use 'rename_vector() instead.'")
  trans <- match.arg(trans)
  to <- from

  # rename itemnames
  fn <- system.file("extdata", "itemnames_translate.tsv", package = "gsedread")
  mt <- readr::read_tsv(fn, col_types = "cccccc", progress = FALSE)
  col <- switch(trans,
                original = "original",
                sequence = "sequential",
                connect = "gsed",
                extend = "gsed2")
  v <- mt[match(from, mt$Ma_), col, drop = TRUE]
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
