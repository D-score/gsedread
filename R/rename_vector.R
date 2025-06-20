#' Rename character vector
#'
#' Translates names between different lexicons (naming schema).
#' @param input    A character vector with names to be translated
#' @param lexin    A string indicating the input lexicon. One of "original",
#'  "sequential", "gsed" or "gsed2". Default is "original".
#' @param lexout   A string indicating the output lexicon. One of "original",
#'  "sequential", "gsed" or "gsed2". Default is "gsed2".
#' @param notfound A string indicating what to do some input value is not found
#' @param contains A string to filter the translation table prior to matching.
#' Needed to prevent double matches. The default ("") does not filter.
#' @param underscore Replaces space (" ") and dash ("-") by underscore ("_")
#' @param trim A substring to be removed from `input`. Defaults to "Ma_".
#' @param lowercase Sets all variables in lower case.
#' in `lexin`? The default `notfound = "copy"` copies the input values into the
#' output value. In other cases (e.g. `""` or `NA_character_`), the function
#' uses the string specified in `notfound` as a replacement value.
#' @param force_subjid_agedays If `TRUE`, forces the output to have `"subjid"`
#' and `"agedays"` as names for the `"ID"` and `"age"`, respectively.
#' @return A character vector of the same length as `input` with processed
#' names.
#' @examples
#' input <- c("file", "GSED_ID", "Ma_SF_Parent ID", "Ma_SF_C01", "Ma_SF_C02")
#' rename_vector(input)
#' rename_vector(input, lexout = "sequential", lowercase = FALSE)
#' rename_vector(input, lexout = "gsed", trim = "Ma_SF_")
#' @export
rename_vector <- function(input,
                          lexin = c("original", "sequential", "gsed", "gsed2"),
                          lexout = c("gsed2", "original", "sequential", "gsed"),
                          notfound = "copy",
                          contains = c("", "Ma_SF_", "Ma_LF_", "bsid_"),
                          underscore = TRUE,
                          trim = "Ma_",
                          lowercase = TRUE,
                          force_subjid_agedays = FALSE) {
  lexin <- match.arg(lexin)
  lexout <- match.arg(lexout)
  contains <- match.arg(contains)

  # rename itemnames
  fn <- system.file("extdata", "itemnames_translate.tsv", package = "gsedread")
  mt <- readr::read_tsv(fn, col_types = "cccccc", progress = FALSE) %>%
    filter(grepl(contains, .data$original))
  colin <- switch(lexin,
                   original = "original",
                   sequential = "sequential",
                   gsed = "gsed",
                   gsed2 = "gsed2",
                   "notfound")
  colout <- switch(lexout,
                   original = "original",
                   sequential = "sequential",
                   gsed = "gsed",
                   gsed2 = "gsed2",
                   "notfound")
  if (colin  == "notfound") stop("Lexicon not found: ", lexin)
  if (colout == "notfound") stop("Lexicon not found: ", lexout)
  output <- input
  v <- mt[match(input, pull(mt, colin)), colout, drop = TRUE]
  output[!is.na(v)] <- v[!is.na(v)]
  if (is.na(notfound[1L]) || notfound[1L] != "copy") output[is.na(v)] <- notfound[1L]

  # prettify
  if (underscore) {
    output <- sub(" ", "_", output)
    output <- sub("-", "_", output)
  }
  output <- sub(trim, "", output)
  if (lowercase) output <- tolower(output)

  # force subjid and agedays names
  if (force_subjid_agedays) {
    output <- sub("gsed_id", "subjid", output)
    output <- sub("age", "agedays", output)
  }

  output
}
