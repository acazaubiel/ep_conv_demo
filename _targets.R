library(targets)
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
    data.table::fread(Liste_IDBANK_EV,data.table = FALSE) %>%
      telechargement_donnees(nom_sauvegarde = "data/EV.RDS")
  ),
  tar_target(
    donnees_ev,
    telechargement_donnees(base_Liste_IDBANK_EV, nom_sauvegarde = "data/EV.RDS") 
  ),
  tar_target(
    donnees_ev_propre,
    nettoyage_base_EV(readRDS(donnees_ev))
  ),
  tar_target(
    Liste_IDBANK_ICF,
    "data/Liste_IDBANK_ICF.csv",
    format = "file"
  ),
  tar_target(
    base_Liste_IDBANK_ICF,
    data.table::fread(Liste_IDBANK_ICF,data.table = FALSE)
  ),
  tar_target(
    donnees_icf,
    telechargement_donnees(base_Liste_IDBANK_ICF, nom_sauvegarde = "data/ICF.RDS")
  ),
  tar_target(
    donnees_icf_propre,
    nettoyage_base_ICF(donnees_icf) 
  ),
  tar_target(
    name=projet_etude,
    rmarkdown::render("vignette/Projet_etude.Rmd")
  )
)

