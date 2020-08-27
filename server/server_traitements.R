
# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiEditImplementation <- renderUI({
  # validate( need(!is.null(input$nav),'...') )
  out <- NULL
  # print(input$nav)
  if(input$nav=="Choix d'une implémentation"){
    ext='.py' ; if(langage()=='R') ext='.R'
    fileName <- paste0('src_',langage(),'/',input$implementation,ext)
    script=readChar(fileName, file.info(fileName)$size)
    out=aceEditor('editImplementation', script, mode=langage(), theme = 'ambiance')
  }
  out
})  

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiImplementation <- renderUI({
  impl=fread('implementations.csv')
  choix_implementations=impl[modele==input$modele]$implementation
  
  list(
    selectInput('implementation', 'Choix de l\'implémentation du modèle', choices =choix_implementations),
    uiOutput('uiEditImplementation')
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiTraitements <- renderUI({
  navbarPage(
  id = 'nav',
  title = input$modele,
  tabPanel(id='preproc0', title = 'Init', uiOutput('uiPreproc0')),
  tabPanel(id='preprocessing', title = 'Preprocessing', uiOutput('uiPreprocessing')),
  tabPanel(id='donnees_pretraitees', title = 'Données prétraitées', uiOutput('uiDonnees_pretraitees')),
  tabPanel(id='choixImplementation', title = "Choix d'une implémentation", uiOutput('uiImplementation')),
  tabPanel(id='resultats', title = 'Résultats', uiOutput('uiResultats')),
  tabPanel(id='evaluation', title = 'Autre évaluation', uiOutput('uiEvaluation'))
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiDonnees_pretraitees <- renderUI({
  list(
    hr(),
    h5("Tirage de 15 lignes obtenues après le premier prétaitement"),
    box(width=12, DT::dataTableOutput('dtFeatures0')),
    br(),hr(),
    column(6,downloadButton('downLoad_X_train',label = "Tirage de 15 lignes obtenues après le préprocessing complet")),
    column(6,checkboxInput('ok_avec_y','Variable cible dans les données'))
  )  
})

