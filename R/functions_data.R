telechargement_donnees <- function(base,nom_sauvegarde="nom_sauvegarde.RDS") {
  assertthat::assert_that("idBank" %in% colnames(base), msg="Il n'y a pas la bonne colonne dans la base")
  base$idBank <- stringr::str_pad(base$idBank,width=9,pad="0",side="left")
  idbank <- paste(base$idBank, collapse="+")
  

  nom_serie <- paste0('https://www.insee.fr/fr/statistiques/serie/telecharger/csv/',
                      idbank,
                      '?ordre=chronologique&transposition=donneescolonne&detail=dataonly')
  download.file(nom_serie,"coucou.zip", mode="wb")
  utils::unzip("coucou.zip", files="valeurs_annuelles.csv",overwrite=TRUE)
  #dir.create("donnees")
  base_p <- data.table::fread("valeurs_annuelles.csv",data.table = FALSE) %>%
    select(!starts_with("Codes"))
  colnames(base_p)<- c("annee",base_p[1,2:ncol(base_p)])
  base_p <-base_p %>%
    slice_tail(n=nrow(base_p)-3) %>%
    mutate(across(everything(), ~as.numeric(.x))) %>%
    tidyr::pivot_longer(cols=-annee,values_to = "variable",names_to="idBank") %>%
    left_join(base,by="idBank")
  saveRDS(base_p, nom_sauvegarde)
  file.remove("valeurs_annuelles.csv")
  file.remove("coucou.zip")
}


nettoyage_base_ICF <- function(data) {
  data %>%
    mutate(LIBDEP=gsub("Indicateur conjoncturel de fécondité des femmes - Ensemble - ",
                       "",Libellé),
           LIBDEP=case_when(LIBDEP=="Territoire de Belfort"~"Territoire-de-Belfort",
                            TRUE ~LIBDEP)) %>%
    rename(ICF=variable) %>%
    select(-Libellé, -idBank) %>%
    left_join(openxlsx::read.xlsx("data/Libelles_DEP_REG.xlsx"), 
              by="LIBDEP") %>%
    relocate(-ICF)
}


nettoyage_base_EV <- function(data) {
  data %>%
    filter(annee>=1975) %>%
    mutate(SEXE=case_when(grepl("Hommes",Libellé)~ "H",
                          TRUE ~ "F"),
           LIBDEP=gsub("Espérance de vie à la naissance - (Hommes|Femmes) - ",
                       "",Libellé),
           LIBDEP=case_when(LIBDEP=="Territoire de Belfort"~"Territoire-de-Belfort",
                            TRUE ~LIBDEP)) %>%
    rename(EV=variable) %>%
    select(-Libellé, -idBank) %>%
    tidyr::pivot_wider(values_from = EV, names_from= SEXE, names_prefix = "EV_") %>%
    left_join(openxlsx::read.xlsx("data/Libelles_DEP_REG.xlsx"), 
              by="LIBDEP") %>%
    relocate(-EV_H, -EV_F)
}
