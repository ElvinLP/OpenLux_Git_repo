# Title: Cleaning OpenLux ----
# Author: Elvin Le Pouhaër
# Date: 20/12/2023

# I) Initialization ----
rm(list=ls(all=T))

## set working directory (change pathperso)
pathperso <- "C:/Users/Jakob.Miethe/ownCloud2/3_Policy/2023_movie"
setwd(dir = paste0(pathperso))

## load data ----
companies <- read.csv("data/dumps_csv/companies.csv")
documents <- read.csv("data/dumps_csv/documents.csv")
owner_company_nature <- read.csv("data/dumps_csv/owner_company_nature.csv")
persons <- read.csv("data/dumps_csv/persons.csv")
persons_details <- read.csv("data/dumps_csv/persons_details.csv")

## load packages ----
library(tidyverse)

# II) Merge databases together according to "OpenLux - database schema.png" ----

# This creates one database called "openlux" with 313,511 observations (one per
# person-company tuple) for companies that have a owner. 140818 additional firms in this
# database have no info on owners.
# (I do not match with the "documents" database).

# WARNING: when doing the merge, the variable "id" in each database only corresponds
# to the row number and not to unique common identifiers across databases.
# We thus need to change the names of the unique identifiers variables before
# the matches and withdraw the row numbers when necessary.

## multiple-to-one match of "documents" with "companies" ----
# documents <- documents %>% select(!id)
names(companies)[c(1,17)] <- c("company_id", "rbe_in_comp")
# names(documents)[c(4,9)] <- c("name_doc", "date_doc")

# openlux <- merge(documents, companies, by = "company_id", all = TRUE)

## multiple-to-one match of "person_details" with "companies" ----
names(persons_details)[1] <- "person_details_id"
# openlux <- merge(openlux, persons_details, by = "company_id", all = TRUE)
openlux <- merge(companies, persons_details, by = "company_id", all = TRUE)


## multiple-to-one match of "owner_company_nature" with "openlux"
owner_company_nature <- owner_company_nature %>% select(!id)
openlux <- merge(openlux, owner_company_nature, by = "person_details_id", all = TRUE)

## one-to-multiple match of "persons" with "openlux"
names(persons)[c(1, 6)] <- c("person_id", "rbe_in_pers")
openlux <- merge(openlux, persons, by = "person_id", all = TRUE)




## save "openlux.Rdata"
save(openlux, file = "data/openlux.Rdata")
rm(list=ls(all=T))
load(file = "./data/openlux.Rdata")
openlux <- data.table(openlux)



## Jakob: I'm adding a bit of  address preparation for ease of access:


# "5, Av. Marie Thérèse L - 2132 Luxembourg"

# take out everything before "\\nL" in address
openlux[, postcode := str_extract(address, 
                                  pattern = "(?<= - ).*")]
# only keep numerics
openlux[, postcode := as.numeric(str_extract(postcode, pattern = "\\d+"))]

# now take other information about district:
openlux[, district := str_extract(address, 
                                      pattern = "(?<= - ).*")]
# get rid of Luxembourg
openlux[, district := gsub("Luxembourg", "", district)]

# get rid of numerics
openlux[, district := gsub("\\d", "", district)]
# drop leading whitespace
openlux[, district := gsub("^\\s+", "", district)]
openlux[ district == "", district := NA]

# get housenumber: 
# Everything until first comma
openlux[, housenumber := str_extract(address, 
                                         pattern = "^(.+?),")]
# get rid of last comma
openlux[, housenumber := gsub(",$", "", housenumber)]
# could go further but fine until now

# get the street
# everything between housenumber and postcode
openlux[, street := str_extract(address, 
                                    pattern = "(?<=, ).*(?= - )")]

# get rid of " L" at the end of the string
openlux[, street := gsub(" L$", "", street)]

# get rid of trailing and leading whitespace
openlux[, street := gsub("^\\s+|\\s+$", "", street)]

# all caps
openlux[, street := toupper(street)]

# get rid of accents
openlux[, street := iconv(street, from="UTF-8",to="ASCII//TRANSLIT")]

# there are still some ugly abbreviations ("THRSE" instead of "Therese" or AV.)
# but we'll leave it here for now

# deletion date for active
openlux[deletion_date == "", deletion_date := NA]
openlux[, active2021 := ifelse(is.na(deletion_date), 1, 0)]

save(openlux, file = "data/openlux.Rdata")

