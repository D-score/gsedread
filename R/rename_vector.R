#' Rename character vector
#'
#' Translates names between different lexicons (naming schema).
#' @param input    A character vector with names to be translated
#' @param lexin    A string indicating the input lexicon. One of "Ma_",
#'  "sequential", "gsed" or "gsed2". Default is "Ma_".
#' @param lexout   A string indicating the output lexicon. One of "Ma_",
#'  "sequential", "gsed" or "gsed2". Default is "gsed2".
#' @param lowercase Sets all variables in lower case.
#' @param underscore Replaces space (" ") and dash ("-") by underscore ("_")
#' @param trim Removes the "Ma_" string
#' @param notfound A string indicating what to do some input value is not found
#' in `lexin`? The default `notfound = "copy"` copies the input values into the
#' output value. In other cases (e.g. `""` or `NA_character_`), the function
#' uses the string specified in `notfound` as a replacement value.
#' @return A character vector of the same length as `from` with processed
#' names.
#' @examples
#' input <- c("file", "GSED_ID", "Ma_SF_Parent ID", "Ma_SF_C01", "Ma_SF_C02")
#' rename_vector(input)
#' rename_vector(input, "Ma_", "sequential", lowercase = FALSE)
#' @export
rename_vector <- function(input,
                          lexin = c("Ma_", "sequential", "gsed", "gsed2"),
                          lexout = c("gsed2", "Ma_", "sequential", "gsed"),
                          lowercase = TRUE,
                          underscore = TRUE,
                          trim = TRUE,
                          notfound = "copy") {
  lexin <- match.arg(lexin)
  lexout <- match.arg(lexout)

  # rename itemnames
  fn <- system.file("extdata", "itemnames_translate.tsv", package = "gsedread")
  mt <- readr::read_tsv(fn, col_types = "cccccc", progress = FALSE)
  colin <- switch(lexin,
                   Ma_ = "Ma_",
                   sequential = "sequential",
                   gsed = "gsed",
                   gsed2 = "gsed2",
                   "notfound")
  colout <- switch(lexout,
                   Ma_ = "Ma_",
                   sequential = "sequential",
                   gsed = "gsed",
                   gsed2 = "gsed2",
                   "notfound")
  if (colin  == "notfound") stop("Lexicon not found: ", lexin)
  if (colout == "notfound") stop("Lexicon not found: ", lexout)
  output <- input
  v <- mt[match(input, dplyr::pull(mt, colin)), colout, drop = TRUE]
  output[!is.na(v)] <- v[!is.na(v)]
  if (is.na(notfound[1L]) || notfound[1L] != "copy") output[is.na(v)] <- notfound[1L]

  # prettify
  if (underscore) {
    output <- sub(" ", "_", output)
    output <- sub("-", "_", output)
  }
  if (trim) output <- sub("Ma_", "", output)
  if (lowercase) output <- tolower(output)

  output
}
