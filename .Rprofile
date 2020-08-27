# This file configures the virtualenv and Python paths differently depending on
# the environment the app is running in (local vs remote server).

# Edit this name if desired when starting a new app
VIRTUALENV_NAME = 'venv_shiny_app'


# ------------------------- Settings (Do not edit) -------------------------- #

if (Sys.info()[['user']] == 'shiny'){
  
  # Running on shinyapps.io
  Sys.setenv(shinyapps_io = 'oui')
  Sys.setenv(PYTHON_PATH = 'python3')
  Sys.setenv(VIRTUALENV_NAME = VIRTUALENV_NAME) # Installs into default shiny virtualenvs dir
  Sys.setenv(RETICULATE_PYTHON = paste0('/home/shiny/.virtualenvs/', VIRTUALENV_NAME, '/bin/python'))
  
} else {
  
  # Running locally
  Sys.setenv(shinyapps_io = 'non')
  Sys.setenv(PYTHON_PATH = 'python3')
  Sys.setenv(VIRTUALENV_NAME = VIRTUALENV_NAME) # exclude '/' => installs into ~/.virtualenvs/
  # RETICULATE_PYTHON is not required locally, RStudio infers it based on the ~/.virtualenvs path
}
