from shiny import module, ui
from htmltools import TagList

@module.ui
def nitrogen_ui():
    return TagList(
        ui.h2("Nitrogen Fertilizer Recommendation"),

        ui.input_select("crop", "Crop:", choices=[
            "Corn", "Grain Sorghum", "Wheat", "Sunflower", "Oats",
            "Corn Silage", "Sorghum Silage", "Brome", "Fescue", "Bermudagrass"
        ]),

        # Efficiency inputs for select crops
        ui.panel_conditional(
            "['Corn','Grain Sorghum','Wheat'].includes(input.crop)",
            TagList(
                ui.output_ui("ie_input_ui"),
                ui.input_select(
                    "fertilizer", "Fertilizer Efficiency (fe):",
                    choices={
                        "0.55": "Default (0.55) – Broadcast, fall-applied pre-plant",
                        "0.65": "High efficiency (0.65) – Injected or split applied"
                    },
                    selected="0.55"
                ),
                ui.input_select(
                    "texture", "Soil Nitrate-N Efficiency (se):",
                    choices={
                        "1.0": "Low risk (1.0) – Medium texture or western KS",
                        "0.7": "High risk (0.7) – Coarse texture or eastern KS"
                    },
                    selected="1.0"
                )
            )
        ),

        # Standard input panel (non-forage crops)
        ui.panel_conditional(
            "!['Brome','Fescue','Bermudagrass'].includes(input.crop)",
            TagList(
                ui.output_ui("yield_label"),
                ui.input_numeric("om", "Soil Organic Matter (%):", value=2.1, step=0.1, min=0),
                ui.input_numeric("profile_n", "Profile Nitrate-N (lb/a):", value=30, min=0),
                ui.input_numeric("manure_n", "Manure N (lb/a):", value=0, min=0),
                ui.input_numeric("other_n", "Other N Adjustments (lb/a):", value=0, min=0),

                # Tillage shown only for Wheat and Oats
                ui.input_select(
                    "tillage", "Tillage System:",
                    choices={ "0": "Conventional Tillage (0 lb/a)",
                            "20": "No-Tillage (+20 lb/a)" },
                    selected="0"
                ),


                ui.input_select("previous_crop_main", "Previous Crop Adjustment:", choices=[
                    "Corn/Wheat", "Sorghum/Sunflower", "Soybean", "Fallow",
                    "Alfalfa", "Red Clover", "Sweet Clover"
                ]),
                ui.output_ui("previous_crop_detail")
            )
        ),

        # Forage-specific panel
        ui.panel_conditional(
            "['Brome','Fescue','Bermudagrass'].includes(input.crop)",
            TagList(
                ui.input_select("forage_yield", "Expected Yield (ton/a):",
                                choices=[2, 4, 6, 8, 10], selected=6),
                ui.input_checkbox("new_seeding", "New Seeding? (+20 lb N/a)", value=False)
            )
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
def nitrogen_server(input, output, session):
    result_text = reactive.Value("")

    @output
    @render.ui
    def yield_label():
        crop = input.crop()
        label = {
            "Corn": "Expected Yield (bu/a):",
            "Grain Sorghum": "Expected Yield (bu/a):",
            "Wheat": "Expected Yield (bu/a):",
            "Sunflower": "Expected Yield (bu/a):",
            "Oats": "Expected Yield (bu/a):",
            "Corn Silage": "Expected Yield (ton/a):",
            "Sorghum Silage": "Expected Yield (ton/a):",
            "Brome": "Expected Yield (ton/a):",
            "Fescue": "Expected Yield (ton/a):",
            "Bermudagrass": "Expected Yield (ton/a):"
        }.get(crop, "Expected Yield:")
        return ui.input_numeric("yield", label, value=150)

    # Internal efficiency
    @output
    @render.ui
    def ie_input_ui():
        crop = input.crop()

        if crop == "Corn":
            choices = {
                "0.84": "Irrigated (0.84 lbs/bu)",
                "0.88": "Non-Irrigated (0.88 lbs/bu)"
            }
            selected = "0.84"
        elif crop == "Grain Sorghum":
            choices = {
                "1.20": "Default (1.20 lbs/bu)"
            }
            selected = "1.20"
        elif crop == "Wheat":
            choices = {
                "1.45": "Default (1.45 lbs/bu)"
            }
            selected = "1.45"
        else:
            return None

        return ui.input_select(
            "ie_input",
            "Internal Crop Efficiency (ie):",
            choices=choices,
            selected=selected
        )

    @output
    @render.ui
    def previous_crop_detail():
        main = input.previous_crop_main()
        crop_options = {
            "Alfalfa": ["Excellent Stand", "Good Stand", "Fair Stand", "Poor Stand"],
            "Red Clover": ["Excellent Stand", "Good Stand", "Poor Stand"],
            "Sweet Clover": ["Excellent Stand", "Good Stand", "Poor Stand"],
            "Fallow": ["Without Profile N Test", "With Profile N Test"]
        }
        options = crop_options.get(main)
        if options:
            return ui.input_select("previous_crop_condition", "Crop Condition or Management:",
                                   choices=options, selected="Good Stand" if "Good Stand" in options else options[0])
        return None

    @output
    @render.ui
    def result():
        return ui.HTML(result_text())

    @reactive.Effect
    @reactive.event(input.calc)
    def calculate():
        crop = input.crop()
        EY = input["yield"]()
        OM = input.om()
        profile_n = input.profile_n()
        manure_n = input.manure_n()
        other_n = input.other_n()
        main = input.previous_crop_main()
        cond = input["previous_crop_condition"]() if "previous_crop_condition" in input else ""
        print("DEBUG: cond =", cond)

        tillage_adj = int(input.tillage()) if crop in ["Wheat", "Oats"] else 0

        ie = float(input.ie_input()) if crop in ["Corn", "Grain Sorghum", "Wheat"] else None
        fe = float(input.fertilizer()) if crop in ["Corn", "Grain Sorghum", "Wheat"] else None
        se = float(input.texture()) if crop in ["Corn", "Grain Sorghum", "Wheat"] else None


        prev_crop_adj = 0
        if crop in ["Wheat", "Oats"]:
            prev_crop_adj = {
                "Corn/Wheat": 0,
                "Sorghum/Sunflower": 30,
                "Soybean": 0,
                "Fallow": {"With Profile N Test": 0, "Without Profile N Test": -20}.get(cond, 0),
                "Alfalfa": {"Excellent Stand": -60, "Good Stand": -40, "Fair Stand": -20, "Poor Stand": 0}.get(cond, 0),
                "Red Clover": {"Excellent Stand": -40, "Good Stand": -20, "Poor Stand": 0}.get(cond, 0),
                "Sweet Clover": {"Excellent Stand": -55, "Good Stand": -30, "Poor Stand": 0}.get(cond, 0)
            }.get(main, 0)
        else:
            prev_crop_adj = {
                "Corn/Wheat": 0,
                "Sorghum/Sunflower": 0,
                "Soybean": -40,
                "Fallow": {"With Profile N Test": 0, "Without Profile N Test": -20}.get(cond, 0),
                "Alfalfa": {"Excellent Stand": -120, "Good Stand": -80, "Fair Stand": -40, "Poor Stand": 0}.get(cond, 0),
                "Red Clover": {"Excellent Stand": -80, "Good Stand": -40, "Poor Stand": 0}.get(cond, 0),
                "Sweet Clover": {"Excellent Stand": -110, "Good Stand": -60, "Poor Stand": 0}.get(cond, 0)
            }.get(main, 0)

        forage_n_base = {2: 80, 4: 160, 6: 240, 8: 320, 10: 400}.get(int(input.forage_yield()), 0)
        forage_n_extra = 20 if input.new_seeding() else 0

        try:
            if crop == "Corn":
                n = (ie / fe) * EY - se * profile_n - (OM * 20) - manure_n - other_n + prev_crop_adj
            elif crop == "Grain Sorghum":
                n = (ie / fe) * EY - se * profile_n - (OM * 20) - manure_n - other_n + prev_crop_adj
            elif crop == "Wheat":
                n = (ie / fe) * EY - se * profile_n - (OM * 10) - manure_n - other_n + prev_crop_adj + tillage_adj
            elif crop == "Sunflower":
                n = (EY * 0.075) - (OM * 20) - profile_n - manure_n - other_n + prev_crop_adj
            elif crop == "Oats":
                n = (EY * 1.3) - (OM * 10) - profile_n - other_n + prev_crop_adj + tillage_adj
            elif crop in ["Corn Silage", "Sorghum Silage"]:
                n = (EY * 10.67) - (OM * 20) - profile_n - manure_n - other_n + prev_crop_adj
            elif crop in ["Brome", "Fescue", "Bermudagrass"]:
                n = forage_n_base + forage_n_extra
            else:
                n = None
        except:
            n = None

        if n is None:
            result_text.set("Nitrogen recommendation is not available. Please complete all input fields.")
        else:
            n_final = max(0, round(n))
            if n_final == 0:
                result_text.set(
                    "Recommended Nitrogen Rate: 0 lb/a<br/>"
                    "Note: A minimum fertilizer N application of 30 lb N/a is recommended for early crop growth and development."
                )
            else:
                result_text.set(f"Recommended Nitrogen Rate: {n_final} lb/a")
