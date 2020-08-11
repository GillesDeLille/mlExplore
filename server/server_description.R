
output$uiDescription <- renderUI({
  list(
    setShadow(class = 'box'),
    column(2,br()), box(width=8, includeMarkdown(paste0('markdown/',input$modele,'.Rmd'))), column(2, br())
    # ,column(6,uiOutput('uiModeleValidite'))
  )
})
