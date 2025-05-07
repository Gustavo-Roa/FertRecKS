### modules/crop_removal.R

# UI function: Defines the layout and input fields for the tool
cropRemovalUI <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Phosphorus and Potassium Crop Removal Estimator"),
    
    # Nutrient selection: P2O5 or K2O
    radioButtons(
      inputId = ns("nutrient"),
      label = "Select Nutrient:",
      choices = c("Phosphorus (P₂O₅)", "Potassium (K₂O)"),
      inline = TRUE
    ),
    
    # Select the crop of interest
    selectInput(ns("crop"), "Select Crop:", choices = c(
      "Alfalfa & Clover", "Bermudagrass", "Bromegrass", "Fescue, tall",
      "Corn", "Corn silage", "Grain sorghum", "Sorghum silage",
      "Wheat", "Sunflowers", "Oats", "Soybeans", "Native grass"
    )),
    
    # Yield input displayed with crop-specific units and moisture basis
    uiOutput(ns("yield_label")),
    
    # Action and result display
    actionButton(ns("calc"), "Calculate Crop Removal"),
    br(), br(),
    tags$div(
      style = "width: 100%; background-color: #f0f0f0; padding: 20px; font-size: 20px; font-weight: bold; border-left: 8px solid black; border-radius: 4px;",
      uiOutput(ns("result"))),
    
    # Static reference image
    br(), hr(),
    h4("Reference Table: Phosphorus and Potassium Crop Removal Values by Crop"),
    tags$img(src = "crop_removal_table.png", width = "30%", alt = "Crop Removal Values")
  )
}

# Server function: Contains the logic to calculate recommendations based on input
cropRemovalServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    
    
    # Data source for removal coefficients and display units
    crop_data <- data.frame(
      crop = c("Alfalfa & Clover", "Bermudagrass", "Bromegrass", "Fescue, tall", "Corn", "Corn silage",
               "Grain sorghum", "Sorghum silage", "Wheat", "Sunflowers", "Oats", "Soybeans", "Native grass"),
      unit = c("Ton", "Ton", "Ton", "Ton", "Bushel", "Ton", "Bushel", "Ton", "Bushel", "Pound", "Bushel", "Bushel", "Ton"),
      moisture = c("15%", "15%", "15%", "15%", "15.5%", "65%", "15.5%", "65%", "13.5%", "10%", "14%", "13%", "15%"),
      P2O5 = c(12, 12, 12, 12, 0.33, 3.20, 0.40, 3.20, 0.50, 0.015, 0.25, 0.80, 5.40),
      K2O = c(60, 40, 40, 40, 0.26, 8.70, 0.26, 8.70, 0.40, 0.006, 0.20, 1.40, 30),
      stringsAsFactors = FALSE
    )
    
    # Dynamically generate yield input label with units and moisture content
    output$yield_label <- renderUI({
      req(input$crop)
      row <- crop_data[crop_data$crop == input$crop, ]
      label <- paste0("Enter Yield (", row$unit, "/a at ", row$moisture, "):")
      numericInput(session$ns("yield"), label, value = 1, min = 0)
    })
  
    # Calculate nutrient removal on button click
    observeEvent(input$calc, {
      if (is.null(input$yield) || is.null(input$nutrient) || is.null(input$crop) ||
          is.na(input$yield) || input$yield <= 0) {
        output$result <- renderUI({
          HTML("Recommendation is not available. Please complete all input fields.")
        })
        return()
      }
      
      row <- crop_data[crop_data$crop == input$crop, ]
      
      # Get removal coefficient based on nutrient
      coeff <- if (input$nutrient == "Phosphorus (P₂O₅)") row$P2O5 else row$K2O
      removal <- round(input$yield * coeff, 0)
      
      # Display formatted result
      output$result <- renderUI({
        HTML(paste0(
          "Crop: ", row$crop, "<br/>",
          "Unit: ", row$unit, " at ", row$moisture, "<br/>",
          "Nutrient: ", input$nutrient, "<br/>",
          "Removal Estimate: ", removal, " lb/a"
        ))
      })
      
    })
  })
}

