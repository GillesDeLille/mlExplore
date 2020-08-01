
shinyServer(function(input, output, session) {
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  applisession <- reactive({
    validate( need(!is.null(input$modele), '...') )
    paste0(input$dossier,'/',input$fichier,'/',input$modele)
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  langage <- reactive({
    # implémentations acceptant les données sous forme d'un tableau contenant features et target
    pyth=c('scikitlearn/randomForest') 
    R=c('R/ranger')
    # D'autres suggestions ?

    langage='python'  # Par défaut, on prendra Python pour le preprocessing notamment
    if(!is.null(input$implementation)){
      if(input$implementation %in% pyth) langage='python'
      if(input$implementation %in% R) langage='R'
    }
    langage
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  # Le script server.R est découpé en plusieurs fichiers thématiques. Ils sont visibles dans le dossier : controllers
  for (file in list.files("server")) {
    source(file.path("server", file), local = TRUE)
  }
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
})
