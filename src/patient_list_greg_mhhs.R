library(tidyverse)
library(readxl)
library(edwr)

pts <- read_excel(
    "data/external/patients_greg_mhhs.xlsx",
    col_names = c("fin", "facility", "home_oac", "transfer_fin"),
    skip = 1
) %>%
    mutate_at("transfer_fin", as.character)

mbo_fin <- concat_encounters(pts$fin)
print(mbo_fin)

pts_transfer <- pts %>%
    filter(!is.na(transfer_fin))

mbo_transfer <- concat_encounters(pts_transfer$transfer_fin)
print(mbo_transfer)
