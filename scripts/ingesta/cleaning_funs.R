library(stringr)

clean_headers <- function(data){
 # Reemplaza puntuación, acentos y espacios de los headers de los datos 
  new_names <- names(data) %>% normalize_fields()
  
  data %>%
  setNames(., nm = new_names)
}

normalize_fields <- function(x){
 # Limpia los campos para buscar palabras clave y crear nuevas variables
  stringr::str_to_lower(x) %>%
  stringr::str_replace(' / ', ' ') %>%
  stringr::str_replace_all('[[:punct:]]', '') %>%
  stringr::str_replace_all(c('á' = 'a')) %>%
  stringr::str_replace_all(c('é' = 'e')) %>%
  stringr::str_replace_all(c('í' = 'i')) %>%
  stringr::str_replace_all(c('ó' = 'o')) %>%
  stringr::str_replace_all(c('ú' = 'u')) %>%
  stringr::str_replace_all(c(' ' = '_'))
}


