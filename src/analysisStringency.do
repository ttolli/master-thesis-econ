//******************************************************************************
//
// Stringency analysis
//
// Runs the corresponding regressions and probits for making corresponding
// table, and makes Table 7 of the thesis.
//
// Script assumes the data has been read using readAllDhsData, and that stored
// datafiles (.dta) are found from current folder.
//
// Results are outputted as latex tables, hence the syntax for labels
//
// Arguments:
//   * basePath             - repository base path
//   * resultTableFolder    - folder to store result table
//******************************************************************************
args basePath resultTableFolder

use women2021.dta, clear

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

//**** Number of injections ************************************************
local modelType 1
gen extraCond = v477 < 98
gen age = v012
gen monthOfBirth = v009
run `basePath'/src/scripts/generateStringency v477 nOfInj wt sdist age monthOfBirth `modelType'

//**** Experienced any violence **********************************************
gen experiencedAnyViolence = .
replace experiencedAnyViolence = 0 if d104 == 0 & d106 == 0 & d107 == 0 & d108 == 0
replace experiencedAnyViolence = 1 if d104 == 1 | d106 == 1 | d107 == 1 | d108 == 1
drop extraCond
gen extraCond = 1
gen sex = 1 // Single sex
local modelType 0
run `basePath'/src/scripts/generateStringency experiencedAnyViolence violence wd sdist age monthOfBirth `modelType'

use children2021.dta, clear

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

run `basePath'/src/scripts/createVaccinationVariables

//**** Not fully vaccinated, 1-12 **********************************************
gen extraCond = is_1_12 == 1
gen sex = b4
gen monthOfBirth = b1
run `basePath'/src/scripts/generateStringency isNotFullyVacc isNotFullyVaccY wt sdist age monthOfBirth `modelType'


//**** Not fully vaccinated, 12-24 *********************************************
drop extraCond
gen extraCond = is_1_12 == 0
run `basePath'/src/scripts/generateStringency isNotFullyVacc isNotFullyVaccO wt sdist age monthOfBirth `modelType'


//**** Never vaccinated, 1-12 **************************************************
drop extraCond
gen extraCond = is_1_12 == 1
run `basePath'/src/scripts/generateStringency neverVacc neverVaccY wt sdist age monthOfBirth `modelType'

//**** Never vaccinated, 12-24 *************************************************
drop extraCond
gen extraCond = is_1_12 == 0
run `basePath'/src/scripts/generateStringency neverVacc neverVaccO wt sdist age monthOfBirth `modelType'

//**** Children underweight ****************************************************
// https://dhsprogram.com/data/Guide-to-DHS-Statistics/index.htm#t=Nutritional_Status.htm&rhsearch=nutrition&rhhlterm=nutrition&rhsyns=%20
run `basePath'/src/scripts/createChildNutritionVariables `basePath'

drop extraCond
gen extraCond = 1

// Stunting, a.k.a., HAZ
run `basePath'/src/scripts/generateStringency childStunting childIsStunting wt sdist age monthOfBirth  `modelType'

// Underweight
run `basePath'/src/scripts/generateStringency childUnderweight childIsUnderw wt sdist age monthOfBirth  `modelType'

// Wasting
run `basePath'/src/scripts/generateStringency childWasting childIsWasting wt sdist age monthOfBirth  `modelType'

use men2021.dta, clear
rename mv024 v024
rename mv025 v025
rename mv006 v006

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 mv130 sm118

//**** Men alcohol ***********************************************************
gen extraCond = mv012 >= 18
gen sex = 1 // Single sex
gen age = mv012
gen monthOfBirth = mv009
run `basePath'/src/scripts/generateStringency sm619 menUseAlcohol wt smdist age monthOfBirth `modelType'

//**** Men smoking ***********************************************************
gen menSmoke=.
replace menSmoke = 0 if mv463z==1
replace menSmoke = 1 if mv463z==0
run `basePath'/src/scripts/generateStringency menSmoke menDoSmoke wt smdist age monthOfBirth `modelType'

use hhMember2021.dta, clear

rename hv024 v024
rename hv025 v025
rename hv006 v006
run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 sh47 sh49

//**** Children anemia *******************************************************
gen childAnemic=.
replace childAnemic=1 if hc57==1|hc57==2|hc57==3
replace childAnemic=0 if hc57==4
gen extraCond = 1
gen sex = .
replace sex = 1 if hv104 == 2
replace sex = 0 if hv104 == 1
gen monthOfBirth = hc30
gen age = hc1
run `basePath'/src/scripts/generateStringency childAnemic childIsAnemic wt shdist age monthOfBirth `modelType'

// //**** Adult anemia **********************************************************
gen adultAnemic=.
replace adultAnemic=1 if hb57==1|hb57==2|hb57==3|ha57==1|ha57==2|ha57==3
replace adultAnemic=0 if hb57==4|ha57==4
drop monthOfBirth
// N/A for adults in hh member data
gen monthOfBirth = 1
gen adultAge = .
replace adultAge = ha1 if ha1 != .
replace adultAge = hb1 if hb1 != .
drop extraCond
gen extraCond = hv105 >= 18
run `basePath'/src/scripts/generateStringency adultAnemic adultIsAnemic wt shdist adultAge monthOfBirth `modelType'

//**** Adult underweight *****************************************************
use adult2021forBMI.dta, clear
// N/A for adults
gen monthOfBirth = 1
gen adultUnderweight = .
replace adultUnderweight = 1 if bmi <= 1850
replace adultUnderweight = 0 if (bmi > 1850 & bmi < 6000)
gen extraCond = 1
run `basePath'/src/scripts/generateStringency adultUnderweight adultUnderw wt sdist age monthOfBirt `modelType'

local resultTableName analysisStringency
local fullTableName `resultTableFolder'/`resultTableName'`tabulatePost'.tex
local interestVariables afterCovidStarted afterAndPoor afterAndHighStringency afterPoorHighStringency

local commonTableCommand fragment star(* 0.10 ** 0.05 *** 0.01) b(%8.3f) se(%8.3f) label coeflabels(afterCovidStarted "\textit{After}" afterAndPoor "\textit{After} x \textit{LowWealth}" afterAndHighStringency "\textit{After} x \textit{HiStr}" afterPoorHighStringency "\textit{After} x \textit{LowWealth} x \textit{HiStr}") nonumbers noobs nomtitles keep(`interestVariables')

//**** Result tables ***********************************************************

// First, some common helpers for reporting tex tables
local postCaption \caption*{\textbf{After} is \textit{after-lockdown}-indicator, \textbf{LowWealth} denotes belonging to two lowest wealth quintiles, \textbf{HiStr} denotes belonging to states with higher COVID-19 stringency index, and \textbf{x} denotes interaction between dependent variables. Models are controlled for wealth status, region (urban/rural), state and month fixed effects, children age and children month of birth.}
// , sex, religion and ethnicity background

local standardErrorsCommand postfoot("\hline\hline \multicolumn{8}{l}{\footnotesize Standard errors in parentheses}\\ \multicolumn{8}{l}{\footnotesize \sym{*} \(p<0.1\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\ \end{tabular} \\ `postCaption' \end{table}")

local preheadCommandPre prehead("\begin{table}[htbp]\centering \footnotesize \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}

local preheadCommandMiddle \begin{tabular}{l*{

local preheadCommandPost }{c}} \hline\hline")

local postheadCommandPre posthead("&\rot{Not Fully Vacc, 12-24}&\rot{Never Vacc, 12-24}&\rot{Not Fully Vacc, 1-12}&\rot{Never Vacc, 1-12}&\rot{Child Stunting}&\rot{Child Underweight}&\rot{Child Wasting}
local postheadCommandPost \\")

local tableHeading \footnotesize Marginal probit estimates (\cref{eq:stringencyProbitModel}) for stringency analysis

local tableCaption \caption{\label{tab:`resultTableName'} `tableHeading'}

local variables isNotFullyVaccO neverVaccO isNotFullyVaccY neverVaccY childIsStunting childIsUnderw childIsWasting
local numberOfRegressions 7
local preheadCommand `preheadCommandPre'`tableCaption'`preheadCommandMiddle'`numberOfRegressions'`preheadCommandPost'
local postHeadCommand `postheadCommandPre'`panelName'`postheadCommandPost'
esttab `variables' using `fullTableName', `preheadCommand' `postHeadCommand' `commonTableCommand' replace

local postheadCommandPre posthead("&\rot{Adult Underweight}&\rot{Child Anaemic}&\rot{Adult Anaemic}&\rot{Men Smoke}&\rot{Men Alcohol}&\rot{Exp Violence}&\rot{Number of Inj}
local variables adultUnderw childIsAnemic adultIsAnemic menDoSmoke menUseAlcohol violence nOfInj

local postHeadCommand `postheadCommandPre'`panelName'`postheadCommandPost'
esttab `variables' using `fullTableName', `postHeadCommand' `commonTableCommand' append `standardErrorsCommand'