//******************************************************************************
//
// A helper to run probit analysis for single variable of interest, in order to
// make marginsplot for current vs past dhs. Thus, this is a helper to make
// figures 3-5
//
// Results are stored into variable-specific value matrix.
//
// Arguments:
//   * variable        - A variable to be analyzed
//   * variableName    - Variable name to be used internally
//   * age             - Age, in months for children, in years for adults
//   * monthOfBirth    - Month of birth
//   * sex             - Sex
//   * weight          - DHS sampling weight
//   * modelType       - 0 for probit, 1 for OLS
//
//******************************************************************************
args variable variableName age monthOfBirth sex weight modelType

// Reference states
local referenceStates isInProgressState == 0
local lowWealthQuintiles isPoorState == 1
local highWealthQuintiles isPoorState == 0

// Investigated states
local  inProgressStates isInProgressState == 1

// For getting the results from actual regressions
local interestVariables afterCovidStarted afterAndPoor isPoorState
local dependentAndControlsForAll `interestVariables' i.v024
local extraControls isUrban
local monthFixed i.v006
local ageFixed i.`age'
local monthOfBirthFixed i.`monthOfBirth'
local individualControls isHindu isMuslim isChristian isSikh isCaste isTribe sex
local validObservations isInProgressState == 1 & isWinterMonths == 1
local baselineConditions e(sample)==1 & `validObservations' & afterCovidStarted==0 & `highWealthQuintiles'
local extraCondition extraCond == 1
local clusterStdError cluster(sdist)
local preCommandProbit quietly probit
local preCommandReg quietly reg

local modelCommand `variable' `dependentAndControlsForAll' `extraControls' `monthFixed' `ageFixed' `monthOfBirthFixed' `individualControls' `weight' if `validObservations' & `extraCondition'

if `modelType' == 0 {
    `preCommandProbit' `modelCommand', `clusterStdError'
    margins, dydx(`interestVariables') post
}
else {
    `preCommandReg' `modelCommand', `clusterStdError'
}

matrix `variableName'Values[1,1] = _b[afterCovidStarted]
matrix `variableName'Values[1,2] = _se[afterCovidStarted]
matrix `variableName'Values[1,3] = _b[afterAndPoor]
matrix `variableName'Values[1,4] = _se[afterAndPoor]
matrix `variableName'Values[1,5] = _b[isPoorState]
matrix `variableName'Values[1,6] = _se[isPoorState]

sum `variable' `weight' if `baselineConditions' & `extraCondition'
matrix `variableName'Values[1,7] = `r(mean)'

sum `variable' `weight' if `referenceStates' & `extraCondition' & `highWealthQuintiles'
matrix `variableName'Values[1,8] = `r(mean)'

sum `variable' `weight' if `referenceStates' & `extraCondition' & `lowWealthQuintiles'
matrix `variableName'Values[1,9] = `r(mean)'