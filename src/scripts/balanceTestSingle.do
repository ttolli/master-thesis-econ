//******************************************************************************
//
// A helper to run balanced tests for used controls -- basically a helper to
// calculate Tables A1-A4
//
// Results are stored into balanceResult-value matrix, starting from given index
//
// Arguments:
//   * dependentVarCond - Used conditions for dependent variable(s)
//   * w                - Used dhs weights
//   * isSexExluded     - 0 if sex is to be included, 1 if not
//   * isAgeInYears     - 0 if age is in months, 1 if in years (just to show
//                        proper header)
//   * variableLabel    - Label of variable
//   * resetMatrix      - 1 if result matrix is to be resetted, 0 if appended
//
//******************************************************************************
args dependentVarCond w isSexExluded isAgeInYears variableLabel resetMatrix

local indepVars isPoorState isUrban isHindu isMuslim isChristian isSikh isCaste isTribe age sex
local commonDeps isInProgressState == 1 & isWinterMonths == 1
local weight [iw=`w']

local isPoorStateLabel Low Wealth
local isUrbanLabel Is Urban
local isHinduLabel Hindi
local isMuslimLabel Muslim
local isChristianLabel Christian
local isSikhLabel Sikh
local isCasteLabel Scheduled Caste
local isTribeLabel Scheduled Tribe
local ageLabelYear Age in Years
local ageLabelMonth Age in Months
local sexLabel Sex

foreach indepVar in `indepVars' {
    // Temporary matrix, will be concatenated with balanceResult
    matrix temp = J(1,4,0)

    if ("`indepVar'" == "sex" & `isSexExluded' == 1) {
        // Single sex, test N/A
        continue
    }
    quiet ttest `indepVar' if `commonDeps' & `dependentVarCond', by(afterCovidStarted)
    matrix temp[1, 2] = `r(mu_1)'       // Before-mean
    matrix temp[1, 3] = `r(mu_2)'       // After-mean

    quiet reg `indepVar' afterCovidStarted `weight' if `commonDeps' & `dependentVarCond', cluster(sdist)
    matrix temp[1,4] = r(table)[4,1]    // P-value
    matrix temp[1,1] = e(N)             // N

    if ("`indepVar'" == "age") {
        if (`isAgeInYears' == 1) {
            mat rownames temp = `"`variableLabel':`ageLabelYear'"'
        }
        else {
            mat rownames temp = `"`variableLabel':`ageLabelMonth'"'
        }
    }
    else {
        mat rownames temp = `"`variableLabel':``indepVar'Label'"'
    }

    // If result matrix is to be re-created, let's reset it on first independent variable
	// Otherwise append
    if (`resetMatrix' == 1 & "`indepVar'" == "isPoorState") {
        mat balanceResult = temp
    }
    else {
        mat balanceResult = balanceResult \ temp
    }
}