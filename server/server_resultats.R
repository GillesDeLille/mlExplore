
# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiResultats <- renderUI({
  validate(
    need(!is.null(input$implementation), 'Choisir une implémentation pour le modèle choisi...')
  )
  
  mf    <- mdl()$mf
  temps <- mdl()$temps
  
  print('=================================')
  print(input$implementation)
  print(paste('Score            :',mf$score))
  print(paste('precision        :',mf$precision))
  print(paste('rappel           :',mf$rappel))
  print(paste('prediction.error :',mf$prediction.error))
  print('=================================')
  
  resultats <- list(
    column(12,h4(input$implementation)),
    column(12,h5(paste('Score               :',mf$score))),
    column(12,h5(paste('Précision           :',round(mf$precision*100,3),'%'))),
    column(12,h5(paste('Rappel              :',round(mf$rappel*100,3),'%'))),
    column(12,h5(paste('prediction.error    :',round(mf$prediction.error*100,3),'%'))),
    column(6,h6(temps[1])),column(5,h6(temps[2]))
  )
  
  list(
    h4(input$modele),
    box(
      width=6,
      column(12,h6(mf$modele)),
      resultats
    ),
    column(width = 6, height = 1, plotOutput('imageGain'))
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
mdl <- reactive({
  validate( need(!is.null(input$implementation),'Choisir une implémentation du modèle dans la section "Présentation des modèles"') )
  
  tic.clearlog()
  tic('total')
  tic('pretraitement')
  X_train <- data_preprocessed()$X_train
  y_train <- data_preprocessed()$y_train
  X_test  <- data_preprocessed()$X_test
  y_test  <- data_preprocessed()$y_test
  toc(log = T)
  
  if(str_detect(input$implementation,'scikitlearn')){
    target=input$target
    source_python(paste0('src_python/',input$implementation,'.py'))        # nom de la methode implémentée : skl_fit()
    source(paste0('src_R/scikitlearn/fit_',input$modele,'.R'), local = T)  # ==> mdl
  }
  if(langage()=='R'){
    target=regulariserNomsColonnes(input$target)
    Ajustement_TrainSet_uniquement=T
    if(Ajustement_TrainSet_uniquement){
      y=tibble(y=y_train)
      names(y)=target
      data=X_train %>% bind_cols(y)
    }else{
      data=data_preproc0()
      names(data)=regulariserNomsColonnes(names(data))
    }
    source(paste0('src_R/',input$implementation,'.R'), local = T)          # ==> mdl
  }
  
  toc(log = T)
  list(mf=mdl, temps=tic.log())
})
