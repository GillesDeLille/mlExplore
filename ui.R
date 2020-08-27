
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
                    uiOutput('uiTarget')
                  ),
                  menuItem('Descritption des modèles',tabName = 'description'),
                  menuItem('Données',tabName = 'donnees'),
                  menuItem('Traitements & évaluation',tabName = 'traitements'),
                  menuItem('Eléments à avoir en tête',tabName = 'fiche1'),
                  menuItem('virtual env Python',tabName = 'venv_python')
                )
                
              ),
              dashboardBody(tabItems(
                
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "venv_python",
                  uiOutput('ui_venv_python')
                ),
                
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "description",
                        uiOutput('uiModeles'),
                        uiOutput('uiDescription')
                ),
                
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "donnees", withMathJax(
                  setShadow(class = 'box'),
                  h5('Données disponibles'),
                  box(width=12, DT::dataTableOutput('donneesDisponibles'))
                )),
                
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "traitements",
                  uiOutput('uiTraitements')
                ),

                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "fiche1", withMathJax(
                  setShadow(class = 'box'),
                  column(2,br()),box(width=8, includeMarkdown('markdown/ml_fiche1.Rmd'))
                ))
                
                # ------------------------------------------------------------------------------------------------------------------------------------

              ))
)
