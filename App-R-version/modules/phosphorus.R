### modules/phosphorus.R

# UI function: Defines the layout and input fields for the tool
phosphorusUI <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Phosphorus Fertilizer Recommendation"),
    # Radio buttons to select between Sufficiency or Build & Maintenance strategy
    radioButtons(ns("mode"), "Choose Recommendation Strategy:",
                 choices = c("Sufficiency", "Build & Maintenance"), inline = TRUE),
    
    # Input section for Sufficiency recommendation strategy
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Sufficiency'", ns("mode")),
      wellPanel(
        h4("Sufficiency Recommendation Considerations"),
        p("Phosphorus: Mehlich 3 Extractable P (Colorimetric) or Bray P1 Extractable P"),
        p("Olsen P – multiply by 1.6 and interpret similarly to Mehlich 3 Colorimetric"),
        tags$ul(
          tags$li("Crop P recommendations are for the total amount of broadcast and banded nutrients to be applied. At a very low soil test level, applying at least 25 to 50% of total as a band is recommended."),
          tags$li("If Mehlich-3 P is greater than 20 ppm (25 ppm for Bermudagrass or Alfalfa and Clover), then only starter fertilizer is suggested, and defined as a maximum of 20 lb P₂O₅/a applied at planting."),
          tags$li("If Mehlich-3 P is less than 20 ppm (25 ppm for Bermudagrass or Alfalfa and Clover), then the minimum P recommendation is 15 lb P₂O₅/a."),
          tags$li("Application of starter fertilizer containing NP, NPK or NPKS may be beneficial regardless of P soil test level, especially for cold/wet soil conditions and/or high surface crop residues."),
          tags$li("Wheat and Oats is generally considered more responsive to band-applied P fertilizer."),
          tags$li("Soybean seedlings are particularly sensitive to fertilizer damage, and fertilizer placed in direct seed contact is not recommended.")
        )
      ),
      
      # Crop selection and yield input for sufficiency
      selectInput(ns("crop"), "Crop:", choices = c("Corn", "Wheat", "Grain Sorghum", "Soybean", "Sunflower", "Oats", "Corn Silage", "Sorghum Silage", 
                                                   "Brome and Fescue", "New Brome and Fescue", "Bermudagrass", "New Bermudagrass", "Alfalfa and Clover", "New Alfalfa and Clover")),
      uiOutput(ns("yield_label")),
      numericInput(ns("mehlich"), "Mehlich-3 P (ppm):", value = 10, min = 0)
    ),
    
    # Input section for Build & Maintenance recommendation strategy
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Build & Maintenance'", ns("mode")),
      wellPanel(
        h4("Build & Maintenance Recommendation Considerations"),
        p("Phosphorus: Mehlich 3 Extractable P (Colorimetric) or Bray P1 Extractable P"),
        p("Olsen P – multiply by 1.6 and interpret similarly to Mehlich 3 Colorimetric"),
        tags$ul(
          tags$li("The goal of the initial phase is to build the soil test value to the critical soil test value (CSTV) of 20 ppm (25 ppm for Alfalfa and Clover), and subsequently maintain it within the range of 20 to 30 ppm through crop removal replacement."),
          tags$li("The quantity of P₂O₅ fertilizer required to elevate the soil test P value differs according to soil type, in addition to differences in P removal and cycling, therefore regular soil sampling is necessary to keep track of soil test levels."),
          tags$li("Build programs can be designed for various timeframes (e.g., 4 or 6 years), but recommended rates should not be less than those of sufficiency-based fertility programs.")
        )
      ),
      
      # Crop selection and inputs for soil test value, build time, and removal
      selectInput(ns("crop_bm"), "Crop:", choices = c("Corn", "Wheat", "Grain Sorghum", "Soybean", "Sunflower", "Oats", "Corn Silage", "Sorghum Silage", "Alfalfa and Clover")),
      numericInput(ns("current_p"), "Current P Soil Test (Mehlich-3 ppm):", value = 10, min = 0),
      numericInput(ns("years"), "Timeframe to Build (years):", value = 4, min = 0),
      numericInput(ns("removal"), "Annual Crop P₂O₅ Removal (lb/a):", value = 60, min = 0)
    ),
    
    # Trigger calculation
    actionButton(ns("calc"), "Calculate Recommendation"),
    br(), br(),
    tags$div(
      style = "width: 100%; background-color: #f0f0f0; padding: 20px; font-size: 20px; font-weight: bold; border-left: 8px solid black; border-radius: 4px;",
      uiOutput(ns("result"))
      ), 
    
    br(), br(), br(),
  )
}

# Server function: Contains the logic to calculate phosphorus recommendations based on inputs
phosphorusServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Dynamically set the label for yield input based on selected crop
    output$yield_label <- renderUI({
      unit <- switch(input$crop,
                     "Corn" = "Expected Yield (bu/a):",
                     "Wheat" = "Expected Yield (bu/a):",
                     "Grain Sorghum" = "Expected Yield (bu/a):",
                     "Soybean" = "Expected Yield (bu/a):",
                     "Sunflower" = "Expected Yield (lb/a):",
                     "Oats" = "Expected Yield (bu/a):",
                     "Corn Silage" = "Expected Yield (ton/a):",
                     "Sorghum Silage" = "Expected Yield (ton/a):",
                     "Brome and Fescue" = "Expected Yield (ton/a):",
                     "New Brome and Fescue" = "Expected Yield (ton/a):",
                     "Bermudagrass" = "Expected Yield (ton/a):",
                     "New Bermudagrass" = "Expected Yield (ton/a):",
                     "Alfalfa and Clover" = "Expected Yield (ton/a):",
                     "New Alfalfa and Clover" = "Expected Yield (ton/a):"
      )
      numericInput(session$ns("yield"), unit, value = 150, min = 0)
    })
    
    # When "Calculate Recommendation" is clicked
    observeEvent(input$calc, {
      mode <- input$mode
      
      # ---------- SUFFICIENCY MODE ----------
      if (mode == "Sufficiency") {
        crop <- input$crop
        yield <- input$yield
        p <- input$mehlich
        
        # Validate input
        if (is.null(crop) || is.null(yield) || is.null(p) || is.na(yield) || is.na(p)) {
          output$result <- renderUI({
            HTML("Phosphorus recommendation is not available. Please complete all input fields.")
          })
          return()
        }
        
        # Set CSTV for some crops to 25 instead of 20
        cstv <- if (crop %in% c("Bermudagrass", "New Bermudagrass", "Alfalfa and Clover", "New Alfalfa and Clover")) 25 else 20
        
        # Calculate sufficiency P recommendation
        if (p >= cstv) {
          p_rec <- 0
        } else {
          p_rec <- switch(crop,
                          "Corn" = 50 + (yield * 0.2) + (p * -2.5) + (yield * p * -0.01),
                          "Wheat" = 46 + (yield * 0.42) + (p * -2.3) + (yield * p * -0.021),
                          "Grain Sorghum" = 50 + (yield * 0.16) + (p * -2.5) + (yield * p * -0.008),
                          "Soybean" = 56 + (yield * 0.51) + (p * -2.8) + (yield * p * -0.0257),
                          "Sunflower" = 42 + (yield * 0.01) + (p * -2.1) + (yield * p * -0.0005),
                          "Oats" = 47 + (yield * 0.25) + (p * -2.3) + (yield * p * -0.013),
                          "Corn Silage" = 56 + (yield * 1.12) + (p * -2.8) + (yield * p * -0.056),
                          "Sorghum Silage" = 48 + (yield * 1.19) + (p * -2.38) + (yield * p * -0.0594),
                          "Brome and Fescue"  = 44 + (yield * 6.3) + (p * -2.2) + (yield * p * -0.315), 
                          "New Brome and Fescue" = 68 + (yield * 11.2) + (p * -2.2) + (yield * p * -0.315),
                          "Bermudagrass" = 64 + (yield * 5.3) + (p * -2.56) + (yield * p * -0.21),
                          "New Bermudagrass" = 64 + (yield * 9.1) + (p * -2.56) + (yield * p * -0.21),
                          "Alfalfa and Clover" = 73 + (yield * 4.56) + (p * -2.92) + (yield * p * -0.18),
                          "New Alfalfa and Clover" = 84 + (yield * 12) + (p * -3.37) + (yield * p * -0.48)
          )
        }
        
        # Output formatted result
        p_rec <- round(p_rec, 0)
        output$result <- renderUI({
          HTML(paste0(
            "[Sufficiency]<br/>",
            "Recommended Phosphorus (P₂O₅) Rate: ", p_rec, " lb/a"
          ))
        })
        
        # ---------- BUILD & MAINTENANCE MODE ----------
      } else if (mode == "Build & Maintenance") {
        current_p <- input$current_p
        years <- as.numeric(input$years)
        removal <- input$removal
        crop_bm <- input$crop_bm
        
        # Validate input
        if (is.null(current_p) || is.na(current_p) || is.null(years) || is.na(years) || is.null(removal) || is.na(removal)) {
          output$result <- renderUI({
            HTML("Phosphorus recommendation is not available. Please complete all input fields.")
          })
          return()
        }
        
        # Use CSTV = 25 for Alfalfa/Clover, else 20
        cstv <- if (crop_bm %in% c("Alfalfa and Clover")) 25 else 20
        build_amt <- (cstv - current_p) * 18
        total_p <- round(build_amt + (removal * years), 0)
        yearly_p <- round(total_p / years, 0)
        
        # Output formatted result
        output$result <- renderUI({
          HTML(paste0(
            "[Build & Maintenance]<br/>",
            "Total Phosphorus (P₂O₅) Recommendation: ", total_p, " lb/a over ", years, " years<br/>",
            "→ ", yearly_p, " lb/a each year"
          ))
        })
      }
    })
  })
}
