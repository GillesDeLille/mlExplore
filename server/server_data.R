
# ===================================================================================================================================================
# ===================================================================================================================================================

# ---------------------------------------------------------------------------------------------------------------------------------------------------
donnees <- reactive({
  fichier=paste0(input$dossier,'/',input$fichier)
  validate(
    need(!is.null(input$fichier), 'Choisir un fichier'),
    need(file.exists(fichier), '...')
  )
  fread(fichier)
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
data_preproc0 <- reactive({
  data=donnees()
  if(langage()=='python') data=pyth_preproc0()
  if(langage()=='R')      data=r_preproc0()
  data
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
data_preprocessed <- reactive({
  data=pyth_preprocessing()
})


# ===================================================================================================================================================
# ===================================================================================================================================================

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$donneesDisponibles <- DT::renderDataTable({
  donnees <- donnees()
  datatable(
    donnees, #caption = 'Données disponibles',
    options = list(searching=T, paging=T, pageLength=100, scrollY=430, scrollX=800, info=F),
    rownames=F, selection=c(mode='single')
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$dtFeatures0 <- DT::renderDataTable({
  features=data_preproc0() %>% select(-input$target) %>% sample_n(15)
  features <- features
  datatable(
    features,
    options = list(searching=T, paging=T, pageLength=100, scrollY=230, scrollX=800, info=F),
    rownames=F, selection=c(mode='single')
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$downLoad_X_train <- downloadHandler('X_train.csv', content = function(file) {
  if(input$ok_avec_y){
    data <- data_preprocessed()$X_train %>%
      bind_cols(data_preprocessed()$y_train) %>%
      sample_n(15)
    colnames(data)[ncol(data)] <- input$target
  }else{
    data <- data_preprocessed()$X_train %>% sample_n(15)
  }
  write.csv2(data, file, row.names = F, col.names=T)
})



