#!/usr/bin/env Rscript
library(dplyr)
library(googlesheets)
library(readr)

source('scripts/ingesta/cleaning_funs.R')

# Leemos los datos de la encuesta
encuesta <- googlesheets::gs_url('https://docs.google.com/spreadsheets/d/1QCpVh4dbpV6DfiZoKKOQ7hDhs-qVwffgpAYsBq3uZR4/edit?ts=5c5242fc#gid=0')
raw_data <- googlesheets::gs_read(encuesta) %>%
            clean_headers() %>%
            dplyr::filter(!(is.na(timestamp) & is.na(narracion_de_los_hechos)))

# Leemos los datos del metro.
# Los nombres de estaciones parecen ser únicos, pero no sería mucho problema si se repitieran conforme
# a los transbordos, por ejemplo.
# Para algunos casos (no todos), los nombres vienen con el sufijo _x, donde x es el número de la línea
# en la que se encuentra la estación. Vamos a borrar esos sufijos y normalizar términos
metro_stations <- readr::read_delim('data/raw/estaciones-metro.csv', delim = ';') %>%
                  dplyr::mutate(stop_name = stringr::str_replace_all(stop_name, '_[0-9]+', ''),
                                estacion = normalize_fields(stop_name),
                                stop_desc = str_replace(stop_desc, 'Metro Línea', 'Metro'),
                                linea = str_extract(stop_desc, '(?<=(Metro)\\s)\\w+')) %>%
                  dplyr::distinct(estacion, .keep_all = TRUE)

stations_regex <- metro_stations %>%
                  pull(estacion) %>%
                  paste(., collapse='|')

# Hacemos un poco de limpieza (falta un refactor)
# Name standard:
# _norm stands for "normalized" (no accents, spaces, or punctuation marks, all lowercase)
# _l means it comes from variable "lugar_exacto",
# _n means it comes from variable "narracion_de_los_hechos",
# variable without suffix (en_metro, estacion, lugar_en_metro) is the union of both _l and _n
clean_data <- raw_data %>%
              dplyr::mutate(lugar_exacto_norm = normalize_fields(lugar_exacto),
                            narracion_de_los_hechos_norm = normalize_fields(narracion_de_los_hechos),
                            en_metro_l = grepl('metro|linea|estacion', lugar_exacto_norm),
                            en_metro_n = grepl('metro|linea|estacion', narracion_de_los_hechos_norm),
                            en_metro = en_metro_l | en_metro_n,
                            estacion_l = str_extract(lugar_exacto_norm, stations_regex),
                            estacion_n = str_extract(narracion_de_los_hechos_norm, stations_regex),
                            estacion = if_else(!is.na(estacion_l), estacion_l, estacion_n),
                            lugar_en_metro_l = str_extract(lugar_exacto_norm, 'dentro|fuera|anden|transbordo|vagon|taquilla'),
                            lugar_en_metro_n = str_extract(narracion_de_los_hechos_norm, 'dentro|fuera|anden|transbordo|vagon|taquilla'),
                            lugar_en_metro = if_else(!is.na(lugar_en_metro_l), lugar_en_metro_l, lugar_en_metro_n),
                            lugar_en_metro = str_replace(lugar_en_metro, 'anden|vagon|taquilla', 'dentro'),
                            fuente = 'encuesta_larga') %>%
              dplyr::mutate_if(is.character, function(x) str_replace_all(x, "[\r\n]" , "")) %>%
              dplyr::select(-ends_with('_l'), -ends_with('_n'), -ping) %>%
              dplyr::rename(fecha = fecha_del_incidente, hora_aproximada = hora_del_incidente,
                            consecuencias_fisicas = consecuencias_fisicas_moretones_raspones_fracturas) %>%
              dplyr::mutate_if(is.logical, as.numeric)

readr::write_delim(clean_data, 'data/clean/encuesta_larga.csv', delim = ';', na = '')
