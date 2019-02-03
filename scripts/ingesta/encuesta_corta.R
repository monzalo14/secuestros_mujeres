library(dplyr)
library(googlesheets)

# Leemos los datos de la encuesta
encuesta_corta <- googlesheets::gs_url('https://docs.google.com/spreadsheets/d/1Pxxzrw7zJ1a3l6Y0kb9Z3A09nYuoRQEbbNaKvHovPbU/edit#gid=406101006')
raw_data <- googlesheets::gs_read(encuesta)

clean_data <- raw_data %>%
              dplyr::mutate(en_metro = 1)