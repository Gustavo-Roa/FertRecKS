from shiny import App, ui, render, reactive
from pathlib import Path
import os

# Import module functions
try:
    from modules.home import home_ui, home_server
    from modules.general import general_guide_ui, general_guide_server
    from modules.nitrogen import nitrogen_ui, nitrogen_server
    from modules.phosphorus import phosphorus_ui, phosphorus_server
    from modules.potassium import potassium_ui, potassium_server
    from modules.crop_removal import crop_removal_ui, crop_removal_server  
    from modules.sulfur import sulfur_ui, sulfur_server
    from modules.micronutrients import micronutrients_ui, micronutrients_server
    from modules.lime import lime_ui, lime_server

except ImportError as e:
    print(f"Import error: {e}")
    raise

app_ui = ui.page_fluid(
    ui.tags.head(
        ui.include_css("www/styles.css"),
        ui.tags.style("""
            .btn {
                background-color: #000000 !important;
                color: white !important;
                border-color: #000000 !important;
                font-size: 1.2em !important;
                padding: 10px 20px !important;
                border-radius: 6px !important;
            }
        """)
    ),
    ui.h1("Kansas Fertilizer Recommendation Tool"),
    ui.navset_tab(
        ui.nav_panel("Home", home_ui("home")),
        ui.nav_panel("General Guide", general_guide_ui("general")),
        ui.nav_panel("Nitrogen", nitrogen_ui("nitro")),
        ui.nav_panel("Phosphorus", phosphorus_ui("p")),
        ui.nav_panel("Potassium", potassium_ui("k")),
        ui.nav_panel("Crop Removal", crop_removal_ui("removal")), 
        ui.nav_panel("Sulfur", sulfur_ui("s")),
        ui.nav_panel("Micronutrients", micronutrients_ui("micro")),
        ui.nav_panel("Lime", lime_ui("lime")),
    ),
    ui.div(
        {
            "style": """
                position: fixed;
                bottom: 10px;
                right: 15px;
                color: #888;
                font-size: 0.75em;
                text-align: right;
                z-index: 1000;
            """
        },
        ui.HTML("""
            Developed by <strong>Gustavo Roa</strong> with contributions from <strong>Bryan Rutter & Dorivar Ruiz Diaz</strong><br>
            © 2025 · <a href='https://opensource.org/licenses/MIT' target='_blank'>MIT License</a>
        """)
    )
)

def server(input, output, session):
    home_server("home")
    general_guide_server("general", input, output, session)
    nitrogen_server("nitro")
    phosphorus_server("p")
    potassium_server("k")
    crop_removal_server("removal")
    sulfur_server("s")
    micronutrients_server("micro")
    lime_server("lime")

from pathlib import Path

app = App(app_ui, server, static_assets=Path(__file__).parent / "www") 

