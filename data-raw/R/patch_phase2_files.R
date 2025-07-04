# File patches for Phase 2 GSED data
# Run this before trying to read the data with gsedread
library(readr)

onedrive <- Sys.getenv("ONEDRIVE_GSED")
path <- file.path(onedrive, "GSED Final Collated Phase 2 Files 02_06_25")
out <- file.path(getwd(), "data-raw/data")
repaired <- file.path(getwd(), "data-raw/repaired")
# path <- repaired

# BRA
files <- list.files(file.path(path, "BRA"), pattern = "\\b(lf|sf|bsid)\\b")

# BRA SF
file <- files[3]
spec <- gsedread:::define_col(ins = "sf", adm = "fixed", date_format = "%d/%m/%Y")
cat("File stamp: ", file, as.character(file.info(file.path(path, "BRA", file))$mtime), "\n")
data <- readr::read_delim(file.path(path, "BRA", file),
                          delim = ";",
                          col_types = spec,
                          na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                          show_col_types = TRUE,
                          progress = FALSE)
problems(data)

# File stamp:  br-sf-2025-06-03.csv 2025-06-17 08:18:02
#
# problem 1: rows 2017+ datetime format (YYYY-MM-DD 00:00:00.000000)
#            instead of expected date format (DD/MM/YYYY)
# problem 2: last column is anonymous, should be removed
# problem 3: column names are not as expected
# problem 4: delimited by semicolon, not comma
# problem 5: file contains two almost empty rows

data <- data[, -ncol(data)]  # solve 2: drop last anonymous column
data <- dplyr::rename(data,  # solve 3: rename columns
                      `Ma_SF_Parent ID` = Ma_SF_ParentID,
                      `Ma_SF_Worker Code` = Ma_SF_WorkerCode,
                      `Ma_SF_Vist Type` = Ma_SF_VistType)

# Check
readr::write_csv(data, file.path(out, file))  # solve 4: save as csv
data2 <- readr::read_csv(file.path(out, file))

# Looks good, but..
problems(data2)

# ... there are 28 missing dates due to format issue
table(is.na(data2$Ma_SF_Date))

# ---

# BRA LF

file <- files[2]
spec <- gsedread:::define_col(ins = "lf", adm = "fixed", date_format = "%d/%m/%Y")
cat("File stamp: ", file, as.character(file.info(file.path(path, "BRA", file))$mtime), "\n")
data <- readr::read_delim(file.path(path, "BRA", file),
                          delim = ";",
                          col_types = spec,
                          na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                          show_col_types = TRUE,
                          progress = FALSE)

problems(data)

# File stamp:  br-lf-2025-06-03.csv 2025-06-20 17:42:10
#
# problem 1: rows 1961+ date format (YYYY-MM-DD) instead of expected
#            date format (DD/MM/YYYY)
# problem 2: comma's are used in some fields, preventing proper csv
#            reading
# problem 3: line 702 is garbled
# problem 4: delimited by semicolon, not comma

# Check
readr::write_csv(data, file.path(out, file))
data2 <- readr::read_csv(file.path(out, file))

# zero rows, but..
problems(data2)

# we have 27 missing dates
table(is.na(data2$Ma_LF_Date))

# BRA BSID


file <- files[1]
spec <- gsedread:::define_col(ins = "bsid", adm = "bra", date_format = "%d/%m/%Y")
cat("File stamp: ", file, as.character(file.info(file.path(path, "BRA", file))$mtime), "\n")
data <- readr::read_csv(file.path(path, "BRA", file),
                               col_types = spec,
                               na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                               show_col_types = verbose,
                               progress = progress,
                               locale = locale(encoding = "Latin1"))
problems(data)

# File stamp:  br-bsid-2025-06-03.csv 2025-06-17 08:18:00
#
# problem 1: rows 110+ date format (MM/DD/YYYY) instead of expected
#            date format (DD/MM/YYYY)
# problem 2: delimited by semicolon, not comma
# problem 3: colnames do not match

#solve 1:
tofix <- readr::read_csv2(file.path(path, "BRA", file),
                            na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                            show_col_types = verbose,
                            progress = progress,
                            locale = locale(encoding = "Latin1"))

datfix <-
  tofix |>  mutate(rn = dplyr::row_number(),
         date_of_b = as.Date(DatadeAplicação, format = "%d/%m/%Y"), #seems that this is birthdate?
         date_of_b2 = as.Date(DatadeAplicação, format = "%m/%d/%Y"),
         date_of_b = dplyr::if_else(rn < 109, date_of_b, date_of_b2),
         date_of_visit = as.Date(DateofEnrollment, format = "%d/%m/%Y"),
         Study_Country = 76
  ) |>
  select(-DatadeAplicação, -DateofEnrollment, -GENDER, -Aplicador, -rn, -date_of_b, -date_of_b2) |>
  #solve 3:
  rename(
    GSED_ID = GSEDId,
    Parent_study_ID = ParentId,
    ra_code_bsid = STRATEGY,
    visit_age_bsid = AgeatEnrollmentDays
    ) |>
  dplyr::rename_with(~paste("bsid", tolower(.x), sep = "_"),
              .cols = COG1:MOTSCORE) |>
  dplyr::rename_with(
    ~ stringr::str_replace_all(.x, c("rlang" = "rc", "elang" = "ec", "gm" = "gsm"))
  ) |>
  rename(bsid_cog01 = bsid_cog1,
         bsid_cog02 = bsid_cog2,
         bsid_cog03 = bsid_cog3,
         bsid_cog04 = bsid_cog4,
         bsid_cog05 = bsid_cog5,
         bsid_cog06 = bsid_cog6,
         bsid_cog07 = bsid_cog7,
         bsid_cog08 = bsid_cog8,
         bsid_cog09 = bsid_cog9,
         bsid_rc01 = bsid_rc1,
         bsid_rc02 = bsid_rc2,
         bsid_rc03 = bsid_rc3,
         bsid_rc04 = bsid_rc4,
         bsid_rc05 = bsid_rc5,
         bsid_rc06 = bsid_rc6,
         bsid_rc07 = bsid_rc7,
         bsid_rc08 = bsid_rc8,
         bsid_rc09 = bsid_rc9,
         bsid_ec01 = bsid_ec1,
         bsid_ec02 = bsid_ec2,
         bsid_ec03 = bsid_ec3,
         bsid_ec04 = bsid_ec4,
         bsid_ec05 = bsid_ec5,
         bsid_ec06 = bsid_ec6,
         bsid_ec07 = bsid_ec7,
         bsid_ec08 = bsid_ec8,
         bsid_ec09 = bsid_ec9,
         bsid_fm01 = bsid_fm1,
         bsid_fm02 = bsid_fm2,
         bsid_fm03 = bsid_fm3,
         bsid_fm04 = bsid_fm4,
         bsid_fm05 = bsid_fm5,
         bsid_fm06 = bsid_fm6,
         bsid_fm07 = bsid_fm7,
         bsid_fm08 = bsid_fm8,
         bsid_fm09 = bsid_fm9,
         bsid_gsm01 = bsid_gsm1,
         bsid_gsm02 = bsid_gsm2,
         bsid_gsm03 = bsid_gsm3,
         bsid_gsm04 = bsid_gsm4,
         bsid_gsm05 = bsid_gsm5,
         bsid_gsm06 = bsid_gsm6,
         bsid_gsm07 = bsid_gsm7,
         bsid_gsm08 = bsid_gsm8,
         bsid_gsm09 = bsid_gsm9
  ) |>
  select(Study_Country, GSED_ID, Parent_study_ID, date_of_visit, ra_code_bsid, visit_age_bsid, everything())




# Check
readr::write_csv(datfix, file.path(out, file))
data2 <- readr::read_csv(file.path(out, file))

# zero rows, but..
problems(data2)

readr::write_csv(data, file.path(out, "br-bsid-2025-07-04.csv"))


# --- CIV

files <- list.files(file.path(path, "CIV"), pattern = "\\b(lf|sf|bsid)\\b")

# CIV SF
file <- files[4]
spec <- gsedread:::define_col(ins = "sf", adm = "fixed", date_format = "%d/%m/%Y")
cat("File stamp: ", file, as.character(file.info(file.path(path, "CIV", file))$mtime), "\n")
data <- readr::read_delim(file.path(path, "CIV", file),
                          delim = ",",
                          col_types = spec,
                          na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                          show_col_types = TRUE,
                          progress = FALSE)
problems(data)

# File stamp:  cdi-sf-2023-09-05_clean.csv 2025-06-18 11:07:27
#
# problem 1: no columns: Ma_SF_Parent ID, Ma_SF_Worker Code, Ma_SF_Vist Type

data <- dplyr::rename(data,  # solve 1: rename columns
                      `Ma_SF_Parent ID` = Ma_SF_Parent.ID,
                      `Ma_SF_Worker Code` = Ma_SF_Worker.Code,
                      `Ma_SF_Vist Type` = Ma_SF_Vist.Type)

# Check
readr::write_csv(data, file.path(out, file))
data2 <- readr::read_csv(file.path(out, file))

# Looks good
problems(data2)

# No missing dates
table(is.na(data2$Ma_SF_Date))

# ---

# CIV LF

file <- files[3]
spec <- gsedread:::define_col(ins = "lf", adm = "fixed", date_format = "%d/%m/%Y")
cat("File stamp: ", file, as.character(file.info(file.path(path, "CIV", file))$mtime), "\n")
data <- readr::read_delim(file.path(path, "CIV", file),
                          delim = ",",
                          col_types = spec,
                          na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                          show_col_types = TRUE,
                          progress = FALSE)

problems(data)

# File stamp:  cdi-lf-2023-09-05_clean.csv 2025-06-18 11:07:27
#
# problem 1: no columns Ma_SF_Parent ID, Ma_SF_Worker Code, Ma_SF_Vist Type

data <- dplyr::rename(data,  # solve 1: rename columns
                      `Ma_LF_Parent ID` = Ma_LF_Parent.ID,
                      `Ma_LF_Worker Code` = Ma_LF_Worker.Code,
                      `Ma_LF_Vist Type` = Ma_LF_Vist.Type)

# Check
readr::write_csv(data, file.path(out, file))
data2 <- readr::read_csv(file.path(out, file))

# Looks good
problems(data2)

# and no missing dates
table(is.na(data2$Ma_LF_Date))



#BSID
file <- files[1]
#spec <- gsedread:::define_col(ins = "bsid", adm = "cdi", date_format = "")
cat("File stamp: ", file, as.character(file.info(file.path(path, "CIV", file))$mtime), "\n")
tofix <- readr::read_delim(file.path(path, "CIV", file),
                          delim = ",",
                         # col_types = spec,
                          na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                          show_col_types = TRUE,
                          progress = FALSE)

data <- tofix |>
  mutate(date_of_visit = as.Date(as.numeric(date_of_visit) ,origin = "1899-12-30"))

problems(data)

#no fixes necessary

# Check
readr::write_csv(data, file.path(out, "cdi-bsid-2025-07-04.csv"))

# --- NLD

files <- list.files(file.path(path, "NLD"), pattern = "\\b(lf|sf|bsid|BSID)\\b")

# NLD SF
file <- files[2]
spec <- gsedread:::define_col(ins = "sf", adm = "fixed", date_format = "%d-%m-%Y")
cat("File stamp: ", file, as.character(file.info(file.path(path, "NLD", file))$mtime), "\n")
data <- readr::read_delim(file.path(path, "NLD", file),
                          delim = "\t",
                          col_types = spec,
                          na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                          show_col_types = TRUE,
                          progress = FALSE)
problems(data)

# File stamp:  nl-sf-2025-15-1.txt 2025-06-17 08:16:37
#
# problem 1: no columns Ma_SF_Parent ID, Ma_SF_Vist Type
# problem 2: Ma_SF_Parent ID should be character (not double)
# problem 3: delimited by tab, not comma
# problem 4: about 20 empty lines at the end of the file

data <- dplyr::rename(data,  # solve 1: rename columns
                      `Ma_SF_Parent ID` = Ma_SF_ParentID,
                      `Ma_SF_Vist Type` = Ma_SF_VistType)

# Check
readr::write_csv(data, file.path(out, file)) # solve 3: save as csv
data2 <- readr::read_csv(file.path(out, file))

# Looks good
problems(data2)

# No missing dates
table(is.na(data2$Ma_SF_Date))

# ---

# NLD LF

file <- files[1]
spec <- gsedread:::define_col(ins = "lf", adm = "fixed", date_format = "%d-%m-%Y")
cat("File stamp: ", file, as.character(file.info(file.path(path, "NLD", file))$mtime), "\n")
data <- readr::read_delim(file.path(path, "NLD", file),
                          delim = "\t",
                          col_types = spec,
                          na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                          show_col_types = TRUE,
                          progress = FALSE)

problems(data)

# File stamp:  cdi-lf-2023-09-05_clean.csv 2025-06-18 11:07:27
#
# problem 1: no columns Ma_SF_Parent ID, Ma_SF_Worker Code, Ma_SF_Vist Type
# problem 2: Ma_SF_Parent ID should be character (not double)
# problem 3: delimited by tab, not comma
# problem 4: about 20 empty lines at the end of the file

data <- dplyr::rename(data,  # solve 1: rename columns
                      `Ma_LF_Parent ID` = Ma_LF_Parent.ID,
                      `Ma_LF_Worker Code` = Ma_LF_Worker.Code,
                      `Ma_LF_Vist Type` = Ma_LF_Vist.Type)

# Check
readr::write_csv(data, file.path(out, file))
data2 <- readr::read_csv(file.path(out, file))

# Looks good
problems(data2)

# and no missing dates
table(is.na(data2$Ma_LF_Date))


#bsid
file <- files[1]
spec <- gsedread:::define_col(ins = "bsid", adm = "nld", date_format = "%d-%m-%Y")
cat("File stamp: ", file, as.character(file.info(file.path(path, "NLD", file))$mtime), "\n")
data <- readr::read_delim(file.path(path, "NLD", file),
                          delim = "\t",
                          col_types = spec,
                          na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                          show_col_types = TRUE,
                          progress = FALSE)
problems(data)

# no problems, but the GSED_ID column is empty and so is visit_age_bsid. So the data is worthless.
readr::write_csv(data, file.path(out, "nl-bsid-2025-07-04.csv"))


# --- CHN

files <- list.files(file.path(path, "CHN"), pattern = "\\b(lf|sf|bsid)\\b")

# CHN SF
file <- files[2]
spec <- gsedread:::define_col(ins = "sf", adm = "fixed", date_format = "%Y/%m/%d")
cat("File stamp: ", file, as.character(file.info(file.path(path, "CHN", file))$mtime), "\n")
data <- readr::read_delim(file.path(path, "CHN", file),
                          delim = ",",
                          col_types = spec,
                          na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                          show_col_types = TRUE,
                          progress = FALSE)
problems(data)

# No missing dates
table(is.na(data$Ma_SF_Date))

# ---

# CHN LF

file <- files[1]
spec <- gsedread:::define_col(ins = "lf", adm = "fixed", date_format = "%Y/%m/%d")
cat("File stamp: ", file, as.character(file.info(file.path(path, "CHN", file))$mtime), "\n")
data <- readr::read_delim(file.path(path, "CHN", file),
                          delim = ",",
                          col_types = spec,
                          na = c("", "NA", "-8888", "-8,888.00", "-9999"),
                          show_col_types = TRUE,
                          progress = FALSE)

problems(data)

# and no missing dates
table(is.na(data$Ma_LF_Date))

