
# ---------------------------------------------------------------------------------------------------------------------------------------------------
data_preproc0 <- reactive({
  data=donnees()
  if(langage()=='python') data=pyth_preproc0()
  if(langage()=='R')      data=r_preproc0()
  data
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


