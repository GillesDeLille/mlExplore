
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
  liste <- list(
    uiOutput('editEvaluation'),
    column(12,hr()),
    uiOutput('uiResultatsEvaluation')
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$editEvaluation <- renderUI({
  input$annulerProcedure_evaluation
  
  validerProcedure_evaluation=NULL ; if(!is.null(isolate(input$activerProcedure_evaluation))){ validerProcedure_evaluation=isolate(input$activerProcedure_evaluation) }
  # activer=FALSE ; if(!is.null(validerProcedure_evaluation)) activer=validerProcedure_evaluation
  
  ed <- editeur('Procedure_evaluation', 'python', 25, activer=isolate(input$activerProcedure_evaluation), initScript=(is.null(validerProcedure_evaluation)))
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiResultatsEvaluation <- renderUI({
  
  liste <- NULL ; if(!is.null(input$activerProcedure_evaluation)) if(input$activerProcedure_evaluation){
    if(!is.null(resultatsEvaluation())){
      liste <- list(
        box(
          width = 3, title = 'Matrice de confusion',
          DT::dataTableOutput('matconf')
        ),
        box(
          width = 9,
          verbatimTextOutput('rapport')
        ),
        # box(
        #   width = 12,
          # 'Learning Curve',
          plotOutput('image_learningCurve')
        # )
      )
    }else liste <- list( affichage_erreurEvaluation() )
  }
  liste
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
resultatsEvaluation <- reactive({
  
  validate( need(input$activerProcedure_evaluation,'...') )
  
  dossier=paste0('src/',applisession())
  
  print('=============================================================================================')
  print("=========================   calcul des resultats de l'évaluation  ===========================")
  
  fichiersource=paste0(dossier,'/procedure_evaluation.py')
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
    evaluation(RandomForest, X_train, y_train, X_test, y_test, dossier),
    error = function(e){e ; erreurEvaluation(e) }
  )
  if(!is.null(isolate(erreurEvaluation()))) print(paste('  sortie en erreur :',isolate(erreurEvaluation())))
  if(!is.null(isolate(erreurEvaluation()))) return(NULL)

  print('=============================================================================================')

  matrice_confusion=res[[1]]
  classification_report=res[[2]]
  fichier_report=paste0(dossier,'/classification_report.txt')
  writeLines(classification_report, fichier_report)
  
  list(matrice_confusion=matrice_confusion, rapport=classification_report)
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$matconf <- DT::renderDataTable({
  res <- resultatsEvaluation()
  matconf <- res$matrice_confusion %>% as_tibble()
  matconf %>%
    datatable(rownames = F, options = list(searching=F, paging=F, info=F))
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$rapport <- renderText({
  res <- resultatsEvaluation()
  texte <- res$rapport
  texte
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$image_learningCurve <- renderImage({
  validate( need(input$activerProcedure_evaluation,'...') )
  
  dossier=paste0('src/',applisession())
  
  filename <- normalizePath(file.path(dossier, 'eval_learning_curve.png'))
  list(src = filename, alt = 'Learning curve', width='100%')
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








