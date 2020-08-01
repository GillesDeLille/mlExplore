
# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiDummies <- renderUI({
  factors=donnees() %>% select_if(is.character) %>% names()
  sel=NULL ; if(length(setdiff(c("Int'l Plan", 'VMail Plan'),factors))==0){ sel=c("Int'l Plan", 'VMail Plan') }
  selectInput('dummies','Dummies',choices = factors, selected = sel, multiple = T)
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiTo_drop <- renderUI({
  colonnes=donnees() %>% names()
  sel=NULL ; if(length(setdiff(c('State', 'Area Code', 'Phone'),colonnes))==0){ sel=c('State', 'Area Code', 'Phone') }
  selectInput('to_drop','colonnes à retirer',choices = colonnes, selected = sel, multiple = T)
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiPreproc0 <- renderUI({
  # 1er prétraitement (basique)
  fileName <- 'src_python/preproc0.py'
  script=readChar(fileName, file.info(fileName)$size)
  ace <- aceEditor('editpreproc0', script, mode='python', theme = 'ambiance')
  activer <- NULL
  if((!is.null(input$to_drop))&(!is.null(input$dummies))){
    val=F
    factors=donnees() %>% select_if(is.character) %>% names()
    if(length(setdiff(c("Int'l Plan", 'VMail Plan'),factors))==0){ val=T }
    activer <- column(2,checkboxInput('okpreproc0','Activer', value = val))
  }
  
  liste <- list(
    column(6,uiOutput('uiDummies')), column(6,uiOutput('uiTo_drop')),
    column(10,ace),
    column(2,actionButton('save_script_preproc0','Enregistrer')),
    activer
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiPreprocessing <- renderUI({
  # preprocessing
  fileName <- 'src_python/preprocessing.py'
  script=readChar(fileName, file.info(fileName)$size)
  ace <- aceEditor('editPreprocessing', script, mode='python', theme = 'ambiance', maxLines = 18, autoScrollEditorIntoView=T)
  dev <- "<h5><i>Cette application est en développement."
  dev <- paste(dev,"Le preprocessing qui suit n'est disponible que pour une implémentation en Python du modèle choisi.</i></h5>")
  liste <- list(
    column(12,HTML(dev)),
    column(10,ace),
    column(2,actionButton('savePreprocessing','Enregistrer')),
    column(2,checkboxInput('okPreprocessing','Activer'))
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
data_preprocessed <- reactive({
  data=pyth_preprocessing()
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Preprocessing (python uniquement pour commencer)
pyth_preprocessing <- reactive({
  data <- data_preproc0() ; target <- input$target
  
  names(data)=regulariserNomsColonnes(names(data)) ; target=regulariserNomsColonnes(target)
  
  print('')
  print('=======  pyth_preprocessing  =======')
  print(target)
  print(data)
  print('')
  print('====================================')
  res <- NULL
  if(input$okPreprocessing){
    source_python(paste0('src/',applisession(),'/preprocessing.py'))
    res <- preprocessingSet(data, target)
  }
  print('')
  print("====================================")
  print("              res[[1]]")
  print(res[[1]])
  print('====================================')
  
  data_preprocessed <- NULL ; if(!is.null(res)) data_preprocessed <- list(X_train=res[[1]], y_train=res[[2]], X_test=res[[3]], y_test=res[[4]]) 
  data_preprocessed
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$target_value_counts_avant_preproc <- DT::renderDataTable({
  data=data_preproc0() ; target=input$target
  datatable(data %>% group_by(!!as.symbol(target)) %>% summarise(n=n()), options = list(paging=F, searching=F, info=F), rownames = F)
})  

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$dt_y_train <- DT::renderDataTable({
  y_train <- data_preprocessed()$y_train %>%
    as_tibble %>% 
    group_by(value) %>% summarise(n=n())
  colnames(y_train)<-c(input$target,'Nb')
  datatable(y_train, options = list(paging=F, searching=F, info=F), rownames = F)
})
output$dt_y_test <- DT::renderDataTable({
  y_test <- data_preprocessed()$y_test %>%
    as_tibble %>% 
    group_by(value) %>% summarise(n=n())
  colnames(y_test)<-c(input$target,'Nb')
  datatable(y_test, options = list(paging=F, searching=F, info=F), rownames = F)
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$target_value_counts_apres_preproc <- renderUI({
  liste=NULL
  if(!is.null(input$okPreprocessing)) if(input$okPreprocessing){
    y_test  <- data_preprocessed()$y_test %>% as_tibble
    liste=list(
      box(width = 5,
          h5('Train set'),
          dataTableOutput('dt_y_train')
      ),
      box(width = 5,
          h5('Test set'),
          dataTableOutput('dt_y_test')
      )
    )
  }
  liste
})

# --------------------------------------------------------------------------------
observe({
  # ------------------------
  input$save_script_preproc0
  script='' ; if(!is.null(isolate(input$editpreproc0))) script=isolate(input$editpreproc0)
  dossier <- paste0('src/',applisession())
  if(!dir.exists(dossier)) dir.create(dossier, recursive = T)
  writeLines(script,paste0(dossier,'/preproc0.py'))
  
  # ------------------------
  input$savePreprocessing
  script='' ; if(!is.null(isolate(input$editPreprocessing))) script=isolate(input$editPreprocessing)
  dossier <- paste0('src/',applisession())
  if(!dir.exists(dossier)) dir.create(dossier, recursive = T)
  writeLines(script,paste0(dossier,'/preprocessing.py'))
  
})

# --------------------------------------------------------------------------------
regulariserNomsColonnes <- function(noms){ str_replace_all(string = noms, pattern = " |'", replacement = '.') }

