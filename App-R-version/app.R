library(shiny)
#library(bslib)
#library(shinyWidgets)


# Load all module files
source("modules/home.R")
source("modules/general.R")
source("modules/nitrogen.R")
source("modules/phosphorus.R")
source("modules/potassium.R")
source("modules/crop_removal.R")
source("modules/sulfur.R")
source("modules/micronutrients.R")
source("modules/lime.R")
source("utils/reset_recommendation.R")


# Define the UI for the application
ui <- fluidPage(
  #theme = bs_theme(bootswatch = "sandstone"),  # https://bootswatch.com/
  
  tags$head(
    tags$style(HTML("
    .btn {
      background-color: #000000 !important;
      color: white !important;
      border-color: #000000 !important;
      font-size: 1.7rem !important;   /* Slightly larger text */
      padding: 10px 20px !important;   /* More height and width */
      border-radius: 6px !important;   /* Rounded corners */
    }
  "))
  ),
  

  titlePanel("Kansas Fertilizer Recommendation Tool"),
  
  # Navigation bar with a tab for each module
  navbarPage("",
             tabPanel("Home", homeUI("home")),
             tabPanel("General Guide", icon = icon("book-open"), generalGuideUI("general")),
             tabPanel("Nitrogen", nitrogenUI("nitro")),
             tabPanel("Phosphorus", phosphorusUI("p")),
             tabPanel("Potassium", potassiumUI("k")),
             tabPanel("Crop Removal", cropRemovalUI("removal")),
             tabPanel("Sulfur", sulfurUI("s")),
             tabPanel("Micronutrients", micronutrientsUI("micro")),
             tabPanel("Lime", limeUI("lime"))
  ), 
  
  # Bottom corner footer
  tags$div(
    style = "
    position: fixed;
    bottom: 10px;
    right: 15px;
    color: #888;
    font-size: 0.75em;
    text-align: right;
    z-index: 1000;",
    HTML("Developed by <strong>Gustavo Roa</strong> with contributions from <strong>Bryan Rutter & Dorivar Ruiz Diaz</strong><br>
         © 2025 · <a href='https://opensource.org/licenses/MIT' target='_blank'>MIT License</a>")
    
  )
)

# Define server logic for each module
server <- function(input, output, session) {
  homeServer("home")
  generalGuideUI("general")
  nitrogenServer("nitro")
  phosphorusServer("p")
  potassiumServer("k")
  cropRemovalServer("removal")
  sulfurServer("s")
  micronutrientsServer("micro") 
  limeServer("lime")
}

# Launch the application
shinyApp(ui, server)
