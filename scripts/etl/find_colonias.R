#!/usr/bin/env Rscript
library(dplyr)
library(readr)
library(sf)
library(tidyr)

encuesta_clean <- readr::read_csv('data/encuesta_clean.csv', sep = '|')

# Define path for colonias data
path_colonias <- 'data/colonias_wgs84.shp'

# Leemos los datos de las colonias (fuente: ADIP)
colonias <- sf::read_sf(path_colonias)

# Find if pair of (lon, lat) points belong to a polygon
find_polygon <- function(lon, lat, sp_polygon = colonias){
    # If any coordinate is missing, result is empty
    if(is.na(lon) | is.na(lat)) return('null_null_null_null')
    # Check whether the point belongs to any of polygons.
    which_row <- sf::st_contains(sp_polygon,
                                 sf::st_point(c(lon, lat)),
                                 sparse = FALSE)
    # If there's no matched polygon, result is also empty
    if(sum(which_row) == 0){
      return('null_null_null_null')
    }
    # Return name variable for joining
    result <- sp_polygon %>%
              dplyr::filter(which_row) %>%
              dplyr::select(colonia_nombre = NOMBRE,
                            entidad_num = ENTIDAD,
                            municipio_num = MUNICIPIO,
                            cp = CP)

    result <- `st_geometry<-`(result, NULL)

    if(nrow(result) > 1){
      print('More than one colonia, returning the first match')
      result <- result[1 ,]
    }
    result %>%
    tidyr::unite(geo_vars, colonia_nombre, entidad_num, municipio_num, cp) %>%
    dplyr::pull(geo_vars)
}

# Find spatial data for all points
encuesta_colonias <- encuesta_clean %>%
                     dplyr::rowwise() %>%
                     dplyr::mutate(point_spdata = find_polygon(Longitud, Latitud)) %>%
                     tidyr::separate(point_spdata, into = colonias_vars, sep = '_') %>%
                     dplyr::mutate_at(vars(one_of(colonias_vars)), function(x) stringr::str_replace(x, 'null', '')) %>%
                     dplyr::mutate_all(function(x) tidyr::replace_na(x, ''))

# Write into spreadsheet
googlesheets::gs_ws_new(encuesta, ws_title = 'respuestas_colonias', input = encuesta_colonias)
#googlesheets::gs_edit_cells(encuesta, input = data_to_write, anchor = 'R1')
