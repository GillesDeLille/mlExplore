
# Prétraitement pour un Random Forest

import pandas as pd

pafexemples='~/data/exemples/'
# fic='churn.csv'
# cible='Churn?'

def prepare_datas(fichier,cible):
  churn_df=pd.read_csv(pafexemples+fichier)
  # churn_df.info()
  # churn_df.head()
  target=churn_df[cible]
  if fichier=='churn.csv':
    churn_df=churn_df.join(pd.get_dummies(churn_df['Int\'l Plan'], prefix='international'))
    churn_df=churn_df.join(pd.get_dummies(churn_df['VMail Plan'], prefix='voicemail'))
    to_drop=['Int\'l Plan', 'VMail Plan', 'State', 'Area Code', 'Phone', 'Churn?']
    data=churn_df.drop(to_drop,axis=1)
  return (data,target)
