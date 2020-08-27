
# ===========================
# 1er prétraitement (basique)
# ===========================

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$uiPreproc0 <- renderUI({
  factors=donnees() %>% select_if(is.character) %>% names()
  sel=NULL ; if(length(setdiff(c("Int'l Plan", 'VMail Plan'),factors))==0){ sel=c("Int'l Plan", 'VMail Plan') }
  uiDummies <- selectInput('dummies','Dummies',choices = factors, selected = sel, multiple = T)
  
  colonnes=donnees() %>% names()
  sel=NULL ; if(length(setdiff(c('State', 'Area Code', 'Phone'),colonnes))==0){ sel=c('State', 'Area Code', 'Phone') }
  uiTo_drop <- selectInput('to_drop','colonnes à retirer',choices = colonnes, selected = sel, multiple = T)
  
  list(
    column(4,uiDummies), column(4,uiTo_drop), column(4,selectInput('encoding', 'Enconding', choices = c('','ISO-8859-1'))),
    uiOutput('editPreproc0')
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$editPreproc0 <- renderUI({
  input$annulerPreproc0
  validerPreproc0=NULL ; if(!is.null(isolate(input$activerPreproc0))){ validerPreproc0=isolate(input$activerPreproc0) }
  activer=isChurn() ; if(!is.null(validerPreproc0)) activer=validerPreproc0

  ed <- editeur('Preproc0', langage='python', 30, activer=activer, initScript=(is.null(validerPreproc0)))
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
# Renvoie un tableau contenant features et target,
# reconstitué avec des indicatrices (dummies) et débarassé des colonnes à retirer
pyth_preproc0 <- reactive({
  # data=donnees()

  print('==================================================================================================')
  print('                            Prétraitement des données avec pandas')
  print('==================================================================================================')
  if(!is.null(input$activerPreproc0)) if(input$activerPreproc0){
    source_python('src_python/util.py')

    res <- executer('preproc0.py')

    if(!is.null(erreurScript())){
      print('=========  sortie anormale =========')
      print(erreurScript())
      print('====================================')
      return(NULL)
    }
    
    toDrop=NULL ; if(!is.null(input$to_drop)){ toDrop=input$to_drop }
    dummies=NULL ; if(!is.null(input$dummies)){ dummies=input$dummies }
    
    data=prepare_data(
      data=NULL,
      dummies=dummies,
      to_drop=toDrop,
      encoding=input$encoding,
      fichier=input$fichier,
      paf=paste0(input$dossier,'/')
    )

    print('...ok')
    print('Nom des colonnes en sortie du pretraitement :')
    print(colnames(data))
    print('==================================================================================================')
  }
  data
})

# --------------------------------------------------------------------------------
# 1er Pretraitement - basique : Renvoie un tibble contenant features et target,
# reconstitué avec des indicatrices (dummies) et débarassé des colonnes à retirer
r_preproc0 <- reactive({
  print('====================================')
  print('Prétraitement des données avec dplyr')
  print('=> tibble (features, target)')
  print('====================================')
  if(!is.null(input$infile)){
    donnees=fread(input$infile$datapath, drop = input$to_drop, stringsAsFactors = T)
  }else{
    donnees=fread(paste0(input$dossier,'/',input$fichier), drop = input$to_drop, stringsAsFactors = T)
  }
  if(!is.null(input$dummies)) donnees <- one_hot(donnees, input$dummies)
  donnees
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
observe({
  # annuler tous les changements opérés sur le script
  input$annulerPreproc0
  initScript('Preproc0','python')
})

observe({
  # sauver
  input$okPreproc0
  script='' ; if(!is.null(isolate(input$editPreproc0))) script=isolate(input$editPreproc0)
  writeLines(script,paste0(dossier_src(),'/preproc0.py'))
})

observe({
  # # des modifs sont observées dans le script ? => désactiver
  input$editPreproc0
  updateCheckboxInput(session, 'activerPreproc0',  value = F)
})


