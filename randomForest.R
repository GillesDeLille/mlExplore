
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

# py_run_file('pretraitement_rf.py')
# py_run_file('randomForest.py')
# py$confusion
# py$clfScore

source_python('pretraitement_rf.py')

# fichier='churn.csv' ; cible='Churn?'
fichier='churn2.csv' ; cible='Churn'

datas=prepare_datas(fichier,cible)
exemples=list(
  data=datas[[1]] %>% as_tibble(),
  target=datas[[2]] %>% as_tibble()
)

source_python('randomForest.py')
res=rf(datas, cible)
res=list(modele=res[[1]], confusion=res[[2]], score=res[[3]], y_test=res[[4]], y_probas=res[[5]], precision=res[[6]], rappel=res[[7]])

if(F){
  res$modele
  res$confusion
  res$score
  res$precision
  res$rappel
}

# ========================================================================================================================================
if(F){}
library(microbenchmark)
library(ggplot2)
set.seed(2017)
n <- 10000
p <- 100
X <- matrix(rnorm(n*p), n, p)
y <- X %*% rnorm(p) + rnorm(100)

check_for_equal_coefs <- function(values) {
  tol <- 1e-12
  max_error <- max(c(abs(values[[1]] - values[[2]]),
                     abs(values[[2]] - values[[3]]),
                     abs(values[[1]] - values[[3]])))
  max_error < tol
}

mbm <- microbenchmark("lm" = { b <- lm(y ~ X + 0)$coef },
                      "pseudoinverse" = { b <- solve(t(X) %*% X) %*% t(X) %*% y },
                      "linear system" = { b <- solve(t(X) %*% X, t(X) %*% y) },
                      check = check_for_equal_coefs
)

mbm
autoplot(mbm)
}
# ========================================================================================================================================
