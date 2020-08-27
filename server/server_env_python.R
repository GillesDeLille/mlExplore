
# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$ui_venv_python <- renderUI({
  liste <- list(
    h3("Environnement d'exécution - Informations"),
    hr(),
    withSpinner(DT::dataTableOutput('sysinfo')),
    br(),
    verbatimTextOutput('which_python'),
    verbatimTextOutput('python_version'),
    verbatimTextOutput('ret_env_var'),
    verbatimTextOutput('venv_root')
  )
  liste
})

# ------------------------------------------------------------------------
# Display info about the system running the code
output$sysinfo <- DT::renderDataTable({
  s = Sys.info()
  df = data.frame(Info_Field = names(s),
                  Current_System_Setting = as.character(s))
  return(datatable(df, rownames = F, selection = 'none',
                   style = 'bootstrap', filter = 'none', options = list(dom = 't')))
})

# ------------------------------------------------------------------------
# Display system path to python
output$which_python <- renderText({
  paste0('which python: ', Sys.which('python'))
})

# ------------------------------------------------------------------------
# Display Python version
output$python_version <- renderText({
  rr = reticulate::py_discover_config(use_environment = 'python35_env')
  paste0('Python version: ', rr$version)
})

# ------------------------------------------------------------------------
# Display RETICULATE_PYTHON
output$ret_env_var <- renderText({
  paste0('RETICULATE_PYTHON: ', Sys.getenv('RETICULATE_PYTHON'))
})

# ------------------------------------------------------------------------
# Display virtualenv root
output$venv_root <- renderText({
  paste0('virtualenv root: ', reticulate::virtualenv_root())
})

