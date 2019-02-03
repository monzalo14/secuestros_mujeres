#!/usr/bin/env Rscript
library(dplyr)
library(lubridate)
library(readr)

# Read both clean datasets
df_short <- readr::read_delim('data/clean/encuesta_corta_clean.csv', delim = ';') %>%
            dplyr::select(-stop_id)
df_long <- readr::read_delim('data/clean/encuesta_larga_clean.csv', delim = ';') %>%
           dplyr::select(-timestamp, -ends_with('norm'))

# Select common characteristics and bind them together
df_secuestros <- dplyr::bind_rows(df_short, df_long)

