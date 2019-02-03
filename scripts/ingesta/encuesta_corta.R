library(dplyr)
library(googlesheets)

# Leemos los datos de la encuesta
encuesta_corta <- googlesheets::gs_url('https://docs.google.com/spreadsheets/d/1Pxxzrw7zJ1a3l6Y0kb9Z3A09nYuoRQEbbNaKvHovPbU/edit#gid=406101006')
raw_data_c <- googlesheets::gs_read(encuesta_corta)

clean_data_c <- raw_data_c %>%
                clean_headers() %>%
                dplyr::mutate_all(vars(-fecha)) %>%
                dplyr::mutate(en_metro = 1,
                              fuente = 'encuesta_corta',
                              lugar_en_metro = str_extract(lugar_exacto_del_incidente, '^\\w+'))



readr::write_delim(clean_data, 'data/encuesta_corta_clean.csv', delim = ';')