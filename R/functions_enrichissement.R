enrichissement <- function(base,ma_variable) {
  temp <-base %>%
    select(annee, DEP, {{ma_variable}}) %>%
    tidyr::pivot_longer(cols={{ma_variable}}, names_to="name",
                        values_to="values")
  
  temp <- temp %>%
  filter(DEP !="99") %>%
  left_join(temp %>%
              filter(DEP=="99") %>%
              select(-DEP),
            by=c("annee","name"),suffix=c("","_fce")) %>%
  group_by(annee,name) %>%
  mutate(sd=sd(values),
         mean=mean(values),
         ecart_moyenne=values-values_fce,
         rank=rank(values,ties="average"),
         q_25=quantile(values,probs=0.25),
         q_50=quantile(values,probs=0.5),
         q_75=quantile(values,probs=0.75)) %>%
  ungroup()
  
  if(length(ma_variable>1)) {
    temp<- tidyr::pivot_wider(temp,
                       id_cols = c("annee","DEP"),
                       names_from=name,
                       values_from =-c(annee,DEP,name))
  } else{
    temp <- select(temp,-name)
    colnames(temp)[3:ncol(temp)] <- paste0(colnames(temp)[3:ncol(temp)],
                                           "_",ma_variable) 
  }
  return(temp)
}