//******************************************************************************
//
// This script collects all the analysis that are needed to run the models and
// build tables and main graphs for the thesis.
//
// Please note possible further documentation at the start of each .do-script.
//
// After data import is done once (readAllDhsData), one can run analysis
// separately, as all the data is read from stored .dta-files thereafter into
// the working folder. Please note that it requires ~16GB disc space.
//
// In addition to main files, there are some additional scripts in scripts-
// folder. It includes also plenty of helper scripts that main .do-scipts use.
//
//******************************************************************************

// Go to the location where you want to store the .dta, files, update this
// path according to your folder struct after cloning the repo

// Win
local basePath C:/Users/ttoll/Documents/src/git/aalto/master-thesis-econ
// Macbook
// local basePath /Users/tuomastolli/Documents/aalto/master-thesis-econ

// These may also need some adjustments
local resultTableFolder `basePath'/docs/tables/
local resultImageFolder `basePath'/docs/images/

// Set this to 0 (zero) if you want to run without edge analysis (column 5 of
// main tables)
local runEdgeAnalysis 1

// Prepare data
//
// Please refer to the start of readAllDhsData to further details before running
// the script.
//
// You need to run this only once. However, if you have run it first without
// edge analysis, and then you want to do edge analysis again, you need to run
// it once more. After that, no need to run anymore, but single analysis scipts
// can be run. All the needed data is stored in corresponding .dta-files, that
// all the analysis-scripts are using
//
// Please note that this takes a considerable amount of time, and stores data
// about 16GB on current running folder.
//
// With a TUF GAMING Z490 having Intel Core TM i9-10850K CPU and 32GB RAM,
// Without edge analysis, the running time is ~30min
// With edge analysis that uses brute-force python implementation, there's
// additional half an our
// With Macbook Pro having Apple M1 SoCs, edge analysis is considerably faster
do `basePath'/src/readAllDhsData `basePath' `runEdgeAnalysis'

// Main analysis -- Tables 1 to 4
// Single run estimates 5 models for all 14 outcome variables, taking ~15min to run
do `basePath'/src/analysisMain `basePath' `resultTableFolder' `runEdgeAnalysis'

// Mean analysis -- Figures 3 to 5
do `basePath'/src/analysisMeans `basePath' `resultImageFolder'

// Balancing tests -- Tables A1 to A4
do `basePath'/src/analysisBalance `basePath' `resultTableFolder'

// Detailed vaccination -- Table 5
do `basePath'/src/analysisVaccDetailed `basePath' `resultTableFolder'

// Detailed nutrition -- Table 6
do `basePath'/src/analysisNutritionDetailed `basePath' `resultTableFolder'

// Stringency -- Table 7
do `basePath'/src/analysisStringency `basePath' `resultTableFolder'