Objectif naïf du projet mlExplore
---------------------------------

Permettre aux utilisateurs de sélectionner des modèles de **M**achine
**L**earning compatibles avec leurs données.

Bien souvent, de nombreuses implémentations existent, sous R et sous
Python pour ne s’en tenir qu’à ces deux langages.

Le but est de s’y retrouver tout en s’affranchissant de la barrière …de
la langue !

Pour le modèle sélectionné, le choix d’une implémentation est proposé
(si possible) :

-   avec scikit-learn, donc en Python

-   ou bien avec R + packages spécialisés

De quoi s’agit-il vraiment ?
----------------------------

### =&gt; Un outil pédagogique

Tout l’intérêt du projet ne se résume pas au produit final et
certainement pas à ses capacités de calcul :

Des outils graphiques pour gérer des problèmes ML, il en existe déjà
beaucoup

-   GCP
-   MatLab (The MathWorks)

**On pourra continuer la liste non exhaustive**

L’outil produit ici ne peut concurrencer sur le fond les acteurs
spécilistes du domaine depuis des années.

Il apporte plutôt une dimension pédagogique en présentant aux
*utilisateurs*

-   des algorithmes,
-   des modèles,
-   un concentré d’éléments de connaissances relatives au ML, adapté *à
    eux* puisque enrichi *par eux*.

Mais l’intérêt pédagogique ne se résume pas à l’application produite.

Au contraire, l’élaboration elle-même de \*mlExplore\*\* constitut
l’essentiel de la démarche engagée ici.

Les apports pour notre connaissance et savoir-faire sont multiples :

Il s’agit d’un exercice grandeur nature, collaboratif, qui met en oeuvre
les outils récents de développement,

et les 2 langages qui ont réuni la communauté Spyrales.

Le projet n’a donc pas vocation a être terminé un jour, ce serait
tellement dommage (!)

### =&gt; Un produit Spyrales

Quoi de plus enthousiasmant qu’un premier outil totalement maîtrisé par
la communauté Spyrales puisque développé par elle et pour ses propres
objectifs.

Où en sommes-nous ?
-------------------

Au tout début…

Mais voyons d’un peu plus près sous 2 angles différents

### Du point de vue de l’utilisateur, que trouve-t-on dans cette application ?

Une interface permettant de

#### Choisir nos propres fichiers pour les soumettre au ML

-   Un fichier de données, livré pour l’exemple : churn2.csv

C’est lui qui est traité par défaut au démarrage de l’appli, en guise de
validation du bon déroulement de chaque fonctionnalité de l’appli.

-   Tout fichier envoyé dans le dossier data (dans l’arborescence du
    projet), via un bouton **&lt; upload &gt;**

-   Le minimum syndical pour le <span
    style="color: #FE446A;">*preprocessing*</span> :

    -   définition de la cible ou *target*,  
    -   colonnes à retirer,  
    -   découpage des colonnes catégorielles (*factors* dans le
        jargon R) en *dummies*.

Remarque au passage, je remercie
<a href="mailto:lino.galiana@insee.fr" class="email">lino.galiana@insee.fr</a>
et ses collègues pour leur très bon
[article](https://linogaliana.netlify.app/post/datatable/datatable-intro/ "article")
sur la librairie **data.table** et dont Spyrales à fait l’echo. Je
développe (un peu) ce thème un peu plus bas, dans la rubrique *Point de
vue du développeur*.

#### Choisir le modèle à ajuster

Une indication est donnée sur la <span style="color: #FE446A;">validité
du modèle</span> choisi en rapport avec l’état des données
(pré-traitées)

Un premier modèle est proposé : <span style="color: #FE446A;">*Random
Forest*</span>,

-   avec une implémentation **Python/scikit-learn**

-   et une autre en lagage **R** associé au costaud **ranger** …Juste
    une remarque en passant, je ne suis pas encore copain avec lui et il
    a l’air suceptible question paramétrage. Je vais donc prendre mon
    temps…

#### L’interface permet aussi d’afficher les scripts de *Machine Learning*

On peut <span style="color: #FE446A;">*contrôler les scripts*</span>
précis (R ou Python) mis en oeuvre pour l’ajustement du modèle et la
restitution des résultats.

Cela pourra peut-être servir pour faciliter leur mise au point avec le
concours des utilisateurs qui ne prendraient part au projet que (et
c’est déjà beaucoup) au travers de l’interface.

### Du point de vue du développeur, qu’avons-nous appris/mis en oeuvre ?

Langages de programmation

-   R
-   python

Environnement de dev

-   Rstudio
-   ShinyApp

Bibliothèques

-   scikitlearn
-   pandas

Dans le détail du développement :

L’article de Lino Galiana nous encourage à <span
style="color: blue;">*mettre en oeuvre data.table*</span>, j’ajoute
<span style="color: blue;">*selon les circonstances*</span> en pensant à
une remarque qui m’a été faite par un certain Romain Lesur (il ne m’en
voudra pas de le citer, j’espère), malgré l’attachement parfois aveugle
que l’on peut porter à dplyr.  
C’est chose faite (au moins partiellement) dans ce projet, pour le
bénéfice qu’apporte la <span style="color: blue;">méthode
*one\_hot*</span>. Pour être complet et ne pas me mettre à dos les
sujets ensorcellés par le gros serpent, un procédé similaire en
Python/pandas a fait l’affaire : <span
style="color: blue;">*get\_dummies*</span>

Plus sur le fond, lorsque l’implémentation du modèle est écrite en
Python, un script <span style="color: blue;">*modele*.py</span> définit
la méthode *fit*.  
Le programme principal use alors de la magie de la librairie <span
style="color: blue;">*reticulate*</span> pour sourcer le script et
appeler la méthode. Il fait ça dans un prolongement de lui même, visible
de l’utilisateur (c’est là l’intérêt), que constitue le script <span
style="color: blue;">fit\_*modele*.R</span> Pour l’utilisateur, les deux
scripts sont visibles et c’est ce qui compte.

Que faire de plus ?
-------------------

**La liste va être longue…**

On peut commencer par…

### Corriger les bugs

-   Tous les fichiers utilisateurs .csv ne sont pas bien pris en compte
-   ?

### Ajouter des modèles

-   Bien les décrire
-   Proposer au moins une implémentation (nous sommes à peu près sûr de
    la trouver dans scikit-learn)
-   Soigner l’affichage de la sortie (exemple de la courbe de gain
    cumulée pour *random forest*)

### Donner plus de possibilité aux utilisateurs

-   Prise en compte des modifications des scripts dans l’éditeur de
    texte (shinyAce)
-   ?

Conseils pour le bon démarrage de l’application
-----------------------------------------------

Deux possibilités :

**=&gt; Profiter de l’application directement à partir d’un des liens
suivants :**

Version stable sur Spyrales : cliquez sur ce lien
[![Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/spyrales/la-piscine/master?urlpath=shiny/mlExplore/)
<!-- [![Binder](http://mybinder.org/badge_logo.svg)](http://mybinder.org/v2/gh/pnavaro/la-piscine/binder?urlpath=shiny/mlExplore/) -->

Version la plus récente (instable), ici :
[![Binder](http://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/GillesDeLille/mlExplore/master?urlpath=shiny/)

L’appli met du temps à démarrer, mais normalement ça fonctionne ! (un
raffraîchissement de la page - touche F5 - est parfois utile suite à
l’erreur 500 trop fréquente à mon goût…)

**=&gt; ou alors installer l’appli sur votre machine (dans l’idée à plus
ou moins long terme de contribuer au projet)**

Pré-requis :

1.  Pour ceux qui traverse des proxies, on m’a soufflé qu’une ligne
    telle que  
    **Sys.setenv(http\_proxy = “xxxx”)**  
    peut aider dans global.R
2.  Un certain nombre de librairies sont bien sûr nécessaires

Pour les scripts R d’une part :

-   reticulate (pour articuler R et Python)
-   DT (pour afficher efficacement les tableaux de données)
-   dplyr (pour les manipuler)
-   readr (pour lire les fichiers csv, mais là je ne suis pas de très
    bon conseil)
-   stringr (je l’utilise pour remettre dans le rang les noms de
    colonnes contenant des charactères exotiques)
-   tictoc (pour mesurer les temps d’exécution, elle est tip top !)
-   shinyEffects (pour faire joli)
-   shinydashboard (parce que c’est beau)
-   data.table (Spyrales en a parlé, alors…)
-   mltools (bien pratique)
-   shinyAce (pour afficher un éditeur de texte dans l’appli)

-   ranger : le petit dernier pour faire du randomForest efficace sous
    R, alternativement à scikitlearn qui s’avèrera là-dessus moins bon.
    A confirmer.

Les commandes à passer, dans une console R :

    install.packages('reticulate')
    install.packages('tictoc')
    install.packages('shinyEffects')
    install.packages('shinydashboard')
    install.packages('DT')
    install.packages('dplyr')
    install.packages('readr')
    install.packages('mltools')
    install.packages('data.table')
    install.packages('shinyAce')
    install.packages('ranger')

Pour les scripts python d’autre part :

-   pandas
-   scikit-learn\`

Mais tant qu’on y est, on peut installer aussi d’autres librairies qui
seront utiles rapidement.

Toujours sous R, j’ai fait comme ceci :

    library(reticulate)

    conda_install("r-reticulate", "scipy")
    conda_install("r-reticulate", "scikit-learn")
    conda_install("r-reticulate", "pandas")
    conda_install("r-reticulate", "matplotlib")
    conda_install("r-reticulate", "scikit-plot")
    conda_install("r-reticulate", "seaborn")

Après avoir récupéré tout le paquet (avec l’outil git à priori), je vois
2 options :

1.  le déposer dans le dossier ShinyApps s’il existe et qu’un serveur
    Shiny tourne sur votre machine locale.

2.  le déposer où bon vous semble pour le reconnaître ensuite dans vos
    projets à partir de l’environnement Rstudio.

C’est presque tout :

Option 1 : accédez classiquement depuis le navigateur à la page
@ip/users/votreUser/mlExplore/

Option 2 : sous Rstudio, se positionner sur global.R, ui.R ou server.R
puis runApp

Personnellement, je n’ai pas pris le temps d’installer (sur mon pc
nouvellement acquis) un server Shiny. Vous me direz si vous rencontrez
des problèmes en choisissant l’option 1, mais à priori il n’y aura pas
de soucis.

Je suis dans le cas de l’option 2

-   pour mon pc perso, tout fonctionne parfaitement.

-   et puis aussi sur une machine bien plus puissante …qui n’est pas à
    moi et à laquelle j’accède par ssh et Rstudio server.

Il se trouve que l’affichage du *DISPLAY* sur ma machine distante est un
peu rebel. Vous n’aurez sans doute pas le soucis chez vous, ignorez
alors la remarque qui suit.  
Pour forcer le *DISPLAY*, je n’ai rien trouvé de mieux que de lancer le
petit script python **plot.py** que vous trouverez dans src\_python/ .
Cela m’active l’affichage et tout fonctionne alors à merveilles. C’est
de la bidouille, conseillez moi vite un truc plus pro si vous savez et
avez du temps à consacrer à ça !

Et à quoi ça ressemble en images ?
----------------------------------

Vous demander de commencer par corriger les bugs, c’est pas très vendeur
je reconnaît.

Plus vendeur, une image :

![Sortie d’un modèle célèbre](mlExplore1.png)

Et puis une autre, l’interface ayant un peu évolué entre temps :

![Le code python est affiché dans l’appli](mlExplore2.png)
