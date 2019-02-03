#!/usr/bin/env Rscript
library(dplyr)
library(googlesheets)
library(readr)

# Leemos los datos de la encuesta
encuesta <- googlesheets::gs_url('https://docs.google.com/spreadsheets/d/1QCpVh4dbpV6DfiZoKKOQ7hDhs-qVwffgpAYsBq3uZR4/edit?ts=5c5242fc#gid=0')
raw_data <- googlesheets::gs_read(encuesta) %>%
            clean_headers() %>%
            dplyr::mutate(id = row_number()) %>%
            dplyr::filter(!(is.na(timestamp) & is.na(narracion_de_los_hechos)))

# Leemos los datos del metro.
# Los nombres de estaciones parecen ser únicos, pero no sería mucho problema si se repitieran conforme
# a los transbordos, por ejemplo.
# Para algunos casos (no todos), los nombres vienen con el sufijo _x, donde x es el número de la línea
# en la que se encuentra la estación. Vamos a borrar esos sufijos y normalizar términos
metro_stations <- readr::read_delim('data/estaciones-metro.csv', delim = ';') %>%
                  dplyr::select(stop_id, stop_name) %>%
                  dplyr::mutate(stop_name_lc = stringr::str_replace_all(stop_name, '_[0-9]+', ''),
                                stop_name_lc = normalize_fields(stop_name_lc))

stations_regex <- metro_stations %>%
                  pull(stop_name_lc) %>%
                  paste(., collapse='|')

# Hacemos refactor y un poco de limpieza
clean_data <- raw_data %>%
              dplyr::mutate(lugar_exacto_lc = normalize_fields(lugar_exacto),
                            narracion_de_los_hechos_lc = normalize_fields(narracion_de_los_hechos),
                            en_metro_lugar = grepl('metro|linea|estacion', lugar_exacto_lc),
                            en_metro_descr = grepl('metro|linea|estacion', narracion_de_los_hechos_lc),
                            en_metro = en_metro_lugar | en_metro_descr,
                            estacion_lugar = str_extract(lugar_exacto_lc, stations_regex),
                            estacion_descripcion = str_extract(narracion_de_los_hechos_lc, stations_regex),
                            estacion = if_else(!is.na(estacion_lugar), estacion_lugar, estacion_descripcion),
                            fuente = 'encuesta_larga')

readr::write_delim(clean_data, 'data/encuesta_larga_clean.csv', delim = ';')
