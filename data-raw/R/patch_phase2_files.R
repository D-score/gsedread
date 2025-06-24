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


# --- NLD

files <- list.files(file.path(path, "NLD"), pattern = "\\b(lf|sf|bsid)\\b")

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

