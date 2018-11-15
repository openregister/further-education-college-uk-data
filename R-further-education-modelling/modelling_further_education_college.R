#### Modelling: Further-Education-College-UK

### Library call: -----
library(tidyverse)
library(readxl)

### Load source files -----
source_file <- read_xlsx(path = "../list/List of FE Colleges UK-wide 30 Oct 2018.xlsx", col_types = "text")

### Analysis in Excel -----
# A single list of collleges
# separated by region, by a row inserted as a divider

### Analysis in R ----

## Work with data_file
data_file <- source_file

# rename field "Colleges in England" to "name"
names(data_file)[1] <- "name"

# Summary view of data_file
glimpse(data_file)
# 1 column
# 317 rows
# each row: Is a name for a college/institution

## check for duplicate row
duplicate_check <- as_tibble(table(data_file))
duplicate_check <-duplicate_check[duplicate_check$n>1,]
# 1 dupicate found: 'College' appears x2 -- Also appears to be an ambiguos entry.

# Index for rows with "College" as a value:
which(data_file$name == "College")
# row: 160, 217
# [] query with contact


## Possible data to enrich with:
# College contact details?
# UKPRN per college/institution?

### Modelling ----

## Todo
# [x] separate into separate tables per region
# [x] create an indexed table of regions
# [x] map each college to a region by index

# There are 4 regions in the dataset: "England", "Northern Ireland", "Wales", "Scotland"

## [x] create an indexed table of regions
v_index <- c("1","2","3","4")
v_regions <- c("England", "Northern Ireland", "Wales", "Scotland")
df_region <- tibble(v_index, v_regions)

## [x] separate into separate tables per region
# England:
df_coll_eng <- data_file[1:268,]

# Northern Ireland:
df_coll_ni <- data_file[269:275,]
# remove first row containing the divider row
df_coll_ni <-  df_coll_ni[-1,]

# Wales
df_coll_wls <- data_file[276:290,]
# remove first row containing the divider row
df_coll_wls <-df_coll_wls[-1,] 

# Scotland
df_coll_sct <- data_file[291:317,]
# remove first row containing the divider row
df_coll_sct <-df_coll_sct[-1,] 


## [x] map each college to a region by index

# England is region '1':
df_coll_eng$region <- "1"

# Northern Ireland is region "2":
df_coll_ni$region <- "2"

# Wales is region "3":
df_coll_wls$region <- "3"

# Scotland is region "4":
df_coll_sct$region <- "4"


## [x] Collate all regions to one list
df_coll_all <- rbind(df_coll_eng, df_coll_ni, df_coll_wls, df_coll_sct)

# turn region index into CURIE:
df_coll_all <- df_coll_all %>% mutate(region_c = paste("further-education-college-uk-region:", region, sep = ""))


### Review/Checking for accuracy ----

## Row count for original data_file: 317

## Row count for region lists:
length(df_coll_eng$name) # 268
length(df_coll_ni$name) # 6
length(df_coll_sct$name) # 26
length(df_coll_wls$name) # 14
# Total: 314
# a differnce of 3


## irregularities that I am aware of 
# x2 duplicate entry for 'College' in source_file
#  -1 row from df_coll_ni
#  -1 row from df_coll_wls
#  -1 row from df_coll_sct

# Total: -3 missing records


## Check the content match the original list:
# create lists of names to check:
v_data_file_names <- data_file[[1]]
v_df_coll_all_names <- df_coll_all[[1]]

# length of lists:
length(v_data_file_names) # length of original list: 317
length(v_df_coll_all_names) # length of processed list: 314

# 317 - missing_records = 314 (count of all records df_coll_all)

# what records are in data_file, but not df_coll_all:
v_diff_between_data_file_and_coll_all <- setdiff(v_data_file_names, v_df_coll_all_names)
#[1] "Colleges in Northern Ireland" "Colleges in Walex"            "Colleges in Scotland"
# the 3 items identified as being removed.


### Clean Up ----

## should now have two list, to turn into registers:

## - further-education-college-uk
#[x] Add an index as 'further-education-college-uk' (uid), 'start-date', 'end-date'
df_coll_all$`further-education-college-uk` <- seq.int(nrow(df_coll_all))
df_coll_all$`start-date` <- NA
df_coll_all$`end-date` <- NA

#[x] remove 'region',
df_coll_all <- df_coll_all[-2]

#[x] rename 'region_c' to 'region'
df_coll_all <- rename(df_coll_all, region = region_c)

#[x] re-order fields: 'further-education-college-uk', 'name', 'region', 'start-date', 'end-date'
df_coll_all <- select(df_coll_all,
             `further-education-college-uk`, name, region, `start-date`, `end-date`)


## - further-education-college-uk-region
#[x] Add 'start-date', 'end-date'
df_region$`start-date` <- NA
df_region$`end-date` <- NA

#[x] rename 'v_index' to 'further-education-college-uk-region' (uid)
df_region <- rename(df_region, `further-education-college-uk-region` = v_index)

#[x] rename 'v_regions' to region
df_region <- rename(df_region, name = v_regions)

#[x] reorder fileds: 'further-education-college-uk-region', 'name', 'start-date', 'end-date'


### Export ----

## export df_coll_all as "further-education-college-uk.tsv"
write_tsv(df_coll_all, path = "../data/further-education-college-uk.tsv", na = "")

## export df_region as "further-education-college-uk-region.tsv"
write_tsv(df_region, path = "../data/further-education-college-uk-region.tsv", na = "")
