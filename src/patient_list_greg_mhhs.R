library(tidyverse)
library(readxl)
library(edwr)

tmc_pts <- read_excel(
    "U:/Data/kcentra_ed/external/patients_greg.xlsx",
    col_names = "fin"
) %>%
    mutate(mrn = str_sub(fin, end = 8L))

mbo_fin_tmc <- concat_encounters(tmc_pts$fin)
print(mbo_fin_tmc)

mhhs_pts <- read_excel(
    "U:/Data/kcentra_ed/external/patients_greg_mhhs.xlsx",
    col_names = c("fin", "facility", "home_oac", "transfer_fin"),
    skip = 1
) %>%
    mutate_at("transfer_fin", as.character) %>%
    mutate(mrn = str_sub(fin, end = 8L))

mbo_fin_mhhs <- concat_encounters(mhhs_pts$fin)
print(mbo_fin_mhhs)

pts_transfer <- mhhs_pts %>%
    filter(!is.na(transfer_fin)) %>%
    mutate(mrn = str_sub(fin, end = 8L))

mbo_transfer <- concat_encounters(pts_transfer$transfer_fin)
print(mbo_transfer)

trnsf <- semi_join(mhhs_pts, tmc_pts, by = "mrn")

tf_fin <- semi_join(pts_transfer, tmc_pts, by = c("transfer_fin" = "fin"))

tf <- semi_join(mhhs_pts, tmc_pts, by = "fin")

tf2 <- semi_join(pts_transfer, tmc_pts, by = "mrn")
