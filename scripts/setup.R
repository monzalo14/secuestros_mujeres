install_stable <- function(package_list){
  to_install <- package_list[!(package_list %in% installed.packages()[, 'Package'])]
  if (length(to_install))
    install.packages(to_install, dependencies=TRUE,
                     repos='http://cran.us.r-project.org')
  sapply(package_list, require, character.only=TRUE)
}

packages <- c('googlesheets', 'tidyverse', 'sf')
install_stable(packages)