
# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiModeles <- renderUI({
  impl=fread('implementations.csv')
  liste_modeles=impl$modele %>% unique()
  selectInput('modele','Modèles disponibles', choices = liste_modeles)
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiDescription <- renderUI({
  modele='RandomForest' ; if(!is.null(input$modele)) modele=input$modele
  list(
    setShadow(class = 'box'),
    column(2,br()), box(width=8, includeMarkdown(paste0('markdown/',modele,'.Rmd'))), column(2, br())
    # ,column(6,uiOutput('uiModeleValidite'))
  )
})
