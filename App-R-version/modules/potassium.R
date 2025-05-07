### modules/potassium.R

# UI function: Defines the layout and user inputs for potassium recommendations
potassiumUI <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Potassium Fertilizer Recommendation"),
    
    # Choose between Sufficiency and Build & Maintenance strategies
    radioButtons(ns("mode"), "Choose Recommendation Strategy:",
                 choices = c("Sufficiency", "Build & Maintenance"), inline = TRUE),
    
    # Input section for Sufficiency recommendation strategy
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Sufficiency'", ns("mode")),
      wellPanel(
        h4("Sufficiency Recommendation Considerations"),
        p("Potassium: Mehlich 3 Extractable or Ammonium Acetate Extractable"),
        tags$ul(
          tags$li("Crop K recommendations are for the total amount of broadcast and banded nutrients to be applied."),
          tags$li("If soil extractable K is greater than 130 ppm (150 ppm for Bermudagrass or Alfalfa and Clover), then only NPK or NPKS starter fertilizer is suggested."),
          tags$li("If extractable K is less than 130 ppm (150 ppm for Bermudagrass or Alfalfa and Clover), then the minimum K recommendation is 15 lb K₂O/a"),
          tags$li("For in-furrow starter fertilizer do not exceed N + K₂O guidelines for fertilizer placed in direct seed contact."),
          tags$li("Soybean seedlings are particularly sensitive to fertilizer damage, and fertilizer placed in direct seed contact is not recommended.")
        )
      ),
      
      # Crop selection and yield input for sufficiency
      selectInput(ns("crop"), "Crop:", choices = c("Corn", "Wheat", "Grain Sorghum", "Soybean", "Sunflower", "Oats", "Corn Silage", "Sorghum Silage", 
                                                   "Brome and Fescue", "New Brome and Fescue", "Bermudagrass", "New Bermudagrass", "Alfalfa and Clover", "New Alfalfa and Clover")),
      uiOutput(ns("yield_label")),
      numericInput(ns("mehlich_k"), "Mehlich-3 K (ppm):", value = 100, min = 0)
    ),
    
    # Input section for Build & Maintenance recommendation strategy
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Build & Maintenance'", ns("mode")),
      wellPanel(
        h4("Build & Maintenance Recommendation Considerations"),
        p("Potassium: Mehlich 3 Extractable or Ammonium Acetate Extractable"),
        tags$ul(
          tags$li("The goal of the initial phase is to build the soil test value to the critical soil test value (CSTV) of 130 ppm (150 ppm for Alfalfa and Clover), and subsequently maintain it within the range of 130 to 160 ppm through crop removal replacement."),
          tags$li("The quantity of K₂O fertilizer required to elevate the soil test K value differs according to soil type, in addition to differences in K crop removal, cycling to the soil and soil-K interaction, therefore regular soil sampling is necessary to keep track of soil test levels."),
          tags$li("Build programs can be designed for various timeframes (e.g., 4 or 6 years), but recommended rates should not be less than those of sufficiency-based fertility programs.")
        )
      ),
      
      # Crop selection and inputs for soil test value, build time, and removal
      selectInput(ns("crop_bm"), "Crop:", choices = c("Corn", "Wheat", "Grain Sorghum", "Soybean", "Sunflower", "Oats", "Corn Silage", "Sorghum Silage", "Alfalfa and Clover")),
      numericInput(ns("current_k"), "Current K Soil Test (Mehlich-3 ppm):", value = 100, min = 0),
      numericInput(ns("years"), "Timeframe to Build (years):", value = 4, min = 0),
      numericInput(ns("removal"), "Annual Crop K₂O Removal (lb/a):", value = 80, min = 0)
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


# Server function: Contains the logic to calculate recommendations based on inputs
potassiumServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Dynamically set yield label based on selected crop and expected units
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
    
    # Main logic triggered when 'Calculate Recommendation' button is clicked
    observeEvent(input$calc, {
      mode <- input$mode
      
      # ---------- SUFFICIENCY MODE ----------
      if (mode == "Sufficiency") {
        crop <- input$crop
        yield <- input$yield
        k <- input$mehlich_k
        
        if (is.null(crop) || is.null(yield) || is.null(k) || is.na(yield) || is.na(k)) {
          output$result <- renderUI({
            HTML("Potassium recommendation is not available. Please complete all input fields.")
          })
          return()
        }
        
        cstv <- if (crop %in% c("Bermudagrass", "New Bermudagrass", "Alfalfa and Clover", "New Alfalfa and Clover")) 150 else 130
        
        if (k >= cstv) {
          k_rec <- 0
        } else {
          k_rec <- switch(crop,
                          "Corn" = 73 + (yield * 0.21) + (k * -0.565) + (yield * k * -0.0016), 
                          "Wheat" = 62 + (yield * 0.24) + (k * -0.48) + (yield * k * -0.0018), 
                          "Grain Sorghum" = 80 + (yield * 0.17) + (k * -0.616) + (yield * k * -0.0013), 
                          "Soybean" = 60 + (yield * 0.628) + (k * -0.46) + (yield * k * -0.0048), 
                          "Sunflower" = 88 + (yield * 0.008) + (k * -0.622) + (yield * k * -0.00006), 
                          "Oats" = 62 + (yield * 0.221) + (k * -0.48) + (yield * k * -0.0017), 
                          "Corn Silage" = 74 + (yield * 1.50) + (k * -0.567) + (yield * k * -0.0115), 
                          "Sorghum Silage" = 73 + (yield * 1.8) + (k * -0.56) + (yield * k * -0.0139), 
                          "Brome and Fescue"  = 41 + (yield * 5.85) + (k * -0.315) + (yield * k * -0.045), 
                          "New Brome and Fescue" = 91 + (yield * 15) + (k * -0.7) + (yield * k * -0.116),
                          "Bermudagrass" = 75 + (yield * 5.3) + (k * -2.56) + (yield * k * -0.21),
                          "New Bermudagrass" = 105 + (yield * 15) + (k * -0.7) + (yield * k * -0.1),
                          "Alfalfa and Clover" = 84 + (yield * 5.24) + (k * -0.56) + (yield * k * -0.035),
                          "New Alfalfa and Clover" = 105 + (yield * 15) + (k * -0.7) + (yield * k * -0.1)
          )
        }
        
        k_rec <- round(k_rec, 0)
        output$result <- renderUI({
          HTML(paste0(
            "[Sufficiency]<br/>",
            "Recommended Potassium (K₂O) Rate: ", k_rec, " lb/a"
          ))
        })
        
        # ---------- BUILD & MAINTENANCE MODE ----------
      } else if (mode == "Build & Maintenance") {
        current_k <- input$current_k
        years <- as.numeric(input$years)
        removal <- input$removal
        crop_bm <- input$crop_bm
        
        if (is.null(current_k) || is.na(current_k) || is.null(years) || is.na(years) || is.null(removal) || is.na(removal)) {
          output$result <- renderUI({
            HTML("Potassium recommendation is not available. Please complete all input fields.")
          })
          return()
        }
        
        cstv <- if (crop_bm %in% c("Alfalfa and Clover")) 150 else 130
        build_amt <- (cstv - current_k) * 9
        total_k <- round(build_amt + (removal * years), 0)
        yearly_k <- round(total_k / years, 0)
        
        output$result <- renderUI({
          HTML(paste0(
            "[Build & Maintenance]<br/>",
            "Total Potassium (K₂O) Recommendation: ", total_k, " lb/a over ", years, " years<br/>",
            "→ ", yearly_k, " lb/a each year"
          ))
        })
      }
    })
  })
}


