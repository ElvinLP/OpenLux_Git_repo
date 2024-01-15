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
                                 c("2","4","2-4","6","12","2","22", "24","22-24","25","26"),
                               street=c("Rue Eugène Ruppert",
                                        "Rue Eugène Ruppert",
                                        "Rue Eugène Ruppert",
                                        "Rue Eugène Ruppert",
                                        "Rue Eugène Ruppert",
                                        "Avenue Charles de Gaulle",
                                        "Boulevard Royal",
                                        "Boulevard Royal",
                                        "Boulevard Royal",
                                        "Boulevard Royal",
                                        "Boulevard Royal"))
# all caps
addresses_walked[, street := toupper(street)]
# get rid of accents
addresses_walked[, street := iconv(street, from="UTF-8",to="ASCII//TRANSLIT")]

UBO <- copy(openlux)

opencorplux[, quick_address := paste0(street, "_", housenumber)]
UBO[, quick_address := paste0(street, "_", housenumber)]
addresses_walked[, quick_address := paste0(street, "_", housenumber)]



# +---------+
# | TABLE 1 |
# +---------+

UBO[active2021 == 1 & quick_address %in% addresses_walked[, quick_address] & has_real_bo == 1, 
    .N, by = full_name][order(-N)]

savedata_table1 <- UBO[active2021 == 1 & quick_address %in% addresses_walked[, quick_address] & has_real_bo == 1, 
                       .N, by = full_name][order(-N)]
setnames(savedata_table1, "N", "active_Firms_Walked")
savedata_table1 <- savedata_table1[order(-active_Firms_Walked)]


write.csv2(savedata_table1, file = "./data/data_table_1_walkedAddresses.csv")


# +---------+
# | TABLE 2 |
# +---------+

all_people <- unique(UBO[active2021 == 1 & quick_address %in% addresses_walked[, quick_address] & has_real_bo == 1, full_name])


savedata_table2 <- UBO[full_name %in% all_people & active2021 == 1 & has_real_bo == 1, .N, by = full_name][order(-N)]
setnames(savedata_table2, "N", "active_Firms_all_Lux")
# savedata_table2_b <- UBO[full_name %in% all_people &  has_real_bo == 1, .N, by = full_name][order(-N)]
# setnames(savedata_table2_b, "N", "total_firms_allLuxFirms")

# savedata_table2 <- merge(savedata_table2_a, savedata_table2_b , by = "full_name", all = T)
savedata_table2 <- savedata_table2[order(-active_Firms_all_Lux)]


write.csv2(savedata_table2, file = "./data/data_table_2_AllAddresses.csv")



# +-------------------+
# | TABLE 2 B ADDRESS |
# +-------------------+

UBO[active2021 == 1 & quick_address %in% addresses_walked[, quick_address] & has_real_bo == 1, 
    .N, by = .(full_name, quick_address)][order(-quick_address)]

savedata_table2b <- UBO[active2021 == 1 & quick_address %in% addresses_walked[, quick_address] & has_real_bo == 1, 
                       .N, by = .(full_name, quick_address)][order(-quick_address)]

setnames(savedata_table2b, "N", "active_Firms_Walked")
savedata_table2b <- savedata_table2b[order(-active_Firms_Walked)]


write.csv2(savedata_table2b, file = "./data/data_table_2b_walkedAddresses_withAddresses.csv")



# 
# # check walked addresses
# opencorplux[street %in% addresses_walked[,street]]
# UBO[street %in% addresses_walked[,street]] # February 2021
# 
# 
# opencorplux[street %in% addresses_walked[,street],.N, by = street]
# 
# 
# View(opencorplux[!inactive == TRUE &  street %in% addresses_walked[,street], .(normalised_name, street)])
# 
# View(opencorplux[!inactive == TRUE &  street %in% addresses_walked[,street], .(normalised_name, street, year)])
# 
# opencorplux[grepl("louvre", normalised_name), .N, by = normalised_name]
# 
# opencorplux[normalised_name == "louvre group holding sa"]
# 
# UBO[grepl("ouvre", name), .N, by = name]
# 
# 
# UBO[,.N, by = deletion_date][order(N)]
# 
# View(UBO[!statut_rbe == "Has false BO" & street %in% addresses_walked[,street], .N, by = nationality][order(N)])
# 
# View(UBO[!statut_rbe == "Has false BO" & street %in% addresses_walked[,street], .(full_name, street)])
# 
# View(UBO[!statut_rbe == "Has false BO" & street %in% addresses_walked[,street], .N, by = full_name][order(N)])
# 
# UBO[ !statut_rbe == "Has false BO" & street %in% addresses_walked[,street], .(full_name, street)]
# UBO[name == "Holding du Louvre S.A.", statut]
# UBO[full_name == "BONDERMAN, David", name]
# 
# UBO[full_name == "COULTER, James George", name]
# 
# UBO[full_name %in% c("COULTER, James George","BONDERMAN, David"), name]
# 
# UBO[full_name == "BONDERMAN, David", name][duplicated(UBO[full_name == "BONDERMAN, David", name],UBO[full_name == "COULTER, James George", name])]
# UBO[full_name == "COULTER, James George", name][duplicated(UBO[full_name == "COULTER, James George", name],UBO[full_name == "BONDERMAN, David", name])]
# # [312] "TPG Lux 2020 SC IX, S.à r.l."  
# # [311] "TPG Lux 2020 SC V, S.à r.l.|Vardos 2 S.à r.l." 
# # [313] "TPG Lux 2020 SC VII, S.à r.l."   
# # [316] "TPG Lux 2020 SC VI, S.à r.l."  # COULTER
# # [316] "TPG Lux 2020 SC VI, S.à r.l."  # BONDERMAN
# 
# 
# opencorplux[!inactive == TRUE &  street %in% addresses_walked[,street], .N, by = street]
# 
# opencorplux[!inactive == TRUE &  quick_address %in% addresses_walked[,quick_address], .N, by = quick_address][order(N)]
# 
# View(opencorplux[!inactive == TRUE &  street %in% addresses_walked[,street], .N, by = quick_address])
# 
# 
# View(UBO[name == "TPG Lux 2020 SC VI, S.à r.l."])
# 
# str(opencorplux)
# 
# # make incorporation date a date
# opencorplux[, date := as.Date(incorporation_date, format = "%Y-%m-%d")]
# opencorplux[, year := substr(incorporation_date, 1, 4)]
# plotdata <- opencorplux[!inactive == TRUE & street %in% addresses_walked[,street], .N, by = year]
# plotdata <- opencorplux[!inactive == TRUE, .N, by = year]
# 
# ggplot(plotdata[year > 2000], aes( x= as.numeric(year), y = N)) + geom_line() + theme_bw() +ylab("") + xlab("")
# 
# ggplot(plotdata, aes( x= as.numeric(year), y = N)) + geom_line() 
# 
# 
# as.Date("2001-10-04", format = "%y-/%m/-%d")




