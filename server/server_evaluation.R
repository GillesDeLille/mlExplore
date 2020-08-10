
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
output$uiEvaluation <- renderUI({
  input$annulerProcedure_evaluation
  validerProcedure_evaluation=NULL ; if(!is.null(isolate(input$activerProcedure_evaluation))){ validerProcedure_evaluation=isolate(input$activerProcedure_evaluation) }
  activer=isChurn() ; if(!is.null(validerProcedure_evaluation)) activer=validerProcedure_evaluation
  
  ed <- editeur('Procedure_evaluation', 'python', 30, activer=activer, initScript=(is.null(validerProcedure_evaluation)))
  
  
  resultats <- NULL
  if(!is.null(input$activerProcedure_evaluation)) if(input$activerProcedure_evaluation){
    resultats <- uiOutput('resultatEvaluation')
  }
  liste <- list(
    column(10, ed),
    resultats
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$resultatEvaluation <- renderUI({
  liste <- list(
    affichage_erreurEvaluation()
  )
  erreurEvaluation(NULL)
  tryCatch(
    source_python(paste0('src/',applisession(),'/procedure_evaluation.py')),
    error = function(e){e ; erreurEvaluation(e) }
  )
  if(!is.null(erreurEvaluation())) return(liste)
  
  
  erreurEvaluation(NULL)
  res <- tryCatch(
    evaluation(RandomForest),
    error = function(e){e ; erreurEvaluation(e) }
  )
  if(!is.null(erreurEvaluation())) return(liste)
  
  print('=== RandomForest ===')
  print(res[[1]])
  
  liste <- list(
    h5("Résultats de l'évaluation..."),
    br()
  )
  
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
  # sauver
  input$activerProcedure_evaluation
  script='' ; if(!is.null(isolate(input$editProcedure_evaluation))) script=isolate(input$editProcedure_evaluation)
  writeLines(script,paste0(dossier_src(),'/procedure_evaluation.py'))
})

