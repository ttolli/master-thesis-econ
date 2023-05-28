//******************************************************************************
//
// Appends proper data for adult underweight calculator.
//
// DHS data has BMI-data in hh-member dataset. However, in order to drop
// pregnant women as well as women who have gave birth in less than two months,
// one needs such info from women dataset. Thus, in order to combine these both,
// a new dataset needs to be done, as it is not possible to use hh-member
// dataset as a master for merge.
// Arguments:
//   * basePath             - repository base path
//   * runEdgeAnalysis      - 1 ~ run edge analysis, 0 ~ do not run and report
//******************************************************************************
args basePath runEdgeAnalysis

// If edge analysis not selected, we haven't build corresponding variable so
// it's not available
if (`runEdgeAnalysis' > 0) {
	local edgeAnalysisVariable distancetobordersinsidestate
}

// 2021 ************************************************************************
use women2021.dta, clear

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 v130 s116

sort v001
gen age = v012
gen bmi = v445

// Drop if pregnant, or if gave birth in the 2 months preceding the date of the interview
drop if !(b19_01 >= 2 | v208 == 0) | v213 == 1 | age < 18

// Woman
gen sex = 1
keep age sex afterCovidStarted afterAndPoor isPoorState highStringencyState highStringencyAndPoor afterAndHighStringency afterPoorHighStringency isInProgressState isWinterMonths isUrban v024 v006 sdist wt isHindu isMuslim isChristian isSikh isCaste isTribe bmi v001 `edgeAnalysisVariable'

save women2021forBMI.dta, replace

use hhMember2021.dta, clear
rename hv024 v024
rename hv025 v025
rename hv006 v006
rename shdist sdist
rename hb40 bmi

run `basePath'/src/scripts/makeControls afterCovidStarted isPoorState v024 v025 sh47 sh49

sort v001
gen age = .
replace age = hb1 if hb1 != .
drop if age < 18 | age == . | bmi== .
// Man
gen sex = 0
keep age sex afterCovidStarted afterAndPoor isPoorState highStringencyState highStringencyAndPoor afterAndHighStringency afterPoorHighStringency isInProgressState isWinterMonths isUrban v024 v006 sdist wt isHindu isMuslim isChristian isSikh isCaste isTribe bmi v001 `edgeAnalysisVariable'

append using women2021forBMI.dta

save adult2021forBMI.dta, replace

// 2016 ************************************************************************

use women2016.dta, clear

sort v001
gen age = v012
gen bmi = v445

// Drop if pregnant, or if gave birth in the 2 months preceding the date of the interview
// Note that only pregnancy status available for 2016
drop if v213 == 1 | age < 18

// Woman
gen sex = 1
keep age sex isPoorState isInProgressState isUrban v024 v006 sdist wt bmi v001
save women2016forBMI.dta, replace

use hhMember2016.dta, clear
rename hv024 v024
rename hv025 v025
rename hv006 v006
rename shdist sdist
rename hb40 bmi

sort v001
gen age = .
replace age = hb1 if hb1 != .
drop if age < 18 | age == . | bmi == .
// Man
gen sex = 0
keep age sex isPoorState isInProgressState isUrban v024 v006 sdist wt bmi v001

append using women2016forBMI.dta

save adult2016forBMI.dta, replace

// 2006 ************************************************************************

use women2006.dta, clear

sort v001
gen age = v012
gen bmi = v445

// Drop if pregnant, or if gave birth in the 2 months preceding the date of the interview
// Note that only pregnancy status available for 2016
drop if v213 == 1 | age < 18

// Woman
gen sex = 1
keep age sex isPoorState isInProgressState isUrban v024 v006 wt bmi v001
save women2006forBMI.dta, replace

use hhMember2006.dta, clear
rename hv024 v024
rename hv025 v025
rename hv006 v006
rename hb40 bmi

sort v001
gen age = .
replace age = hb1 if hb1 != .
drop if age < 18 | age == . | bmi == .
// Man
gen sex = 0
keep age sex isPoorState isInProgressState isUrban v024 v006 wt bmi v001

append using women2006forBMI.dta

save adult2006forBMI.dta, replace