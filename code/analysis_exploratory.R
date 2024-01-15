# Title: Analysis Exploratory ----
# Author: Thijs Busschots, Elvin Le Pouhaer, Jakob Miethe
# Date: 15/01/2024

# I) Initialization ----
rm(list=ls(all=T))


# load packages ----
library(tidyverse)
library(data.table)

# set working directory (change pathperso)
pathperso <- "C:/Users/Jakob.Miethe/ownCloud2/3_Policy/2023_movie"
setwd(dir = paste0(pathperso))

# load data ----
load("data/opencorporatelux.Rdata")
load("data/openlux.Rdata")
openlux <- data.table(openlux)

# II) Analysis ----

# now, very simply we can brows addresses. Here are the ones that were visited:
# 2-4 Rue Eugène Ruppert
# 6 Rue Eugène Ruppert
# 12 Rue Eugène Ruppert
# 2 Avenue Charles de Gaulle
# 22-24 Boulevard Royal
# 25 Boulevard Royal
# 26 Boulevard Royal

addresses_walked <- data.table(housenumber =
                                 c("2-4","6","12","2","22-24","25","26"),
                               street=c("Rue Eugène Ruppert",
                                        "Rue Eugène Ruppert",
                                        "Rue Eugène Ruppert",
                                        "Avenue Charles de Gaulle",
                                        "Boulevard Royal",
                                        "Boulevard Royal",
                                        "Boulevard Royal"))
# all caps
addresses_walked[, street := toupper(street)]
# get rid of accents
addresses_walked[, street := iconv(street, from="UTF-8",to="ASCII//TRANSLIT")]



# check walked addresses
opencorplux[street %in% addresses_walked[,street]]
openlux[street %in% addresses_walked[,street]]










