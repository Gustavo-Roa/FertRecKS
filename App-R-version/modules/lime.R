### modules/lime.R

# UI function: Defines the layout and input fields for the tool
limeUI <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Lime Recommendation Calculator"),
    
    # Explanation and reference for users
    wellPanel(
      h4("About These Recommendations"),
      p("The appropriate target pH varies by region based on subsoil acidity; lime rates are based on 6-inch soil depth. Soil depth is the depth of lime incorporation
through tillage. For no-till systems, alfalfa and grass – assume 2-inch depth of incorporation (about one third of the rate for 6-inch depth). When lime recommendation exceeds 10,000 lb ECC/a, we suggest
applying one-half rate, incorporate, wait 12 to 18 months and then retest."),
      
      # Display the formulas used for each target pH
      tags$ul(
        tags$li(
          tags$strong("Target pH of 6.8 = [28,300 − (7,100 × Buffer pH) + (Buffer pH × Buffer pH × 449)] × Depth (inches)"),
          tags$ul(
            tags$li("All crops in southeast Kansas – east of Flint Hills and south of Highway 56"),
            tags$li("Alfalfa and clover in northeast Kansas"),
            tags$li("Lime Rec if pH < 6.4")
          )
        ),
        tags$li(
          tags$strong("Target pH of 6.0 = [14,100 − (3,540 × Buffer pH) + (Buffer pH × Buffer pH × 224)] × Depth (inches)"),
          tags$ul(
            tags$li("All crops in northeast Kansas except alfalfa and clover"),
            tags$li("All crops in central and western Kansas"),
            tags$li("Lime Rec if pH < 5.8")
          )
        ),
        tags$li(
          tags$strong("Target pH of 5.5 = [7,060 − (1,770 × Buffer pH) + (Buffer pH × Buffer pH × 112)] × Depth (inches)"),
          tags$ul(
            tags$li("Cash flow/lime availability problem areas in central and western Kansas"),
            tags$li("Lime Rec if pH < 5.5")
          )
        )
      )
      
    ),
    
    # User inputs for lime recommendation calculation
    radioButtons(ns("target"), "Select Target pH Strategy:",
                 choices = c("Target pH 6.8", "Target pH 6.0", "Target pH 5.5")
    ),
    numericInput(ns("buffer_ph"), "Buffer pH:", value = 6.1, step = 0.1, min = 0),
    numericInput(ns("depth"), "Incorporation Depth (inches):", value = 6, min = 2, max = 12),
    
    # Action and output
    actionButton(ns("calc"), "Calculate Lime Recommendation"),
    br(), br(),
    tags$div(
      style = "width: 100%; background-color: #f0f0f0; padding: 20px; font-size: 20px; font-weight: bold; border-left: 8px solid black; border-radius: 4px;",
      uiOutput(ns("result"))
      ),
    
    # Static image reference table
    br(), hr(),
    h4("Quick Table"),
    tags$img(src = "lime_table.png", width = "60%", alt = "Lime Recommendation Table")
  )
}

# Server function: Contains the logic to calculate recommendations based on inputs
limeServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Calculate lime recommendation when the button is clicked
    observeEvent(input$calc, {
      bpH <- input$buffer_ph
      depth <- input$depth
      
      # Validate inputs
      if (is.null(bpH) || is.null(depth) || is.na(bpH) || is.na(depth)) {
        output$result <- renderUI({
          HTML("Recommendation is not available. Please complete all input fields.")
        })
        return()
      }
      
      # Calculate based on selected target pH formula
      lime_rec <- switch(input$target,
                         "Target pH 6.8" = (28300 - (7100 * bpH) + (bpH * bpH * 449)) * depth,
                         "Target pH 6.0" = (14100 - (3540 * bpH) + (bpH * bpH * 224)) * depth,
                         "Target pH 5.5" = (7060 - (1770 * bpH) + (bpH * bpH * 112)) * depth
      )
      
      lime_rec <- round(lime_rec, 0)
      
      # Display final recommendation
      output$result <- renderUI({
        HTML(paste0("Lime Recommendation: ", lime_rec, " lb ECC/a"))
      })
    })
  })
}
