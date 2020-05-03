
if(F){ fichier='churn.csv' ; cible='Churn?' }

shinyServer(function(input, output, session) {
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  exemples <- reactive({ read.csv(paste0(pafdata,'exemples/',input$fichier), dec = ',') %>% as_tibble() })
  datas <- reactive({
    source_python('pretraitement_rf.py')
    datas=prepare_datas(input$fichier,input$cible)
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiMod <- renderUI({
    res=res()
    list(
      DT::dataTableOutput('datas'),
      h5(input$modele),
      box(width=4,
          column(12,h6(res$modele)),
          column(12,h5(paste('Score :',res$score)))
      ),
      column(width = 6, height = 1, plotOutput('imageGain'))
    )
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  res <- reactive({
    # py_run_file('pretraitement_rf.py') ; py_run_file('randomForest.py') ; list(mc=py$confusion, score=py$clfScore)
    # source('randomForest.R')
    source_python(paste0(input$modele,'.py'))  # nom de la methode implémentée : "rf"    un nom générique comme "modele" sera peut être préférable !!!
    res=rf(datas())
    res=list(modele=res[[1]], confusion=res[[2]], score=res[[3]], y_test=res[[4]], y_probas=res[[5]])
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$datas <- DT::renderDataTable({
    datatable(exemples(),
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
