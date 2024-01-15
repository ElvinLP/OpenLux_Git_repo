# Title: Cleaning Open Corporate ----
# Author: Jakob Miethe
# Date: 15/01/2024

# I) Initialization ----
rm(list=ls(all=T))

## load packages ----
library(tidyverse)
library(data.table)

## set working directory (change pathperso)
pathperso <- "C:/Users/Jakob.Miethe/ownCloud2/3_Policy/2023_movie"
setwd(dir = paste0(pathperso))

## load data ----
opencorplux <- data.table(read.csv("./data/companies_lu.csv", encoding = "UTF-8"))
# could use some text cleaning

# accents usually cause trouble but that seems to already be solved in normalized_name

# could get rid of new line indicators but actually, they very usefully separate 
# postcodes:

# take out everything before "\\nL" in address
opencorplux[, postcode := str_extract(registered_address.in_full, 
                                                      pattern = "(?<= - ).*")]
# only keep numerics
opencorplux[, postcode := as.numeric(str_extract(postcode, pattern = "\\d+"))]

# now take other information about district:
opencorplux[, district := str_extract(registered_address.in_full, 
                                  pattern = "(?<= - ).*")]
# get rid of Luxembourg
opencorplux[, district := gsub(", Luxembourg", "", district)]

# get rid of numerics
opencorplux[, district := gsub("\\d", "", district)]
# drop leading whitespace
opencorplux[, district := gsub("^\\s+", "", district)]
opencorplux[ district == "", district := NA]

# get housenumber: 
# Everything until first comma
opencorplux[, housenumber := str_extract(registered_address.in_full, 
                                     pattern = "^(.+?),")]
# get rid of last comma
opencorplux[, housenumber := gsub(",$", "", housenumber)]
# could go further but fine until now

# get the street
# everything between housenumber and postcode
opencorplux[, street := str_extract(registered_address.in_full, 
                                pattern = "(?<=, ).*(?= - )")]
# get rid of \\nL
opencorplux[, street := gsub("\\\\nL", "", street)]
# get rid of trailing and leading whitespace
opencorplux[, street := gsub("^\\s+|\\s+$", "", street)]

# all caps
opencorplux[, street := toupper(street)]

# get rid of accents
opencorplux[, street := iconv(street, from="UTF-8",to="ASCII//TRANSLIT")]


# save "opencorporatelux.Rdata"
save(opencorplux, file = "data/opencorporatelux.Rdata")


