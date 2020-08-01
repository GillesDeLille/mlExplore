

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$donneesDisponibles <- DT::renderDataTable({
  donnees <- donnees() %>% mutate_if(is.double, as.character)
  datatable(
    donnees, #caption = 'Données disponibles',
    options = list(searching=T, paging=T, pageLength=100, scrollY=430, scrollX=800, info=F),
    rownames=F, selection=c(mode='single')
  )
})

# ---------------------------------------------------------------------------------------------------------------------------------------------------
output$dtFeatures <- DT::renderDataTable({
  
  # dplyr !!! je ne sais pas m'en passer...
  features=data_preproc0() %>% select(-input$target) %>% mutate_if(is.double, as.character)
  datatable(
    features, # caption = 'Features',
    options = list(searching=T, paging=T, pageLength=100, scrollY=230, scrollX=800, info=F),
    rownames=F, selection=c(mode='single')
  )
})
