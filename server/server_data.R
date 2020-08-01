

# ---------------------------------------------------------------------------------------------------------------------------------------------------
donnees <- reactive({
  fichier=paste0(input$dossier,'/',input$fichier)
  validate(
    need(!is.null(input$fichier), 'Choisir un fichier'),
    need(file.exists(fichier), '...')
  )
  fread(fichier)
})
