
# ---------------------------------------------------------------------------------------------------------------------------------------------------
erreurEvaluation <- reactiveVal()

# ---------------------------------------------------------------------------------------------------------------------------------------------------
affichage_erreurEvaluation <- reactive({
  list(
    h5('Le script python renvoie une erreur :'),
    h5(as.character(erreurEvaluation()))
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$editEvaluation <- renderUI({
  input$annulerProcedure_evaluation

  validerProcedure_evaluation=NULL ; if(!is.null(isolate(input$activerProcedure_evaluation))){ validerProcedure_evaluation=isolate(input$activerProcedure_evaluation) }
  # activer=FALSE ; if(!is.null(validerProcedure_evaluation)) activer=validerProcedure_evaluation
  
  ed <- editeur('Procedure_evaluation', 'python', 30, activer=isolate(input$activerProcedure_evaluation), initScript=(is.null(validerProcedure_evaluation)))
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiEvaluation <- renderUI({
  liste <- list(
    column(10, uiOutput('editEvaluation')),
    column(12,uiOutput('uiResultatsEvaluation'))
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
resultatsEvaluation <- reactive({
  
  input$activerProcedure_evaluation
  
  print('=============================================================================================')
  print("=========================   calcul des resultats de l'évaluation  ===========================")
  
  fichiersource=paste0('src/',applisession(),'/procedure_evaluation.py')
  print(fichiersource)

  # ----------------------------------  
  print('Definition des fonctions')
  erreurEvaluation(NULL)
  tryCatch(
    source_python(fichiersource),
    error = function(e){e ; erreurEvaluation(e) }
  )
  if(!is.null(isolate(erreurEvaluation()))) print(paste('  sortie en erreur :',isolate(erreurEvaluation())))
  if(!is.null(isolate(erreurEvaluation()))) return(NULL)

  # ----------------------------------  
  print('Appel au(x) fonction(s)')
  X_train <- data_preprocessed()$X_train
  y_train <- data_preprocessed()$y_train
  X_test <- data_preprocessed()$X_test
  y_test <- data_preprocessed()$y_test
  res <- tryCatch(
    evaluation(RandomForest, X_train, y_train, X_test, y_test),
    error = function(e){e ; erreurEvaluation(e) }
  )
  if(!is.null(isolate(erreurEvaluation()))) print(paste('  sortie en erreur :',isolate(erreurEvaluation())))
  if(!is.null(isolate(erreurEvaluation()))) return(NULL)

  print('=== Evaluation ===')
  res1=res[[1]]
  save(res1, file='~/resultats_eval.rdata')
  
  print(res1)
  print('=============================================================================================')
  res
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiResultatsEvaluation <- renderUI({
  
  liste <- NULL
  
  if(!is.null(input$activerProcedure_evaluation)) if(input$activerProcedure_evaluation){
    res <- resultatsEvaluation()
    if(!is.null(res)){
      liste <- list(
        HTML('toto')
      )
    }else{
      liste <- list(
        affichage_erreurEvaluation()
      )
    }
  }
  liste
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
courbeGain <- reactive({
  listeModeles=c('randomForest')
  courbeOk <- ((input$implementation=='scikitlearn/randomForest')&(input$modele %in% listeModeles))
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$imageGain <- renderImage({
  validate( need(courbeGain(),'Courbe de gain cumulée à construire selon contexte') )
  
  filename <- normalizePath(file.path('./figures', 'courbeGainCumulée.png'))
  list(src = filename, alt = 'Courbe de gain cumulée', height='250px')
}, deleteFile = FALSE)


# ---------------------------------------------------------------------------------------------------------------------------------------------------
observe({
  # # annuler tous les changements opérés sur le script
  input$annulerProcedure_evaluation
  # on demandera confirmation !!!
  initScript('Procedure_evaluation','python')
})

observe({
  # sauver
  input$activerProcedure_evaluation
  script='' ; if(!is.null(isolate(input$editProcedure_evaluation))) script=isolate(input$editProcedure_evaluation)
  writeLines(script,paste0(dossier_src(),'/procedure_evaluation.py'))
})

observe({
  # # des modifs sont observées dans le script ? => désactiver
  input$editProcedure_evaluation
  updateCheckboxInput(session, 'activerProcedure_evaluation',  value = F)
})





