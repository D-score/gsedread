
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gsedread

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of gsedread is to read validation data of the project Global
Scales for Early Development (GSED).

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

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

The following script reads all SF data from
`GSED Final Collated Phase 1 Data Files 18_05_22` directory and returns
a tibble with one record per administration.

``` r
library(gsedread)
data <- read_sf(path = "GSED Final Collated Phase 1 Data Files 18_05_22")
head(data, 2)
```
