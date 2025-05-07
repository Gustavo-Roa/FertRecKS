from shiny import ui, render, module
import pandas as pd

@module.ui
def home_ui():
    return ui.div(
        ui.h2("Welcome to FertRecKS"),
        ui.p(
            "This Shiny web application provides soil test interpretations and fertilizer recommendations for major crops in Kansas"
        ),
        ui.h4("📘 About the Guide"),
        ui.p(
            "The recommendations follow the publication: ",
            ui.tags.em("Soil Test Interpretations and Fertilizer Recommendations in Kansas"),
            " (MF2586, January 2024)"
        ),
        ui.p(
            ui.a(
                "View the full MF2586 publication",
                href="https://bookstore.ksre.ksu.edu/pubs/MF2586.pdf",
                target="_blank",
                rel="noopener noreferrer"
            )
        ),

        ui.h4("App Modules"),
        ui.tags.ul(
            ui.tags.li("Nitrogen – Adjusted for different efficiencies, SOM, prior crop, and others"),
            ui.tags.li("Phosphorus – Choose between Sufficiency and Build & Maintenance strategies"),
            ui.tags.li("Potassium – Choose between Sufficiency and Build & Maintenance strategies"),
            ui.tags.li("Crop Removal – Estimates nutrient removal based on yield goals"),
            ui.tags.li("Sulfur – Sulfur recommendations"),
            ui.tags.li("Micronutrients – Zinc, Boron, and Chloride recommendations"),
            ui.tags.li("Lime – Lime recommendations"),
        ),

        ui.output_ui("abbr_table"),
        ui.br(), ui.br()
    )

@module.server
def home_server(input, output, session):
    @output
    @render.ui
    def abbr_table():
        import pandas as pd

        df = pd.DataFrame({
            "Abbreviation": ["B", "Bu", "Cl", "CSTV", "Cu", "DTPA", "ECC", "Fe", "K", "Mn", "Mo", "N", "P", "ppm", "S", "Zn"],
            "Meaning": [
                "Boron", "Bushel", "Chlorine", "Critical Soil Test Value", "Copper",
                "Diethylenetriaminepentaacetic acid", "Effective Calcium Carbonate", "Iron",
                "Potassium", "Manganese", "Molybdenum", "Nitrogen", "Phosphorus",
                "Parts per million", "Sulfur", "Zinc"
            ]
        })

        html = df.to_html(
            index=False,
            border=0,
            classes="table table-bordered table-sm",
            justify="left"
        )

        return ui.HTML(f"""
        <div style="max-width: 500px;">
            <h4 style="margin-bottom: 10px;">The following abbreviations are used</h4>
            {html}
        </div>
        """)



