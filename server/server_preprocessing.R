
# ---------------------------------------------------------------------------------------------------------------------------------------------------
erreurPreprocessing <- reactiveVal()

# ---------------------------------------------------------------------------------------------------------------------------------------------------
affichage_erreurPreprocessing <- reactive({
  list(
    h5('Le script python renvoie une erreur :'),
    h5(as.character(erreurPreprocessing()))
  )
})
# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$editPreprocessing <- renderUI({
  # input$validerPreprocessing
  input$annulerPreprocessing
  validerPreprocessing=NULL ; if(!is.null(isolate(input$activerPreprocessing))){ validerPreprocessing=isolate(input$activerPreprocessing) }
  activer=isChurn() ; if(!is.null(validerPreprocessing)) activer=validerPreprocessing
  
  ed <- editeur(Objet='Preprocessing', langage='python', mxl=30, activer=activer, initScript=(is.null(validerPreprocessing)))
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiPreprocessing <- renderUI({
  dev <- "<h5><i>Cette application est en développement."
  dev <- paste(dev,"Le preprocessing qui suit n'est implémenté qu'en Python.</i></h5>")
  
  list(
    box(width=3, DT::dataTableOutput('counts_avant')),
    column(3, img(src='engrenages_preprocessing.png', width='100%')),
    uiOutput('counts_apres'),
    column(12,HTML(dev)),
    uiOutput('editPreprocessing')
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$counts_apres <- renderUI({
  liste=NULL
  if(!is.null(input$activerPreprocessing)) if(input$activerPreprocessing){
    data_preprocessed <- data_preprocessed()
    if(!is.null(data_preprocessed)){
      y_test  <- data_preprocessed()$y_test %>% as_tibble
      liste=list(
        box(width = 3, dataTableOutput('dt_y_train')),
        box(width = 3, dataTableOutput('dt_y_test'))
      )
    }else{
      liste <- affichage_erreurPreprocessing()
    }
  }
  liste
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Preprocessing (python uniquement pour commencer)
pyth_preprocessing <- reactive({
  data <- data_preproc0() ; target <- input$target
  names(data)=regulariserNomsColonnes(names(data)) ; target=regulariserNomsColonnes(target)
  
  data_preprocessed <- NULL
  if(input$activerPreprocessing){
    print('')
    print('===================================')
    print('preprocessing python...')
    
    # -----------------------
    # 1er passage sous python
    erreurPreprocessing(NULL)
    tryCatch(
      source_python(paste0('src/',applisession(),'/preprocessing.py')),
      error = function(e){e ; erreurPreprocessing(e) }
    )
    if(!is.null(erreurPreprocessing())) return(NULL)
  
    # ------------------------
    # 2eme passage sous python
    erreurPreprocessing(NULL)
    tryCatch(
      res <- preprocessingSet(data, target),
      error = function(e){e ; erreurPreprocessing(e) }
    )
    # erreurPreprocessing(sortie)
    if(!is.null(erreurPreprocessing())) return(NULL)

    # -----    
    # ouf !
    print('terminé')
    print('=> X_train, y_train, X_test, y_test')
    print('===================================')
    data_preprocessed <- list(X_train=res[[1]], y_train=res[[2]], X_test=res[[3]], y_test=res[[4]])
  }
  
  data_preprocessed
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$counts_avant <- DT::renderDataTable({
  target=input$target ; data=data_preproc0() %>% group_by(!!as.symbol(target)) %>% summarise(n=n())
  datatable(data, caption = 'Data set' , options = list(paging=F, searching=F, info=F), rownames = F)
})  

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$dt_y_train <- DT::renderDataTable({
  y_train <- data_preprocessed()$y_train %>% as_tibble %>% group_by(value) %>% summarise(n=n()) ; colnames(y_train)<-c(input$target,'Nb')
  datatable(y_train, caption = 'Train set', options = list(paging=F, searching=F, info=F), rownames = F)
})
output$dt_y_test <- DT::renderDataTable({
  y_test <- data_preprocessed()$y_test %>% as_tibble %>% group_by(value) %>% summarise(n=n()) ; colnames(y_test)<-c(input$target,'Nb')
  datatable(y_test, caption = 'Test set', options = list(paging=F, searching=F, info=F), rownames = F)
})

# --------------------------------------------------------------------------------
observe({
  # # annuler tous les changements opérés sur le script
  input$annulerPreprocessing
  # on demandera confirmation !!!
    initScript('Preprocessing','python')
})

observe({
  # sauver
  input$activerPreprocessing
    script='' ; if(!is.null(isolate(input$editPreprocessing))) script=isolate(input$editPreprocessing)
    writeLines(script,paste0(dossier_src(),'/preprocessing.py'))
})

observe({
  # # des modifs sont observées dans le script ? => désactiver
  input$editPreprocessing
  updateCheckboxInput(session, 'activerPreprocessing',  value = F)
})

