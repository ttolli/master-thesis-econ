# The Effect of COVID-19 on Health Outcome of Developing Countries -- an Empirical Study on India

## Instructions to run analysis

- Prepare data import, as per instructed at the beginning of *readAllDhsData.do*
- Analysis is mainly written in Stata. Some python-scripts are also run during the analysis, depending on options
    - Several additional packages are used. Before running, make sure they are installed. Additional packages are:
        - **egenmore**: some variable creations
        - **estout**: making LaTeX-tables
        - **shp2dta**: converting shape boundary files to stata when importing GPS-data
        - **grc1leg2**: adding a common legend when creating mean graphs
        - **heatplot**: visualizing stringency across states
        - **palettes**: visualizing stringency across states and making histogram data
        - **colrspace**: visualizing stringency across states and making histogram data
        - **gr0034**: providing state labels with average stringency values in stringency visualization
    - You may install *packageName* using
    ```
    ssc install packageName
    ```
    - Install *gr0034* and *grc1leg2* by clicking the found package after typing
    ```
    search packageName
    ```

- For python, there's *requirements.txt* available for required libraries. You may e.g., run the following to make sure proper libraries are installed

```
pip install -r scripts\requirements.txt
```

- Refer to the instructions at the beginning of *runAll.do*, and thereafter:

```
run runAll.do                     // Runs each analysis needed for the thesis
```

- Alternatively, once data is imported, any analysis can be run separately as well. Maybe easiest is just to take *runAll.do*, keep init-part but uncomment those scripts that are not required. Alternatively, scripts can be run individually, in which case please see the instructions from the beginning of corresponding script:

```
run readAllDhsData.do             // Import data, create necessary variables. Needs to be done only once
run analysisMain.do               // Main analysis (Tables 1-4)
run analysisMean.do               // Trends from past (Figures 3-5)
run analysisBalance.do            // Balancing tests (Tables A1-A4)
run analysisVaccDetailed.do       // Detailed analysis for programme vaccinations (Table 5)
run analysisNutritionDetailed.do  // Detailed analysis for nutrition indicators (Table 6)
run analysisStringency.do         // Stringency analysis (Table 7)
```

- Please note specifically that there are some helper scripts available to ease importing DHS data. Details can be found from the start of *readAllDhsData*

## Folder structure

- **src**:
    - *readAllDhsData.do*: Import data, create and store necessary variables. Needs to be run only once.
    - *runAll.do*: Runs each analysis needed for the thesis
    - *analysisMain.do*: Main analysis
    - *analysisMean.do*: Graphs from the past surveys, including main coefficients
    - *analysisBalance.do*: Balancing tests
    - *analysisVaccDetailed.do*: Detailed analysis for programme vaccinations
    - *analysisNutritionDetailed.do*: Detailed analysis for nutrition indicators
    - *analysisStringency.do*: Stringency analysis
    - **scripts** : miscellaneous helper scripts
        - reading dhs data in, and storing so that can be used by main analysis
        - helpers used by analysis scripts
        - python scripts to do the edge calculations from gps data
        - miscellaneous visualization scripts for the thesis
- **doc** :
    - Thesis report