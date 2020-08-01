# mdl=skl_fit(data, target)
mdl=skl_fit(X_train, y_train, X_test, y_test, paste0('Courbe de gain cumulée - ',target))
# On appréciera que les prochaines implémentations suivent l'exemple de cette sortie,
# pour faciliter l'intégration des résultats complets dans la section ...résultats
mdl=list(
  modele      = mdl[[1]], 
  confusion   = mdl[[2]], 
  score       = mdl[[3]], 
  y_test      = mdl[[4]], 
  y_probas    = mdl[[5]], 
  precision   = mdl[[6]], 
  rappel      = mdl[[7]]
)
