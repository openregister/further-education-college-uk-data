#### Modelling: Further-Education-College-UK

### Library call: -----
library(tidyverse)
library(readxl)

### Load source files -----
source_file <- read_xlsx(path = "../list/List of FE Colleges UK-wide 30 Oct 2018.xlsx", col_types = "text")

### Analysis -----
glimpse(source_file)
# 1 column
# 317 rows
# each row: is a name for a college
