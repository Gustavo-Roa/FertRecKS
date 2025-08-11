# FertRecKS

**FertRecKS** is a web-based application that provides **soil test-based fertilizer recommendations** for crops grown in Kansas. The app is built using the official guidelines from Kansas State University’s MF2586 publication and is designed to make soil fertility interpretation and nutrient recommendation easier, faster, and more accessible to agronomists, students, and producers.

---

## 🌾 Purpose

Developed to streamline the complex tables and equations in the MF2586 document, FertRecKS transforms them into a responsive, interactive, and user-friendly tool. The application helps users:

- Input soil test values, crop, yield goals, and other factors
- Receive real-time, accurate nutrient recommendations
- Avoid manual calculation errors

---

## 🚀 Live App

- 🔗 [FertRecKS – R version (V2)](https://ksusoiltesting.shinyapps.io/FertRecKS_App-R-v2/)

This V2 release is the officially published version of FertRecKS, featuring updated design and color scheme for improved usability.  
It is based on the original application code, with changes focused solely on visual presentation.

---

## 💻 Why Both R and Python?

FertRecKS is available in **both R and Python (Shiny for Python)** to support broader accessibility and long-term adaptability. This dual-language structure:

- Supports collaboration across R and Python communities
- Ensures the app can evolve as K-State guidelines change
- Makes the platform more sustainable for future developers

---

## 📦 Modules and Features

The application is modularized by nutrient and functionality:

| Module              | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| `home`              | Welcome page with navigation and overview                                   |
| `general_guide`     | Background on soil testing principles and MF2586 interpretation guidelines   |
| `nitrogen`          | Calculates N requirements based on crop, yield, SOM, residual N, and efficiency |
| `phosphorus`        | Supports both Sufficiency and Build & Maintenance strategies for Phosphorus |
| `potassium`         | Supports both Sufficiency and Build & Maintenance strategies for Potassium  |
| `crop_removal`      | Estimates nutrient removal based on selected crop and yield level            |
| `sulfur`            | Recommends S based on crop demand, organic matter, and soil profile S        |
| `micronutrients`    | Visual guidance for Zn, B, Cl based on MF2586 thresholds                     |
| `lime`              | Calculates lime requirements using buffer pH and soil incorporation depth    |

---

## 📚 Reference

This application is based on the guidelines provided in the publication:

> Ruiz Diaz, D.A., (2024).  
> **Soil Test Interpretations and Fertilizer Recommendations in Kansas (MF2586)**.  
> Kansas State University Agricultural Experiment Station and Cooperative Extension Service.  
> 📄 [Read the full publication](https://bookstore.ksre.ksu.edu/pubs/soil-test-interpretations-and-fertilizer-recommendations_MF2586.pdf)

---

## 👤 About the Developer

**Gustavo Roa** is a Ph.D. candidate in Soil Fertility and Nutrient Management at Kansas State University. Originally from Paraguay, his research englove different studies related nitrogen, phosphorus and sulfur. He is also pursuing an M.S. in Statistics (Data Science and Analytics track), with a strong focus on applying data science to agronomic decision-making.

🌐 Feel free to connect or collaborate: [https://gustavo-roa.github.io/](https://gustavo-roa.github.io/)

---

## 📄 License

This project is open-source and shared under the [CC BY 4.0 License](https://creativecommons.org/licenses/by/4.0/).

---

## 🤝 Contributions

Bug reports and feature suggestions are welcome via GitHub Issues, pull requests or direct contact at groa@ksu.edu. Help us make this tool better for Kansas growers and agronomists!

This project also serves as a starting point for developers and researchers in other states who wish to adapt similar tools based on their local soil test interpretation guidelines. The modular, open-source design allows for easy customization and expansion.


