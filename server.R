
if(F){
  fichier='churn.csv'
  cible='Churn?'
}

shinyServer(function(input, output, session) {
  
  # ----------------------------------------------------------------------------------------------------------------------------------------------------------
  
  datas <- reactive({
    source_python('pretraitement_rf.py')
    datas=prepare_datas(input$fichier,input$cible)
  })
  exemples <- reactive({
    # datas=datas()
    # exemples=list(
    #   data=datas[[1]] %>% as_tibble(),
    #   target=datas[[2]] %>% as_tibble()
    # )
    exemples=read.csv(paste0(pafdata,'exemples/',input$fichier), dec = ',') %>% as_tibble()
    exemples
  })
  
  res <- reactive({
    # py_run_file('pretraitement_rf.py')
    # py_run_file('randomForest.py')
    # list(mc=py$confusion, score=py$clfScore)
    
    # source('randomForest.R')
    source_python('randomForest.py')  # nom de la methode implémentée : "rf"    un nom générique comme "modele" sera peut être préférable !!!
    res=rf(datas())
    res=list(modele=res[[1]], confusion=res[[2]], score=res[[3]], y_test=res[[4]], y_probas=res[[5]])
    res
  })
  
  # ----------------------------------------------------------------------------------------------------------------------------------------------------------
  output$datas <- DT::renderDataTable({
    datatable(exemples(), options = list(searching=T, paging=T, pageLength=100, scrollY=130, scrollX=800, info=F), rownames=F, selection=c(mode='single'))
  })
  
  # output$plotGain <- renderPlot({
  #   res=rf()
  #   source_python('plotCumulativeGain.py')
  #   courbeGain(res$y_test, res$y_probas)
  # })
  
  
  output$imageGain <- renderImage({
    filename <- normalizePath(file.path('./figures', 'courbeGainCumulée.png'))
    list(src = filename, alt = 'Courbe de gain cumulée')
  }, deleteFile = FALSE)
  
  output$uiMod <- renderUI({
    res=res()
    list(
      DT::dataTableOutput('datas'),
      h5(input$modele),
      box(width=4,
        column(12,h6(res$modele)),
        column(12,h5(paste('Score :',res$score)))
      ),
      
      # img(src=normalizePath(file.path('./figures','courbeGainCumulée.png')), height='400px')
      box(width = 6, plotOutput('imageGain', height = 150))
      # ,plotOutput('plotGain')
    )
  })
  
 
})
