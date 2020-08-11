

output$uiPresentation <- renderUI({
  impl=fread('implementations.csv')
  choix_implementations=impl[modele==input$modele]$implementation
  
  tabFit=NULL
  if(modeleOk()) tabFit=tabPanel(id='fit', title = 'Ajustement et résultats', uiOutput('uiResultats') )

  navbarPage(
    id = 'nav',
    title = input$modele,
    tabPanel(
      id='choixImplementation',
      title = "Choix de l'implémentation", 
      selectInput('implementation', 'Choix de l\'implémentation du modèle', choices =choix_implementations)
    ),
    tabFit
  )
})  

output$uiEditImplementation <- renderUI({
  validate( need(!is.null(input$nav),'...') )
  out <- NULL
  print(input$nav)
  if(input$nav=="Choix de l'implémentation"){
    ext='.py' ; if(langage()=='R') ext='.R'
    fileName <- paste0('src_',langage(),'/',input$implementation,ext)
    script=readChar(fileName, file.info(fileName)$size)
    out=aceEditor('editImplementation', script, mode=langage(), theme = 'ambiance')
  }
  out
})  
