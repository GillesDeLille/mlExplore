
# -------------------------------------------------------------------------------------------------------------
# Procédure d'évaluation
from sklearn.metrics import f1_score, confusion_matrix, classification_report
from sklearn.model_selection import learning_curve

def evaluation(model):
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
  return plt.show()
