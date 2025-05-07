from shiny import module, ui
from htmltools import TagList

@module.ui
def crop_removal_ui():
    return TagList(
        ui.h2("Phosphorus and Potassium Crop Removal Estimator"),

        ui.input_radio_buttons(
            "nutrient",
            "Select Nutrient:",
            choices=["Phosphorus (P₂O₅)", "Potassium (K₂O)"],
            inline=True
        ),

        ui.input_select(
            "crop",
            "Select Crop:",
            choices=[
                "Alfalfa & Clover", "Bermudagrass", "Bromegrass", "Fescue, tall",
                "Corn", "Corn silage", "Grain sorghum", "Sorghum silage",
                "Wheat", "Sunflowers", "Oats", "Soybeans", "Native grass"
            ]
        ),

        ui.output_ui("yield_label"),

        ui.input_action_button("calc", "Calculate Crop Removal"),
        ui.br(), ui.br(),
        ui.div(
            ui.output_ui("result"),
            style=(
                "width: 100%; background-color: #f0f0f0; padding: 20px; font-size: 20px; "
                "font-weight: bold; border-left: 8px solid black; border-radius: 4px;"
            )
        ),

        ui.br(), ui.hr(),
        ui.h4("Reference Table: Phosphorus and Potassium Crop Removal Values by Crop"),
        ui.tags.img(src="crop_removal_table.png", width="30%", alt="Crop Removal Values")
    )

from shiny import module, ui, render, reactive
import pandas as pd

@module.server
def crop_removal_server(input, output, session):
    # Create crop data DataFrame
    crop_data = pd.DataFrame({
        "crop": [
            "Alfalfa & Clover", "Bermudagrass", "Bromegrass", "Fescue, tall",
            "Corn", "Corn silage", "Grain sorghum", "Sorghum silage",
            "Wheat", "Sunflowers", "Oats", "Soybeans", "Native grass"
        ],
        "unit": [
            "Ton", "Ton", "Ton", "Ton", "Bushel", "Ton", "Bushel", "Ton",
            "Bushel", "Pound", "Bushel", "Bushel", "Ton"
        ],
        "moisture": [
            "15%", "15%", "15%", "15%", "15.5%", "65%", "15.5%", "65%",
            "13.5%", "10%", "14%", "13%", "15%"
        ],
        "P2O5": [12, 12, 12, 12, 0.33, 3.20, 0.40, 3.20, 0.50, 0.015, 0.25, 0.80, 5.40],
        "K2O": [60, 40, 40, 40, 0.26, 8.70, 0.26, 8.70, 0.40, 0.006, 0.20, 1.40, 30],
    })

    # Result holder
    result_text = reactive.Value("")

    @output
    @render.ui
    def yield_label():
        crop = input.crop()
        row = crop_data[crop_data["crop"] == crop].iloc[0]
        label = f"Enter Yield ({row.unit}/a at {row.moisture}):"
        return ui.input_numeric("yield", label, value=1, min=0)

    @output
    @render.ui
    def result():
        return ui.HTML(result_text())

    @reactive.Effect
    @reactive.event(input.calc)
    def calculate_removal():
        if (
            "yield" not in input
            or input["yield"]() is None
            or input["yield"]() <= 0
            or input.crop() is None
            or input.nutrient() is None
        ):
            result_text.set("Recommendation is not available. Please complete all input fields.")
            return

        crop = input.crop()
        nutrient = input.nutrient()
        yield_val = input["yield"]()

        row = crop_data[crop_data["crop"] == crop].iloc[0]
        coeff = row["P2O5"] if nutrient == "Phosphorus (P₂O₅)" else row["K2O"]
        removal = max(int(round(yield_val * coeff)), 0)

        result_text.set(
            f"Crop: {row.crop}<br/>"
            f"Unit: {row.unit} at {row.moisture}<br/>"
            f"Nutrient: {nutrient}<br/>"
            f"Removal Estimate: {removal} lb/a"
        )


