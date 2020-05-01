
library(reticulate)
library(dplyr)

# py_run_file('pretraitement_rf.py')
# py_run_file('randomForest.py')
# py$confusion
# py$clfScore

source_python('pretraitement_rf.py')

fic='churn.csv'
cible='Churn?'

datas=prepare_datas(fic,cible)
exemples=list(
  data=datas[[1]] %>% as_tibble(),
  target=datas[[2]] %>% as_tibble()
)

source_python('randomForest.py')
res=rf(datas)
res=list(modele=res[[1]], confusion=res[[2]], score=res[[3]], y_test=res[[4]], y_probas=res[[5]])

if(F){
  res$modele
  res$confusion
  res$score
}