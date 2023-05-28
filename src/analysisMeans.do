//******************************************************************************
//
// Create mean figures.
//
// Creates figures from past trends using data from all the three DHS survey
// rounds. The figures are Figure 3-5 of the thesis.
//
// Script assumes the data has been read using readAllDhsData, and that
// the stored datafiles (.dta) are found from current folder
//
//   * basePath             - repository base path
//   * resultImageFolder    - folder to store result image
//******************************************************************************
args basePath resultImageFolder

// Used model type, Probit/OLS
local modelTypeProbit 0
local modelTypeReg 1

// Reference states
local referenceStates isInProgressState == 0
// Investigated states
local  inProgressStates isInProgressState == 1

// Health quintiles
local lowWealthQuintiles isPoorState == 1
local highWealthQuintiles isPoorState == 0

// Sampling weights used
local normalWeight [iw=wt]
local violenceWeight [iw=wd]

// All used variables
local variables inj violence nFullVaccY nFullVaccO neverVaccY neverVaccO chHAZ chUnderw chWasting alcohol smoking chAnemic adultAnemic adultUnderw

// For each variable, value matrix will contain following 17 values when graphs are made:
// 1: afterCovid main estimate, after, high wealth
// 2: afterCovidSe, se of afterCovid
// 3: afterAndPoor after, low wealth
// 4: afterAndPoorSe, se of afterAndPoor
// 5: poor, baseline of low wealth
// 6: poorSe, se of poor
// 7: baseline, baseline of high wealth
// 8: meanHigh2021, reference states, high wealth, 2021
// 9: meanLow2021, reference states, low wealth, 2021
// 10: meanHigh2006, reference states, high wealth, 2006
// 11: meanLow2006, reference states, low wealth, 2006
// 12: meanHighInPr2006, in-progress state high wealth, 2006
// 13: meanLowInPr2006, in-progress state low wealth, 2006
// 14: meanHigh2016, reference states, high wealth, 2016
// 15: meanLow2016, reference states, low wealth, 2016
// 16: meanHighInPr2016, in-progress state high wealth, 2016
// 17: meanLowInPr2016, in-progress state low wealth, 2016
foreach variable in `variables' {
    matrix `variable'Values = J(1,17,0)
	matrix list `variable'Values
}

//**** Collect data **********************************************************

//**** 2021-22 DHS ***********************************************************

use women2021.dta, clear
run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

//**** Number of injections ************************************************
gen extraCond = v477 < 98
gen age = v012
gen monthOfBirth = v009
gen sex = 1 // Single sex
run `basePath'/src/scripts/analysisSingleMean v477 inj age monthOfBirth sex `normalWeight' `modelTypeReg'

//**** Experienced any violence **********************************************
drop extraCond
gen extraCond = 1
gen experiencedAnyViolence = .
replace experiencedAnyViolence = 0 if d104 == 0 & d106 == 0 & d107 == 0 & d108 == 0
replace experiencedAnyViolence = 1 if d104 == 1 | d106 == 1 | d107 == 1 | d108 == 1
run `basePath'/src/scripts/analysisSingleMean experiencedAnyViolence violence age monthOfBirth sex `violenceWeight' `modelTypeProbit'

use children2021.dta, clear

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

run `basePath'/src/scripts/createVaccinationVariables

//**** Not fully vaccinated, 1-12 **********************************************
gen extraCond = is_1_12 == 1
gen sex = b4
gen monthOfBirth = b1
run `basePath'/src/scripts/analysisSingleMean isNotFullyVacc nFullVaccY age monthOfBirth sex `normalWeight' `modelTypeProbit'

//**** Not fully vaccinated, 12-24 *********************************************
drop extraCond
gen extraCond = is_1_12 == 0
run `basePath'/src/scripts/analysisSingleMean isNotFullyVacc nFullVaccO age monthOfBirth sex `normalWeight' `modelTypeProbit'

//**** Never vaccinated, 1-12 **************************************************
drop extraCond
gen extraCond = is_1_12 == 1
run `basePath'/src/scripts/analysisSingleMean neverVacc neverVaccY age monthOfBirth sex `normalWeight' `modelTypeProbit'

//**** Never vaccinated, 12-24 *************************************************
drop extraCond
gen extraCond = is_1_12 == 0
run `basePath'/src/scripts/analysisSingleMean neverVacc neverVaccO age monthOfBirth sex `normalWeight' `modelTypeProbit'

//**** Stunting, a.k.a., HAZ ***************************************************
run `basePath'/src/scripts/createChildNutritionMainVariables
drop extraCond
gen extraCond = 1
run `basePath'/src/scripts/analysisSingleMean childStunting chHAZ age monthOfBirth sex `normalWeight' `modelTypeProbit'

//**** Children underweight **************************************************
run `basePath'/src/scripts/analysisSingleMean childUnderweight chUnderw age monthOfBirth sex `normalWeight' `modelTypeProbit'

//**** Children wasting ********************************************************
run `basePath'/src/scripts/analysisSingleMean childWasting chWasting age monthOfBirth sex `normalWeight' `modelTypeProbit'

use men2021.dta, clear
rename mv024 v024
rename mv025 v025
rename mv006 v006
rename smdist sdist
run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 mv130 sm118
gen age = mv012
gen monthOfBirth = mv009
gen sex = 1 // Single sex

//**** Men alcohol *************************************************************
gen extraCond = mv012 >= 18
run `basePath'/src/scripts/analysisSingleMean sm619 alcohol age monthOfBirth sex `normalWeight' `modelTypeProbit'

//**** Men smoking *************************************************************
gen menSmoke = .
replace menSmoke = 0 if mv463z==1
replace menSmoke = 1 if mv463z==0
run `basePath'/src/scripts/analysisSingleMean menSmoke smoking age monthOfBirth sex `normalWeight' `modelTypeProbit'

use hhMember2021.dta, clear

rename hv024 v024
rename hv025 v025
rename hv006 v006
rename shdist sdist
run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 sh47 sh49

gen monthOfBirth = hc30
gen age = hc1

gen childAnemic=.
replace childAnemic=1 if hc57==1|hc57==2|hc57==3
replace childAnemic=0 if hc57==4
gen adultAnemic=.
replace adultAnemic=1 if hb57==1|hb57==2|hb57==3|ha57==1|ha57==2|ha57==3
replace adultAnemic=0 if hb57==4|ha57==4

//**** Children anemia *******************************************************
gen extraCond = 1
gen sex = .
replace sex = 1 if hv104 == 2
replace sex = 0 if hv104 == 1
run `basePath'/src/scripts/analysisSingleMean childAnemic chAnemic age monthOfBirth sex `normalWeight' `modelTypeProbit'

//**** Adult anemia **********************************************************
gen adultAge = .
replace adultAge = ha1 if ha1 != .
replace adultAge = hb1 if hb1 != .
drop monthOfBirth
// N/A for adults in hh member data
gen monthOfBirth = 1
drop extraCond
gen extraCond = hv105>=18
run `basePath'/src/scripts/analysisSingleMean adultAnemic adultAnemic adultAge monthOfBirth sex `normalWeight' `modelTypeProbit'

//**** Adult underweight *****************************************************
use adult2021forBMI.dta, clear
// N/A for adults
gen monthOfBirth = 1
gen adultUnderweight = .
replace adultUnderweight = 1 if bmi <= 1850
replace adultUnderweight = 0 if (bmi > 1850 & bmi < 6000)

// Note that only adults are contained in adult2021forBMI, please see
// mergeMenAndWomenForBMI for details
gen extraCond = 1
run `basePath'/src/scripts/analysisSingleMean adultUnderweight adultUnderw age monthOfBirth sex `normalWeight' `modelTypeProbit'

// Fetch reference data from previous DHS surveys
// Please note that "use alcohol" for men has different variable name for each
// DHS survey round. That's why it needs a special handling.
//**** 2005-6 and 2015-16 DHS **************************************************
local prevYears 2006 2016
foreach y in `prevYears' {
    use women`y'.dta, clear

    //**** Number of injections ***************************************************
    local validInjections v477 < 98
    gen extraCond = v477 < 98
    run `basePath'/src/scripts/analysisSingleMeanPastDhs v477 inj `normalWeight' `y'

    //**** Experienced any violence **********************************************
    drop extraCond
    gen extraCond = 1
    gen experiencedAnyViolence = .
    replace experiencedAnyViolence = 0 if d104 == 0 & d106 == 0 & d107 == 0 & d108 == 0
    replace experiencedAnyViolence = 1 if d104 == 1 | d106 == 1 | d107 == 1 | d108 == 1
    run `basePath'/src/scripts/analysisSingleMeanPastDhs experiencedAnyViolence violence `violenceWeight' `y'

    use children`y'.dta, clear

    run `basePath'/src/scripts/createVaccinationVariables

    //**** Not fully vaccinated, 1-12 **********************************************
    gen extraCond = is_1_12 == 1
    run `basePath'/src/scripts/analysisSingleMeanPastDhs isNotFullyVacc nFullVaccY `normalWeight' `y'

    //**** Not fully vaccinated, 12-24 *********************************************
    drop extraCond
    gen extraCond = is_1_12 == 0
    run `basePath'/src/scripts/analysisSingleMeanPastDhs isNotFullyVacc nFullVaccO `normalWeight' `y'

    //**** Never vaccinated, 1-12 **************************************************
    drop extraCond
    gen extraCond = is_1_12 == 1
    run `basePath'/src/scripts/analysisSingleMeanPastDhs neverVacc neverVaccY `normalWeight' `y'

    //**** Never vaccinated, 12-24 *************************************************
    drop extraCond
    gen extraCond = is_1_12 == 0
    run `basePath'/src/scripts/analysisSingleMeanPastDhs neverVacc neverVaccO `normalWeight' `y'

    //**** Stunting, a.k.a., HAZ ***************************************************
    drop extraCond
    gen extraCond = 1

    run `basePath'/src/scripts/createChildNutritionMainVariables

    run `basePath'/src/scripts/analysisSingleMeanPastDhs childStunting chHAZ `normalWeight' `y'

    //**** Children underweight **************************************************
    run `basePath'/src/scripts/analysisSingleMeanPastDhs childUnderweight chUnderw `normalWeight' `y'

    //**** Children wasting ****************************************************
    run `basePath'/src/scripts/analysisSingleMeanPastDhs childWasting chWasting `normalWeight' `y'

    use men`y'.dta, clear

    //**** Men alcohol *************************************************************
    gen extraCond = mv012 >= 18
    // Note that variable is different per year: 2021 sm619, 2016 sm615, 2006 sm612
    local alcoholVariable sm615
    if `y' == 2006 {
        local alcoholVariable sm612
    }
    run `basePath'/src/scripts/analysisSingleMeanPastDhs `alcoholVariable' alcohol `normalWeight' `y'

    //**** Men smoking *************************************************************
    gen menSmoke=.
    replace menSmoke = 0 if mv463z==1
    replace menSmoke = 1 if mv463z==0
    run `basePath'/src/scripts/analysisSingleMeanPastDhs menSmoke smoking `normalWeight' `y'

    use hhMember`y'.dta, clear

    gen childAnemic=.
    replace childAnemic=1 if hc57==1|hc57==2|hc57==3
    replace childAnemic=0 if hc57==4
    gen adultAnemic=.
    replace adultAnemic=1 if hb57==1|hb57==2|hb57==3|ha57==1|ha57==2|ha57==3
    replace adultAnemic=0 if hb57==4|ha57==4
    gen adultUnderweight = .
    replace adultUnderweight = 1 if ha40 <= 1850 | hb40 <= 1850
    replace adultUnderweight = 0 if (ha40 > 1850 & ha40 < 6000) | (hb40 > 1850 & hb40 < 6000)

    //**** Children anemia *******************************************************
    gen extraCond = 1
    run `basePath'/src/scripts/analysisSingleMeanPastDhs childAnemic chAnemic `normalWeight' `y'

    //**** Adult anemia **********************************************************
    drop extraCond
    gen extraCond = hv105>=18
    run `basePath'/src/scripts/analysisSingleMeanPastDhs adultAnemic adultAnemic `normalWeight' `y'

    //**** Adult underweight *****************************************************
    use adult`y'forBMI.dta, clear
    gen extraCond = 1
    gen adultUnderweight = .
    replace adultUnderweight = 1 if bmi <= 1850
    replace adultUnderweight = 0 if (bmi > 1850 & bmi < 6000)
    run `basePath'/src/scripts/analysisSingleMeanPastDhs adultUnderweight adultUnderw `normalWeight' `y'
}

clear

//**** Create mean table *****************************************************

// Local script to use correct amount of stars as per standard error
capture program drop sstar
program sstar, rclass
    tempname sstar
    di `0'
    if `0' > 1.65 {
        if `0' > 1.96 {
            if `0' > 2.58 {
                scalar `sstar' = "***"
            }
            else {
                scalar `sstar' = "**"
            }
        }
        else {
            scalar `sstar' = "*"
        }
    }
    else {
        scalar `sstar' = ""
    }
    di "sstar = ", `sstar'
    return local sstar = `sstar'
end

local graphName1 meanGraphs1
local graphName2 meanGraphs2
local graphName3 meanGraphs3
local graphFormat eps

set obs 4
gen year = .
replace year = 2006 in 1
replace year = 2016 in 2
replace year = 2020 in 3
replace year = 2021 in 4

local graphTypeProbitNoLegend 0
local graphTypeProbitLegend 1
local graphTypeReg 2

// Add graph titles here
local injGraphTitle Number of Injections
local violenceGraphTitle Experienced Any Violence
local nFullVaccYGraphTitle Is Not Fully Vaccinated (1-12 months)
local nFullVaccOGraphTitle Is Not Fully Vaccinated (12-24 months)
local neverVaccYGraphTitle Never Vaccinated (1-12 months)
local neverVaccOGraphTitle Never Vaccinated (12-24 months)
local chHAZGraphTitle Child Stunting
local chUnderwGraphTitle Child Underweight
local chWastingGraphTitle Child Wasting
local alcoholGraphTitle Men Use Alcohol
local smokingGraphTitle Men Do Smoke
local chAnemicGraphTitle Child Is Anaemic
local adultAnemicGraphTitle Adult Is Anaemic
local adultUnderwGraphTitle Adult Underweight

// Add main estimate Y-axis location
local injBeta1Y 1
local violenceBeta1Y 0.9
local nFullVaccYBeta1Y 0.3
local nFullVaccOBeta1Y 0.9
local neverVaccYBeta1Y 0.9
local neverVaccOBeta1Y 0.9
local chHAZBeta1Y 0.9
local chUnderwBeta1Y 0.9
local chWastingBeta1Y 0.9
local alcoholBeta1Y 0.9
local smokingBeta1Y 0.9
local chAnemicBeta1Y 0.3
local adultAnemicBeta1Y 0.9
local adultUnderwBeta1Y 0.9

// Add lowWealth estimate Y-axis location
local injBeta2Y 0.5
local violenceBeta2Y 0.7
local nFullVaccYBeta2Y 0.1
local nFullVaccOBeta2Y 0.7
local neverVaccYBeta2Y 0.7
local neverVaccOBeta2Y 0.7
local chHAZBeta2Y 0.7
local chUnderwBeta2Y 0.7
local chWastingBeta2Y 0.7
local alcoholBeta2Y 0.7
local smokingBeta2Y 0.7
local chAnemicBeta2Y 0.1
local adultAnemicBeta2Y 0.7
local adultUnderwBeta2Y 0.7

local injGraphType `graphTypeReg'
local violenceGraphType `graphTypeProbitLegend'
local nFullVaccYGraphType `graphTypeProbitNoLegend'
local nFullVaccOGraphType `graphTypeProbitNoLegend'
local neverVaccYGraphType `graphTypeProbitLegend'
local neverVaccOGraphType `graphTypeProbitNoLegend'
local chHAZGraphType `graphTypeProbitNoLegend'
local chUnderwGraphType `graphTypeProbitNoLegend'
local chWastingGraphType `graphTypeProbitNoLegend'
local alcoholGraphType `graphTypeProbitLegend'
local smokingGraphType `graphTypeProbitNoLegend'
local chAnemicGraphType `graphTypeProbitNoLegend'
local adultAnemicGraphType `graphTypeProbitNoLegend'
local adultUnderwGraphType `graphTypeProbitLegend'

foreach varName in `variables' {
    local t abs(`varName'Values[1,1] / `varName'Values[1,2])
    sstar `t'
    local hiStars "`r(sstar)'"
    local t abs(`varName'Values[1,3] / `varName'Values[1,4])
    sstar `t'
    local loStars "`r(sstar)'"

    local graphTitle ``varName'GraphTitle'
    local beta1Y ``varName'Beta1Y'
    local beta2Y ``varName'Beta2Y'
    run `basePath'/src/scripts/makeGraph `varName'Values `varName' "`graphTitle'" `beta1Y' `beta2Y' ``varName'GraphType' `hiStars' `loStars'
}

// Figure 3
grc1leg2 nFullVaccO.gph neverVaccO.gph nFullVaccY.gph neverVaccY.gph,  rows(2) legendfrom(neverVaccY.gph) graphregion(color(white)) name(`graphName1', replace) iscale(0.4)
gr export "`resultImageFolder'/`graphName1'.`graphFormat'", as(`graphFormat') name(`graphName1') replace

// Figure 4
grc1leg2 chHAZ.gph chUnderw.gph chWasting.gph adultUnderw.gph,  rows(2) legendfrom(adultUnderw.gph) graphregion(color(white)) name(`graphName2', replace) iscale(0.4)
gr export "`resultImageFolder'/`graphName2'.`graphFormat'", as(`graphFormat') name(`graphName2') replace

// Figure 5
grc1leg2 chAnemic.gph adultAnemic.gph smoking.gph alcohol.gph violence.gph inj.gph, rows(3) legendfrom(alcohol.gph) graphregion(color(white)) name(`graphName3', replace) iscale(0.4) ysize(7)
gr export "`resultImageFolder'/`graphName3'.`graphFormat'", as(`graphFormat') name(`graphName3') replace