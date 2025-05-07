from shiny import module, ui, render, reactive
from htmltools import TagList

@module.ui
def sulfur_ui():
    return TagList(
        ui.h2("Sulfur Fertilizer Recommendation"),

        ui.panel_well(
            ui.h4("About These Recommendations"),
            ui.p("Default Profile Sulfur = 25 lb S/a")
        ),

        ui.input_select("crop", "Crop:", choices=[
            "Corn", "Grain Sorghum", "Corn Silage", "Sorghum Silage", "Wheat",
            "Soybean", "Sunflower", "Brome", "Fescue", "Bermudagrass", "Alfalfa"
        ]),
        ui.output_ui("yield_label"),
        ui.input_numeric("om", "Soil Organic Matter (%):", 1.2, min=0, max=100, step=0.1),
        ui.input_numeric("profile_s", "Profile Sulfur (lb/a):", 25, min=0),
        ui.input_numeric("other_s", "Other Sulfur Credits (lb/a):", 0, min=0),

        ui.input_action_button("calc", "Calculate Recommendation"),
        ui.br(), ui.br(),
        ui.div(
            ui.output_ui("result"),
            style="width: 100%; background-color: #f0f0f0; padding: 20px; font-size: 20px; font-weight: bold; border-left: 8px solid black; border-radius: 4px;"
        ),
        ui.br(), ui.br(), ui.br()
    )

@module.server
def sulfur_server(input, output, session):
    # Store output result
    result_text = reactive.Value("")

    @output
    @render.ui
    def yield_label():
        crop = input.crop()
        unit = {
            "Corn": "Expected Yield (bu/a):",
            "Grain Sorghum": "Expected Yield (bu/a):",
            "Corn Silage": "Expected Yield (ton/a):",
            "Sorghum Silage": "Expected Yield (ton/a):",
            "Wheat": "Expected Yield (bu/a):",
            "Soybean": "Expected Yield (bu/a):",
            "Sunflower": "Expected Yield (lb/a):",
            "Brome": "Expected Yield (ton/a):",
            "Fescue": "Expected Yield (ton/a):",
            "Bermudagrass": "Expected Yield (ton/a):",
            "Alfalfa": "Expected Yield (ton/a):"
        }.get(crop, "Expected Yield:")
        return ui.input_numeric("expected_yield", unit, value=160, min=0)

    @output
    @render.ui
    def result():
        return ui.HTML(result_text())

    @reactive.Effect
    @reactive.event(input.calc)
    def calculate_recommendation():
        if "expected_yield" not in input:
            result_text.set("Waiting for yield input...")
            return

        crop = input.crop()
        expected_yield = input["expected_yield"]()
        om = input.om()
        profile_s = input.profile_s()
        other_s = input.other_s()

        factors = {
            "Corn": 0.2,
            "Grain Sorghum": 0.2,
            "Corn Silage": 1.33,
            "Sorghum Silage": 1.33,
            "Wheat": 0.6,
            "Soybean": 0.4,
            "Sunflower": 0.005,
            "Brome": 5.0,
            "Fescue": 5.0,
            "Bermudagrass": 5.0,
            "Alfalfa": 6.0
        }

        s_rec = factors.get(crop, 0) * expected_yield - 2.5 * om - profile_s - other_s
        s_rec = max(int(round(s_rec)), 0)

        result_text.set(f"Recommended Sulfur Rate: {s_rec} lb/a")
