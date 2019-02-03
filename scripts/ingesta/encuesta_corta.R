#!/usr/bin/env Rscript
library(dplyr)
library(googlesheets)
library(readr)
library(stringr)

# Leemos los datos de la encuesta
encuesta_c <- googlesheets::gs_url('https://docs.google.com/spreadsheets/d/1Pxxzrw7zJ1a3l6Y0kb9Z3A09nYuoRQEbbNaKvHovPbU/edit#gid=406101006')
raw_data_c <- googlesheets::gs_read(encuesta_c)

# Tomamos los datos del metro para imputar long, lat
metro_stations <- readr::read_delim('data/raw/estaciones-metro.csv', delim = ';') %>%
                  dplyr::mutate(stop_name = stringr::str_replace_all(stop_name, '_[0-9]+', ''),
                  estacion = normalize_fields(stop_name),
                  stop_desc = str_replace(stop_desc, 'Metro Línea', 'Metro'),
                  linea = str_extract(stop_desc, '(?<=(Metro)\\s)\\w+')) %>%
                  dplyr::distinct(estacion, linea, .keep_all = TRUE) %>%
                  dplyr::select(stop_id, estacion, linea, latitud = stop_lat, longitud = stop_lon)

# Creamos ciertas variables comunes e imputamos lat long a partir del metro
clean_data_c <- raw_data_c %>%
                clean_headers() %>%
                dplyr::mutate(lugar_en_metro = str_to_lower(str_extract(lugar_exacto_del_incidente, '^\\w+')),
                              en_metro = 1,
                              fuente = 'encuesta_corta',
                              estacion = normalize_fields(estacion_de_stc_metro),
                              linea = str_extract(linea_del_stc_metro, '(?<=(Línea)\\s)\\w+')) %>%
                dplyr::left_join(metro_stations) %>%
                dplyr::select(fecha, hora_aproximada, modalidad:longitud)

readr::write_delim(clean_data_c, 'data/clean/encuesta_corta_clean.csv', delim = ';')
