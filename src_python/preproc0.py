
import pandas as pd

# -------------------------------------------------------------------------------------------------------------
def prepare_data(fichier, dummies, to_drop, pafexemples='exemples/'):
  data=pd.read_csv(pafexemples+fichier, encoding = "ISO-8859-1")
  if dummies is not None: 
    n=len(dummies)
    for i in range(0,n):
      di=dummies[i]
      data=data.join(pd.get_dummies(data[di], prefix=di))
      to_drop.append(dummies[i])
  data=data.drop(to_drop, axis=1)
  return (data)
  
