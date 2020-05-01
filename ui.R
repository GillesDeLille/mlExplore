
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
                  menuItem('Présentation des modèles','presentation'),
                  menuItem("Modele 1", tabName = "mod1")                
                )
              ),
              dashboardBody(tabItems(
                # ------------------------------------------------------------------------------------------------------------------------------------
                tabItem(tabName = "presentation", column(12, uiOutput('uiPresentation'))),
                tabItem(tabName = "mod1", column(12, uiOutput('mod1')))
                # ------------------------------------------------------------------------------------------------------------------------------------
                
              ))
)
