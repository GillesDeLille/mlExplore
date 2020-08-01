
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
    factors=donnees() %>% select_if(is.character) %>% names()
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
      options = list(searching=T, paging=T, pageLength=100, scrollY=430, scrollX=800, info=F),
      rownames=F, selection=c(mode='single')
    )
  })

  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$dtFeatures <- DT::renderDataTable({
    
    # dplyr !!! je ne sais pas m'en passer...
    features=data_preproc0() %>% select(-input$target) %>% mutate_if(is.double, as.character)
    datatable(
      features, # caption = 'Features',
      options = list(searching=T, paging=T, pageLength=100, scrollY=230, scrollX=800, info=F),
      rownames=F, selection=c(mode='single')
    )
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
  data_preproc0 <- reactive({
    data=donnees()
    if(langage()=='python') data=pyth_preproc0()
    if(langage()=='R')      data=r_preproc0()
    data
  })
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  data_preprocessed <- reactive({
    data=pyth_preprocessing()
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  # 1er Pretraitement des données par python
  # Renvoie un tableau contenant features et target
  pyth_preproc0 <- reactive({
    data=donnees()
    print('=====================================')
    print('Prétraitement des données avec pandas')
    print('=> liste (features, target)')
    print('=====================================')
    # ----------------------------------------------------------------------------------------------------------------    
    # 1er Pretraitement - basique : choix dans l'interface des variables indicatrices (dummies) et de celles à retirer
    if(!is.null(input$okpreproc0)) if(input$okpreproc0){
      source_python('src_python/util.py')
      source_python(paste0('src/',applisession(),'/preproc0.py'))
      print('!!! toto !!!')
      toDrop='' ; if(!is.null(input$to_drop)){ toDrop=input$to_drop }
      dummies='' ; if(!is.null(input$dummies)){ dummies=input$dummies }
      data=prepare_data(
        input$fichier,
        dummies=dummies,
        to_drop=toDrop,
        pafexemples=paste0(input$dossier,'/')
      )
    }
    
    print('============')
    print(head(data))
    data
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  # Preprocessing (python uniquement pour commencer)
  pyth_preprocessing <- reactive({
    data <- data_preproc0() ; target <- input$target
    
    names(data)=regulariserNomsColonnes(names(data)) ; target=regulariserNomsColonnes(target)
    
    print('')
    print('=======  pyth_preprocessing  =======')
    print(target)
    print(data)
    print('')
    print('====================================')
    res <- NULL
    if(input$okPreprocessing){
      source_python(paste0('src/',applisession(),'/preprocessing.py'))
      res <- preprocessingSet(data, target)
    }
    print('')
    print("====================================")
    print("              res[[1]]")
    print(res[[1]])
    print('====================================')
    
    data_preprocessed <- NULL ; if(!is.null(res)) data_preprocessed <- list(X_train=res[[1]], y_train=res[[2]], X_test=res[[3]], y_test=res[[4]]) 
    data_preprocessed
  })
  
  # --------------------------------------------------------------------------------
  regulariserNomsColonnes <- function(noms){ str_replace_all(string = noms, pattern = " |'", replacement = '.') }
  
  # --------------------------------------------------------------------------------
  # Pretraitement des données par R (je m'applique ici à fournir les données au bon format pour ranger)
  # Renvoie un tibble contenant features et target
  # Avec des noms de colonnes valides...
  r_preproc0 <- reactive({
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
  
  # # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiEvaluation <- renderUI({
    source('evaluation.R')
    liste
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
    X_train <- data_preprocessed()$X_train
    y_train <- data_preprocessed()$y_train
    X_test  <- data_preprocessed()$X_test
    y_test  <- data_preprocessed()$y_test
    toc(log = T)
    
    if(str_detect(input$implementation,'scikitlearn')){
      target=input$target
      source_python(paste0('src_python/',input$implementation,'.py'))        # nom de la methode implémentée : skl_fit()
      source(paste0('src_R/scikitlearn/fit_',input$modele,'.R'), local = T)  # ==> mdl
    }
    if(langage()=='R'){
      data=data_preproc0()
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
      ext='.py' ; if(langage()=='R') ext='.R'
      fileName <- paste0('src_',langage(),'/',input$implementation,ext)
      script=readChar(fileName, file.info(fileName)$size)
      out=aceEditor('editImplementation', script, mode=langage(), theme = 'ambiance')
    }
    out
  })  

  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiPreproc0 <- renderUI({
    # 1er prétraitement (basique)
    fileName <- 'src_python/preproc0.py'
    script=readChar(fileName, file.info(fileName)$size)
    ace <- aceEditor('editpreproc0', script, mode='python', theme = 'ambiance')
    activer <- NULL
    if((!is.null(input$to_drop))&(!is.null(input$dummies))) activer <- column(2,checkboxInput('okpreproc0','Activer'))

    liste <- list(
      column(6,uiOutput('uiDummies')), column(6,uiOutput('uiTo_drop')),
      column(10,ace),
      column(2,actionButton('save_script_preproc0','Enregistrer')),
      activer
    )
  })
  
  output$target_value_counts_avant_preproc <- DT::renderDataTable({
    data=data_preproc0() ; target=input$target
    datatable(data %>% group_by(!!as.symbol(target)) %>% summarise(n=n()), options = list(paging=F, searching=F, info=F), rownames = F)
  })  
  output$dt_y_train <- DT::renderDataTable({
    y_train <- data_preprocessed()$y_train %>%
      as_tibble %>% 
      group_by(value) %>% summarise(n=n())
    colnames(y_train)<-c(input$target,'Nb')
    datatable(y_train, options = list(paging=F, searching=F, info=F), rownames = F)
  })
  output$dt_y_test <- DT::renderDataTable({
    y_test <- data_preprocessed()$y_test %>%
      as_tibble %>% 
      group_by(value) %>% summarise(n=n())
    colnames(y_test)<-c(input$target,'Nb')
    datatable(y_test, options = list(paging=F, searching=F, info=F), rownames = F)
  })
  output$target_value_counts_apres_preproc <- renderUI({
    liste=NULL
    if(!is.null(input$okPreprocessing)) if(input$okPreprocessing){
      y_test  <- data_preprocessed()$y_test %>% as_tibble
      liste=list(
        box(width = 5,
            h5('Train set'),
            dataTableOutput('dt_y_train')
        ),
        box(width = 5,
            h5('Test set'),
            dataTableOutput('dt_y_test')
        )
      )
    }
    liste
  })  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  output$uiPreprocessing <- renderUI({
    # preprocessing
    fileName <- 'src_python/preprocessing.py'
    script=readChar(fileName, file.info(fileName)$size)
    ace <- aceEditor('editPreprocessing', script, mode='python', theme = 'ambiance', maxLines = 18, autoScrollEditorIntoView=T)
    dev <- "<h5><i>Cette application est en développement."
    dev <- paste(dev,"Le preprocessing qui suit n'est disponible que pour une implémentation en Python du modèle choisi.</i></h5>")
    liste <- list(
      column(12,HTML(dev)),
      column(10,ace),
      column(2,actionButton('savePreprocessing','Enregistrer')),
      column(2,checkboxInput('okPreprocessing','Activer'))
    )
  })

  observe({
    # ------------------------------------
    input$save_script_preproc0
    script='' ; if(!is.null(isolate(input$editpreproc0))) script=isolate(input$editpreproc0)
    dossier <- paste0('src/',applisession())
    if(!dir.exists(dossier)) dir.create(dossier, recursive = T)
    writeLines(script,paste0(dossier,'/preproc0.py'))

    # ------------------------------------
    input$savePreprocessing
    script='' ; if(!is.null(isolate(input$editPreprocessing))) script=isolate(input$editPreprocessing)
    dossier <- paste0('src/',applisession())
    if(!dir.exists(dossier)) dir.create(dossier, recursive = T)
    writeLines(script,paste0(dossier,'/preprocessing.py'))
    
  })
  
  applisession <- reactive({
    validate( need(!is.null(input$modele), '...') )
    paste0(input$dossier,'/',input$fichier,'/',input$modele)
  })
})
