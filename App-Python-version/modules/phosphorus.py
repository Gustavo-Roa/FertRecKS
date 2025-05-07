from shiny import module, ui
from htmltools import TagList

@module.ui
def phosphorus_ui():
    return TagList(
        ui.h2("Phosphorus Fertilizer Recommendation"),

        ui.input_radio_buttons("mode", "Choose Recommendation Strategy:",
            choices=["Sufficiency", "Build & Maintenance"], inline=True
        ),

        # Sufficiency panel
        ui.panel_conditional(
            "input.mode == 'Sufficiency'",
            ui.panel_well(
                ui.h4("Sufficiency Recommendation Considerations"),
                ui.p("Phosphorus: Mehlich 3 Extractable P (Colorimetric) or Bray P1 Extractable P"),
                ui.p("Olsen P – multiply by 1.6 and interpret similarly to Mehlich 3 Colorimetric"),
                ui.tags.ul(
                    ui.tags.li("Crop P recommendations are for the total amount of broadcast and banded nutrients to be applied. "
                               "At a very low soil test level, applying at least 25 to 50% of total as a band is recommended."),
                    ui.tags.li("If Mehlich-3 P is greater than 20 ppm (25 ppm for Bermudagrass or Alfalfa and Clover), then only starter fertilizer is suggested, "
                               "and defined as a maximum of 20 lb P₂O₅/a applied at planting."),
                    ui.tags.li("If Mehlich-3 P is less than 20 ppm (25 ppm for Bermudagrass or Alfalfa and Clover), then the minimum P recommendation is 15 lb P₂O₅/a."),
                    ui.tags.li("Application of starter fertilizer containing NP, NPK or NPKS may be beneficial regardless of P soil test level, "
                               "especially for cold/wet soil conditions and/or high surface crop residues."),
                    ui.tags.li("Wheat and Oats is generally considered more responsive to band-applied P fertilizer."),
                    ui.tags.li("Soybean seedlings are particularly sensitive to fertilizer damage, and fertilizer placed in direct seed contact is not recommended.")
                )
            ),
            ui.input_select("crop", "Crop:", choices=[
                "Corn", "Wheat", "Grain Sorghum", "Soybean", "Sunflower", "Oats",
                "Corn Silage", "Sorghum Silage", "Brome and Fescue", "New Brome and Fescue",
                "Bermudagrass", "New Bermudagrass", "Alfalfa and Clover", "New Alfalfa and Clover"
            ]),
            ui.output_ui("yield_label"),
            ui.input_numeric("mehlich", "Mehlich-3 P (ppm):", value=10, min=0)
        ),

        # Build & Maintenance panel
        ui.panel_conditional(
            "input.mode == 'Build & Maintenance'",
            ui.panel_well(
                ui.h4("Build & Maintenance Recommendation Considerations"),
                ui.p("Phosphorus: Mehlich 3 Extractable P (Colorimetric) or Bray P1 Extractable P"),
                ui.p("Olsen P – multiply by 1.6 and interpret similarly to Mehlich 3 Colorimetric"),
                ui.tags.ul(
                    ui.tags.li("The goal of the initial phase is to build the soil test value to the critical soil test value (CSTV) of 20 ppm "
                               "(25 ppm for Alfalfa and Clover), and subsequently maintain it within the range of 20 to 30 ppm through crop removal replacement."),
                    ui.tags.li("The quantity of P₂O₅ fertilizer required to elevate the soil test P value differs according to soil type, "
                               "in addition to differences in P removal and cycling, therefore regular soil sampling is necessary to keep track of soil test levels."),
                    ui.tags.li("Build programs can be designed for various timeframes (e.g., 4 or 6 years), but recommended rates should not be less than those of sufficiency-based fertility programs.")
                )
            ),
            ui.input_select("crop_bm", "Crop:", choices=[
                "Corn", "Wheat", "Grain Sorghum", "Soybean", "Sunflower", "Oats",
                "Corn Silage", "Sorghum Silage", "Alfalfa and Clover"
            ]),
            ui.input_numeric("current_p", "Current P Soil Test (Mehlich-3 ppm):", value=10, min=0),
            ui.input_numeric("years", "Timeframe to Build (years):", value=4, min=0),
            ui.input_numeric("removal", "Annual Crop P₂O₅ Removal (lb/a):", value=60, min=0)
        ),

        ui.input_action_button("calc", "Calculate Recommendation"),
        ui.br(), ui.br(),
        ui.div(
            ui.output_ui("result"),
            style="width: 100%; background-color: #f0f0f0; padding: 20px; font-size: 20px; font-weight: bold; border-left: 8px solid black; border-radius: 4px;"
        ),
        ui.br(), ui.br(), ui.br()
    )

from shiny import module, ui, render, reactive

@module.server
def phosphorus_server(input, output, session):
    result_text = reactive.Value("")

    @output
    @render.ui
    def yield_label():
        crop = input.crop()
        unit = {
            "Corn": "Expected Yield (bu/a):",
            "Wheat": "Expected Yield (bu/a):",
            "Grain Sorghum": "Expected Yield (bu/a):",
            "Soybean": "Expected Yield (bu/a):",
            "Sunflower": "Expected Yield (lb/a):",
            "Oats": "Expected Yield (bu/a):",
            "Corn Silage": "Expected Yield (ton/a):",
            "Sorghum Silage": "Expected Yield (ton/a):",
            "Brome and Fescue": "Expected Yield (ton/a):",
            "New Brome and Fescue": "Expected Yield (ton/a):",
            "Bermudagrass": "Expected Yield (ton/a):",
            "New Bermudagrass": "Expected Yield (ton/a):",
            "Alfalfa and Clover": "Expected Yield (ton/a):",
            "New Alfalfa and Clover": "Expected Yield (ton/a):"
        }.get(crop, "Expected Yield:")
        return ui.input_numeric("yield", unit, value=150, min=0)

    @output
    @render.ui
    def result():
        return ui.HTML(result_text())

    @reactive.Effect
    @reactive.event(input.calc)
    def calculate():
        mode = input.mode()

        if mode == "Sufficiency":
            crop = input.crop()
            yield_val = input["yield"]()
            p = input.mehlich()

            if crop is None or yield_val is None or p is None:
                result_text.set("Phosphorus recommendation is not available. Please complete all input fields.")
                return

            cstv = 25 if crop in ["Bermudagrass", "New Bermudagrass", "Alfalfa and Clover", "New Alfalfa and Clover"] else 20

            if p >= cstv:
                p_rec = 0
            else:
                formulas = {
                    "Corn": lambda y, p: 50 + (y * 0.2) + (p * -2.5) + (y * p * -0.01),
                    "Wheat": lambda y, p: 46 + (y * 0.42) + (p * -2.3) + (y * p * -0.021),
                    "Grain Sorghum": lambda y, p: 50 + (y * 0.16) + (p * -2.5) + (y * p * -0.008),
                    "Soybean": lambda y, p: 56 + (y * 0.51) + (p * -2.8) + (y * p * -0.0257),
                    "Sunflower": lambda y, p: 42 + (y * 0.01) + (p * -2.1) + (y * p * -0.0005),
                    "Oats": lambda y, p: 47 + (y * 0.25) + (p * -2.3) + (y * p * -0.013),
                    "Corn Silage": lambda y, p: 56 + (y * 1.12) + (p * -2.8) + (y * p * -0.056),
                    "Sorghum Silage": lambda y, p: 48 + (y * 1.19) + (p * -2.38) + (y * p * -0.0594),
                    "Brome and Fescue": lambda y, p: 44 + (y * 6.3) + (p * -2.2) + (y * p * -0.315),
                    "New Brome and Fescue": lambda y, p: 68 + (y * 11.2) + (p * -2.2) + (y * p * -0.315),
                    "Bermudagrass": lambda y, p: 64 + (y * 5.3) + (p * -2.56) + (y * p * -0.21),
                    "New Bermudagrass": lambda y, p: 64 + (y * 9.1) + (p * -2.56) + (y * p * -0.21),
                    "Alfalfa and Clover": lambda y, p: 73 + (y * 4.56) + (p * -2.92) + (y * p * -0.18),
                    "New Alfalfa and Clover": lambda y, p: 84 + (y * 12) + (p * -3.37) + (y * p * -0.48),
                }
                p_rec = formulas[crop](yield_val, p)

            p_rec = max(round(p_rec), 0)

            result_text.set(
                f"[Sufficiency]<br/>Recommended Phosphorus (P₂O₅) Rate: {p_rec} lb/a"
            )

        elif mode == "Build & Maintenance":
            current_p = input.current_p()
            years = input.years()
            removal = input.removal()
            crop_bm = input.crop_bm()

            if current_p is None or years is None or removal is None:
                result_text.set("Phosphorus recommendation is not available. Please complete all input fields.")
                return

            cstv = 25 if crop_bm == "Alfalfa and Clover" else 20
            build_amt = (cstv - current_p) * 18
            total_p = max(round(build_amt + (removal * years)), 0)
            yearly_p = round(total_p / years) if years > 0 else total_p

            result_text.set(
                f"[Build & Maintenance]<br/>"
                f"Total Phosphorus (P₂O₅) Recommendation: {total_p} lb/a over {years} years<br/>"
                f"→ {yearly_p} lb/a each year"
            )
