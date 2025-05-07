### modules/home.R

homeUI <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Welcome to FertRecKS"),
    
    p("This Shiny web application provides soil test interpretations and fertilizer recommendations for major crops in Kansas"),
    
    h4("📘 About the Guide"),
    p("The recommendations follow the publication:",
      tags$em("Soil Test Interpretations and Fertilizer Recommendations in Kansas"),
      " (MF2586, January 2024)"),
    tags$a(href = "https://bookstore.ksre.ksu.edu/pubs/MF2586.pdf", "View the full MF2586 publication", target = "_blank"),
    
    h4("App Modules"),
    tags$ul(
      tags$li("Nitrogen – Adjusted for different efficiencies, SOM, prior crop, and others"),
      tags$li("Phosphorus – Choose between Sufficiency and Build & Maintenance strategies"),
      tags$li("Potassium – Choose between Sufficiency and Build & Maintenance strategies"),
      tags$li("Crop Removal – Estimates nutrient removal based on yield goals"),
      tags$li("Sulfur – Sulfur recommendations"),
      tags$li("Micronutrients – Zinc, Boron, and Chloride recommendations"),
      tags$li("Lime – Lime recommendations"),
      
    ),
    
    h4("The following abbreviations are used"),
    tableOutput(ns("abbr_table")),
    
    br(), br()
  )
}

homeServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$abbr_table <- renderTable({
      data.frame(
        Abbreviation = c("B", "Bu", "Cl", "CSTV", "Cu", "DTPA", "ECC", "Fe", "K", "Mn", "Mo", "N", "P", "ppm", "S", "Zn"),
        Meaning = c(
          "Boron", "Bushel", "Chlorine", "Critical Soil Test Value", "Copper",
          "Diethylenetriaminepentaacetic acid", "Effective Calcium Carbonate", "Iron",
          "Potassium", "Manganese", "Molybdenum", "Nitrogen", "Phosphorus",
          "Parts per million", "Sulfur", "Zinc"
        )
      )
    }, striped = TRUE, bordered = TRUE, spacing = "s")
  })
}