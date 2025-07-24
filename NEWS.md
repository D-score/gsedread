# gsedread 0.21.0

* Changes mode to "s" (self-report) for SF items collected in the Netherlands

# gsedread 0.20.0

* Transfers `gsedread::rename_vector()` to the `dscore` (>= 1.10.4) package

# gsedread 0.19.0

* -- CONTAINS BREAKING CHANGES

* Repairs an error in `itemnames_translate.txt` in the B43-B51 range, updates the labels
* Renames the column headers in `itemnames_translate.txt` to a more consistent set
* Adds the new lexicon `gsed3` to `itemnames_translate.txt`. The main advantage of `gsed3` is that the item order conforms to the published LF and SF order (this was not the case in the `gsed` and `gsed2` lexicons). 
* Changes the default lexicons in `rename_vector()`. The `lexin` is `phase2` (was 'original') and `lexout` is `gsed3` (was 'gsed2'). You may revert to previous default by setting `lexin = "phase1"` and `lexout = "gsed2"` in calls to `rename_vector()`. The new lexicon follows the published item order, which should prevent errors in data entry and reading.
* Updates `read_gsed_fixed()` to use the new lexicon `gsed3`.

# gsedread 0.18.0

* Extends hard trunction with three items at 12 and 18 months
* Add `hard_edits` argument to `read_gsed_fixed()`
* Repairs an error in `itemnames_translate.tsv` for "Runs well" item

# gsedread 0.17.0

* Solves an error in the item name matching between phase1 and phase2 related to the reversal of items `gpaclc089` (was `gpaclc088`) and `gpasec088` (was `gpasec089`).
* Updates the item name conversion table `inst/extdata/itemnames_translate.tsv` to reflect the above change.
* Replaces the `LOCAL_DUCKDB` environmental variable by `GSED_PHASE2` in `data-raw/R/build_database_fixed.R` to increase consistency with downstream scripts.

# gsedread 0.16.0

* Rereads `nl-bsid-2025-07-07.csv` after manually adding `GSED_ID` field

# gsedread 0.15.0

* Updates README
* Updates package authors
* Updates LICENSE
* Documents and exports the `read_gsed_fixed()` function
* Adds the `repair_visits()` and `repair_responses()` functions to repair 
`visits` and `responses` data after these have been read and combined
* Shortens the main data reading script `data-raw/R/build_database_fixed.R`
* Expands `read_gsed_fixed()` to read Phase 2 BSID data
* Adds definitions for reading Phase 2 BSID data
* Adds harmonization code for Phase 2 BSID in `data-raw/R/patch_phase2_files.R`
* Moves argument `adm` in `read_lf()` and `read_sf()` to the third position

# gsedread 0.14.0

* Adds `cohort` and `cohortn` variables to `visits`
* Defines grouping factors for unique visits and responses
* Deduplicates `visits` and `responses` data frames
* Adds `phase` indicator
* Adds a small TODO list to `data-raw/R/build_database_fixed.R`

# gsedread 0.13.0

* Repairs function imports and pronoun use
* Replaces dplyr pipe by base R pipe |>

# gsedread 0.12.0

* Adds script `data-raw/R/build_database_fixed.R` to create duckDB datasets with fixed LF, SF and BSID administration
* Adds script `data-raw/R/build_database_adaptive.R` to store adaptive SF and LF (Phase 1 only)
* Adds internal `read_gsed_fixed()` function to read fixed LF, SF and BSID (Phase 1 and Phase 2) data
* Removes outdated `data-raw/data/Data_File_Guide.xlsx`
* Adds script `data-raw/R/patch_phase2_files.R` to identify and repair problem with Phase 2 LF and SF data
* Specify `Latin1` format to read CSV files in `read_sf()`
* Extends `rename_vector()` with an option to translate SF/LF phase 2 names

# gsedread 0.11.0

* Defines Phase 2 source file names and date formats in `read_sf()` and `read_lf()` functions

# gsedread 0.10.0

* Adds `force_subjid_agedays` option to `rename_vector()`

# gsedread 0.9.0

* Adds `Correct-Phase-2-Item-order-to-Stef.tsv` (dated 2024-10-22) to the package
* Updates to external package changes

# gsedread 0.8.0

* Update `itemnames_translate.tsv` with correct LF1 item order

# gsedread 0.7.2 

* Translate `gpalgc059` into `crosec014` (instead of `mdtlgd008`)

# gsedread 0.7.1

* Removes variables `form`, `type` and `vist_type` from BSID data

# gsedread 0.7.0

* Changes the variables names of data read by `read_bsid()` to ease combining with other data

# gsedread 0.6.1

* Adds a new argument `contains` to `rename_vector()` to pre-select the translation table. This argument should be used if `lexin = "gsed"` to evade incorrect name matches from duplicate "gsed" item names.
* Adds a column called `type` to the reader functions.

# gsedread 0.6.0

* Replaces `rename_variables()` by the more versatile `rename_vector()`
* Redefines the column names of the translation table

# gsedread 0.5.1

* Adds support for renaming items from BSID

# gsedread 0.5.0

* Adds `read_bsid()` for reading Bayley III data

# gsedread 0.4.0

* Adds site documentation for github-pages

# gsedread 0.3.2

* Adds `rename_variables()` to obtain user-friendly variable names and to connect or create a 9-position lexicon for item names (#4)

# gsedread 0.3.1

* Stops `read_csv()` babbling by `verbose`, `progress` and `warnings`

# gsedread 0.3.0

* Adds `read_lf()` for reading directly observed data
* Improve README with more detailed installation instructions

# gsedread 0.2.1

* Renames `define_col_type()`  to `define_col()` for clarity
* Changes argument name `form` to `type` in `define_col()` for consistency
* Makes `define_col()` an internal function

# gsedread 0.2.0

* Converts the `data-raw/R/read_sf` script into the function `read_sf()`
* Explains the inner workings of the package in the README

# gsedread 0.1.0

* Adds a `NEWS.md` file to track changes to the package.
* Adds script `data-raw/R/read_sf` with SF data
