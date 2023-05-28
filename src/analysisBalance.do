//******************************************************************************
//
// Balancing checks for used controls
//
// Runs the balancing tests and makes corresponding tables, namely Tables A1-A4
//
// Script assumes the data has been read using readAllDhsData, and that stored
// datafiles (.dta) are found from current folder
//
// Arguments:
//   * basePath             - repository base path
//   * resultTableFolder    - folder to store result table
//******************************************************************************
args basePath resultTableFolder

// Set up results
local resultTableName balance
local resultTableName2 balance2
local resultTableName3 balance3
local resultTableName4 balance4
local fullTableName `resultTableFolder'/`resultTableName'.tex
local fullTableName2 `resultTableFolder'/`resultTableName2'.tex
local fullTableName3 `resultTableFolder'/`resultTableName3'.tex
local fullTableName4 `resultTableFolder'/`resultTableName4'.tex

local columnLabels "N" "Before" "After" "P-value (Before==After)"

local sexIsIncluded 0
local sexIsNotIncluded 1

local ageIsInMonths 0
local ageIsInYears 1

local resetMatrix 1
local doNotResetMatrix 0

use children2021.dta, clear

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

run `basePath'/src/scripts/createVaccinationVariables

gen sex = b4 == 2

//**** Not fully vaccinated, 12-24 *********************************************
gen isNotFullyVaccO=.
replace isNotFullyVaccO=isNotFullyVacc if is_1_12==0
local dependentVarCond isNotFullyVaccO !=.
local variableHeader "Is Not Fully Vaccinated (Aged 12-24)"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsIncluded' `ageIsInMonths' "`variableHeader'" `resetMatrix'

//**** Never vaccinated, 12-24 **********************************************
gen neverVaccO =.
replace neverVaccO=neverVacc if is_1_12==0
local dependentVarCond neverVaccO !=.
local variableHeader "Never Vaccinated (12-24)"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsIncluded' `ageIsInMonths' "`variableHeader'" `doNotResetMatrix'

//**** Not fully vaccinated, 1-12 *********************************************
gen isNotFullyVaccY=.
replace isNotFullyVaccY=isNotFullyVacc if is_1_12==1
local dependentVarCond isNotFullyVaccY !=.
local variableHeader "Is Not Fully Vaccinated (1-12)"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsIncluded' `ageIsInMonths' "`variableHeader'" `doNotResetMatrix'

//**** Never vaccinated, 1-12 **********************************************
gen neverVaccY =.
replace neverVaccY=neverVacc if is_1_12==1
local dependentVarCond neverVaccY !=.
local variableHeader "Never Vaccinated (1-12)"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsIncluded' `ageIsInMonths' "`variableHeader'" `doNotResetMatrix'

mat colnames balanceResult = "`columnLabels'"
esttab mat(balanceResult, fmt(%8.0f %8.3f %8.3f %8.3f)) using `fullTableName', mlabels(,none) replace

run `basePath'/src/scripts/createChildNutritionVariables `basePath'

//**** Child Stunting *********************************************
local dependentVarCond childStunting !=.
local variableHeader "Child Stunting"
local depVar chStunting
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsIncluded' `ageIsInMonths' "`variableHeader'" `resetMatrix'

//**** Child Underweight *********************************************
local dependentVarCond childUnderweight !=.
local variableHeader "Child Underweight"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsIncluded' `ageIsInMonths' "`variableHeader'" `doNotResetMatrix'

//**** Child Wasting *********************************************
local dependentVarCond childWasting !=.
local variableHeader "Child Wasting"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsIncluded' `ageIsInMonths' "`variableHeader'" `doNotResetMatrix'

use adult2021forBMI.dta, clear
// **** Adult Underweight ******************************************************
gen adultUnderweight = .
replace adultUnderweight = 1 if bmi <= 1850
replace adultUnderweight = 0 if (bmi > 1850 & bmi < 6000)
local dependentVarCond adultUnderweight!=.
local variableHeader "Adult Underweight"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsIncluded' `ageIsInYears' "`variableHeader'" `doNotResetMatrix'

mat colnames balanceResult = "`columnLabels'"
esttab mat(balanceResult, fmt(%8.0f %8.3f %8.3f %8.3f)) using `fullTableName2', mlabels(,none) replace

use hhMember2021.dta, clear
rename hv024 v024
rename hv025 v025
rename hv006 v006
rename shdist sdist

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 sh47 sh49

gen sex = .
replace sex = 1 if hv104 == 2
replace sex = 0 if hv104 == 1
gen age = hc1
gen childAnemic=.
replace childAnemic=1 if hc57==1|hc57==2|hc57==3
replace childAnemic=0 if hc57==4
local dependentVarCond childAnemic!=.
local variableHeader "Child Is Anemic"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsIncluded' `ageIsInMonths' "`variableHeader'" `resetMatrix'

// **** Adult Anemic ***********************************************************
drop age
gen age = .
replace age = ha1 if ha1 != .
replace age = hb1 if hb1 != .
gen adultAnemic=.
replace adultAnemic=1 if hb57==1|hb57==2|hb57==3|ha57==1|ha57==2|ha57==3
replace adultAnemic=0 if hb57==4|ha57==4
gen isAdult = hv105 >= 18
local dependentVarCond adultAnemic != . & isAdult == 1
local variableHeader "Adult Is Anemic"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsIncluded' `ageIsInYears' "`variableHeader'" `doNotResetMatrix'

use men2021.dta, clear
rename mv024 v024
rename mv025 v025
rename mv006 v006
rename smdist sdist

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 mv130 sm118

// **** Men Smoking ************************************************************
gen age = mv012
gen isAdult = mv012 >= 18
local dependentVarCond mv463z != . & isAdult == 1
local variableHeader "Men Do Smoke"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsNotIncluded' `ageIsInYears' "`variableHeader'" `doNotResetMatrix'

// **** Men Alcohol ************************************************************
local dependentVarCond sm619 != . & isAdult == 1
local variableHeader "Men Use Alcohol"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsNotIncluded' `ageIsInYears' "`variableHeader'" `doNotResetMatrix'

mat colnames balanceResult = "`columnLabels'"
esttab mat(balanceResult, fmt(%8.0f %8.3f %8.3f %8.3f)) using `fullTableName3', mlabels(,none) replace

use women2021.dta, clear

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

//**** Experienced any violence ************************************************
gen age = v012
gen experiencedAnyViolence = .
replace experiencedAnyViolence = 0 if d104 == 0 & d106 == 0 & d107 == 0 & d108 == 0
replace experiencedAnyViolence = 1 if d104 == 1 | d106 == 1 | d107 == 1 | d108 == 1

local dependentVarCond experiencedAnyViolence!=.
local variableHeader "Experienced Any Violence"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wd `sexIsNotIncluded' `ageIsInYears' "`variableHeader'" `resetMatrix'

// **** Women N Of Injections **************************************************
local dependentVarCond v477 < 98
local variableHeader "Number of Injections"
run `basePath'/src/scripts/balanceTestSingle "`dependentVarCond'" wt `sexIsNotIncluded' `ageIsInYears' "`variableHeader'" `doNotResetMatrix'

mat colnames balanceResult = "`columnLabels'"
esttab mat(balanceResult, fmt(%8.0f %8.3f %8.3f %8.3f)) using `fullTableName4', mlabels(,none) replace
