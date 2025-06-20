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
