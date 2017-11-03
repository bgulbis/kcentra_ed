library(tidyverse)
library(lubridate)
library(edwr)

dir_raw <- "data/raw"

# mpp --------------------------------------------------

# run MBO query
#   * Patients - by Order - no Building
#       - Mnemonic (Primary Generic) FILTER ON: CDM Oral Anticoagulant Reversal

pts_mpp <- read_data(dir_raw, "mpp-patients", FALSE) %>%
    as.patients()

mbo_mpp <- concat_encounters(pts_mpp$millennium.id)

# run MBO query
#   * Orders
#       - Mnemonic (Primary Generic) FILTER ON: CDM Oral Anticoagulant Reversal

# medications ------------------------------------------

# run MBO query
#   * Patients - by Medication (Generic)
#       - Medication (Generic): prothrombin complex;prothrombin complex human

pts_med <- read_data(dir_raw, "med-patients", FALSE) %>%
    as.patients()

mbo_med <- concat_encounters(pts_med$millennium.id)

# run MBO query
#   * Medications - Inpatient - Prompt
#       - Medication (Generic): prothrombin complex;prothrombin complex human

meds <- read_data(dir_raw, "meds-inpt", FALSE) %>%
    as.meds_inpt() %>%
    filter(med.location %in% c("HH EDTR", "HH EREV", "HH VUHH", "HH EDHH"))

mbo_id <- concat_encounters(unique(meds$millennium.id))

# run MBO query
#   * Identifiers - by Millennium Encounter Id

meds_id <- read_data(dir_raw, "id", FALSE) %>%
    distinct() %>%
    rename(millennium.id = `Encounter Identifier`,
           fin = `Financial Number`)

meds %>%
    left_join(meds_id, by = "millennium.id") %>%
    select(fin, med.datetime, med, med.dose, med.dose.units, route, med.location) %>%
    arrange(fin, med.datetime) %>%
    write.csv("data/external/kcentra_patients.csv", row.names = FALSE)
