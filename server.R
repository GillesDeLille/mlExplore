
shinyServer(function(input, output, session) {
  
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
  output$uiDummies <- renderUI({
    factors=donnees() %>% Filter(f=is.character) %>% names()
    sel=NULL ; if(length(setdiff(c("Int'l Plan", 'VMail Plan'),factors))==0){ sel=c("Int'l Plan", 'VMail Plan') }
    selectInput('dummies','Dummies',choices = factors, selected = sel, multiple = T)
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiTo_drop <- renderUI({
    colonnes=donnees() %>% names()
    sel=NULL ; if(length(setdiff(c('State', 'Area Code', 'Phone'),colonnes))==0){ sel=c('State', 'Area Code', 'Phone') }
    selectInput('to_drop','colonnes à retirer',choices = colonnes, selected = sel, multiple = T)
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiModeles <- renderUI({
    selectInput('modele','Modèle', choices = c('randomForest'))
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  donnees <- reactive({
    # validate( need(!is.null(input$fichier), '...') )
    fichier=paste0(input$dossier,'/',input$fichier)
    validate(
      need(!is.null(input$fichier), 'Choisir un fichier'),
      need(file.exists(fichier), '...')
    )
      fread(fichier)
  })

  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$donneesDisponibles <- DT::renderDataTable({
    donnees <- donnees() %>% mutate_if(is.double, as.character)
    datatable(
      donnees, #caption = 'Données disponibles',
      options = list(searching=T, paging=T, pageLength=100, scrollY=130, scrollX=800, info=F),
      rownames=F, selection=c(mode='single')
    )
  })

  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$features <- DT::renderDataTable({
    
    # dplyr !!! je ne sais pas m'en passer...
    if(formatDonnees()=='liste_ft') features=datas()[[1]] %>% mutate_if(is.double, as.character)
    if(formatDonnees()=='tibble')  features=datas()       %>% select(-input$target) %>% mutate_if(is.double, as.character)
    datatable(
      features, # caption = 'Features',
      options = list(searching=T, paging=T, pageLength=100, scrollY=100, scrollX=800, info=F),
      rownames=F, selection=c(mode='single')
    )
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  formatDonnees <- reactive({
    # Pour laisser un maximum de champs libre aux différentes implémentations, 
    # on participe ici même au prétraitement des données
    
    # validate( need(!is.null(input$implementation),'Choisir une implementation du modèle dans la section "Présentation des modèles" ') )
    validate( need(input$implementation!='','Choisir une implementation du modèle dans la section "Présentation des modèles" ') )
    
    formatListe=c('scikitlearn/randomForest') # implémentation acceptant les données sous forme de liste (features, target)
    formatTibble=c('R/ranger')  # implémentation acceptant les données sous forme d'un tibble en entrée
    # D'autres suggestions ?

    if(input$implementation %in% formatListe) formatDonnees='liste_ft'
    if(input$implementation %in% formatTibble) formatDonnees='tibble'
    formatDonnees
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  datas <- reactive({
    if(formatDonnees()=='liste_ft') datas=pyth_datas()   # Le langage choisi ici
    if(formatDonnees()=='tibble')   datas=r_datas()      # importe peu...
    datas
  })
  
  # --------------------------------------------------------------------------------
  # Pretraitement des données par python
  # Renvoie une liste (features, target)
  pyth_datas <- reactive({
    fichier=paste0(input$dossier,'/',input$fichier)
    validate(
      need(!is.null(input$fichier), 'Choisir un fichier'),
      need(!is.null(input$target), 'Choisir une target'),
      need(file.exists(fichier), '...')
    )
    print('====================================')
    print('Prétraitement des données avec panda')
    print('=> liste (features, target)')
    print('====================================')
    
    source_python('src_python/pretraitement.py')
    toDrop='' ; if(!is.null(input$to_drop)){ toDrop=input$to_drop }
    dummies='' ; if(!is.null(input$dummies)){ dummies=input$dummies }
    datas=prepare_datas(
      input$fichier,
      input$target,
      dummies=dummies,
      to_drop=toDrop,
      pafexemples=paste0(input$dossier,'/')
    )
  })
  
  
  # --------------------------------------------------------------------------------
  regulariserNomsColonnes <- function(noms){
    str_replace_all(string = noms, pattern = " |'", replacement = '.')
  }
  
  # --------------------------------------------------------------------------------
  # Pretraitement des données par R (je m'applique ici à fournir les données au bon format pour ranger)
  # Renvoie un tibble contenant features et target
  # Avec un bon format pour les noms de colonnes
  r_datas <- reactive({
    validate( need(!is.null(input$target), 'Choisir une target') )
    
    print('====================================')
    print('Prétraitement des données avec dplyr')
    print('=> tibble (features, target)')
    print('====================================')
    if(!is.null(input$infile)){
      donnees=fread(input$infile$datapath, drop = input$to_drop, stringsAsFactors = T)
    }else{
      donnees=fread(paste0(input$dossier,'/',input$fichier), drop = input$to_drop, stringsAsFactors = T)
    }
    names(donnees)=regulariserNomsColonnes(names(donnees))
    if(!is.null(input$dummies)) donnees <- one_hot(donnees, input$dummies %>% regulariserNomsColonnes())
    donnees
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiResultats <- renderUI({
    validate(
      need(!is.null(input$implementation), 'Choisir une implémentation pour le modèle choisi...')
    )
    
    mf    <- modeleFitted()$mf
    temps <- modeleFitted()$temps
    
    print('=================================')
    print(input$implementation)
    print(paste('Score            :',mf$score))
    print(paste('precision        :',mf$precision))
    print(paste('rappel           :',mf$rappel))
    print(paste('prediction.error :',mf$prediction.error))
    print('=================================')
    
    resultats <- list(
      column(12,h4(input$implementation)),
      column(12,h5(paste('Score               :',mf$score))),
      column(12,h5(paste('Précision           :',round(mf$precision*100,3),'%'))),
      column(12,h5(paste('Rappel              :',round(mf$rappel*100,3),'%'))),
      column(12,h5(paste('prediction.error    :',round(mf$prediction.error*100,3),'%'))),
      column(6,h6(temps[1])),column(5,h6(temps[2]))
    )

    list(
      h4(input$modele),
      box(
        width=6,
        column(12,h6(mf$modele)),
        resultats
      ),
      column(width = 6, height = 1, plotOutput('imageGain'))
    )
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  modeleFitted <- reactive({
    validate( need(!is.null(input$implementation),'Choisir une implémentation du modèle dans la section "Présentation des modèles"') )
    
    if(str_detect(input$implementation, 'scikitlearn')){
      source_python(paste0('src_python/',input$modele,'.py'))  # nom de la methode implémentée : skl()
    }
    
    tic.clearlog()
    tic('total')
    tic('pretraitement')
    datas=datas()
    toc(log = T)
    
    if(str_detect(input$implementation,'scikitlearn')){
      modeleFitted=skl(datas)
      # On appréciera que les prochaines implémentations suivent l'exemple de cette sortie,
      # pour faciliter l'intégration des résultats complets dans la section ...résultats
      modeleFitted=list(
        modele      = modeleFitted[[1]], 
        confusion   = modeleFitted[[2]], 
        score       = modeleFitted[[3]], 
        y_test      = modeleFitted[[4]], 
        y_probas    = modeleFitted[[5]], 
        precision   = modeleFitted[[6]], 
        rappel      = modeleFitted[[7]]
      )
    }
    if(input$implementation=='R/ranger'){
      data=datas()
      require(ranger)
      modeleFitted <- ranger(as.formula(paste(input$target,'~ .')), data=data)
      # //
      # TO DO
      # "ranger" un maximum de résultats sous la même forme que pour la sortie de skl (avez-vous vu le jeu de mot ?)
      # //
    }

    toc(log = T)
    list(mf=modeleFitted, temps=tic.log())
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  courbeGain <- reactive({
    listeModeles=c('randomForest')
    courbeOk <- ((input$implementation=='scikitlearn/randomForest')&(input$modele %in% listeModeles))
  })
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$imageGain <- renderImage({
    validate( need(courbeGain(),'Courbe de gain cumulée à construire selon contexte') )
    
    filename <- normalizePath(file.path('./figures', 'courbeGainCumulée.png'))
    list(src = filename, alt = 'Courbe de gain cumulée', height='250px')
  }, deleteFile = FALSE)
 
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiPresentation <- renderUI({

    if(input$modele=='randomForest'){
      choix_implementations=c('','scikitlearn/randomForest','R/ranger')
      # d'autres suggestions ?
    }
    
    list(
      # h4(input$modele),
      setShadow(class = 'box'),
      column(2,br()), box(width=8, includeMarkdown(paste0('markdown/',input$modele,'.Rmd'))), column(2,br()),
      box(width=8, 
        h4('Implémentation'),
        selectInput('implementation', 'Choix de l\'implémentation du modèle', choices =choix_implementations)
      )
      
    )
  })  
  
  
})
