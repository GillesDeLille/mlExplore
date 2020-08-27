
# -->      Ce script doit définir une fonction qui ajuste un modele donné
# -->      et renvoie des éléments d'évaluation.
# -->      Les résultats sont stockés dans dans un "dossier"

# -->      Elle sera appelée par mlExplore de la façon suivante :

# -->      evaluation(model, X_train, y_train, X_test, y_test, dossier)

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# -------------------------------------------------------------------------------------------------------------
# Procédure d'évaluation
from sklearn.metrics import f1_score, confusion_matrix, classification_report
from sklearn.model_selection import learning_curve

def evaluation(model, X_train, y_train, X_test, y_test, dossier):
  model.fit(X_train, y_train)
  ypred = model.predict(X_test)
  print(confusion_matrix(y_test, ypred))
  print(classification_report(y_test, ypred))
  N, train_score, val_score = learning_curve(
    model, X_train, y_train,
    cv=4, scoring='f1',
    train_sizes=np.linspace(0.1, 1, 10)
  )
  plt.figure(figsize=(12, 8))
  plt.plot(N, train_score.mean(axis=1), label='train score')
  plt.plot(N, val_score.mean(axis=1), label='validation score')
  plt.legend()
  plt.savefig(dossier + '/eval_learning_curve')
  return (confusion_matrix(y_test, ypred), classification_report(y_test, ypred))
  #return (confusion_matrix(y_test, ypred), classification_report(y_test, ypred), plt.show())


# -------------------------------------------------------------------------------------------------------------

from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier

from sklearn.pipeline import make_pipeline
from sklearn.feature_selection import SelectKBest, f_classif
from sklearn.preprocessing import PolynomialFeatures, StandardScaler

preprocessor = make_pipeline(PolynomialFeatures(2, include_bias=False), SelectKBest(f_classif, k=10))

RandomForest = make_pipeline(preprocessor, RandomForestClassifier(random_state=0))

