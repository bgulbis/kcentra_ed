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

# run MBO query
#   * Identifiers
