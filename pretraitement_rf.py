
# Prétraitement pour un Random Forest

import pandas as pd

pafexemples='~/data/exemples/'
# fichier='churn.csv'
# cible='Churn?'

def prepare_datas(fichier,cible):
  data=pd.read_csv(pafexemples+fichier)
  # data.info()
  # data.head()
  target=data[cible]
  if fichier=='churn.csv':
    data=data.join(pd.get_dummies(data['Int\'l Plan'], prefix='international'))
    data=data.join(pd.get_dummies(data['VMail Plan'], prefix='voicemail'))
    to_drop=['Int\'l Plan', 'VMail Plan', 'State', 'Area Code', 'Phone', 'Churn?']
    data=data.drop(to_drop,axis=1)
  return (data,target)
