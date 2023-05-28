//******************************************************************************
//
// Detailed analysis for nutrition -- dietary diversity and meal frequency, as
// well as combined minimum acceptable diet
//
// Runs the corresponding regressions and probits for making corresponding
// table. Table is also made, and it is Table 6 of the thesis.
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

local resultTableName analysisNutritionDetailed
local fullTableName `resultTableFolder'/`resultTableName'`tabulatePost'.tex

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

run `basePath'/src/scripts/createChildNutritionVariables `basePath'

gen sex = b4
gen monthOfBirth = b1
gen age = hw1

local interestVariables afterCovidStarted afterAndPoor
local monthFixed i.v006
local individualControls sex isHindu isMuslim isChristian isSikh isCaste isTribe
local dependentAndControlsForAll `interestVariables' isPoorState i.v024 i.age i.monthOfBirth isUrban `monthFixed' sex

local validObservations isInProgressState == 1 & isWinterMonths == 1
local baselineConditions e(sample)==1 & `validObservations' & afterCovidStarted==0 & isPoorState == 0
local clusterStdError cluster(sdist)
local weightCommand [iw=wt]
local preCommand quiet probit
local breastFeedExtraCondition m4 == 95 & b19 >= 6 & b19 <= 23
local nonBreastFeedExtraCondition m4 != 95 & b19 >= 6 & b19 <= 23

local nutritionVariables nMinDietDiversity nMinMealFreq nMinAcceptDiet
local nutritionVariablesBFeed
local nutritionVariablesNonBFeed

foreach nutritionVariable in `nutritionVariables' {
    local variable `nutritionVariable'BFeed
    `preCommand' `variable' `dependentAndControlsForAll' `weightCommand' if `validObservations' & `breastFeedExtraCondition', `clusterStdError'
    eststo `variable'R: margins, dydx(`interestVariables' isPoorState) post
    sum `variable' `weightCommand' if `baselineConditions' & `breastFeedExtraCondition'
    local baselineValue "`r(mean)'"
    estadd scalar BaselineHighWealth = `baselineValue'
    local poorState = `baselineValue' + _b[isPoorState]
    estadd scalar BaselineLowWealth = `poorState'
    local nutritionVariablesBFeed `nutritionVariablesBFeed' `variable'R

    local variable `nutritionVariable'NonBFeed
    `preCommand' `variable' `dependentAndControlsForAll' `weightCommand' if `validObservations' & `nonBreastFeedExtraCondition', `clusterStdError'
    eststo `variable'R: margins, dydx(`interestVariables' isPoorState) post
    sum `variable' `weightCommand' if `baselineConditions' & `nonBreastFeedExtraCondition'
    local baselineValue "`r(mean)'"
    estadd scalar BaselineHighWealth = `baselineValue'
    local poorState = `baselineValue' + _b[isPoorState]
    estadd scalar BaselineLowWealth = `poorState'
    local nutritionVariablesNonBFeed `nutritionVariablesNonBFeed' `variable'R
}

local commonTableCommand fragment star(* 0.10 ** 0.05 *** 0.01) b(%8.3f) se(%8.3f) label coeflabels(afterCovidStarted "\textit{After}" afterAndPoor "\textit{After} x \textit{LowWealth}") nonumbers keep(`interestVariables') stat(BaselineHighWealth BaselineLowWealth, fmt(%8.3f %8.3f) labels("Baseline High Wealth" "Baseline Low Wealth"))

local subTitles mtitles("N-MDD" "N-MMF" "N-MAD")

//**** Result tables ***********************************************************

// First, some common helpers for reporting tex tables
local postCaption \caption*{\footnotesize Upper and lower panel shows the corresponding estimate for \textit{\textbf{not} fulfilling corresponding nutrition indicator}-outcome variable for breastfed and non-breastfed children aged 6-23 months, respectively. Columns are nutritional status indicators: not having Minimum Dietary Diversity (N-MDD), not having Minimum Meal Frequency (N-MMF) and not having Minimum Acceptable Diet (N-MAD). \textbf{After} shows the effect of the \textit{after-lockdown}-indicator, and \textbf{After x LowWealth} shows the interaction of \textit{After} and belonging into two lowest wealth quintiles. \textbf{Baseline High} and \textbf{Low Wealth} are before-lockdown-means of dependent variable of high and low wealth individuals, respectively. The models are controlled for wealth status, region (urban/rural), state and month fixed effects, as well as children age in months, month of birth and sex.}

local standardErrorsCommand postfoot("\hline\hline \multicolumn{4}{l}{\footnotesize Standard errors in parentheses}\\ \multicolumn{4}{l}{\footnotesize \sym{*} \(p<0.1\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\ \end{tabular} \\ `postCaption' \end{table}")

local preheadCommandPre prehead("\begin{table}[htbp]\centering \footnotesize \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}

local preheadCommandMiddle \begin{tabular}{l*{

local preheadCommandPost }{c}} \hline\hline")

local postheadCommandPre posthead("\hline \\ [-2em] \multicolumn{4}{l}{\textbf{

local postheadCommandPost }} \\")

local tableHeading \footnotesize Marginal probit estimates (\cref{eq:probitModel}) for nutrition indicator variables

local tableCaption \caption{\label{tab:`resultTableName'} `tableHeading'}

local numberOfRegressions 3
local preheadCommand `preheadCommandPre'`tableCaption'`preheadCommandMiddle'`numberOfRegressions'`preheadCommandPost'

local panelName "Child 6-23 Months, Breastfed"
local postHeadCommand `postheadCommandPre'`panelName'`postheadCommandPost'
esttab `nutritionVariablesBFeed' using `fullTableName', `preheadCommand' `postHeadCommand' `commonTableCommand' `subTitles' nonumbers noobs replace

local panelName "Child 6-23 Months, Non-Breastfed"
local postheadCommandPre posthead("\\ [-2em] \hline \multicolumn{4}{l}{\textbf{
local postHeadCommand `postheadCommandPre'`panelName'`postheadCommandPost'
esttab `nutritionVariablesNonBFeed' using `fullTableName', `postHeadCommand' `commonTableCommand' nomtitles append `standardErrorsCommand'