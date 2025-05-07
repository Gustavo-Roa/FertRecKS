useRecommendationReset <- function(input, output, outputId, calcTrigger, generateText) {
  result_text <- reactiveVal(HTML(""))
  
  # Delay input changes so it doesn't reset while typing
  delayed_inputs <- debounce(reactiveValuesToList(input), millis = 1000)
  
  observeEvent(delayed_inputs(), {
    result_text(HTML(""))
  }, ignoreInit = TRUE)
  
  observeEvent(calcTrigger(), {
    result_text(generateText())
  })
  
  output[[outputId]] <- renderUI({
    result_text()
  })
}
