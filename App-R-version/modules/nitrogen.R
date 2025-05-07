### modules/nitrogen.R

# UI function: Defines the layout and input fields for the tool
nitrogenUI <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Nitrogen Fertilizer Recommendation"),
    
    # Select the crop to trigger appropriate logic and inputs
    selectInput(ns("crop"), "Crop:", choices = c(
      "Corn", "Grain Sorghum", "Wheat", "Sunflower", "Oats",
      "Corn Silage", "Sorghum Silage", "Brome", "Fescue", "Bermudagrass"
    )),
    
    # Show efficiency factor selectors ONLY for Corn, Grain Sorghum, and Wheat
    conditionalPanel(
      condition = sprintf("['Corn','Grain Sorghum','Wheat'].includes(input['%s'])", ns("crop")),
      tagList(
        uiOutput(ns("ie_input_ui")),
        selectInput(ns("irrigation"), "Fertilizer Efficiency (fe):",
                    choices = c("Default (0.55) - Broadcast, fall-applied pre-plant" = 0.55,
                                "High Efficiency (0.65) - Injected or split applied" = 0.65)),
        selectInput(ns("texture"), "Soil Nitrate-N Efficiency (se):",
                    choices = c("Low Risk (1.0) - Medium texture or western KS" = 1.0,
                                "High Risk (0.7) - Coarse texture or eastern KS" = 0.7))
      )
    ),
    
    # All regular inputs, shown only for non-forage crops
    conditionalPanel(
      condition = sprintf("!['Brome','Fescue','Bermudagrass'].includes(input['%s'])", ns("crop")),
      tagList(
        uiOutput(ns("yield_label")),
        numericInput(ns("om"), "Soil Organic Matter (%):", value = 2.1, step = 0.1, min = 0),
        numericInput(ns("profile_n"), "Profile Nitrate-N (lb/a):", value = 30, min = 0),
        numericInput(ns("manure_n"), "Manure N (lb/a):", value = 0, min = 0),
        numericInput(ns("other_n"), "Other N Adjustments (lb/a):", value = 0, min = 0),
        
        # Tillage option only shown for Wheat and Oats
        conditionalPanel(
          condition = sprintf("['Wheat','Oats'].includes(input['%s'])", ns("crop")),
          selectInput(ns("tillage"), "Tillage System:",
                      choices = c("Conventional Tillage (0 lb/a)" = 0,
                                  "No-Tillage (+20 lb/a)" = 20),
                      selected = 0)
        ),
        
        # Previous crop adjustment logic
        selectInput(ns("previous_crop_main"), "Previous Crop Adjustment:", choices = c(
          "Corn/Wheat", "Sorghum/Sunflower", "Soybean", "Fallow",
          "Alfalfa", "Red Clover", "Sweet Clover"
        )),
        uiOutput(ns("previous_crop_detail"))
      )
    ),
    
    # Forage-specific logic: only shown for Brome, Fescue, and Bermudagrass
    conditionalPanel(
      condition = sprintf("['Brome','Fescue','Bermudagrass'].includes(input['%s'])", ns("crop")),
      tagList(
        selectInput(ns("forage_yield"), "Expected Yield (ton/a):",
                    choices = c(2, 4, 6, 8, 10), selected = 6),
        checkboxInput(ns("new_seeding"), "New Seeding? (+20 lb N/a)", value = FALSE)
      )
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
nitrogenServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    output$yield_label <- renderUI({
      unit <- switch(input$crop,
                     "Corn" = "Expected Yield (bu/a):",
                     "Grain Sorghum" = "Expected Yield (bu/a):",
                     "Wheat" = "Expected Yield (bu/a):",
                     "Sunflower" = "Expected Yield (bu/a):",
                     "Oats" = "Expected Yield (bu/a):",
                     "Corn Silage" = "Expected Yield (ton/a):",
                     "Sorghum Silage" = "Expected Yield (ton/a):",
                     "Brome" = "Expected Yield (ton/a):",
                     "Fescue" = "Expected Yield (ton/a):",
                     "Bermudagrass" = "Expected Yield (ton/a):"
      )
      numericInput(session$ns("yield"), unit, value = 150)
    })
    
    output$ie_input_ui <- renderUI({
      choices <- switch(input$crop,
                        "Corn" = c("Corn (Irrigated) – 0.84" = 0.84, "Corn (Non-Irrigated) – 0.88" = 0.88),
                        "Grain Sorghum" = c("Grain Sorghum – 1.20" = 1.20),
                        "Wheat" = c("Wheat – 1.45" = 1.45),
                        NULL)
      if (!is.null(choices)) {
        selectInput(session$ns("ie_input"), "Internal Crop Efficiency (ie):", choices = choices)
      }
    })
    
    output$previous_crop_detail <- renderUI({
      detail_choices <- switch(input$previous_crop_main,
                               "Alfalfa" = c("Excellent Stand", "Good Stand", "Fair Stand", "Poor Stand"),
                               "Red Clover" = c("Excellent Stand", "Good Stand", "Poor Stand"),
                               "Sweet Clover" = c("Excellent Stand", "Good Stand", "Poor Stand"),
                               "Fallow" = c("Without Profile N Test", "With Profile N Test"),
                               NULL)
      
      if (!is.null(detail_choices)) {
        selectInput(session$ns("previous_crop_condition"),
                    "Crop Condition or Management:",
                    choices = detail_choices,
                    selected = if ("Good Stand" %in% detail_choices) "Good Stand" else detail_choices[[1]])
      }
    })
    
    observeEvent(input$calc, {
      crop <- input$crop
      EY <- input$yield
      OM <- input$om
      profile_n_lb <- input$profile_n
      manure_n <- input$manure_n
      other_n <- input$other_n
      
      tillage_adj <- 0
      if (crop %in% c("Wheat", "Oats")) {
        req(input$tillage)
        tillage_adj <- as.numeric(input$tillage)
      }
      
      # Internal crop efficiency
      ie <- if (crop %in% c("Corn", "Grain Sorghum", "Wheat")) as.numeric(input$ie_input) else NA
      fe <- if (crop %in% c("Corn", "Grain Sorghum", "Wheat")) as.numeric(input$irrigation) else NA
      se <- if (crop %in% c("Corn", "Grain Sorghum", "Wheat")) as.numeric(input$texture) else NA
      
      # Previous crop adjustment
      main <- input$previous_crop_main
      cond <- if (!is.null(input$previous_crop_condition)) input$previous_crop_condition else ""
      
      if (crop %in% c("Wheat", "Oats")) {
        prev_crop_adj <- switch(main,
                                "Corn/Wheat" = 0,
                                "Sorghum/Sunflower" = +30,
                                "Soybean" = 0,
                                "Fallow" = switch(cond,"With Profile N Test" = 0, "Without Profile N Test" = -20),
                                "Alfalfa" = switch(cond, "Excellent Stand" = -60, "Good Stand" = -40, "Fair Stand" = -20, "Poor Stand" = 0),
                                "Red Clover" = switch(cond, "Excellent Stand" = -40, "Good Stand" = -20, "Poor Stand" = 0),
                                "Sweet Clover" = switch(cond, "Excellent Stand" = -55, "Good Stand" = -30, "Poor Stand" = 0)
        )
      } else {
        prev_crop_adj <- switch(main,
                                "Corn/Wheat" = 0,
                                "Sorghum/Sunflower" = 0,
                                "Soybean" = -40,
                                "Fallow" = switch(cond,"With Profile N Test" = 0, "Without Profile N Test" = -20),
                                "Alfalfa" = switch(cond, "Excellent Stand" = -120, "Good Stand" = -80, "Fair Stand" = -40, "Poor Stand" = 0),
                                "Red Clover" = switch(cond, "Excellent Stand" = -80, "Good Stand" = -40, "Poor Stand" = 0),
                                "Sweet Clover" = switch(cond, "Excellent Stand" = -110, "Good Stand" = -60, "Poor Stand" = 0)
        )
      }
      
      # Nitrogen recommendation
      
      forage_n_base <- switch(as.character(input$forage_yield),
                              "2" = 80, "4" = 160, "6" = 240, "8" = 320, "10" = 400, NA)
      forage_n_extra <- ifelse(isTRUE(input$new_seeding), 20, 0)
      
      n_rec <- switch(crop,
                      "Corn" = (ie / fe) * EY - se * profile_n_lb - (OM * 20) - manure_n - other_n + prev_crop_adj,
                      "Grain Sorghum" = (ie / fe) * EY - se * profile_n_lb - (OM * 20) - manure_n - other_n + prev_crop_adj,
                      "Wheat" = (ie / fe) * EY - se * profile_n_lb - (OM * 10) - manure_n - other_n + prev_crop_adj + tillage_adj,
                      
                      "Sunflower" = (EY * 0.075) - (OM * 20) - profile_n_lb - manure_n - other_n + prev_crop_adj,
                      "Oats" = (EY * 1.3) - (OM * 10) - profile_n_lb - other_n + prev_crop_adj + tillage_adj,
                      "Corn Silage" = (EY * 10.67) - (OM * 20) - profile_n_lb - manure_n - other_n + prev_crop_adj,
                      "Sorghum Silage" = (EY * 10.67) - (OM * 20) - profile_n_lb - manure_n - other_n + prev_crop_adj,
                      
                      "Brome" = forage_n_base + forage_n_extra,
                      "Fescue" = forage_n_base + forage_n_extra,
                      "Bermudagrass" = forage_n_base + forage_n_extra,
      )
      
      output$result <- renderUI({
        if (is.na(n_rec)) {
          HTML("Nitrogen recommendation is not available. Please complete all input fields.")
        } else {
          n_final <- max(0, round(n_rec))  # Ensure non-negative  
          
          if (n_final == 0) {
            HTML(paste0(
              "Recommended Nitrogen Rate: 0 lb/a<br/>",
              "Note: A minimum fertilizer N application of 30 lb N/a is recommended for early crop growth and development."
            ))
          } else {
            HTML(paste0("Recommended Nitrogen Rate: ", n_final, " lb/a"))
          }
        }
      })
      
    })
  })
}
