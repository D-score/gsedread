# Reads sf data and stores to /data
# SvB, May 2022

library(dplyr)
library(readr)
onedrive <- Sys.getenv("ONEDRIVE_GSED")

# read fixed sf data into tibble
files_fixed <- c(
  "Pemba Validation/TZA-DATA-2021-11-02/tza-sf-2021-11-01.csv",
  "Pemba Validation/TZA-DATA-2022-11-05/Final_Predictive_dataset/tza_sf_predictive_10_05_2022.csv",
  "Final Phase 1 Data - May 10th 2022/Tan Raw Data/TZA-DATA-2022-11-05/Final_dataset_new_enrollment/tza_sf_new_enrollment_10_05_2022.csv",
  "Bangladesh Validation/Ban_10-05-22/ban_SF_10-05-22.csv",
  "Pakistan Validation/0015_GSED_data_PK_20220517/0015_GSED_data_PK_20220517/Pak_Enrollments_Data/pak_sf_2022_05_17.csv",
  "Pakistan Validation/0015_GSED_data_PK_20220517/0015_GSED_data_PK_20220517/Pak_Predictive_Data/pak_sf_predictive_2022_05_17.csv")
files <- file.path(onedrive, files_fixed)
data <- vector(mode = "list", length = length(files))
names(data) <- tolower(gsub("-", "_", basename(files)))
date_formats <- c("%Y-%m-%d", "%d-%m-%Y", "%d-%m-%Y", "%d/%m/%Y", "%m/%d/%Y", "%m/%d/%Y")
for (i in 1:length(files)) {
  spec <- gsedvalidation::define_col_type("sf", "fixed", date_formats[i])
  data[[i]] <- readr::read_csv(files[i],
                               col_types = spec,
                               na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                               show_col_types = FALSE)
}
df <- dplyr::bind_rows(data, .id = "file")

# read adaptive sf data into tibble
files_adaptive <- c(
  "Pemba Validation/TZA-DATA-2022-11-05/Final_Dataset_Adaptive/tza_sf_adaptive_10_05_2022.csv",
  "Final Phase 1 Data - May 10th 2022/Tan Raw Data/TZA-DATA-2022-11-05/Final_dataset_new_enrollment/tza_sf_new_adaptive_10_05_2022.csv",
  "Bangladesh Validation/Ban_10-05-22/ban_ADAP_SF_10-05-22.csv",
  "Pakistan Validation/0015_GSED_data_PK_20220517/0015_GSED_data_PK_20220517/Pak_Adaptive_Data/pak_sf_adaptive_2022_05_17.csv")
files <- file.path(onedrive, files_adaptive)
data <- vector(mode = "list", length = length(files))
names(data) <- tolower(gsub("-", "_", basename(files)))
date_formats <- c("%d-%m-%Y", "%d-%m-%Y", "%d-%m-%Y", "%m/%d/%Y")
datetime_formats <- c("%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M", "%d-%m-%Y %H:%M:%S", "%d-%m-%Y %H:%M:%S")
for (i in 1:length(files)) {
  spec <- gsedvalidation::define_col_type("sf", "adaptive", date_formats[i],
                                          datetime_format = datetime_formats[i])
  data[[i]] <- readr::read_csv(files[i],
                               col_types = spec,
                               na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                               show_col_types = FALSE)
}
da <- dplyr::bind_rows(data, .id = "file")

# Note: pak_sf_adaptive_2022_05_17.csv has mixed time stamps. Only records with
# the seconds format have a proper values. Time stamps using the other format
# are set to missing (about 15% of the values).


