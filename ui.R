
largeurBandeau=300

dashboardPage(skin = 'green',
              dashboardHeader(title = "Machine Learning", titleWidth=largeurBandeau),
              dashboardSidebar(
                width=largeurBandeau,
                sidebarMenu(
                  id='menu',
                  getElement(tags, "div")(style = "font-size: 11px",
                    selectInput('fichier','Fichier des exemples', choices = c('churn2.csv')),
                    selectInput('cible', 'Cible', choices = c('Churn')),
                    selectInput('modele','Modèle', choices = c('randomForest'))
                  ),
                  menuItem('Présentation des modèles',tabName = 'presentation'),
                  menuItem("Modele", tabName = "mod"),
                  menuItem('Eléments à avoir en tête',tabName = 'fiche1')
                )
              ),
              dashboardBody(tabItems(
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "presentation", withMathJax(
                  setShadow(class = 'box'),
                  column(2,br()),box(width=8, uiOutput('uiPresentation') )
                )),
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "mod",
                  column(12, uiOutput('uiMod'))
                ),
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "fiche1", withMathJax(
                  setShadow(class = 'box'),
                  column(2,br()),box(width=8, includeMarkdown('ml_fiche1.Rmd'))
                ))
                # ------------------------------------------------------------------------------------------------------------------------------------
                
              ))
)
