
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gsedread

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of gsedread is to read validation data of the project Global
Scales for Early Development (GSED).

## Installation

If you have been marked as a collaborator on GitHub for this repository,
generate a personal access token as in
<https://github.com/settings/tokens>. Add a line

``` r
GITHUB_PAT=ghp_vC82.....................
```

with your token in the file `.Renviron` in your home directory.
Restarting R adds the environmental variable GITHUB_PAT to your session.
Then install the `gsedread` package from GitHub as follows:

``` r
install.packages("remotes")
remotes::install_github("d-score/gsedread")
```

## Example

You need access to the WHO SharePoint site and sync the data to a local
OneDrive. In the file `.Renviron` in your home directory add a line
specifying the location of your synced OneDrive, e.g.,

    ONEDRIVE_GSED='/Users/username/Library/CloudStorage/OneDrive-Sharedlibraries-WorldHealthOrganization/CAVALLERA, Vanessa - GSED Validation 2021_phase I'

After setting the environmental variable `ONEDRIVE_GSED`, restart R, and
manually check whether you are able to read the OneDrive directory.

``` r
dir(Sys.getenv("ONEDRIVE_GSED"))
#>  [1] "Bangladesh Validation"                             
#>  [2] "Baseline Analysis - OLD - NOV 2021"                
#>  [3] "Final Phase 1 Data - May 10th 2022"                
#>  [4] "GSED Final Collated Phase 1 Data Files 18_05_22"   
#>  [5] "GSED PHASE 1 DATA COLLECTED LOG"                   
#>  [6] "GSED_data_quality_1_output_LF_TEST.csv"            
#>  [7] "GSED_data_quality_1_output.csv"                    
#>  [8] "GSED_phase1_merged_11_11_21.csv"                   
#>  [9] "interim DAZ values combined.csv"                   
#> [10] "Interim validation data_phase I_May2021"           
#> [11] "Master_data_dictionary_MAIN_v0.9.1_2021.04.22.xlsx"
#> [12] "Pakistan Validation"                               
#> [13] "Pemba Validation"                                  
#> [14] "QUALITATIVE DATA PHASE 1 MAY 2022"                 
#> [15] "Stop rule change exploration"
```

The following commands reads all SF data from
`GSED Final Collated Phase 1 Data Files 18_05_22` directory and returns
a tibble with one record per administration.

``` r
library(gsedread)
data <- read_sf()
dim(data)
#> [1] 6350  159
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

## Operations

The package reads and processes GSED data. It does not store data. The
`read_sf()` function takes the following actions:

1.  Constructs the paths to the files OneDrive sync file;
2.  Reads all specified datasets in a list;
3.  Internally specifies the desired format for each column;
4.  Specifies the available date and data-time formats per file;
5.  Recodes empty, `NA`, `-8888`, `-8,888.00` and `-9999` values as
    `NA`;
6.  Repairs problems with mixed data-time formats in the adaptive
    Pakistan data;
7.  Stacks the datasets to one tibble with an extra column called
    `file`.
