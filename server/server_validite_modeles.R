
# ---------------------------------------------------------------------------------------------------------------------------------------------------
modelesValides <- reactive({
  # Tous les modèles ne sont pas systématiquement applicables aux données (même prétraitées)
  # On s'attachera ici à donner la liste des modèles, parmis tous ceux implémentés, qui sont compatibles avec les données
  # // TO DO
  # // Définir les critères associés à chaque modèle
  # // Par exemple, pour randomForest les features et la target doivent toutes être numériques
  
  # Pour l'instant, on triche : randomForest fonctionne très bien avec l'exemple churn.csv
  mv=c('randomForest')
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
modeleOk <- reactive( input$modele %in% modelesValides() )
# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiModeleValidite <- renderUI({
  if(modeleOk()){
    out=h5('Ce modèle est valide pour les données')
  }else{
    out=h5('Ce modèle est incompatible avec les données. Ces dernières sont peut-être mal préparées !')
  }
})

