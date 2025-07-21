
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gsedread

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License: CC BY-NC-ND
4.0](https://img.shields.io/badge/License-CC%20BY--NC--ND%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)
<!-- badges: end -->

The goal of gsedread is to read the Phase 1 and Phase 2 validation data
of the project Global Scales for Early Development (GSED).

## Installation

Install the `gsedread` package from GitHub as follows:

``` r
install.packages("remotes")
remotes::install_github("d-score/gsedread")
```

## How to use

You need access to the proper SharePoint site and sync the data to a
local OneDrive. In the file `.Renviron` in your home directory add a
line specifying the location of your synced OneDrive, e.g.,

    ONEDRIVE_GSED='/Users/username/Library/CloudStorage/OneDrive-Sharedlibraries-...'

After saving `.Renviron`, (re)start R, and manually check whether you
are able to read the OneDrive directory. The following R expression
should return the contents of the OneDrive directory:

``` r
head(dir(Sys.getenv("ONEDRIVE_GSED")))
#> [1] "-DESKTOP-GU6P9PF.RData"                       
#> [2] "-DESKTOP-GU6P9PF.Rhistory"                    
#> [3] "Bangladesh Validation"                        
#> [4] "Baseline Analysis - OLD - NOV 2021"           
#> [5] "Data Cleaning Script MK1 - Run before merge.R"
#> [6] "DATA DICTIONARY"
```

Then set the proper paths **to** and **within** the OneDrive directory
where the data are located. For example, for Phase 1 data, the paths
are:

``` r
onedrive <- Sys.getenv("ONEDRIVE_GSED")
path <- file.path("GSED Phase 1 Final Analysis",
                  "GSED Final Collated Phase 1 Data Files 18_05_22")
```

The high-level function `read_gsed_fixed()` reads and combines SF, LF
and BSID data files. For the Phase 1 data, the function is called as
follows:

``` r
library(gsedread)
phase1 <- read_gsed_fixed(onedrive, path, phase = 1)
```

The `read_gsed_fixed()` functions returns a list with two elements:
`visits` and `responses`.

The `visits` element is a data frame with the visit information, with
the following structure:

``` r
str(phase1$visits)
#> tibble [12,888 × 27] (S3: tbl_df/tbl/data.frame)
#>  $ file                 : chr [1:12888] "ban_sf_2021_11_03" "ban_sf_2021_11_03" "ban_sf_2021_11_03" "ban_sf_2021_11_03" ...
#>  $ subjid               : chr [1:12888] "11-GSED-0001" "11-GSED-0001" "11-GSED-0001" "11-GSED-0002" ...
#>  $ parent_id            : chr [1:12888] "627662" "627662" "627662" "618677" ...
#>  $ worker_code          : num [1:12888] 224 224 223 227 227 223 223 225 228 226 ...
#>  $ vist_type            : int [1:12888] 1 6 8 1 6 8 1 1 1 1 ...
#>  $ location             : num [1:12888] 1 1 1 1 1 1 1 1 1 1 ...
#>  $ agedays              : int [1:12888] 421 429 631 581 589 791 85 245 516 176 ...
#>  $ ah01                 : num [1:12888] NA 1 1 NA 1 1 NA NA NA NA ...
#>  $ ah02                 : num [1:12888] NA 0 0 NA 0 0 NA NA NA NA ...
#>  $ ah03                 : num [1:12888] NA 0 0 NA 0 0 NA NA NA NA ...
#>  $ ah04                 : num [1:12888] NA 0 0 NA 0 0 NA NA NA NA ...
#>  $ ah05                 : num [1:12888] NA 0 0 NA 0 0 NA NA NA NA ...
#>  $ ah06                 : num [1:12888] NA 0 0 NA 0 0 NA NA NA NA ...
#>  $ ah07                 : num [1:12888] NA 0 0 NA 0 0 NA NA NA NA ...
#>  $ ah08                 : num [1:12888] NA 0 0 NA 0 0 NA NA NA NA ...
#>  $ m01                  : num [1:12888] NA NA 3 NA NA 2 NA NA NA NA ...
#>  $ m02                  : num [1:12888] NA NA 0 NA NA 0 NA NA NA NA ...
#>  $ m03                  : chr [1:12888] NA NA NA NA ...
#>  $ date                 : Date[1:12888], format: "2021-02-10" "2021-02-18" ...
#>  $ caregiver            : num [1:12888] 11 11 11 11 11 11 11 11 11 11 ...
#>  $ adm                  : chr [1:12888] "fixed" "fixed" "fixed" "fixed" ...
#>  $ ins                  : chr [1:12888] "sf" "sf" "sf" "sf" ...
#>  $ d01                  : int [1:12888] NA NA NA NA NA NA NA NA NA NA ...
#>  $ d01_spcy             : chr [1:12888] NA NA NA NA ...
#>  $ d02                  : int [1:12888] NA NA NA NA NA NA NA NA NA NA ...
#>  $ d02_spcfy            : chr [1:12888] NA NA NA NA ...
#>  $ agedays_adj_premature: int [1:12888] NA NA NA NA NA NA NA NA NA NA ...
```

There are 12888 visits in the data, with 4374 unique GSED IDs. A visit
is defined by a combination of `subjid`, `agedays`, `vist_type` and
`ins`.

The `responses` element is a data frame with the responses, with the
following structure:

``` r
str(phase1$responses)
#> tibble [568,046 × 5] (S3: tbl_df/tbl/data.frame)
#>  $ subjid   : chr [1:568046] "11-GSED-0001" "11-GSED-0001" "11-GSED-0001" "11-GSED-0001" ...
#>  $ agedays  : int [1:568046] 421 421 421 421 421 421 421 421 421 421 ...
#>  $ vist_type: int [1:568046] 1 1 1 1 1 1 1 1 1 1 ...
#>  $ item     : chr [1:568046] "gs1moc054" "gs1lgc058" "gs1moc059" "gs1moc064" ...
#>  $ response : int [1:568046] 1 1 1 1 1 1 1 1 1 1 ...
```

There are 568046 responses in the data, with 4374 unique GSED IDs. A
response is defined by a combination of `subjid`, `agedays`, `vist_type`
and `item`. The column named `response` is the 0/1 score on the item.

## Lower-level functions

You can assess lower-level functions for reading data files, such as the
Short Form (SF), by the `read_sf()` function. For example, to read the
Phase 1 SF data files:

``` r
sf <- read_sf(onedrive, path)
```

The resulting dataset is in a form much closer to the raw data.
Normally, you would not need to use this function, as the
`read_gsed_fixed()` function reads and processes the data for you, but
it can help to diagnose issues with the data. Similar functions exist
for the Long Form (LF) and BSID data files, `read_lf()` and
`read_bsid()`, respectively.

## Operations

The package reads and processes GSED data. It does not store data. The
`read_sf()`, `read_lf()` and `read_bsid()` functions take the following
actions:

1.  Construct the paths to the files OneDrive sync file
2.  Read all specified datasets in a list
3.  Internally specofy the desired format for each column
4.  Specify the available date and data-time formats per file
5.  Recode empty, `NA`, `-8888`, `-8,888.00` and `-9999` values as `NA`
6.  Repair problems with mixed data-time formats in the adaptive
    Pakistan data
7.  Stack the datasets to one tibble and adds columns `file` and `adm`
8.  Remove records without a `GSED_ID`

In addition, the `read_gsed_fixed()` function performs the following
actions:

9.  Account for the different item orders between Phase 1 and Phase 2
    for SF and LF by means of the `phase` argument
10. Add the `ins` field to `visits`, providing a short hand for
    instrument (`"sf"`, `"lf"`, `"bsid"`)
11. Transform the data for consistency, efficiency and clarity
12. Remove duplicates and sorts the data
13. Rename all item names to conform to the 9-position GSED convention
    using the `gsed3` lexicon. This produces item names that start with
    `gl1` and `gs1` (was `gto` and `gpa`).
14. Split the data into `visits` and `responses` data frames, where
    `visits` contains the visit information and `responses` contains the
    item responses.
15. Remove `gs1moc028` (Clench fist)
16. Remove responses for several language items after the age of 6, 9,
    12 or 18 months, because the meaning changes with age.
17. Make sure that all responses are coded as 0 or 1.

Item renaming with `rename_variables()` relies on the item translation
table at
<https://github.com/D-score/gsedread/blob/main/inst/extdata/itemnames_translate.txt>.

## Additional cleaning and data repair

The `read_gsed_fixed()` reads the data per phase. After combining the
data from the different phases, the functions `repair_visits()` and
`repair_responses` should be run to ensure that the data are in a
consistent format.

## Data governance

The Global Scales of Early Development (GSED) study is an international
project coordinated by the World Health Organization (WHO). The data are
stored in a secure SharePoint site and are shared within the GSED team
for research purposes only. Team members are not allowed to share the
data with third parties. See
<https://www.who.int/publications/i/item/WHO-MSD-GSED-package-v1.0-2023.1>
for information on the GSED study.

## Acknowledgement

This study was supported by the Bill & Melinda Gates Foundation. The
contents are the sole responsibility of the authors and may not
necessarily represent the official views of the Bill & Melinda Gates
Foundation or other agencies that may have supported the primary data
studies used in the present study.
