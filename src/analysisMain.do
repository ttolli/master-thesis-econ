//******************************************************************************
//
// Main analysis of the paper
//
// Runs the corresponding regressions and probits for making main and detailed
// tables, and makes them, namely Tables 1-4
//
// Script assumes the data has been read using readAllDhsData, and that
// the stored datafiles (.dta) are found from current folder.
//
// Results are outputted as latex tables, hence the syntax for labels
//
// Arguments:
//   * basePath             - repository base path
//   * resultTableFolder    - folder to store result table
//   * runEdgeAnalysis      - 1 ~ run edge analysis, 0 ~ do not run and report
//******************************************************************************
args basePath resultTableFolder runEdgeAnalysis

// The databases are such a big that stata default for maximum number of
// variables is not enough, and it needs to be increased
// set maxvar 120000

local resultTableName tableLongProbit
local resultTableName2 tableLongProbit2
local resultTableName3 tableLongProbit3
local resultTableName4 tableLongProbit4

//**** Women *******************************************************************
use women2021.dta, clear

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

//**** Number of injections ****************************************************
// Do not take into account "Dont' knows" == 98, last valid is 90
gen extraCond = v477 < 98
gen age = v012
gen monthOfBirth = v009
run `basePath'/src/scripts/analysisSingleOLS v477 nOfInj age monthOfBirth sdist wt `runEdgeAnalysis'

//**** Experienced any violence ************************************************
gen experiencedAnyViolence = .
replace experiencedAnyViolence = 0 if d104 == 0 & d106 == 0 & d107 == 0 & d108 == 0
replace experiencedAnyViolence = 1 if d104 == 1 | d106 == 1 | d107 == 1 | d108 == 1
drop extraCond
gen extraCond = 1
gen sex = 1 // Single sex
run `basePath'/src/scripts/analysisSingleProbit experiencedAnyViolence expViolence age monthOfBirth sdist sex wd `runEdgeAnalysis'

//**** Children ****************************************************************
use children2021.dta, clear

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

run `basePath'/src/scripts/createVaccinationVariables

//**** Not fully vaccinated, 1-12 **********************************************
gen extraCond = is_1_12 == 1
gen sex = b4
gen monthOfBirth = b1
run `basePath'/src/scripts/analysisSingleProbit isNotFullyVacc isNotFullyVaccY age monthOfBirth sdist sex wt `runEdgeAnalysis'

//**** Not fully vaccinated, 12-24 *********************************************
drop extraCond
gen extraCond = is_1_12 == 0
run `basePath'/src/scripts/analysisSingleProbit isNotFullyVacc isNotFullyVaccO age monthOfBirth sdist sex wt `runEdgeAnalysis'

//**** Never vaccinated, 1-12 **************************************************
drop extraCond
gen extraCond = is_1_12 == 1
run `basePath'/src/scripts/analysisSingleProbit neverVacc neverVaccY age monthOfBirth sdist sex wt `runEdgeAnalysis'

//**** Never vaccinated, 12-24 *************************************************
drop extraCond
gen extraCond = is_1_12 == 0
run `basePath'/src/scripts/analysisSingleProbit neverVacc neverVaccO age monthOfBirth sdist sex wt `runEdgeAnalysis'

//**** Children underweight ****************************************************
// https://dhsprogram.com/data/Guide-to-DHS-Statistics/index.htm#t=Nutritional_Status.htm&rhsearch=nutrition&rhhlterm=nutrition&rhsyns=%20
run `basePath'/src/scripts/createChildNutritionVariables `basePath'

drop extraCond
gen extraCond = 1

// Stunting, a.k.a., HAZ
run `basePath'/src/scripts/analysisSingleProbit childStunting childIsStunting age monthOfBirth sdist sex wt `runEdgeAnalysis'

// Underweight
run `basePath'/src/scripts/analysisSingleProbit childUnderweight childIsUnderw age monthOfBirth sdist sex wt `runEdgeAnalysis'

// Wasting
run `basePath'/src/scripts/analysisSingleProbit childWasting childIsWasting age monthOfBirth sdist sex wt `runEdgeAnalysis'

//**** Men *********************************************************************
use men2021.dta, clear
rename mv024 v024
rename mv025 v025
rename mv006 v006

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 mv130 sm118

// Survey is from year 15->, but need to drop kids and have adults only.
gen extraCond = mv012 >= 18
gen sex = 1 // Single sex
gen age = mv012
gen monthOfBirth = mv009
//**** Men alcohol *************************************************************
run `basePath'/src/scripts/analysisSingleProbit sm619 menUseAlcohol age monthOfBirth smdist sex wt `runEdgeAnalysis'

//**** Men smoking *************************************************************
gen menSmoke=.
replace menSmoke = 0 if mv463z==1
replace menSmoke = 1 if mv463z==0
run `basePath'/src/scripts/analysisSingleProbit menSmoke menDoSmoke age monthOfBirth smdist sex wt `runEdgeAnalysis'

//**** Household ***************************************************************
use hhMember2021.dta, clear
rename hv024 v024
rename hv025 v025
rename hv006 v006

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 sh47 sh49

//**** Children anemia *********************************************************
gen childAnemic=.
replace childAnemic=1 if hc57==1|hc57==2|hc57==3
replace childAnemic=0 if hc57==4
gen extraCond = 1
gen sex = .
replace sex = 1 if hv104 == 2
replace sex = 0 if hv104 == 1
gen monthOfBirth = hc30
gen age = hc1
run `basePath'/src/scripts/analysisSingleProbit childAnemic childIsAnemic age monthOfBirth shdist sex wt `runEdgeAnalysis'

//**** Adult anemia *********************************************************
gen adultAge = .
replace adultAge = ha1 if ha1 != .
replace adultAge = hb1 if hb1 != .
drop monthOfBirth
// N/A for adults in hh member data
gen monthOfBirth = 1
gen adultAnemic=.
replace adultAnemic=1 if hb57==1|hb57==2|hb57==3|ha57==1|ha57==2|ha57==3
replace adultAnemic=0 if hb57==4|ha57==4
drop extraCond
gen extraCond = hv105 >= 18
run `basePath'/src/scripts/analysisSingleProbit adultAnemic adultIsAnemic adultAge monthOfBirth shdist sex wt `runEdgeAnalysis'

//**** Adult underweight *******************************************************
use adult2021forBMI.dta, clear
// N/A for adults
gen monthOfBirth = 1
gen adultUnderweight = .
replace adultUnderweight = 1 if bmi <= 1850
replace adultUnderweight = 0 if (bmi > 1850 & bmi < 6000)
// Note that only adults are contained in adult2021forBMI, please see
// mergeMenAndWomenForBMI for details
gen extraCond = 1
run `basePath'/src/scripts/analysisSingleProbit adultUnderweight adultIsUnderw age monthOfBirth sdist sex wt `runEdgeAnalysis'

//**** Result tables ***********************************************************

//**** Full results ************************************************************

local rowOrderFirst 0
local rowOrderMiddle 1
local rowOrderLast 2

local modelProbit 0
local modelReg 1

// 1st table (Table 1)
local tableHeading \footnotesize Marginal probit estimates (\cref{eq:probitModel}) for vaccination-specific health outcome variables.

run `basePath'/src/scripts/makeSingleTableRow isNotFullyVaccO "Is Not Fully Vaccinated (12-24)" `resultTableFolder' `resultTableName' "`tableHeading'" `rowOrderFirst' `modelProbit' `runEdgeAnalysis'

run `basePath'/src/scripts/makeSingleTableRow neverVaccO "Never Vaccinated (12-24)" `resultTableFolder' `resultTableName' "`tableHeading'" `rowOrderMiddle' `modelProbit' `runEdgeAnalysis'

run `basePath'/src/scripts/makeSingleTableRow isNotFullyVaccY "Is Not Fully Vaccinated (1-12)" `resultTableFolder' `resultTableName' "`tableHeading'" `rowOrderMiddle' `modelProbit' `runEdgeAnalysis'

run `basePath'/src/scripts/makeSingleTableRow neverVaccY "Never Vaccinated (1-12)" `resultTableFolder' `resultTableName' "`tableHeading'" `rowOrderLast' `modelProbit' `runEdgeAnalysis'

// 2nd table (Table 2)
local tableHeading \footnotesize Marginal probit estimates (\cref{eq:probitModel}) for nutrition-specific health outcome variables.

run `basePath'/src/scripts/makeSingleTableRow childIsStunting "Child Stunting" `resultTableFolder' `resultTableName2' "`tableHeading'" `rowOrderFirst' `modelProbit' `runEdgeAnalysis'

run `basePath'/src/scripts/makeSingleTableRow childIsUnderw "Child Underweight" `resultTableFolder' `resultTableName2' "`tableHeading'" `rowOrderMiddle' `modelProbit' `runEdgeAnalysis'

run `basePath'/src/scripts/makeSingleTableRow childIsWasting "Child Wasting" `resultTableFolder' `resultTableName2' "`tableHeading'" `rowOrderMiddle' `modelProbit' `runEdgeAnalysis'

run `basePath'/src/scripts/makeSingleTableRow adultIsUnderw "Adult Underweight" `resultTableFolder' `resultTableName2' "`tableHeading'" `rowOrderLast' `modelProbit' `runEdgeAnalysis'

// 3rd table (Table 3)
local tableHeading \footnotesize Marginal probit estimates (\cref{eq:probitModel}) for outcome variables.

run `basePath'/src/scripts/makeSingleTableRow childIsAnemic "Child Is Anaemic" `resultTableFolder' `resultTableName3' "`tableHeading'" `rowOrderFirst' `modelProbit' `runEdgeAnalysis'

run `basePath'/src/scripts/makeSingleTableRow adultIsAnemic "Adult Is Anaemic" `resultTableFolder' `resultTableName3' "`tableHeading'" `rowOrderMiddle' `modelProbit' `runEdgeAnalysis'

run `basePath'/src/scripts/makeSingleTableRow menDoSmoke "Men Do Smoke" `resultTableFolder' `resultTableName3' "`tableHeading'" `rowOrderMiddle' `modelProbit' `runEdgeAnalysis'

run `basePath'/src/scripts/makeSingleTableRow menUseAlcohol "Men Use Alcohol" `resultTableFolder' `resultTableName3' "`tableHeading'" `rowOrderLast' `modelProbit' `runEdgeAnalysis'

// 4th table (Table 4)
local tableHeading \footnotesize OLS (\cref{eq:continuousModel}$^\dagger$) and marginal probit estimates (\cref{eq:probitModel}) for outcome variables.

run `basePath'/src/scripts/makeSingleTableRow expViolence "Experienced Any Violence" `resultTableFolder' `resultTableName4' "`tableHeading'" `rowOrderFirst' `modelProbit' `runEdgeAnalysis'

run `basePath'/src/scripts/makeSingleTableRow nOfInj "Number of Injections$^\dagger$" `resultTableFolder' `resultTableName4' "`tableHeading'" `rowOrderLast' `modelReg' `runEdgeAnalysis'