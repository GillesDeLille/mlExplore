
from sklearn.model_selection import train_test_split
from sklearn import ensemble
import matplotlib.pyplot as plt
import scikitplot as skplt

from sklearn.metrics import accuracy_score
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score

def skl_fit(X_train, y_train, X_test, y_test, titre_courbe):
  # --------------------------------------------------------------------------------------------------------------------------
  clf=ensemble.RandomForestClassifier(n_jobs=-1, random_state=321)
  clf.fit(X_train, y_train)
  # --------------------------------------------------------------------------------------------------------------------------
  y_pred=clf.predict(X_test)
  confusion=pd.crosstab(y_test, y_pred, rownames=['Classes réelles'], colnames=['Classes prédites'])
  # --------------------------------------------------------------------------------------------------------------------------
  clfScore=clf.score(X_test,y_test)
  precision=precision_score(y_test, y_pred)                # , average='binary' par défaut
  rappel=recall_score(y_test, y_pred)                      # , average='binary' par défaut
  # precision=precision_score(y_test, y_pred, average=None)
  # rappel=recall_score(y_test, y_pred, average=None)
  y_probas=clf.predict_proba(X_test)
  skplt.metrics.plot_cumulative_gain(y_test, y_probas, title=titre_courbe, title_fontsize='small')
  plt.savefig('figures/courbeGainCumulée')
  # --------------------------------------------------------------------------------------------------------------------------
  # plt.show()
  return (clf, confusion, clfScore, y_test, y_probas, precision, rappel)
