
import pandas as pd

pafexemples='~/data/exemples/'
# fichier='churn.csv'
# cible='Churn?'

def prepare_datas(fichier, cible, dummies=[], prefixes=[], to_drop=[]):
  data=pd.read_csv(pafexemples+fichier)
  # data.info()
  # data.head()
  target=data[cible]
  n=len(dummies)
  if(n>0):
    for i in range(0,n):
      di=dummies[i]
      data=data.join(pd.get_dummies(data[di], prefix=prefixes[i]))
      to_drop.append(dummies[i])
    to_drop.append(cible)
    data=data.drop(to_drop,axis=1)
  return (data,target)
