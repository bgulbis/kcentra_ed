library(readxl)
library(edwr)

pts <- read_excel(
    "data/external/patients_greg.xlsx",
    col_names = "fin"
)

mbo_fin <- concat_encounters(pts$fin)
print(mbo_fin)
