
import pandas as pd

# -------------------------------------------------------------------------------------------------------------
# data=pd.read_csv(pafexemples+fichier, encoding = "ISO-8859-1")
# data=pd.read_csv(pafexemples+fichier)
def lire_fichier(paf, fichier, encoding):
  if encoding != '':
    data=pd.read_csv(paf + fichier, encoding=encoding)
  else:
    data=pd.read_csv(paf + fichier)
  return data

# -------------------------------------------------------------------------------------------------------------
def prepare_data(data, dummies, to_drop, encoding, fichier, paf='exemples/'):
  if data is None:
    data=lire_fichier(paf, fichier, encoding)
  if dummies is not None: 
    n=len(dummies)
    for i in range(0,n):
      di=dummies[i]
      data=data.join(pd.get_dummies(data[di], prefix=di))
      if i==0:
        dr=[dummies[i]]
      else:
        dr.append(dummies[i])
    data=data.drop(dr, axis=1)
  if to_drop is not None: 
    data=data.drop(to_drop, axis=1)
  return data

