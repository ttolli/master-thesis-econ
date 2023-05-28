//******************************************************************************
//
// A helper to run probit analysis (Equation 2 in the paper) for single variable
// of interest.
//
// The result is stored using eststo
//
// Arguments:
//   * variable         - A variable to be analyzed
//   * variableName     - Variable name to be used internally
//   * age              - Age, in months for children, in years for adults
//   * monthOfBirth     - Month of birth
//   * stdErrorCluster  - Variable to be used to cluster std errors
//   * sex              - A variable indicating sex
//   * weight           - DHS sampling weight
//   * runEdgeAnalysis  - 1 ~ run edge analysis, 0 ~ don't run edge analysis
//                        with latter one 4 and former 5 regression results
//
//******************************************************************************
args variable variableName age monthOfBirth stdErrorCluster sex weight runEdgeAnalysis

local interestVariables afterCovidStarted afterAndPoor isPoorState
local dependentAndControlsForAll `interestVariables' isPoorState i.v024
local extraControls isUrban
local monthFixed i.v006
local ageFixed i.`age'
local monthOfBirthFixed i.`monthOfBirth'
local individualControls isHindu isMuslim isChristian isSikh isCaste isTribe sex
local validObservations isInProgressState == 1 & isWinterMonths == 1
local baselineConditions e(sample)==1 & `validObservations' & afterCovidStarted==0 & isPoorState == 0
local clusterStdError cluster(`stdErrorCluster')
local extraCondition extraCond == 1
local weightCommand [iw=`weight']

local borderCondition distancetobordersinsidestate < 20 & distancetobordersinsidestate > 0

local preCommand quietly probit

// Regression without extra controls, i.e., with state fixed and wealth status only
`preCommand' `variable' `dependentAndControlsForAll' `weightCommand' if `validObservations' & `extraCondition', `clusterStdError'
local pseudoR2Value = `e(r2_p)'
eststo `variableName': margins, dydx(`interestVariables') post

// Store baseline after first regression
sum `variable' `weightCommand' if `baselineConditions' & `extraCondition'
local baselineValue "`r(mean)'"
local poorState = `baselineValue' + _b[isPoorState]
estadd scalar Baseline = `baselineValue'
estadd scalar PseudoR2 = `pseudoR2Value'
estadd scalar BaselineLowWealth = `poorState'

// With extra controls
`preCommand' `variable' `dependentAndControlsForAll' `extraControls' `weightCommand' if `validObservations' & `extraCondition', `clusterStdError'
local pseudoR2Value = `e(r2_p)'
eststo `variableName'Controls: margins, dydx(`interestVariables') post
estadd scalar Baseline = `baselineValue'
local poorState = `baselineValue' + _b[isPoorState]
estadd scalar BaselineLowWealth = `poorState'
estadd scalar PseudoR2 = `pseudoR2Value'

// With extra controls, month fixed, ageFixed and monthOfBirthFixed
`preCommand' `variable' `dependentAndControlsForAll' `extraControls' `monthFixed' `ageFixed' `monthOfBirthFixed' `weightCommand' if `validObservations' & `extraCondition', `clusterStdError'
local pseudoR2Value = `e(r2_p)'
eststo `variableName'Month: margins, dydx(`interestVariables') post
estadd scalar Baseline = `baselineValue'
local poorState = `baselineValue' + _b[isPoorState]
estadd scalar BaselineLowWealth = `poorState'
estadd scalar PseudoR2 = `pseudoR2Value'

// With extra controls, month fixed, age fixed, month of birth fixed and individual controls
`preCommand' `variable' `dependentAndControlsForAll' `extraControls' `monthFixed' `ageFixed' `monthOfBirthFixed' `individualControls' `weightCommand' if `validObservations' & `extraCondition', `clusterStdError'
local pseudoR2Value = `e(r2_p)'
eststo `variableName'Ind: margins, dydx(`interestVariables') post
// Seems there are some missing ethnicity statuses, thus baseline needs to be recalculated
sum `variable' `weightCommand' if `baselineConditions' & isCaste!=. & `extraCondition'
local baselineValue "`r(mean)'"
estadd scalar Baseline = `baselineValue'
local poorState = `baselineValue' + _b[isPoorState]
estadd scalar BaselineLowWealth = `poorState'
estadd scalar PseudoR2 = `pseudoR2Value'

if (`runEdgeAnalysis' == 1) {
    // With extra controls, month fixed, age fixed, month of birth fixed and observations on before-after-edges
`preCommand' `variable' `dependentAndControlsForAll' `extraControls' `monthFixed' `ageFixed' `monthOfBirthFixed' `individualControls' `weightCommand' if `validObservations' & `extraCondition' & `borderCondition', `clusterStdError'
    local pseudoR2Value = `e(r2_p)'
    eststo `variableName'BorderNear: margins, dydx(`interestVariables') post
    // Store first baseline, as sample is smaller
    sum `variable' `weightCommand' if `baselineConditions' & `borderCondition' & `extraCondition'
    local baselineValue "`r(mean)'"
    estadd scalar Baseline = `baselineValue'
    local poorState = `baselineValue' + _b[isPoorState]
    estadd scalar BaselineLowWealth = `poorState'
    estadd scalar PseudoR2 = `pseudoR2Value'
}