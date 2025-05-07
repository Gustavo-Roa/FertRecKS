from shiny import module, ui
from htmltools import TagList

@module.ui
def potassium_ui():
    return TagList(
        ui.h2("Potassium Fertilizer Recommendation"),

        ui.input_radio_buttons("mode", "Choose Recommendation Strategy:",
            choices=["Sufficiency", "Build & Maintenance"], inline=True
        ),

        # Sufficiency panel
        ui.panel_conditional(
            "input.mode == 'Sufficiency'",
            ui.panel_well(
                ui.h4("Sufficiency Recommendation Considerations"),
                ui.p("Potassium: Mehlich 3 Extractable or Ammonium Acetate Extractable"),
                ui.tags.ul(
                    ui.tags.li("Crop K recommendations are for the total amount of broadcast and banded nutrients to be applied."),
                    ui.tags.li("If soil extractable K is greater than 130 ppm (150 ppm for Bermudagrass or Alfalfa and Clover), then only NPK or NPKS starter fertilizer is suggested."),
                    ui.tags.li("If extractable K is less than 130 ppm (150 ppm for Bermudagrass or Alfalfa and Clover), then the minimum K recommendation is 15 lb K₂O/a"),
                    ui.tags.li("For in-furrow starter fertilizer do not exceed N + K₂O guidelines for fertilizer placed in direct seed contact."),
                    ui.tags.li("Soybean seedlings are particularly sensitive to fertilizer damage, and fertilizer placed in direct seed contact is not recommended.")
                )
            ),
            ui.input_select("crop", "Crop:", choices=[
                "Corn", "Wheat", "Grain Sorghum", "Soybean", "Sunflower", "Oats",
                "Corn Silage", "Sorghum Silage", "Brome and Fescue", "New Brome and Fescue",
                "Bermudagrass", "New Bermudagrass", "Alfalfa and Clover", "New Alfalfa and Clover"
            ]),
            ui.output_ui("yield_label"),
            ui.input_numeric("mehlich_k", "Mehlich-3 K (ppm):", value=100, min=0)
        ),

        # Build & Maintenance panel
        ui.panel_conditional(
            "input.mode == 'Build & Maintenance'",
            ui.panel_well(
                ui.h4("Build & Maintenance Recommendation Considerations"),
                ui.p("Potassium: Mehlich 3 Extractable or Ammonium Acetate Extractable"),
                ui.tags.ul(
                    ui.tags.li("The goal of the initial phase is to build the soil test value to the critical soil test value (CSTV) of 130 ppm "
                               "(150 ppm for Alfalfa and Clover), and subsequently maintain it within the range of 130 to 160 ppm through crop removal replacement."),
                    ui.tags.li("The quantity of K₂O fertilizer required to elevate the soil test K value differs according to soil type, in addition to differences "
                               "in K crop removal, cycling to the soil and soil-K interaction, therefore regular soil sampling is necessary to keep track of soil test levels."),
                    ui.tags.li("Build programs can be designed for various timeframes (e.g., 4 or 6 years), but recommended rates should not be less than those of sufficiency-based fertility programs.")
                )
            ),
            ui.input_select("crop_bm", "Crop:", choices=[
                "Corn", "Wheat", "Grain Sorghum", "Soybean", "Sunflower", "Oats",
                "Corn Silage", "Sorghum Silage", "Alfalfa and Clover"
            ]),
            ui.input_numeric("current_k", "Current K Soil Test (Mehlich-3 ppm):", value=100, min=0),
            ui.input_numeric("years", "Timeframe to Build (years):", value=4, min=0),
            ui.input_numeric("removal", "Annual Crop K₂O Removal (lb/a):", value=80, min=0)
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
def potassium_server(input, output, session):
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
            k = input.mehlich_k()

            if crop is None or yield_val is None or k is None:
                result_text.set("Potassium recommendation is not available. Please complete all input fields.")
                return

            cstv = 150 if crop in ["Bermudagrass", "New Bermudagrass", "Alfalfa and Clover", "New Alfalfa and Clover"] else 130

            if k >= cstv:
                k_rec = 0
            else:
                formulas = {
                    "Corn": lambda y, k: 73 + (y * 0.21) + (k * -0.565) + (y * k * -0.0016),
                    "Wheat": lambda y, k: 62 + (y * 0.24) + (k * -0.48) + (y * k * -0.0018),
                    "Grain Sorghum": lambda y, k: 80 + (y * 0.17) + (k * -0.616) + (y * k * -0.0013),
                    "Soybean": lambda y, k: 60 + (y * 0.628) + (k * -0.46) + (y * k * -0.0048),
                    "Sunflower": lambda y, k: 88 + (y * 0.008) + (k * -0.622) + (y * k * -0.00006),
                    "Oats": lambda y, k: 62 + (y * 0.221) + (k * -0.48) + (y * k * -0.0017),
                    "Corn Silage": lambda y, k: 74 + (y * 1.50) + (k * -0.567) + (y * k * -0.0115),
                    "Sorghum Silage": lambda y, k: 73 + (y * 1.8) + (k * -0.56) + (y * k * -0.0139),
                    "Brome and Fescue": lambda y, k: 41 + (y * 5.85) + (k * -0.315) + (y * k * -0.045),
                    "New Brome and Fescue": lambda y, k: 91 + (y * 15) + (k * -0.7) + (y * k * -0.116),
                    "Bermudagrass": lambda y, k: 75 + (y * 5.3) + (k * -2.56) + (y * k * -0.21),
                    "New Bermudagrass": lambda y, k: 105 + (y * 15) + (k * -0.7) + (y * k * -0.1),
                    "Alfalfa and Clover": lambda y, k: 84 + (y * 5.24) + (k * -0.56) + (y * k * -0.035),
                    "New Alfalfa and Clover": lambda y, k: 105 + (y * 15) + (k * -0.7) + (y * k * -0.1)
                }
                k_rec = formulas[crop](yield_val, k)

            k_rec = max(round(k_rec), 0)

            result_text.set(
                f"[Sufficiency]<br/>Recommended Potassium (K₂O) Rate: {k_rec} lb/a"
            )

        elif mode == "Build & Maintenance":
            current_k = input.current_k()
            years = input.years()
            removal = input.removal()
            crop_bm = input.crop_bm()

            if current_k is None or years is None or removal is None:
                result_text.set("Potassium recommendation is not available. Please complete all input fields.")
                return

            cstv = 150 if crop_bm == "Alfalfa and Clover" else 130
            build_amt = (cstv - current_k) * 9
            total_k = max(round(build_amt + (removal * years)), 0)
            yearly_k = round(total_k / years) if years > 0 else total_k

            result_text.set(
                f"[Build & Maintenance]<br/>"
                f"Total Potassium (K₂O) Recommendation: {total_k} lb/a over {years} years<br/>"
                f"→ {yearly_k} lb/a each year"
            )
