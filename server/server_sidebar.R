
# ---------------------------------------------------------------------------------------------------------------------------------------------------
observe({
  if(!is.null(input$infile)){
    data=fread(input$infile$datapath)
    fwrite(data, file=paste0(pafdata,'/',input$infile$name))
    updateSelectInput(session,'dossier', selected = 'data')
    updateSelectInput(session,'target', selected = NULL)
    updateSelectInput(session,'implementation', selected = NULL)
  }
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
observe({
  input$fichier
  updateSelectInput(session,'target', selected = NULL)
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiFichiers <- renderUI({
  choix=dir(input$dossier)
  selectInput('fichier','Fichier de données', choices = choix, selected = input$fichier)
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiTarget <- renderUI({
  colonnes=donnees() %>% names()
  sel=NULL ; if('Churn' %in% colonnes){ sel='Churn' }
  selectInput('target', 'Target', choices = colonnes, selected = sel)
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiModeles <- renderUI({
  impl=fread('implementations.csv')
  liste_modeles=impl$modele %>% unique()
  selectInput('modele','Modèle à appliquer', choices = liste_modeles)
})
