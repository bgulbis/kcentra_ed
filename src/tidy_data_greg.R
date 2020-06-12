library(tidyverse)
library(readxl)
library(openxlsx)

df_pts_tmc <- read_excel(
    "U:/Data/kcentra_ed/external/patients_greg.xlsx",
    col_names = "fin"
) %>%
    mutate(mrn = str_sub(fin, end = 8L))

df_pts_mhhs <- read_excel(
    "U:/Data/kcentra_ed/external/patients_greg_mhhs.xlsx",
    col_names = c("fin", "facility", "home_oac", "transfer_fin"),
    skip = 1
) %>%
    mutate_at("transfer_fin", as.character) %>%
    mutate(mrn = str_sub(fin, end = 8L))

raw_pcc_times <- read_excel(
    "U:/Data/kcentra_ed/external/pcc_times_greg.xlsx",
    col_names = c("fin", "pcc_datetime"),
    skip = 1
) %>%
    mutate_at("fin", as.character)

df_transf_fin <- select(df_pts_mhhs, orig_fin = fin, transfer_fin)

f <- c(
    "U:/Data/kcentra_ed/tidy/kcentra_data.xlsx",
    "U:/Data/kcentra_ed/tidy/kcentra_data_mhhs.xlsx",
    "U:/Data/kcentra_ed/tidy/kcentra_data_transfer.xlsx",
    "U:/Data/kcentra_ed/tidy/kcentra_data_2020-06-11.xlsx"
)

raw_demog <- map_df(
    f,
    read_excel,
    sheet = "demographics"
) %>%
    rename_all(str_to_lower) %>%
    left_join(df_transf_fin, by = c("fin" = "transfer_fin")) %>%
    mutate_at("orig_fin", ~coalesce(., fin)) %>%
    arrange(orig_fin, arrive_datetime) %>%
    distinct(orig_fin, .keep_all = TRUE)

raw_vitals <- map_df(
    f,
    read_excel,
    sheet = "vitals"
) %>%
    rename_all(str_to_lower) %>%
    left_join(df_transf_fin, by = c("fin" = "transfer_fin")) %>%
    mutate_at("orig_fin", ~coalesce(., fin)) %>%
    arrange(orig_fin, vital_datetime) %>%
    mutate_at("vital", str_to_lower)

raw_labs <- map_df(
    f,
    read_excel,
    sheet = "labs"
) %>%
    rename_all(str_to_lower) %>%
    left_join(df_transf_fin, by = c("fin" = "transfer_fin")) %>%
    mutate_at("orig_fin", ~coalesce(., fin)) %>%
    arrange(orig_fin, lab_datetime) %>%
    mutate_at("lab", str_to_lower)

raw_transfusions <- map_df(
    f,
    read_excel,
    sheet = "transfusions"
) %>%
    rename_all(str_to_lower) %>%
    left_join(df_transf_fin, by = c("fin" = "transfer_fin")) %>%
    mutate_at("orig_fin", ~coalesce(., fin)) %>%
    arrange(orig_fin, event_datetime)

raw_reversal <- map_df(
    f,
    read_excel,
    sheet = "reversal_agents"
) %>%
    rename_all(str_to_lower) %>%
    left_join(df_transf_fin, by = c("fin" = "transfer_fin")) %>%
    mutate_at("orig_fin", ~coalesce(., fin)) %>%
    arrange(orig_fin, order_datetime, dose_datetime)

df_bsln_labs <- raw_labs %>%
    select(-fin) %>%
    distinct(orig_fin, lab, .keep_all = TRUE) %>%
    select(fin = orig_fin, lab, lab_result) %>%
    pivot_wider(names_from = "lab", values_from = "lab_result")

df_bsln_vitals <- raw_vitals %>%
    select(-fin) %>%
    mutate_at(
        "vital",
        str_replace_all,
        pattern = c(
            "arterial systolic bp 1" = "sbp",
            "systolic blood pressure" = "sbp",
            "glasgow coma score" = "gcs"
        )
    ) %>%
    distinct(orig_fin, vital, .keep_all = TRUE) %>%
    select(fin = orig_fin, vital, vital_result) %>%
    pivot_wider(names_from = "vital", values_from = "vital_result")

df_transfuse <- raw_transfusions %>%
    left_join(raw_demog[c("orig_fin", "arrive_datetime")], by = "orig_fin") %>%
    mutate_at("product", str_to_lower) %>%
    mutate_at(
        "product",
        ~case_when(
            str_detect(product, "rbc") ~ "prbc",
            str_detect(product, "plasma|ffp") ~ "ffp",
            str_detect(product, "php|platelet|plts") ~ "platelets",
            str_detect(product, "cryo") ~ "cryo"
        )
    ) %>%
    mutate(
        arrive_transfuse_time = difftime(
            event_datetime,
            arrive_datetime,
            units = "hours"
        )
    ) %>%
    select(
        fin = orig_fin,
        product,
        volume,
        arrive_transfuse_time
    )

df_transfuse_4h <- df_transfuse %>%
    filter(arrive_transfuse_time <= 4) %>%
    group_by(fin, product) %>%
    summarize_at("volume", sum, na.rm = TRUE) %>%
    pivot_wider(
        names_from = "product",
        values_from = "volume",
        values_fill = 0L,
        names_prefix = "blood_4h_"
    ) %>%
    mutate(
        blood_4h_total_vol = sum(
            blood_4h_prbc,
            blood_4h_ffp,
            blood_4h_platelets,
            na.rm = TRUE
        )
    ) %>%
    ungroup()

df_transfuse_24h <- df_transfuse %>%
    filter(arrive_transfuse_time <= 24) %>%
    group_by(fin, product) %>%
    summarize_at("volume", sum, na.rm = TRUE) %>%
    pivot_wider(
        names_from = "product",
        values_from = "volume",
        values_fill = 0L,
        names_prefix = "blood_24h_"
    ) %>%
    mutate(
        blood_24h_total_vol = sum(
            blood_24h_prbc,
            blood_24h_ffp,
            blood_24h_platelets,
            blood_24h_cryo,
            na.rm = TRUE
        )
    ) %>%
    ungroup()

df_pcc <- raw_reversal %>%
    select(-fin) %>%
    filter(medication == "prothrombin complex") %>%
    select(fin = orig_fin, dose_datetime) %>%
    arrange(fin, dose_datetime) %>%
    distinct(fin, .keep_all = TRUE) %>%
    left_join(raw_pcc_times, by = "fin")

df_inr <- raw_labs %>%
    select(-fin) %>%
    filter(lab == "inr") %>%
    select(
        fin = orig_fin,
        lab_datetime,
        lab_result
    ) %>%
    left_join(df_pcc, by = "fin") %>%
    filter(lab_datetime > dose_datetime) %>%
    arrange(fin, lab_datetime) %>%
    distinct(fin, .keep_all = TRUE) %>%
    mutate(
        pcc_inr_time = difftime(
            lab_datetime,
            dose_datetime,
            "mins"
        )
    ) %>%
    select(
        fin,
        inr_after_pcc = lab_result,
        pcc_inr_time
    )

df <- raw_demog %>%
    select(fin = orig_fin) %>%
    left_join(df_bsln_labs, by = "fin") %>%
    left_join(df_inr, by = "fin") %>%
    left_join(df_bsln_vitals, by = "fin") %>%
    left_join(df_transfuse_4h, by = "fin") %>%
    left_join(df_transfuse_24h, by = "fin") %>%
    mutate_at(
        c("hct", "hgb", "platelet", "inr_after_pcc", "pcc_inr_time", "gcs", "sbp"),
        as.numeric
    )

write.xlsx(df, "U:/Data/kcentra_ed/final/data_2020-06-12.xlsx")
