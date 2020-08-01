
import pandas as pd

# -------------------------------------------------------------------------------------------------------------
def prepare_data(fichier, dummies=[], to_drop=[], pafexemples='exemples/'):
  to_drop=reglage_type(to_drop)
  dummies=reglage_type(dummies)
  data=pd.read_csv(pafexemples+fichier)
  n=len(dummies)
  if(n>0):
    for i in range(0,n):
      di=dummies[i]
      data=data.join(pd.get_dummies(data[di], prefix=di))
      to_drop.append(dummies[i])
  data=data.drop(to_drop, axis=1)
  return (data)
  
