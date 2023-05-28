//******************************************************************************
//
// A helper to collect reference data from variable of interest from past DHS
// rounds, in order to make marginsplot for current vs past dhs. Thus, this is a
// helper to make figures 3-5
//
// Results are stored into variable-specific value matrix.
//
// Arguments:
//   * variable        - A variable to be analyzed
//   * variableName    - Variable name to be used internally
//   * weight          - DHS sampling weight
//   * y               - Year, either 2006 or 2016
//
//******************************************************************************
args variable variableName weight y

// Reference states
local referenceStates isInProgressState == 0
local lowWealthQuintiles isPoorState == 1
local highWealthQuintiles isPoorState == 0

// Investigated states
local inProgressStates isInProgressState == 1

// For getting the results from actual regressions
local extraCondition extraCond == 1

sum `variable' `weight' if `referenceStates' & `extraCondition' & `highWealthQuintiles'
if `y' == 2006 {
    local mIndex 10
}
else {
    local mIndex 14
}
matrix `variableName'Values[1,`mIndex'] = `r(mean)'

local mIndex `mIndex' + 1
sum `variable' `weight' if `referenceStates' & `extraCondition' & `lowWealthQuintiles'
matrix `variableName'Values[1,`mIndex'] = `r(mean)'

local mIndex `mIndex' + 1
sum `variable' `weight' if `inProgressStates' & `extraCondition' & `highWealthQuintiles'
matrix `variableName'Values[1,`mIndex'] = `r(mean)'

local mIndex `mIndex' + 1
sum `variable' `weight' if `inProgressStates' & `extraCondition' & `lowWealthQuintiles'
matrix `variableName'Values[1,`mIndex'] = `r(mean)'