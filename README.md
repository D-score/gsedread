
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gsedread

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of gsedread is to read validation data of the project Global
Scales for Early Development (GSED).

## Installation

Install the `gsedread` package from GitHub as follows:

``` r
install.packages("remotes")
remotes::install_github("d-score/gsedread")
```

There is no CRAN version.

## Example

You need access to the proper SharePoint site and sync the data to a
local OneDrive. In the file `.Renviron` in your home directory add a
line specifying the location of your synced OneDrive, e.g.,

    ONEDRIVE_GSED='/Users/username/Library/CloudStorage/OneDrive-Sharedlibraries-...'

After setting the environmental variable `ONEDRIVE_GSED`, restart R, and
manually check whether you are able to read the OneDrive directory.

``` r
head(dir(Sys.getenv("ONEDRIVE_GSED")), 3)
#> [1] "Archive Data dictionaries" "Data Merge"               
#> [3] "Final Data Analysis"
```

The following commands reads all SF data from
`GSED Final Collated Phase 1 Data Files 18_05_22` Sharepoint directory
and returns a tibble with one record per administration.

``` r
library(gsedread)
data <- read_sf()
dim(data)
#> [1] 6350  160
```

Count the number of records per file:

``` r
table(data$file)
#> 
#>                ban_sf_2021_11_03 ban_sf_new_enrollment_17_05_2022 
#>                             1543                               72 
#>     ban_sf_predictive_17_05_2022                pak_sf_2022_05_17 
#>                              473                             1761 
#> pak_sf_new_enrollment_2022_05_17     pak_sf_predictive_2022_05_17 
#>                               72                              459 
#>                tza_sf_2021_11_01 tza_sf_new_enrollment_10_05_2022 
#>                             1427                               74 
#>     tza_sf_predictive_10_05_2022 
#>                              469
```

Process variable names user-friendly alternative:

``` r
rename_vector(colnames(data)[c(1:3, 19, 21:25)], lexout = "gsed2", trim = "Ma_SF_")
#> [1] "file"      "gsed_id"   "parent_id" "date"      "gpalac001" "gpacgc002"
#> [7] "gpafmc003" "gpasec004" "gpamoc005"
```

## Operations

The package reads and processes GSED data. It does not store data. The
`read_sf()` and `read_lf()` functions takes the following actions:

1.  Constructs the paths to the files OneDrive sync file;
2.  Reads all specified datasets in a list;
3.  Internally specifies the desired format for each column;
4.  Specifies the available date and data-time formats per file;
5.  Recodes empty, `NA`, `-8888`, `-8,888.00` and `-9999` values as
    `NA`;
6.  Repairs problems with mixed data-time formats in the adaptive
    Pakistan data;
7.  Stacks the datasets to one tibble and adds columns `file` and `adm`;
8.  Removes records without a `GSED_ID`.

Item renaming with `rename_variables()` relies on the item translation
table at
<https://github.com/D-score/gsedread/blob/main/inst/extdata/itemnames_translate.tsv>.

## Acknowledgement

This study was supported by the Bill & Melinda Gates Foundation. The
contents are the sole responsibility of the authors and may not
necessarily represent the official views of the Bill & Melinda Gates
Foundation or other agencies that may have supported the primary data
studies used in the present study.
