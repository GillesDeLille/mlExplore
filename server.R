
shinyServer(function(input, output, session) {
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  # exemples <- reactive({ read.csv(paste0(pafdata,'exemples/',input$fichier), dec = ',') %>% as_tibble() })
  exemples <- reactive({ read_csv(paste0(pafdata,'exemples/',input$fichier), locale=locale(decimal_mark = ',', grouping_mark = ' ')) })
  # exemples <- reactive({
  #   xy=read.csv(paste0(pafdata,'exemples/',input$fichier), dec = ',') %>% as_tibble()
  #   noms=read_csv(paste0(pafdata,'exemples/',input$fichier)) %>% names()
  #   colnames(xy)=noms
  #   # save(xy, file='~/xy.rdata') ; load('~/xy.rdata') ; xy
  #   xy
  # })
  datas <- reactive({
    print(input$dummies)
    source_python('pretraitement.py')
    datas=prepare_datas(input$fichier,input$cible,
                        # dummies=c("Int'l Plan", 'VMail Plan'),
                        # to_drop=c('State', 'Area Code', 'Phone')
                        dummies=input$dummies,
                        prefixes=c('international', 'voicemail'),
                        to_drop=input$to_drop
    )
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiDummies <- renderUI({
    # factors=exemples() %>% Filter(f=is.factor) %>% names()
    factors=exemples() %>% Filter(f=is.character) %>% names()
    selectInput('dummies','Dummies',choices = factors, multiple = T)
  })
  
 # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiTo_drop <- renderUI({
    # factors=exemples() %>% Filter(f=is.factor) %>% names()
    colonnes=exemples() %>% names()
    selectInput('to_drop','colonnes à retirer',choices = colonnes, multiple = T)
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiMod <- renderUI({
    res=res()
    list(
      DT::dataTableOutput('datas'),
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
    # py_run_file('pretraitement_rf.py') ; py_run_file('randomForest.py') ; list(mc=py$confusion, score=py$clfScore)
    # source('randomForest.R')
    source_python(paste0(input$modele,'.py'))  # nom de la methode implémentée : "rf"    un nom générique comme "modele" sera peut être préférable !!!
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
  output$datas <- DT::renderDataTable({
    datatable(exemples(),
    # features=datas()[[1]]
    # # colnames(features)=tolower(colnames(features))
    # features=features[,3:5]
    # # save(features,file='~/features.rdata') ; load('~/features.rdata') ; features %>% as_tibble()
    # datatable(features,
              options = list(searching=T, paging=T, pageLength=100, scrollY=130, scrollX=800, info=F),
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
      # includeMarkdown('ml_fiche1.Rmd')
    )
  })  
  
  
})
