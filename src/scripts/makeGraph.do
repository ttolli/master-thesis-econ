//******************************************************************************
//
// Plots graph for single variable, showing:
//    1) Before-After-COVID19-coefs
//    2) Trends from the past DHS surveys
//
// Legend is plotted separately for high- and low-wealth groups, as well as for
// in-progress and reference states.
//
// Reference results denotes results from reference state, and results from
// in-progress states

// Arguments:
//   * valueMatrix          - values containing estimates, baseline values and
//                            past references
//   * name                 - name used for variable
//   * graphTitle           - title to be used for graph
//   * beta1Y               - y-coordinate for main coefficient text
//   * beta2Y               - y-coordinate for interaction coefficient text
//   * graphType            - 0 - probit without legend
//                            1 - probit with legend
//                            2 - regress without legend
//   * hiStars              - stars indicating stat significance for high-wealth
//   * loStars              - stars indicating stat significance for low-wealth
//******************************************************************************
args valueMatrix name graphTitle beta1Y beta2Y graphType hiStars loStars

//   * afterCovid           - after COVID-19 coefficient (after-COVID-19, high)
//   * afterCovidSd         - after COVID-19 st dev (after-COVID-19, high)
//   * afterAndPoor         - after COVID-19 and low-wealth interaction
//   * afterAndPoorSd       - after COVID-19 and low-wealth interaction st dev
//   * baseline             - baseline result (before-COVID19, high-wealth)
//   * poor                 - low-wealth coefficient (before-COVID)
//   * meanHigh2006,-16,-21 - reference results of high-wealth groups
//   * meanLow2006,-16,-21  - reference results of low-wealth groups
//   * meanInPr2006,-16     - results of hight-wealth groups
//   * meanLowInPr2006,-16  - results of low-wealth groups
// Let's store the value matrices to locals for later calculations and drawings
// so that variable names are a bit more readable
local afterCovid `valueMatrix'[1,1]
local afterCovidSd `valueMatrix'[1,2]
local afterAndPoor `valueMatrix'[1,3]
local afterAndPoorSd `valueMatrix'[1,4]
local poor `valueMatrix'[1,5]
local poorSd `valueMatrix'[1,6]
local baseline `valueMatrix'[1,7]
local meanHigh2021 `valueMatrix'[1,8]
local meanLow2021 `valueMatrix'[1,9]
local meanHigh2006 `valueMatrix'[1,10]
local meanLow2006 `valueMatrix'[1,11]
local meanInPr2006 `valueMatrix'[1,12]
local meanLowInPr2006 `valueMatrix'[1,13]
local meanHigh2016 `valueMatrix'[1,14]
local meanLow2016 `valueMatrix'[1,15]
local meanInPr2016 `valueMatrix'[1,16]
local meanLowInPr2016 `valueMatrix'[1,17]

local meanXLabels xla(2006 "DHS-3" 2008(2)2016 "DHS-4" 2018 2020 "DHS-5-1" 2021 "DHS-5-2" 2022, angle(45))
local meanLegend legend(order(11 "Reference states, high wealth" 13 "Reference states, low wealth" 1 "In-progress states, high wealth" 2 "In-progress states, low wealth"))

local meanXRange range(2005 2022)

if `graphType' == 2 {
    local graphYTitle Mean N of Injections
    local meanLabels `meanXLabels' yla(0(0.5)3.5, grid)
    local meanScale xscale(`meanXRange') yscale(range(1 3.5))
    local commonMeanGraph  legend(off) xtitle("") `meanScale' `meanLabels'
}
else {
    local graphYTitle Mean Proportion
    local meanProbLabels `meanXLabels' yla(0(0.2)1)
    local meanProbScale xscale(`meanXRange') yscale(range(0 1))
    local commonMeanGraph  legend(off) xtitle("") `meanProbScale' `meanProbLabels'
}

local referenceStateColor blue
local inProgressStateColor magenta
local lColorRef lc(`referenceStateColor')
local lColorInPr lc(`inProgressStateColor')
local mColorRef mc(`referenceStateColor')
local mColorInPr mc(`inProgressStateColor')
local lowWealthPattern lpattern(dash)

local nameVar `name'Var
gen `nameVar' = .
replace `nameVar' = `meanHigh2006' in 1
replace `nameVar' = `meanHigh2016' in 2
replace `nameVar' = `meanHigh2021' in 3

local nameLow `name'Low
gen `nameLow' = .
replace `nameLow' = `meanLow2006' in 1
replace `nameLow' = `meanLow2016' in 2
replace `nameLow' = `meanLow2021' in 3

local nameInPr `name'InPr
gen `nameInPr' = .
replace `nameInPr'  = `meanInPr2006' in 1
replace `nameInPr'  = `meanInPr2016' in 2
replace `nameInPr'  = `baseline' in 3

local nameLowInPr `name'LowInPr
gen `nameLowInPr' = .
replace `nameLowInPr'  = `meanLowInPr2006' in 1
replace `nameLowInPr'  = `meanLowInPr2016' in 2
replace `nameLowInPr'  = `baseline' + `poor' in 3

local baselineName baseline`name'
local after after`name'
local afterSd after`name'Sd
local afterUpper after`name'Upper
local afterLower after`name'Lower
local afterLowWealth after`name'LowWealth
local afterLowWealthSd after`name'LowWealthSd
local afterLowWealthUpper after`name'LowWealthUpper
local afterLowWealthLower after`name'LowWealthLower
gen `baselineName'=.
replace `baselineName' = `baseline' in 3
gen `after' = .
replace `after' = `baseline' + `afterCovid' in 4
gen `afterSd' = .
replace `afterSd' = `afterCovidSd' in 4
gen `afterUpper' = `after' + `afterSd'
gen `afterLower' = `after' - `afterSd'
gen `afterLowWealth' = .
replace `afterLowWealth' = `after' + `poor' + `afterAndPoor' in 4
gen `afterLowWealthSd' = .
replace `afterLowWealthSd' = `afterAndPoorSd' in 4
gen `afterLowWealthUpper' = `afterLowWealth' + `afterLowWealthSd'
gen `afterLowWealthLower' = `afterLowWealth' - `afterLowWealthSd'

local high16_21 `name'High16_21
local low16_21 `name'Low16_21
gen `high16_21'=.
replace `high16_21' = `baseline' in 3
replace `high16_21' = `baseline' + `afterCovid' in 4
gen `low16_21'=.
replace `low16_21' = `baseline' + `poor' in 3
replace `low16_21' = `after' + `poor' + `afterAndPoor' in 4

local hiWealth: di %4.3f `afterCovid'
local loWealth: di %4.3f `afterCovid' + `afterAndPoor'
local hiWealthPercent: di %2.1f (`afterCovid' / `baseline')*100.0
local loWealthPercent: di %2.1f ((`afterCovid' + `afterAndPoor') / (`baseline' + `poor'))*100.0

local resultText text(`beta1Y' 2017 "`hiWealth'`hiStars' (`hiWealthPercent'%)", color(green) size(3.4722) place(e)) text(`beta2Y' 2017 "`loWealth'`loStars' (`loWealthPercent'%)", color(orange) size(3.4722) place(e))

if `graphType' == 0 | `graphType' == 2 {
    twoway line `high16_21' year, `lColorInPr' || line `low16_21' year, `lColorInPr' `lowWealthPattern'  || line `nameLowInPr' year, `lColorInPr' `lowWealthPattern' || scatter `after' year, mc(green) || rcap `afterUpper' `afterLower' year, lc(green)|| scatter `afterLowWealth' year, mc(orange) || rcap `afterLowWealthUpper' `afterLowWealthLower' year, lc(orange) || scatter `nameInPr' year, `mColorInPr' || line `nameInPr' year, `lColorInPr' || scatter `nameVar' year, `commonMeanGraph' ytitle(`graphYTitle') `mColorRef' title(`graphTitle') || line `nameVar' year, `lColorRef' || scatter `nameLow' year, `mColorRef' || line `nameLow' year, `lColorRef' `lowWealthPattern' || scatter `nameLowInPr' year, `mColorInPr' || scatter `baselineName' year, mc(red) `resultText'  bgcolor(white) graphregion(color(white)) saving(`name', replace)
}
else {
    twoway line `high16_21' year, `lColorInPr' || line `low16_21' year, `lColorInPr' `lowWealthPattern'  || line `nameLowInPr' year, `lColorInPr' `lowWealthPattern' || scatter `after' year, mc(green) || rcap `afterUpper' `afterLower' year, lc(green)|| scatter `afterLowWealth' year, mc(orange) || rcap `afterLowWealthUpper' `afterLowWealthLower' year, lc(orange) || scatter `nameInPr' year, `mColorInPr' || line `nameInPr' year, `lColorInPr' || scatter `nameVar' year, `commonMeanGraph' ytitle(`graphYTitle') `mColorRef' title(`graphTitle') || line `nameVar' year, `lColorRef' || scatter `nameLow' year, `mColorRef' || line `nameLow' year, `lColorRef' `lowWealthPattern' || scatter `nameLowInPr' year, `mColorInPr' || scatter `baselineName' year, mc(red) `resultText' `meanLegend'  bgcolor(white) graphregion(color(white)) saving(`name', replace)
}
