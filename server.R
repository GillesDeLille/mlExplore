
shinyServer(function(input, output, session) {
  
  # ------------------ App virtualenv setup  ------------------- #
  
  pf = Sys.getenv('shinyapps_io')
  if(pf=='oui'){
    virtualenv_dir = Sys.getenv('VIRTUALENV_NAME')
    python_path = Sys.getenv('PYTHON_PATH')
    
    # Create virtual env and install dependencies
    reticulate::virtualenv_create(envname = virtualenv_dir, python = python_path)
    reticulate::virtualenv_install(virtualenv_dir, packages = PYTHON_DEPENDENCIES)
    reticulate::use_virtualenv(virtualenv_dir, required = T)
  }

  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  applisession <- reactive({
    # Renvoie une proposition de nom de dossier pour stocker les scripts mis au point par l'utilisateur.
    # !!! Attention, l'utilisateur devra encore gérer manuellement le stockage de ce dossier
    # à la fin de sa session (une nouvelle session écrase le dossier)
    validate( need(!is.null(input$modele), '...') )
    paste0(input$dossier,'/',input$fichier,'/',input$modele)
  })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  dossier_src <- reactive({ dossier_src <- paste0('src/',applisession()) })
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  isChurn <- reactive({
    # Renvoie vrai si le jeu de données étudié est celui donné en exemple et dont la cible est Churn.
    # Utile pour certain choix par défaut
    val=F
    factors=donnees() %>% select_if(is.character) %>% names()
    if(length(setdiff(c("Int'l Plan", 'VMail Plan'),factors))==0) val=T
    val
  })
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  langage <- reactive({
    # Renvoie le langage (R ou Python) correspondant au choix de l'implémentation que l'utilisateur choisi pour le modèle.
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
  # Génère un éditeur (input$edit[objet]) avec
  #  - un bouton pour la sauvegarde,
  #  - un bouton d'activation,
  editeur<-function(Objet, langage, mxl, activer=NULL, initScript=F){

    if(initScript) initScript(Objet, langage)
    
    file_name=paste0('src_',langage,'/',tolower(Objet),'.py')
    script_name=paste0(dossier_src(),'/',tolower(Objet),'.py')

    script=readChar(script_name, file.info(script_name)$size)
    
    ace <- aceEditor(paste0('edit',Objet), script, mode=langage, theme = 'ambiance', maxLines = mxl, autoScrollEditorIntoView=T)
    liste <- list(
      column(10,ace),
      column(2,checkboxInput(paste0('activer',Objet),'Activer', value=activer)),
      column(2,actionButton(paste0('annuler',Objet),'Annuler changements'))
    )
  }
  
  initScript <- function(Objet, langage){
    file_name=paste0('src_',langage,'/',tolower(Objet),'.py')
    script_name=paste0(dossier_src(),'/',tolower(Objet),'.py')
    # print('============================================')
    # print(paste('Init :', file_name, '==>', script_name))
    if(!dir.exists(dossier_src())) dir.create(dossier_src(), recursive = T)
    file.copy(file_name,script_name, overwrite = T)
  }

  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  erreurScript <- reactiveVal()
  
  # --------------------------------------------------------------------------------
  executer<-function(script){
    ext=unlist(strsplit(script,'[.]'))[2]
    python <- ext=='py'
    if(python){
      print('============================================')
      print(paste('Exécution du script : ', script, '...'))
      erreurScript(NULL)
      res <- tryCatch(
        source_python(paste0('src/', applisession(),'/', script)),
        error = function(e){e ; erreurScript(e) }
      )
      print('============================================')
    }
    res
  }
  
  # --------------------------------------------------------------------------------
  regulariserNomsColonnes <- function(noms){ str_replace_all(string = noms, pattern = " |'", replacement = '.') }
  
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  # Le script server.R est découpé en plusieurs fichiers thématiques. Ils sont visibles dans le dossier : controllers
  for (file in list.files("server")) {
    source(file.path("server", file), local = TRUE)
  }
  # ---------------------------------------------------------------------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------------------------------------------------------------------

})
