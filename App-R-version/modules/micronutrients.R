### modules/micronutrients.R

# UI function: Defines the layout and input fields for the tool
micronutrientsUI <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Micronutrient Recommendations"),
    
    # Select the micronutrient of interest
    radioButtons(ns("nutrient"), "Select a Micronutrient:",
                 choices = c("Chloride", "Boron", "Zinc"), inline = TRUE
    ),
    
    # Chloride recommendation inputs and notes
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Chloride'", ns("nutrient")),
      wellPanel(
        h4("Chloride Recommendation"),
        p("Chloride fertilizer is recommended for wheat, corn and sorghum only."),
        p("Chloride: Mercury (II) Thiocyanate Extractable (Colorimetric)"),
        tags$ul(
          tags$li("< 4 ppm (or <30 lb/a): 20 lb Cl/a"),
          tags$li("4–6 ppm (30–45 lb/a): 10 lb Cl/a"),
          tags$li("> 6 ppm (>45 lb/a): No chloride needed")
        )
      ),
        numericInput(ns("cl_ppm"), "Profile Soil Chloride (ppm):", value = 3, min = 0)
      ),
    
    # Boron recommendation inputs and notes
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Boron'", ns("nutrient")),
      wellPanel(
        h4("Boron Recommendation"),
        p("Do not band apply boron. Recommendations are for southeast Kansas in alfalfa, corn, sorghum and soybeans only. Test is not well calibrated."),
        p("Boron: DTPA Extractable"),
        tags$ul(
          tags$li("< 0.5 ppm: 2 lb B/a"),
          tags$li("0.6–1.0 ppm: 1 lb B/a"),
          tags$li("> 1.0 ppm: No boron needed")
        )
      ),
        numericInput(ns("b_ppm"), "Extractable Boron (ppm):", value = 0.4, min = 0)
      ),
    
    
    # Zinc recommendation inputs and notes
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Zinc'", ns("nutrient")),
      wellPanel(
        h4("Zinc Recommendation"),
        p("Zinc recommendation is for corn, sorghum and soybeans only."),
        p("Broadcast application is intended to build Zn soil test level to non-responsive range and correct soil deficiency for several years. If applied as banded starter at planting, application of about 0.5 – 1.0 lb Zn/a will correct crop deficiency for that crop year. Soil deficiency will likely remain."),
        p("Zinc recommendation for wheat, sunflowers, oats, alfalfa, brome, fescue, Bermudagrass and other crops. These crops show little to no response to zinc applications. No application is recommended."),
        p("Zinc: DTPA Extractable"),
        tags$ul(
          tags$li(
            tags$strong("Zn Rate = 11.5 − (11.25 × ppm DTPA Zn)"),
            tags$ul(
              tags$li("If Zn > 1.0 ppm: No zinc needed"),
              tags$li("If Zn ≤ 1.0 ppm: Minimum Zn Rec = 1 lb Zn/a")
            )
            )
          )
        ),
        
        numericInput(ns("zn_ppm"), "Extractable Zinc (ppm):", value = 0.5, min = 0)
      ),
    
    # Action and result display
    actionButton(ns("calc"), "Get Recommendation"),
    br(), br(),
    tags$div(
      style = "width: 100%; background-color: #f0f0f0; padding: 20px; font-size: 20px; font-weight: bold; border-left: 8px solid black; border-radius: 4px;",
      uiOutput(ns("result"))
      ),
    
    br(), br(), br(),
  )
}


# Server function: Contains the logic to calculate recommendations based on inputs
micronutrientsServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Run calculation when 'Get Recommendation' button is clicked
    observeEvent(input$calc, {
      
      # FIRST: Validate input
      if (is.null(input$nutrient) || 
          (input$nutrient == "Chloride" && (is.null(input$cl_ppm) || is.na(input$cl_ppm))) ||
          (input$nutrient == "Boron" && (is.null(input$b_ppm) || is.na(input$b_ppm))) ||
          (input$nutrient == "Zinc" && (is.null(input$zn_ppm) || is.na(input$zn_ppm)))) {
        
        output$result <- renderUI({
          HTML("Recommendation is not available. Please complete all input fields.")
        })
        return()
      }
      
      # THEN: Calculate recommendation only after inputs are OK
      recommendation <- switch(input$nutrient,
                               
                               # Chloride logic
                               "Chloride" = {
                                 ppm <- input$cl_ppm
                                 if (ppm < 4) {
                                   "20 lb Cl/a"
                                 } else if (ppm <= 6) {
                                   "10 lb Cl/a"
                                 } else {
                                   "No chloride needed"
                                 }
                               },
                               
                               # Boron logic
                               "Boron" = {
                                 ppm <- input$b_ppm
                                 if (ppm < 0.5) {
                                   "2 lb B/a"
                                 } else if (ppm <= 1.0) {
                                   "1 lb B/a"
                                 } else {
                                   "No boron needed"
                                 }
                               },
                               
                               # Zinc logic
                               "Zinc" = {
                                 ppm <- input$zn_ppm
                                 if (ppm > 1.0) {
                                   "No zinc needed"
                                 } else {
                                   rate <- max(1, round(11.5 - 11.25 * ppm, 0))
                                   paste(rate, "lb Zn/a")
                                 }
                               }
      )
      
      # Display the result
      output$result <- renderUI({
        HTML(paste0(
          "Recommendation for ", input$nutrient, ": ",
          recommendation
        ))
      })
      
    })
  })
}
