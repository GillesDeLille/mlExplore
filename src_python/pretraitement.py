
import pandas as pd

def reglage_type(z):
  if(z==''):
    z=[]
  if isinstance(z,str):
    z=[z]
  return z

def prepare_datas(fichier, dummies=[], to_drop=[], pafexemples='exemples/'):
  to_drop=reglage_type(to_drop)
  dummies=reglage_type(dummies)
  datas=pd.read_csv(pafexemples+fichier)
  n=len(dummies)
  if(n>0):
    for i in range(0,n):
      di=dummies[i]
      datas=datas.join(pd.get_dummies(datas[di], prefix=di))
      to_drop.append(dummies[i])
  datas=datas.drop(to_drop, axis=1)
  return (datas)
  
