//******************************************************************************
//
// A helper to run stringency analysis for single variable of interest.
//
// The result is stored using eststo
//
// Arguments:
//   * variable        - A variable to be analyzed
//   * variableName    - Variable name to be used internally
//   * weight          - DHS sampling weight
//   * stdErrorCluster - Variable to be used to cluster std errors
//   * age             - Age, in months for children, in years for adults
//   * monthOfBirth    - Month of birth
//   * modelType       - 0 for probit, 1 for regress
//
//******************************************************************************
args variable variableName weight stdErrorCluster age monthOfBirth modelType

// For getting the results from actual regressions
local interestVariables afterCovidStarted afterAndPoor isPoorState highStringencyState highStringencyAndPoor afterAndHighStringency afterPoorHighStringency
local dependentAndControlsForAll `interestVariables'
local extraControls isUrban
local monthFixed i.v006
local stateFixed i.v024
local ageFixed i.`age'
local monthOfBirthFixed i.`monthOfBirth'
local validObservations isInProgressState == 1 & isWinterMonths == 1
local baselineConditions e(sample) == 1 & `validObservations' & afterCovidStarted == 0 & `highWealthQuintiles'
local clusterStdError cluster(`stdErrorCluster')
local extraCondition extraCond == 1
local weightCommand [iw=`weight']

// 3  - Punjab
// 5  - Uttarakhand
// 6  - Haryana
// 7  - Nct Of Delhi
// 8  - Rajasthan
// 9  - Uttar Pradesh
// 12 - Arunaachal Pradehs
// 20 - Jharkhand
// 21 - Odisha
// 22 - Chhattisgarh
// 23 - Madhya Pradesh
// 33 - Tamil Nadu
// 34 - Puducherry

// -->
// 8  - Rajasthan 64.89
// 3  - Punjab 63.32
// 34 - Puducherry 61.79
// 20 - Jharkhand 61.47
// 7  - Nct Of Delhi 61.43
// 9  - Uttar Pradesh 61.32
// 12 - Arunaachal Pradehs 61.17
// 21 - Odisha 60.27
// 5  - Uttarakhand 57.12
// 33 - Tamil Nadu 57.01
// 22 - Chhattisgarh 56.68
// 23 - Madhya Pradesh 56.02
// 6  - Haryana 51.06

matrix `variableName'AfterCovid = (0.0, 0.0)
matrix `variableName'AfterCovidSe = (0.0, 0.0)
matrix `variableName'AfterCovidt = (0.0, 0.0)
matrix `variableName'AfterAndPoor = (0.0, 0.0)
matrix `variableName'AfterAndPoorSe = (0.0, 0.0)
matrix `variableName'AfterAndPoort = (0.0, 0.0)

if `modelType' == 0 {
	probit `variable' `dependentAndControlsForAll' `extraControls' `stateFixed' `monthFixed'  `ageFixed' `monthOfBirthFixed' `weightCommand' if `validObservations' & `extraCondition' , `clusterStdError'
	eststo `variableName': margins, dydx(`interestVariables') post
}
else {
	xi: eststo `variableName' : reg `variable' `dependentAndControlsForAll' `extraControls' `stateFixed' `monthFixed' `ageFixed' `monthOfBirthFixed'  `weightCommand' if `validObservations' & `extraCondition' , `clusterStdError'
}
