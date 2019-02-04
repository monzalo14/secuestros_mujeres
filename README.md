# secuestros_mujeres
Análisis de historias recientes de secuestros a mujeres en las inmediaciones del metro en la CDMX

Este repo surge de la colaboración entre un grupo de activistas y funcionarios de la [ADIP](https://adip.cdmx.gob.mx/) para analizar la aparente ola reciente de reportes de intentos de secuestro en las inmediaciones del metro. Ante un aumento en las denuncias a través de redes sociales, dos grupos distintos de mujeres decidieron construir cuestionarios dirigidos a las víctimas para entender mejor el problema. Un par de días después, el gobierno de la CDMX unió fuerzas con las activistas para explotar mejor la información rrecabada. Este repositorio contiene parte de este trabajo.

Para reproducir los resultados, se debe tener acceso a los dos formularios de Google Forms que dieron inicio a este análisis.
Todo el código debe de correrse desde el directorio raíz del repositorio. Así, reproducir los datos limpios se puede lograr corriendo el siguiente código de R:

```R
source('scripts/setup.R')
source('scripts/ingesta/encuesta_corta.R')
source('scripts/ingesta/encuesta_larga.R')
source('scripts/etl/combine_sources.R')
source('scripts/etl/find_colonias.R')
```
