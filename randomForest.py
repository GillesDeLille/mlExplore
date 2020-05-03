
# Random Forest

# executer pretraitement_rf.py

from sklearn.model_selection import train_test_split
from sklearn import ensemble
import matplotlib.pyplot as plt
import scikitplot as skplt

from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
# from sklearn.metrics import f1_score
# from sklearn.metrics import make_scorer
# from sklearn.model_selection import cross_validate
def rf(datas):
  data=datas[0]
  target=datas[1]
  X_train, X_test, y_train, y_test = train_test_split(data, target, test_size=0.2, random_state=12)
  # ----------------------------------------------------------------------------------------------------------------
  clf=ensemble.RandomForestClassifier(n_jobs=-1, random_state=321)
  clf.fit(X_train, y_train)
  # ----------------------------------------------------------------------------------------------------------------
  y_pred=clf.predict(X_test)
  confusion=pd.crosstab(y_test, y_pred, rownames=['Classes réelles'], colnames=['Classes prédites'])
  clfScore=clf.score(X_test,y_test)
  precision_score(y_test, y_pred, average=None)
  recall_score(y_test, y_pred, average=None)
  # plt.show()
  plt.savefig('figures/courbeGainCumulée')
  return (clf, confusion, clfScore, y_test, y_probas)
