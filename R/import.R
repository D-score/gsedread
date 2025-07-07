#' @importFrom dplyr     across all_of arrange bind_rows case_when
#'                       contains distinct filter group_by mutate pull
#'                       rename select slice_head starts_with
#'                       ungroup
#' @importFrom readr     col_character col_date col_datetime col_double
#'                       col_integer cols locale problems read_csv
#' @importFrom rlang    .data
#' @importFrom stringr  str_detect str_extract str_pad str_replace
#' @importFrom tidyr    pivot_longer
NULL

utils::globalVariables(c(
  "subjid", "ctry", "agedays", "vist_type", "ins", "cohort", "item"
))
