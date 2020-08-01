
largeurBandeau=350

dashboardPage(skin = 'green',
              dashboardHeader(title = "mlExplore", titleWidth=largeurBandeau),
              dashboardSidebar(
                width=largeurBandeau,
                sidebarMenu(
                  id='menu',
                  getElement(tags, "div")(style = "font-size: 11px",
                    column(5, selectInput('dossier', 'Dossier', choices = c(pafexemples,pafdata))), column(7,uiOutput('uiFichiers')),
                    column(9,fileInput('infile', 'uploader des données')), column(3, checkboxInput('header', 'Header', value = T)),
                    column(12,uiOutput('uiTarget')),
                    uiOutput('uiModeles')#, uiOutput('uiModeleValide'),
                    
                  ),
                  menuItem('Données',tabName = 'donnees'),
                  menuItem('Prétraitement',tabName = 'pretraitement'),
                  menuItem('Evaluation',tabName = 'evaluation'),
                  menuItem('Présentation des modèles',tabName = 'presentation'),
                  # menuItem("Résultats", tabName = "resultats"),
                  menuItem('Eléments à avoir en tête',tabName = 'fiche1')
                )
              ),
              dashboardBody(tabItems(
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "donnees", withMathJax(
                  setShadow(class = 'box'),
                  h5('Données disponibles'),
                  box(width=12, DT::dataTableOutput('donneesDisponibles'))
                )),
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "pretraitement", withMathJax(
                  tabsetPanel(#selected='Preprocessing',
                    tabPanel(
                      'Prétraitement basique',
                      uiOutput('uiPreproc0')
                    ),
                    tabPanel(
                      'Preprocessing',
                      box(width=10, DT::dataTableOutput('target_value_counts_avant_preproc')),
                      uiOutput('uiPreprocessing'),
                      uiOutput('target_value_counts_apres_preproc')
                    ),
                    tabPanel(
                      'Features prétraitées',
                      hr(),
                      box(width=12, DT::dataTableOutput('dtFeatures'))
                    )
                  )
                )),
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "evaluation", withMathJax(
                  uiOutput('uiEvaluation')
                )),
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "presentation", withMathJax(
                  uiOutput('uiPresentation'),
                  uiOutput('uiEditImplementation')
                )),
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "fiche1", withMathJax(
                  setShadow(class = 'box'),
                  column(2,br()),box(width=8, includeMarkdown('markdown/ml_fiche1.Rmd'))
                ))
                # ------------------------------------------------------------------------------------------------------------------------------------

              ))
)
