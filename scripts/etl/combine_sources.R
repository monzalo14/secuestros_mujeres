#!/usr/bin/env Rscript
library(dplyr)
library(lubridate)
library(readr)
library(stringr)

# Read both clean datasets
df_short <- readr::read_delim('data/clean/encuesta_corta_clean.csv', delim = ';') %>%
            dplyr::select(-stop_id) %>%
            dplyr::rename(narracion_de_los_hechos = modalidad)
            
df_long <- readr::read_delim('data/clean/encuesta_larga_clean.csv', delim = ';') %>%
           dplyr::select(-timestamp, -ends_with('norm')) %>%
           dplyr::mutate(hora_aproximada = as.character(hora_aproximada))
# Select common characteristics and bind them together
df_secuestros <- dplyr::bind_rows(df_short, df_long)


readr::write_delim(df_secuestros, 'data/clean/secuestros_mujeres.csv', delim = ';')

