
# ---------------------------------------------------------------------------------------------------------------------------------------------------
# output$uiEvaluation <- renderUI({
  fileName <- 'src_python/procedure_evaluation.py'
  script=readChar(fileName, file.info(fileName)$size)
  ace <- aceEditor('editprocedure_avaluation', script, mode='python', theme = 'ambiance')
  liste <- list(
    column(10,ace)
  )      
# })


