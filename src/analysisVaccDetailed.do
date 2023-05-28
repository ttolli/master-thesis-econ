//******************************************************************************
//
// Detailed analysis for vaccinations
//
// Runs the corresponding regressions and probits for making corresponding
// table. Table is also made, and it is Table 5 of the thesis.
//
// Script assumes the data has been read using readAllDhsData, and that stored
// datafiles (.dta) are found from current folder.
//
// Results are outputted as latex tables, hence the syntax for labels
//
// Arguments:
//   * basePath             - repository base path
//   * resultTableFolder    - folder to store result table
//******************************************************************************
args basePath resultTableFolder

// The databases are such a big that stata default for maximum number of
// variables is not enough, and it needs to be increased
// set maxvar 120000

use children2021.dta, clear

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

run `basePath'/src/scripts/createVaccinationVariables

gen sex = b4
gen monthOfBirth = b1

local interestVariables afterCovidStarted afterAndPoor
local monthFixed i.v006
local individualControls sex isHindu isMuslim isChristian isSikh isCaste isTribe
local dependentAndControlsForAll `interestVariables' isPoorState i.v024 i.age i.monthOfBirth isUrban `monthFixed' sex

local validObservations isInProgressState == 1 & isWinterMonths == 1
local baselineConditions e(sample)==1 & `validObservations' & afterCovidStarted==0 & isPoorState == 0
local clusterStdError cluster(sdist)
local weightCommand [iw=wt]
local preCommand quiet probit

local vaccVariables doesNotHaveBCG doesNotHaveDPT1 doesNotHaveDPT2 doesNotHaveDPT3 doesNotHavePolio1 doesNotHavePolio2 doesNotHavePolio3 doesNotHaveMeasles
local vaccVariablesY
local vaccVariablesO

foreach vaccVariable in `vaccVariables' {
    // 1-12 month
    local extraCondition is_1_12 == 1
    `preCommand' `vaccVariable' `dependentAndControlsForAll' `weightCommand' if `validObservations' & `extraCondition', `clusterStdError'
    quiet eststo `vaccVariable'Y: margins, dydx(`interestVariables' isPoorState) post
    sum `vaccVariable' `weightCommand' if `baselineConditions' & `extraCondition'
    local baselineValue "`r(mean)'"
    estadd scalar BaselineHighWealth = `baselineValue'
    local poorState = `baselineValue' + _b[isPoorState]
    estadd scalar BaselineLowWealth = `poorState'

    // 12-24 month
    local extraCondition is_1_12 == 0
    `preCommand' `vaccVariable' `dependentAndControlsForAll' `weightCommand' if `validObservations' & `extraCondition', `clusterStdError'
    quiet eststo `vaccVariable'O: margins, dydx(`interestVariables' isPoorState) post
    sum `vaccVariable' `weightCommand' if `baselineConditions' & `extraCondition'
    local baselineValue "`r(mean)'"
    estadd scalar BaselineHighWealth = `baselineValue'
    local poorState = `baselineValue' + _b[isPoorState]
    estadd scalar BaselineLowWealth = `poorState'

    local vaccVariablesY `vaccVariablesY' `vaccVariable'Y
    local vaccVariablesO `vaccVariablesO' `vaccVariable'O
}

local resultTableName analysisVaccDetailed
local fullTableName `resultTableFolder'/`resultTableName'`tabulatePost'.tex

local commonTableCommand fragment star(* 0.10 ** 0.05 *** 0.01) b(%8.3f) se(%8.3f) label coeflabels(afterCovidStarted "\textit{After}" afterAndPoor "\textit{After} x \textit{LowWealth}") nonumbers keep(`interestVariables') stat(BaselineHighWealth BaselineLowWealth, fmt(%8.3f %8.3f) labels("Baseline High Wealth" "Baseline Low Wealth"))

local subTitles mtitles("BCG" "DPT-1" "DPT-2" "DPT-3" "Polio-1" "Polio-2" "Polio-3" "Measles")

//**** Result tables ***********************************************************

// First, some common helpers for reporting tex tables
local postCaption \caption*{\footnotesize Upper and lower panel shows the corresponding estimate for \textit{\textbf{not} having corresponding vaccination}-outcome variable for children aged 12-24 and 1-12 months, respectively. \textbf{After} is the effect of \textit{after-lockdown}-indicator, and \textbf{After x LowWealth} is the interaction between \textit{After} and belonging into two lowest wealth quintiles. \textbf{Baseline High} and \textbf{Low Wealth} are before-lockdown-means of dependent variable of high and low wealth individuals, respectively. The models are controlled for wealth status, region (urban/rural), state and month fixed effects, as well as children age in months, month of birth and sex.}

local standardErrorsCommand postfoot("\hline\hline \multicolumn{9}{l}{\footnotesize Standard errors in parentheses}\\ \multicolumn{9}{l}{\footnotesize \sym{*} \(p<0.1\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\ \end{tabular} \\ `postCaption' \end{table}")

local preheadCommandPre prehead("\begin{table}[htbp]\centering \footnotesize \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}

local preheadCommandMiddle \begin{tabular}{l*{

local preheadCommandPost }{c}} \hline\hline")

local postheadCommandPre posthead("\hline \\ [-2em] \multicolumn{9}{l}{\textbf{

local postheadCommandPost }} \\")

local tableHeading \footnotesize Marginal probit estimates (\cref{eq:probitModel}) for programme vaccinations

local tableCaption \caption{\label{tab:`resultTableName'} `tableHeading'}

local numberOfRegressions 8
local preheadCommand `preheadCommandPre'`tableCaption'`preheadCommandMiddle'`numberOfRegressions'`preheadCommandPost'

local panelName "Child 12-24 Months, Do Not Have Corresponding Vaccination"
local postHeadCommand `postheadCommandPre'`panelName'`postheadCommandPost'
esttab `vaccVariablesO' using `fullTableName', `preheadCommand' `postHeadCommand' `commonTableCommand' `subTitles' nonumbers noobs replace

local panelName "Child 1-12 Months, Do Not Have Corresponding Vaccination"
local postheadCommandPre posthead("\\ [-2em] \hline \multicolumn{9}{l}{\textbf{
local postHeadCommand `postheadCommandPre'`panelName'`postheadCommandPost'
esttab `vaccVariablesY' using `fullTableName', `postHeadCommand' `commonTableCommand' nomtitles append `standardErrorsCommand'