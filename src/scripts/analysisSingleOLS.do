//******************************************************************************
//
// A helper to run regression analysis (Equation 1 in the paper) for single
// variable of interest.
//
// The result is stored using eststo
//
// Arguments:
//   * variable         - A variable to be analyzed
//   * variableName     - Variable name to be used internally
//   * age              - Age, in months for children, in years for adults
//   * monthOfBirth     - Month of birth
//   * stdErrorCluster  - Variable to be used to cluster std errors
//   * weight           - DHS sampling weight
//   * runEdgeAnalysis  - 1 ~ run edge analysis, 0 ~ don't run edge analysis
//                        with latter one 4 and former 5 regression results
//
//******************************************************************************

args variable variableName age monthOfBirth stdErrorCluster weight runEdgeAnalysis

local interestVariables afterCovidStarted afterAndPoor
local dependentAndControlsForAll `interestVariables' isPoorState i.v024
local extraControls isUrban
local monthFixed i.v006
local ageFixed i.`age'
local monthOfBirthFixed i.`monthOfBirth'
local individualControls isHindu isMuslim isChristian isSikh isCaste isTribe
local validObservations isInProgressState == 1 & isWinterMonths == 1
local baselineConditions e(sample)==1 & `validObservations' & afterCovidStarted==0 & isPoorState == 0
local clusterStdError cluster(`stdErrorCluster')
local extraCondition extraCond == 1
local weightCommand [iw=`weight']

local borderCondition distancetobordersinsidestate < 20 & distancetobordersinsidestate > 0

local preCommand xi: eststo

// Regression without extra controls, i.e., with state fixed and wealth status only
`preCommand' `variableName': reg `variable' `dependentAndControlsForAll' `weightCommand' if `validObservations' & `extraCondition' , `clusterStdError'
estadd scalar PseudoR2 = `e(r2)'

// Store baseline after first regression
sum `variable' `weightCommand' if `baselineConditions' & `extraCondition'
local baselineValue `r(mean)'
estadd scalar Baseline = `baselineValue'
local poorState = `baselineValue' + _b[isPoorState]
estadd scalar BaselineLowWealth = `poorState'

// With extra controls
`preCommand' `variableName'Controls: reg `variable' `dependentAndControlsForAll' `extraControls' `weightCommand' if `validObservations' & `extraCondition' , `clusterStdError'
estadd scalar Baseline = `baselineValue'
local poorState = `baselineValue' + _b[isPoorState]
estadd scalar BaselineLowWealth = `poorState'
estadd scalar PseudoR2 = `e(r2)'

// With extra controls, month fixed, ageFixed and monthOfBirthFixed
`preCommand' `variableName'Month: reg `variable' `dependentAndControlsForAll' `extraControls'  `monthFixed' `ageFixed' `monthOfBirthFixed' `weightCommand' if `validObservations' & `extraCondition' , `clusterStdError'
estadd scalar Baseline = `baselineValue'
local poorState = `baselineValue' + _b[isPoorState]
estadd scalar BaselineLowWealth = `poorState'
estadd scalar PseudoR2 = `e(r2)'

// With extra controls, month fixed, age fixed, month of birth fixed and individual controls
`preCommand' `variableName'Ind: reg `variable' `dependentAndControlsForAll' `extraControls'  `monthFixed' `ageFixed' `monthOfBirthFixed' `individualControls' `weightCommand' if `validObservations' & `extraCondition' , `clusterStdError'
// Seems there are some missing ethnicity statuses, thus baseline needs to be recalculated
sum `variable' `weightCommand' if `baselineConditions' & isCaste!=. & `extraCondition'
local baselineValue `r(mean)'
estadd scalar Baseline = `baselineValue'
local poorState = `baselineValue' + _b[isPoorState]
estadd scalar BaselineLowWealth = `poorState'
estadd scalar PseudoR2 = `e(r2)'

if (`runEdgeAnalysis' == 1) {
    // With extra controls, month fixed, age fixed, month of birth fixed and observations on before-after-edges
    `preCommand' `variableName'BorderNear: reg `variable' `dependentAndControlsForAll' `extraControls'  `monthFixed' `ageFixed' `monthOfBirthFixed' `individualControls' `weightCommand' if `validObservations' & `extraCondition' & `borderCondition' , `clusterStdError'
// Store baseline again, as sample is smaller
    sum `variable' `weightCommand' if `baselineConditions' & `borderCondition' & `extraCondition'
    local baselineValue `r(mean)'
    estadd scalar Baseline = `baselineValue'
    local poorState = `baselineValue' + _b[isPoorState]
    estadd scalar BaselineLowWealth = `poorState'
    estadd scalar PseudoR2 = `e(r2)'
}