library(targets)
library(tarchetypes)
source("R/functions_data.R")
tar_option_set(packages=c("tidyverse","assertthat","utils","data.table","rmarkdown","openxlsx"))

list(
  tar_target(
    Liste_IDBANK_EV,
    "data/Liste_IDBANK_EV.csv",
    format = "file"
  ),
  tar_target(
    donnees_ev,
    telechargement_donnees(nom_input=Liste_IDBANK_EV,
                           nom_sauvegarde = "data/EV.RDS")
  ),
  tar_target(
    donnees_ev_propre,
    nettoyage_base_EV(donnees_ev)
  ),
  tar_target(
    Liste_IDBANK_ICF,
    "data/Liste_IDBANK_ICF.csv",
    format = "file"
  ),
  tar_target(
    donnees_icf,
    telechargement_donnees(nom_input=Liste_IDBANK_ICF,
                           nom_sauvegarde = "data/ICF.RDS")
  ),
  tar_target(
    donnees_icf_propre,
    nettoyage_base_ICF(donnees_icf)
  ),
  tar_render(
    name=projet_etude,
    "vignette/Projet_etude.Rmd")
  )

