

regressons <- function(base) {
  lm<- summary(lm(ecart_moyenne ~ annee, data=base))
  return(lm$coefficients)
}
construction_base_regression <- function(base,
                                         starting_year=1975,
                                         ending_year=Inf,
                                         vector_breaks=c(-Inf,-0.03,0.03,Inf)) {
  base <- base %>%
    filter(annee>=starting_year) %>%
    filter(annee<=ending_year) %>%
    group_nest(DEP) %>%
    mutate(coeff =map(data,.f=~regressons(.x)[[2,1]]),
           pvalue =map(data,.f=~regressons(.x)[[2,4]]),
           std =map(data,.f=~regressons(.x)[[2,2]])) %>%
    unnest(cols=data) %>%
    mutate(coeff=unlist(coeff),
           pvalue=unlist(pvalue),
           std=unlist(std)) %>%
    group_by(DEP) %>%
    mutate(sd_temporel=sd(ecart_moyenne),
           mean_temporel=mean(ecart_moyenne*(annee<=1990))) %>%
    ungroup() %>%
    mutate(convergence=-coeff/mean_temporel,
           br_convergence=cut(convergence,breaks=vector_breaks,
                              include.lowest = TRUE),
           cur_conv= case_when(pvalue>0.05 ~ 0,
                               TRUE ~convergence),
           br_cur_conv=cut(cur_conv, breaks=vector_breaks,
                           include.lowest = TRUE))
}
