from shiny import module, ui, render, reactive
from htmltools import TagList

@module.ui
def lime_ui():
    return TagList(
        ui.h2("Lime Recommendation Calculator"),

        ui.panel_well(
            ui.h4("About These Recommendations"),
            ui.p(
                "The appropriate target pH varies by region based on subsoil acidity; lime rates are based on 6-inch soil depth. "
                "Soil depth is the depth of lime incorporation through tillage. For no-till systems, alfalfa and grass – assume 2-inch depth of incorporation "
                "(about one third of the rate for 6-inch depth). When lime recommendation exceeds 10,000 lb ECC/a, we suggest applying one-half rate, incorporate, "
                "wait 12 to 18 months and then retest."
            ),
            ui.tags.ul(
                ui.tags.li(
                    ui.tags.strong("Target pH of 6.8 = [28,300 − (7,100 × Buffer pH) + (Buffer pH² × 449)] × Depth (inches)"),
                    ui.tags.ul(
                        ui.tags.li("All crops in southeast Kansas – east of Flint Hills and south of Highway 56"),
                        ui.tags.li("Alfalfa and clover in northeast Kansas"),
                        ui.tags.li("Lime Rec if pH < 6.4")
                    )
                ),
                ui.tags.li(
                    ui.tags.strong("Target pH of 6.0 = [14,100 − (3,540 × Buffer pH) + (Buffer pH² × 224)] × Depth (inches)"),
                    ui.tags.ul(
                        ui.tags.li("All crops in northeast Kansas except alfalfa and clover"),
                        ui.tags.li("All crops in central and western Kansas"),
                        ui.tags.li("Lime Rec if pH < 5.8")
                    )
                ),
                ui.tags.li(
                    ui.tags.strong("Target pH of 5.5 = [7,060 − (1,770 × Buffer pH) + (Buffer pH² × 112)] × Depth (inches)"),
                    ui.tags.ul(
                        ui.tags.li("Cash flow/lime availability problem areas in central and western Kansas"),
                        ui.tags.li("Lime Rec if pH < 5.5")
                    )
                )
            )
        ),

        ui.input_radio_buttons("target", "Select Target pH Strategy:",
            choices=["Target pH 6.8", "Target pH 6.0", "Target pH 5.5"]
        ),
        ui.input_numeric("buffer_ph", "Buffer pH:", value=6.5, step=0.1, min=0),
        ui.input_numeric("depth", "Incorporation Depth (inches):", value=6, min=2, max=12),
        ui.input_action_button("calc", "Calculate Lime Recommendation"),
        ui.br(), ui.br(),
        ui.div(
            ui.output_ui("result"),
            style="width: 100%; background-color: #f0f0f0; padding: 20px; font-size: 20px; font-weight: bold; border-left: 8px solid black; border-radius: 4px;"
        ),
        ui.br(), ui.hr(),
        ui.h4("Quick Table"),
        ui.tags.img(src="lime_table.png", width="60%", alt="Lime Recommendation Table")
    )

@module.server
def lime_server(input, output, session):
    result_text = reactive.Value("")

    @output
    @render.ui
    def result():
        return ui.HTML(result_text())

    @reactive.Effect
    @reactive.event(input.calc)
    def calculate():
        target = input.target()
        buffer_ph = input.buffer_ph()
        depth = input.depth()

        if buffer_ph is None or depth is None:
            result_text.set("Recommendation is not available. Please complete all input fields.")
            return

        formula = {
            "Target pH 6.8": lambda bpH, d: (28300 - (7100 * bpH) + (bpH * bpH * 449)) * d,
            "Target pH 6.0": lambda bpH, d: (14100 - (3540 * bpH) + (bpH * bpH * 224)) * d,
            "Target pH 5.5": lambda bpH, d: (7060 - (1770 * bpH) + (bpH * bpH * 112)) * d,
        }

        calc_func = formula.get(target)
        lime_rec = calc_func(buffer_ph, depth) if calc_func else 0
        lime_rec = max(int(round(lime_rec)), 0)

        result_text.set(f"Lime Recommendation: {lime_rec} lb ECC/a")
