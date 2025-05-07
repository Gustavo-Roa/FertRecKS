generalGuideUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2("General Guide"),
    div(
        p("Development of sound nutrient management programs involves understanding a wide range of information. Soil test records are an important piece of that information, but other factors, such as soil moisture conditions, land ownership/tenure, crop and cropping sequence, pest management, cultural practices, environmental issues, and other management items are vital for developing sound nutrient management programs. It is beyond the scope of this publication to detail the ramifications of all these factors, but they should not be overlooked when finalizing nutrient application programs."),
        p("The following tables, equations, and accompanying information are the most recent soil test interpretations for major crops for the most commonly deficient plant nutrients in Kansas. These interpretations are valid for interpreting soil test values from the KSU Soil Testing Laboratory and other laboratories using the same soil testing procedures."),
        
        h3("Expected Yield"),
        p("Suggested recommended application rates are tied to expected yields for several nutrients. Yield records should be used to set an individual and realistic, but progressive, expected yield for each field. An appropriate expected yield for a specific field should be high enough to take advantage of high production years when they occur, but not so high as to jeopardize environmental stewardship and/or profitability when environmental conditions are not favorable. Appropriate expected yield should be about 105% of the average yield obtained in a field over the past three to five years."),
        
        h3("Appropriate Soil Test Procedures"),
        p("These soil test interpretations are based on the following soil test procedures: All tests referred to in this publication are among the tests recommended for the North Central Region by the NCERA-13 Regional Committee on Soil Testing and Plant Analysis. These are described in the North Central Regional Publication 221 (Revised 2012) Recommended Chemical Soil Test Procedures for the North Central Region."),
        tags$div(
          tags$b("Soil pH:"), " 1:1 Water pH", tags$br(),
          tags$b("Buffer pH:"), " Sikora Buffer (determines lime requirement)", tags$br(),
          tags$b("Nitrogen:"), " Available Nitrate-N", tags$br(),
          tags$b("Phosphorus:"), tags$br(),
          HTML("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Mehlich 3 Extractable P (Colorimetric)"), tags$br(),
          HTML("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Bray P1 Extractable P"), tags$br(),
          HTML("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Olsen P – multiply by 1.6 and interpret similarly to Mehlich 3 Colorimetric"), tags$br(),
          tags$b("Potassium:"), " Mehlich 3 Extractable or Ammonium Acetate Extractable", tags$br(),
          tags$b("Zinc, Iron and Boron:"), " DTPA Extractable", tags$br(),
          tags$b("Sulfur:"), " Calcium Phosphate Extractable Sulfate", tags$br(),
          tags$b("Chloride:"), " Mercury (II) Thiocyanate Extractable (Colorimetric)"),
        
        h3("Soil pH and Liming Interpretations"),
        p("The Sikora buffer pH is determined and used for lime rate calculations in acidic soils. Options are provided for liming to various target pHs and information is provided for various areas of the state to aid in selection of an appropriate target pH, based on subsoil acidity and crops to be grown."),
        
        h3("Phosphorus and Potassium Interpretations"),
        p("Kansas State University phosphorus and potassium recommendations provide two main options for producers, depending on circumstances for specific producers, fields and situations."),
        p("‘Sufficiency’ fertility programs are intended to estimate the long-term fertilizer phosphorus or potassium required to provide optimum economic return in the year of nutrient application while achieving about 90 to 95% of maximum yield. In some years, greater amounts of nutrient are required for optimum yield and economic return, while in other years less than recommended amounts of nutrient would suffice. There is little consideration of future soil test values, and soil test values will likely stabilize in the ‘low’ (i.e., deficient) sufficiency range."),
        p("“Build-maintenance” recommendations are intended to apply enough phosphorus or potassium to build soil test range to a target soil test value over a planned time frame (typically four to eight years) and then maintain soil test values in a target range in future years. If the soil test is within the target range, then recommended nutrient application rates are equal to crop removal. If soil test values exceed the target range, no phosphorus or potassium is recommended with the exception of low starter applied rates, if desired. Build-maintenance fertility programs are not intended to provide optimum economic returns in a given year, but rather attempt to minimize the probability of phosphorus or potassium limiting crop yields while providing for near maximum yield potential."),
        p("The nutrient concentrations per unit of yield for various agronomic crops are presented in Table 1 (Crop Removal Module), which can be used in conjunction with yield data to calculate the total crop removal over a period of time."),
        
        h3("Secondary/Micronutrient Interpretations"),
        p("The KSU Soil Testing Lab offers soil tests and interpretations for sulfur, zinc, chloride, iron, and boron. Detailed information is provided for interpreting soil test values for these nutrients and for recommending rates of application if they are deficient. To date in Kansas, we have not documented deficiencies of manganese (Mn), copper (Cu), or molybdenum (Mo) and do not offer interpretations for these micronutrients."), 
        
        h3("Nitrogen Recommendations"),
        p("The nitrogen requirement for a specific crop and expected yield is adjusted by considering many field specific factors. The K-State nitrogen recommendation guidelines for all crops are directly adjusted for soil organic matter content. Twenty pounds of available nitrogen per acre is expected to be mineralized during the crop year for each 1.0% soil organic matter in the surface 6 inches for warm season crops (e.g., corn, grain sorghum), while 10 pounds nitrogen per acre is expected to be mineralized for each 1.0% soil organic matter for cool season crops (e.g., wheat). In addition, the previous crop, residual profile nitrogen, manure applications, irrigation water nitrogen content, grazing nitrogen removal and the tillage system used are additional factors used to refine suggested nitrogen application rates for specific crop situations. Detailed information for major crops is provided. Since nitrate (NO3-N) is mobile, we encourage use of a 0- to 24-inch soil sample to assess the profile nitrogen content (also for sulfate and chloride as they are mobile in soils as well)."), 
        p("How and when nitrogen is applied can have a dramatic effect on how efficiently it will be used by the crop. For example, using delayed or split nitrogen applications on irrigated fields, particularly on sandy soils, often improves nitrogen use efficiency by reducing the potential for loss. Also, for high residue systems such as no-till, placing fertilizer nitrogen below the residue or dribbling nitrogen solution in concentrated bands on the soil surface offers the potential for improved nitrogen use efficiency for summer crops. Many factors other than application rate influence nitrogen use efficiency and should be considered when developing the overall nutrient management plan. The Kansas State University nitrogen recommendation guidelines offer efficiency factor adjustments based on crop and fertilizer management.") 
        
    ),
    br(), br(), br(),
  )
}

generalGuideServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # No server-side logic needed
  })
}
