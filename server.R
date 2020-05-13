
shinyServer(function(input, output, session) {
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiFichiers <- renderUI({
    choix=dir(input$dossier)
    selectInput('fichier','Fichier de données', choices = choix)
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiTarget <- renderUI({
    sel=NULL ; if('Churn' %in% colonnes()){ sel='Churn' }
    selectInput('target', 'Target', choices = colonnes(), selected = sel)
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiDummies <- renderUI({
    # factors=exemples() %>% Filter(f=is.factor) %>% names()
    factors=donnees() %>% Filter(f=is.character) %>% names()
    sel=NULL ; if(length(setdiff(c("Int'l Plan", 'VMail Plan'),factors))==0){ sel=c("Int'l Plan", 'VMail Plan') }
    selectInput('dummies','Dummies',choices = factors, selected = sel, multiple = T)
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiTo_drop <- renderUI({
    sel=NULL ; if(length(setdiff(c('State', 'Area Code', 'Phone'),colonnes()))==0){ sel=c('State', 'Area Code', 'Phone') }
    selectInput('to_drop','colonnes à retirer',choices = colonnes(), selected = sel, multiple = T)
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiModeles <- renderUI({
    selectInput('modele','Modèle', choices = c('randomForest'))
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  donnees <- reactive({
    validate( need(!is.null(input$fichier), 'Choisir un fichier') )
    read_csv(paste0(input$dossier,'/',input$fichier), locale=locale(decimal_mark = ',', grouping_mark = ' '))
  })

  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  colonnes <- reactive({ colonnes=donnees() %>% names() })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiDonnees <- renderUI({
    list(
      box(width=12,DT::dataTableOutput('donneesDisponibles')),
      box(width=12,DT::dataTableOutput('features'))
    )
  })
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$donneesDisponibles <- DT::renderDataTable({
    datatable(
      donnees(), caption = 'Données disponibles',
      options = list(searching=T, paging=T, pageLength=100, scrollY=130, scrollX=800, info=F),
      rownames=F, selection=c(mode='single')
    )
  })
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  datas <- reactive({
    validate(
      need(!is.null(input$fichier), 'Choisir un fichier'),
      need(!is.null(input$target), 'Choisir une target')
    )
    source_python('src_python/pretraitement.py')
    toDrop='' ; if(!is.null(input$to_drop)){ toDrop=input$to_drop }
    dummies='' ; if(!is.null(input$dummies)){ dummies=input$dummies }
    datas=prepare_datas(
      input$fichier,input$target,
      dummies=dummies,
      to_drop=toDrop,
      pafexemples=paste0(input$dossier,'/')
    )
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiMod <- renderUI({
    res=res()
    list(
      h4(input$modele),
      box(width=5,
          column(12,h6(res$modele)),
          column(12,h5(paste('Score     :',res$score))),
          column(12,h5(paste('Précision :',round(res$precision*100,3),'%'))),
          column(12,h5(paste('Rappel    :',round(res$rappel*100,3),'%')))
      ),
      column(width = 6, height = 1, plotOutput('imageGain'))
    )
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  res <- reactive({
    source_python(paste0('src_python/',input$modele,'.py'))  # nom de la methode implémentée : "rf"    un nom générique comme "modele" sera peut être préférable !!!
    tic('total')
    tic('pretraitement')
    datas=datas()
    toc()
    res=rf(datas)
    res=list(modele=res[[1]], confusion=res[[2]], score=res[[3]], y_test=res[[4]], y_probas=res[[5]], precision=res[[6]], rappel=res[[7]])
    toc()
    res
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$features <- DT::renderDataTable({
    features=datas()[[1]] %>% mutate_if(is.double, as.character)
    datatable(
      features, caption = 'Features',
      options = list(searching=T, paging=T, pageLength=100, scrollY=100, scrollX=800, info=F),
      rownames=F, selection=c(mode='single')
    )
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$imageGain <- renderImage({
    filename <- normalizePath(file.path('./figures', 'courbeGainCumulée.png'))
    list(src = filename, alt = 'Courbe de gain cumulée', height='250px')
  }, deleteFile = FALSE)
 
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiPresentation <- renderUI({
    list(
      h4(input$modele)
      # includeMarkdown(paste0(input$modele,'.Rmd'))
    )
  })  
  
  
})
