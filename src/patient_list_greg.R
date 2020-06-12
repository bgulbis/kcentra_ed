library(readxl)
library(edwr)

pts <- read_excel(
    "U:/Data/kcentra_ed/external/patients_greg.xlsx",
    col_names = "fin"
)

mbo_fin <- concat_encounters(pts$fin)
print(mbo_fin)

pts <- read_excel(
    "U:/Data/kcentra_ed/external/patients_greg_2020-06-11.xlsx",
    col_names = "fin",
    skip = 1
)

mbo_fin <- concat_encounters(pts$fin)
print(mbo_fin)

