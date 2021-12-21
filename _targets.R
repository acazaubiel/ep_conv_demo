library(targets)
library(tarchetypes)
source("R/functions_data.R")
source("R/functions_enrichissement.R")
source("R/functions_reglineaire.R")
tar_option_set(packages=c("tidyverse","assertthat","utils",
                          "data.table","rmarkdown","openxlsx","sf","tmap"))

list(
  ## PREPARATION DES DONNEES ----
  ##### importation des listes d'idbank ========
  tar_target(
    Liste_IDBANK_EV,
    "data/Liste_IDBANK_EV.csv",
    format = "file"
  ),
  tar_target(
    Liste_IDBANK_ICF,
    "data/Liste_IDBANK_ICF.csv",
    format = "file"
  ),
  ##### téléchargement des données ========
  tar_target(
    donnees_ev,
    telechargement_donnees(nom_input=Liste_IDBANK_EV,
                           nom_sauvegarde = "data/EV.RDS")
  ),
  tar_target(
    donnees_icf,
    telechargement_donnees(nom_input=Liste_IDBANK_ICF,
                           nom_sauvegarde = "data/ICF.RDS")
  ),
  ##### nettoyage des données ========
  tar_target(
    donnees_ev_propre,
    nettoyage_base_EV(donnees_ev)
  ),
  tar_target(
    donnees_icf_propre,
    nettoyage_base_ICF(donnees_icf)
  ),
  
  #### enrichissement des données =====
  tar_target(donnees_ev_enrichie,
    enrichissement(donnees_ev_propre,c("EV_H","EV_F"))),
  tar_target(donnees_icf_enrichie,
    enrichissement(donnees_icf_propre,c("ICF"))),
  
  #### MODELISATION ----
  
  #### modélisation linéaire simple ====
  ####### icf ######
  tar_target(base_regression_icf,
             construction_base_regression(
               donnees_icf_enrichie %>%
                 rename("ecart_moyenne"=ecart_moyenne_ICF),
               starting_year = 1975,
               ending_year = 2021)),
    ####### ev_f ######
  tar_target(base_regression_evf,
             construction_base_regression(
               donnees_ev_enrichie %>%
                 rename("ecart_moyenne"=ecart_moyenne_EV_F),
               starting_year = 1975,
               ending_year = 2021)),
  ####### ev_h ######
  tar_target(base_regression_evh,
             construction_base_regression(
               donnees_ev_enrichie %>%
                 rename("ecart_moyenne"=ecart_moyenne_EV_H),
               starting_year = 1975,
               ending_year = 2021)),
  ## REALISATION D'UN DOCUMENT D'ETUDE ----
  ### Lecture shapefile =====
  tar_target(
    fcemetro_shp,
    sf::st_read("data/shp/dep_francemetro_2021.shp")),
  
  
  ## Compilation =====
  tar_render(
    name=projet_etude,
    "vignette/Projet_etude.Rmd")
  )

