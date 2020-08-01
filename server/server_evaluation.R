
# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiEvaluation <- renderUI({
  fileName <- 'src_python/procedure_evaluation.py'
  script=readChar(fileName, file.info(fileName)$size)
  ace <- aceEditor('editprocedure_avaluation', script, mode='python', theme = 'ambiance')
  liste <- list(
    column(10,ace)
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

