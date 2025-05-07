from shiny import module, ui
from htmltools import TagList

@module.ui
def micronutrients_ui():
    return TagList(
        ui.h2("Micronutrient Recommendations"),

        ui.input_radio_buttons("nutrient", "Select a Micronutrient:",
            choices=["Chloride", "Boron", "Zinc"], inline=True
        ),

        # Chloride section
        ui.panel_conditional(
            "input.nutrient == 'Chloride'",
            ui.panel_well(
                ui.h4("Chloride Recommendation"),
                ui.p("Chloride fertilizer is recommended for wheat, corn and sorghum only."),
                ui.p("Chloride: Mercury (II) Thiocyanate Extractable (Colorimetric)"),
                ui.tags.ul(
                    ui.tags.li("< 4 ppm (or <30 lb/a): 20 lb Cl/a"),
                    ui.tags.li("4–6 ppm (30–45 lb/a): 10 lb Cl/a"),
                    ui.tags.li("> 6 ppm (>45 lb/a): No chloride needed")
                )
            ),
            ui.input_numeric("cl_ppm", "Profile Soil Chloride (ppm):", value=5, min=0)
        ),

        # Boron section
        ui.panel_conditional(
            "input.nutrient == 'Boron'",
            ui.panel_well(
                ui.h4("Boron Recommendation"),
                ui.p("Do not band apply boron. Recommendations are for southeast Kansas in alfalfa, corn, sorghum and soybeans only. Test is not well calibrated."),
                ui.p("Boron: DTPA Extractable"),
                ui.tags.ul(
                    ui.tags.li("< 0.5 ppm: 2 lb B/a"),
                    ui.tags.li("0.6–1.0 ppm: 1 lb B/a"),
                    ui.tags.li("> 1.0 ppm: No boron needed")
                )
            ),
            ui.input_numeric("b_ppm", "Extractable Boron (ppm):", value=0.4, min=0)
        ),

        # Zinc section
        ui.panel_conditional(
            "input.nutrient == 'Zinc'",
            ui.panel_well(
                ui.h4("Zinc Recommendation"),
                ui.p("Zinc recommendation is for corn, sorghum and soybeans only."),
                ui.p("Broadcast application is intended to build Zn soil test level to non-responsive range and correct soil deficiency for several years. "
                     "If applied as banded starter at planting, application of about 0.5 – 1.0 lb Zn/a will correct crop deficiency for that crop year. "
                     "Soil deficiency will likely remain."),
                ui.p("Zinc recommendation for wheat, sunflowers, oats, alfalfa, brome, fescue, Bermudagrass and other crops. These crops show little to no response to zinc applications. No application is recommended."),
                ui.p("Zinc: DTPA Extractable"),
                ui.tags.ul(
                    ui.tags.li(
                        ui.tags.strong("Zn Rate = 11.5 − (11.25 × ppm DTPA Zn)"),
                        ui.tags.ul(
                            ui.tags.li("If Zn > 1.0 ppm: No zinc needed"),
                            ui.tags.li("If Zn ≤ 1.0 ppm: Minimum Zn Rec = 1 lb Zn/a")
                        )
                    )
                )
            ),
            ui.input_numeric("zn_ppm", "Extractable Zinc (ppm):", value=0.5, min=0)
        ),

        ui.input_action_button("calc", "Get Recommendation"),
        ui.br(), ui.br(),
        ui.div(
            ui.output_ui("result"),
            style=(
                "width: 100%; background-color: #f0f0f0; padding: 20px; font-size: 20px; "
                "font-weight: bold; border-left: 8px solid black; border-radius: 4px;"
            )
        ),
        ui.br(), ui.br(), ui.br()
    )

from shiny import module, ui, render, reactive


@module.server
def micronutrients_server(input, output, session):
    result_text = reactive.Value("")

    @output
    @render.ui
    def result():
        return ui.HTML(result_text())

    @reactive.Effect
    @reactive.event(input.calc)
    def calculate_recommendation():
        nutrient = input.nutrient()

        # Validate required inputs
        if nutrient is None:
            result_text.set("Recommendation is not available. Please complete all input fields.")
            return

        if nutrient == "Chloride":
            if "cl_ppm" not in input or input["cl_ppm"]() is None:
                result_text.set("Recommendation is not available. Please complete all input fields.")
                return
            ppm = input["cl_ppm"]()
            if ppm < 4:
                recommendation = "20 lb Cl/a"
            elif ppm <= 6:
                recommendation = "10 lb Cl/a"
            else:
                recommendation = "No chloride needed"

        elif nutrient == "Boron":
            if "b_ppm" not in input or input["b_ppm"]() is None:
                result_text.set("Recommendation is not available. Please complete all input fields.")
                return
            ppm = input["b_ppm"]()
            if ppm < 0.5:
                recommendation = "2 lb B/a"
            elif ppm <= 1.0:
                recommendation = "1 lb B/a"
            else:
                recommendation = "No boron needed"

        elif nutrient == "Zinc":
            if "zn_ppm" not in input or input["zn_ppm"]() is None:
                result_text.set("Recommendation is not available. Please complete all input fields.")
                return
            ppm = input["zn_ppm"]()
            if ppm > 1.0:
                recommendation = "No zinc needed"
            else:
                rate = max(1, int(round(11.5 - 11.25 * ppm)))
                recommendation = f"{rate} lb Zn/a"

        else:
            recommendation = "Unknown nutrient selection."

        result_text.set(f"Recommendation for {nutrient}: {recommendation}")
