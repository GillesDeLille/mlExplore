
library(shinydashboard)

largeurBandeau=300

dashboardPage(skin = 'green',
              dashboardHeader(title = "Machine Learning", titleWidth=largeurBandeau),
              dashboardSidebar(
                width=largeurBandeau,
                sidebarMenu(
                  id='menu',
                  getElement(tags, "div")(style = "font-size: 11px",
                    selectInput('fichier','Fichier des exemples', choices = c('churn.csv')),
                    selectInput('cible', 'Cible', choices = c('Churn?')),
                    selectInput('modele','Modèle', choices = c('randomForest'))
                  ),
                  menuItem('Présentation des modèles',tabName = 'presentation'),
                  menuItem("Modele", tabName = "mod")                
                )
              ),
              dashboardBody(tabItems(
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "presentation", 
                  # column(12, uiOutput('uiPresentation'))
                  includeMarkdown('ml_fiche1.Rmd')      
                ),
                tabItem(tabName = "mod",
                  column(12, uiOutput('uiMod'))
                  # img(src='figures/courbeGainCumulée.png')
                )
                # ------------------------------------------------------------------------------------------------------------------------------------
                
              ))
)
