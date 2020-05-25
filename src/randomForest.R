
library(reticulate)
library(dplyr)
library(readr)
library(stringr)

if(F){
  data=read_csv('~/data/exemples/churn.csv')
  data=data %>% mutate(Churn=`Churn?`) %>% select(-`Churn?`)
  data=data %>% mutate("Churn"=str_detect(Churn,"True"))
  write_csv(data, path = '~/data/exemples/churn2.csv')
  data %>% select(Churn) %>% tail(50)
}

source_python('src_python/pretraitement.py')

# fichier='churn.csv' ; target='Churn?'
fichier='churn2.csv' ; target='Churn'

datas=prepare_datas(fichier,
                    dummies=c("Int'l Plan", 'VMail Plan'),
                    to_drop=c('State', 'Area Code', 'Phone'))

source_python('src_python/randomForest.py')
res=skl(datas, target)
res=list(modele=res[[1]], confusion=res[[2]], score=res[[3]], y_test=res[[4]], y_probas=res[[5]], precision=res[[6]], rappel=res[[7]])

if(F){
  res$modele
  res$confusion
  res$score
  res$precision
  res$rappel
}

# ========================================================================================================================================
