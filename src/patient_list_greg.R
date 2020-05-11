library(readxl)
library(edwr)

pts <- read_excel(
    "U:/Data/kcentra_ed/external/patients_greg.xlsx",
    col_names = "fin"
)

mbo_fin <- concat_encounters(pts$fin)
print(mbo_fin)
