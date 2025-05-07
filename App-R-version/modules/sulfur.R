### modules/sulfur.R

# UI function: Defines the layout and input fields for the tool
sulfurUI <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Sulfur Fertilizer Recommendation"),
    
    # Static description of default assumptions
    wellPanel(
    h4("About These Recommendations"),
    p("Default Profile Sulfur = 25 lb S/a")
    ),
    
    # User inputs for crop and field-specific values
    selectInput(ns("crop"), "Crop:", choices = c(
      "Corn", "Grain Sorghum", "Corn Silage", "Sorghum Silage", "Wheat", "Soybean", "Sunflower",
      "Brome", "Fescue", "Bermudagrass", "Alfalfa"
    )),
    
    # Dynamic yield label based on crop
    uiOutput(ns("yield_label")),
    
    # Additional field and soil inputs
    numericInput(ns("om"), "Soil Organic Matter (%):", value = 1.2, step = 0.1, min = 0, max = 100),
    numericInput(ns("profile_s"), "Profile Sulfur (lb/a):", value = 25, min = 0),
    numericInput(ns("other_s"), "Other Sulfur Credits (lb/a):", value = 0, min = 0),
    
    # Action button to run calculation and show result
    actionButton(ns("calc"), "Calculate Recommendation"),
    br(), br(),
    tags$div(
      style = "width: 100%; background-color: #f0f0f0; padding: 20px; font-size: 20px; 
      font-weight: bold; border-left: 8px solid black; border-radius: 4px;",
      uiOutput(ns("result"))
      ), 
    
    br(), br(), br(),
  )
}

# Server function: Contains the logic to calculate recommendations based on inputs
sulfurServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Dynamically adjust the yield input label based on selected crop
    output$yield_label <- renderUI({
      unit <- switch(input$crop,
                     "Corn" = "Expected Yield (bu/a):",
                     "Grain Sorghum" = "Expected Yield (bu/a):",
                     "Corn Silage" = "Expected Yield (ton/a):",
                     "Sorghum Silage" = "Expected Yield (ton/a):",
                     "Wheat" = "Expected Yield (bu/a):",
                     "Soybean" = "Expected Yield (bu/a):",
                     "Sunflower" = "Expected Yield (lb/a):",
                     "Brome" = "Expected Yield (ton/a):",
                     "Fescue" = "Expected Yield (ton/a):",
                     "Bermudagrass" = "Expected Yield (ton/a):",
                     "Alfalfa" = "Expected Yield (ton/a):"
      )
      numericInput(session$ns("yield"), unit, value = 150, min = 0)
    })
    
    # Perform sulfur recommendation calculation on button click
    observeEvent(input$calc, {
      crop <- input$crop
      yield <- input$yield
      om <- input$om
      profile_s <- input$profile_s
      other_s <- input$other_s
      
      # Crop-specific sulfur recommendation formula
      s_rec <- switch(crop,
                      "Corn" = 0.2 * yield - (2.5 * om) - profile_s - other_s,
                      "Grain Sorghum" = 0.2 * yield - (2.5 * om) - profile_s - other_s,
                      "Corn Silage" = 1.33 * yield - (2.5 * om) - profile_s - other_s,
                      "Sorghum Silage" = 1.33 * yield - (2.5 * om) - profile_s - other_s,
                      "Wheat" = 0.6 * yield - (2.5 * om) - profile_s - other_s,
                      "Soybean" = 0.4 * yield - (2.5 * om) - profile_s - other_s,
                      "Sunflower" = 0.005 * yield - (2.5 * om) - profile_s - other_s,
                      "Brome" = 5.0 * yield - (2.5 * om) - profile_s - other_s,
                      "Fescue" = 5.0 * yield - (2.5 * om) - profile_s - other_s,
                      "Bermudagrass" = 5.0 * yield - (2.5 * om) - profile_s - other_s,
                      "Alfalfa" = 6.0 * yield - (2.5 * om) - profile_s - other_s
      )
      
      # Validate inputs
      if (is.null(crop) || is.null(yield) || is.null(om) || is.null(profile_s) || is.null(other_s) ||
          is.na(yield) || is.na(om) || is.na(profile_s) || is.na(other_s)) {
        output$result <- renderUI({
          HTML("Sulfur recommendation is not available. Please complete all input fields.")
        })
        return()
      }
      
      # Round and correct negative values
      s_rec <- round(s_rec, 1)
      if (s_rec < 0) s_rec <- 0
      
      # Display formatted result
      output$result <- renderUI({
        HTML(paste0("Recommended Sulfur Rate: ", s_rec, " lb/a"))
      })
    })
  })
}
