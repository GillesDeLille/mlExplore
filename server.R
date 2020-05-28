
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
  modelesValides <- reactive({
    # Tous les modèles ne sont pas systématiquement applicables aux données (même prétraitées)
    # On s'attachera ici à donner la liste des modèles, parmis tous ceux implémentés, qui sont compatibles avec les données
    # // TO DO
    # // Définir les critères associés à chaque modèle
    # // Par exemple, pour randomForest les features et la target doivent toutes être numériques
    
    # Pour l'instant, on triche : randomForest fonctionne très bien avec l'exemple churn.csv
    mv=c('randomForest')
  })
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiModeles <- renderUI({
    impl=fread('implementations.csv')
    liste_modeles=impl$modele %>% unique()
    selectInput('modele','Modèle à appliquer', choices = liste_modeles)
  })
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  modeleOk <- reactive({
    input$modele %in% modelesValides()
  })
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiModeleValidite <- renderUI({
    if(modeleOk()){
      out=h5('Ce modèle est valide pour les données')
    }else{
      out=h5('Ce modèle est incompatible avec les données. Ces dernières sont peut-être mal préparées !')
    }
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
  output$dtFeatures <- DT::renderDataTable({
    
    # dplyr !!! je ne sais pas m'en passer...
    features=datas() %>% select(-input$target) %>% mutate_if(is.double, as.character)
    datatable(
      features, # caption = 'Features',
      options = list(searching=T, paging=T, pageLength=100, scrollY=100, scrollX=800, info=F),
      rownames=F, selection=c(mode='single')
    )
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  langage <- reactive({
    # implémentations acceptant les données sous forme d'un tableau contenant features et target
    pyth=c('scikitlearn/randomForest') 
    R=c('R/ranger')
    # D'autres suggestions ?
    
    if(input$implementation %in% pyth) langage='python'
    if(input$implementation %in% R) langage='R'
    langage
  })
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  datas <- reactive({
    validate( need(input$implementation!='','Choisir une implementation du modèle dans la section "Présentation des modèles" ') )
    
    if(langage()=='python') datas=pyth_datas()
    if(langage()=='R')      datas=r_datas()
    datas
  })
  
  # --------------------------------------------------------------------------------
  # Pretraitement des données par python
  # Renvoie un tableau contenant features et target
  pyth_datas <- reactive({
    fichier=paste0(input$dossier,'/',input$fichier)
    validate(
      need(!is.null(input$fichier), 'Choisir un fichier'),
      need(!is.null(input$target), 'Choisir une target'),
      need(file.exists(fichier), '...')
    )
    print('=====================================')
    print('Prétraitement des données avec pandas')
    print('=> liste (features, target)')
    print('=====================================')
    
    source_python('src_python/pretraitement.py')
    toDrop='' ; if(!is.null(input$to_drop)){ toDrop=input$to_drop }
    dummies='' ; if(!is.null(input$dummies)){ dummies=input$dummies }
    datas=prepare_datas(
      input$fichier,
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
  # Avec des noms de colonnes valides...
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
    
    mf    <- mdl()$mf
    temps <- mdl()$temps
    
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
  mdl <- reactive({
    validate( need(!is.null(input$implementation),'Choisir une implémentation du modèle dans la section "Présentation des modèles"') )
    
    tic.clearlog()
    tic('total')
    tic('pretraitement')
    features_target=datas()
    toc(log = T)
    
    if(str_detect(input$implementation,'scikitlearn')){
      target=input$target
      implementation=paste0('src_python/',input$implementation,'.py')
      source_python(implementation)  # nom de la methode implémentée : skl_fit()
      source(paste0('src_R/scikitlearn/fit_',input$modele,'.R'), local = T)  # ==> mdl
    }
    if(langage()=='R'){
      target=input$target
      source(paste0('src_R/',input$implementation,'.R'), local = T)          # ==> mdl
    }
    
    toc(log = T)
    list(mf=mdl, temps=tic.log())
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
    impl=fread('implementations.csv')
    choix_implementations=impl[modele==input$modele]$implementation
    
    tabFit=NULL
    if(modeleOk()){
      tabFit=tabPanel(id='fit', title = 'Ajustement et résultats',
                      uiOutput('uiResultats')
      )
    }
    navbarPage(
      id = 'nav',
      title = input$modele,
      tabPanel(
        id='presentation', title = 'Description',
        setShadow(class = 'box'),
        column(2,br()), box(width=8, includeMarkdown(paste0('markdown/',input$modele,'.Rmd'))), column(2, br()),
        column(6,uiOutput('uiModeleValidite'))
      ),
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
      
      # out=list(aceEditor('editImplementation', input$implementation, mode='r', theme = 'ambiance'))
      ext='.py' ; if(langage()=='R') ext='.R'
      fileName <- paste0('src_',langage(),'/',input$implementation,ext)
      print(fileName)
      script=readChar(fileName, file.info(fileName)$size)
      out=list(aceEditor('editImplementation', script, mode=langage(), theme = 'ambiance'))
    }
    out
  })  
  
})
