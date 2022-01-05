constructioncarte <- function(fond_de_carte, base, variable, palette_choisie, titre="") {
  temp <- right_join(fond_de_carte,base %>% select(DEP, {{variable}}),
                                       by=c("code"="DEP"))
   
   carte <- tm_shape(temp)+
     tm_polygons(c(variable), palette = palette_choisie,
                 title=titre)
   
   return(carte)
 }