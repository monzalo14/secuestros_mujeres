library(dplyr)
library(googlesheets)

# Leemos los datos de la encuesta
encuesta <- googlesheets::gs_url('https://docs.google.com/spreadsheets/d/1QCpVh4dbpV6DfiZoKKOQ7hDhs-qVwffgpAYsBq3uZR4/edit?ts=5c5242fc#gid=0')
raw_data <- googlesheets::gs_read(encuesta) %>%
            clean_headers() %>%
            dplyr::mutate(id = row_number()) %>%
            dplyr::filter(!(is.na(timestamp) & is.na(narracion_de_los_hechos)))

# Hacemos refactor y un poco de limpieza
clean_data <- raw_data %>%
              dplyr::mutate(lugar_exacto_lc = normalize_fields(lugar_exacto),
                            en_metro_lugar = grepl('metro|linea|estacion', lugar_exacto_lc),
                            en_metro_descr = grepl('metro|linea|estacion', lugar_exacto_lc),
                            en_metro = en_metro_lugar | en_metro_descr,
                            estacion = str_extract(lugar_exacto_lc, '(?<=(metro|estacion) )\\w+'))

