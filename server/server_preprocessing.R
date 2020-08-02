
# ---------------------------------------------------------------------------------------------------------------------------------------------------
erreurPreprocessing <- reactiveVal()

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$editPreprocessing <- renderUI({
  input$annulerPreprocessing
  activer=isChurn() ; if(!is.null(input$okPreprocessing)) activer=input$okPreprocessing
  
  ed <- editeur(Objet='Preprocessing', langage='python', mxl=30, activer=activer, initScript=(is.null(input$okPreprocessing)))
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
  if(!is.null(input$okPreprocessing)) if(input$okPreprocessing){
    data_preprocessed <- data_preprocessed()
    if(!is.null(data_preprocessed)){
      y_test  <- data_preprocessed()$y_test %>% as_tibble
      liste=list(
        box(width = 3, dataTableOutput('dt_y_train')),
        box(width = 3, dataTableOutput('dt_y_test'))
      )
    }else{
      liste=list(
        h5('Le script python renvoie une erreur :'),
        h5(as.character(erreurPreprocessing()))
      )
    }
  }
  liste
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Preprocessing (python uniquement pour commencer)
pyth_preprocessing <- reactive({
  data <- data_preproc0() ; target <- input$target
  names(data)=regulariserNomsColonnes(names(data)) ; target=regulariserNomsColonnes(target)
  
  res <- NULL
  if(input$okPreprocessing){
    print('')
    print('===================================')
    print('preprocessing python...')
    
    sortie <- tryCatch(
      source_python(paste0('src/',applisession(),'/preprocessing.py')),
      error = function(e) e
    )
    erreurPreprocessing(sortie)
    if(!is.null(sortie)){
      print('=========  sortie anormale =========')
      print(sortie)
      print('====================================')
      return(NULL)
    }
    res <- preprocessingSet(data, target)
    print('terminé')
    print('=> X_train, y_train, X_test, y_test')
    print('===================================')
  }
  
  data_preprocessed <- NULL ; if(!is.null(res)) data_preprocessed <- list(X_train=res[[1]], y_train=res[[2]], X_test=res[[3]], y_test=res[[4]]) 
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
  initScript('Preprocessing','python')
})

observe({
  # sauver
  input$okPreprocessing
  script='' ; if(!is.null(isolate(input$editPreprocessing))) script=isolate(input$editPreprocessing)
  writeLines(script,paste0(dossier_src(),'/preprocessing.py'))
})


