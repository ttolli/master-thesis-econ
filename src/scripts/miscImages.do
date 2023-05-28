//******************************************************************************
//
// Misc images for paper and presentation:
//  - Histogram visualizing before-after-covid status of in-progress states, as
//    well as reference states
//
//******************************************************************************

local graphName dhsHistogram
local graphFormat eps
local basePath C:/Users/ttoll/Documents/src/git/aalto/master-thesis-econ
local resultImageFolder `basePath'/doc/images/

use indiaGpsMerged.dta, clear

// 3 - Punjab
// 5 - Uttarakhand
// 6 - Haryana
// 7 - Nct Of Delhi
// 8 - Rajasthan
// 9 - Uttar Pradesh
// 12 - Arunaachal Pradehs
// 20 - Jharkhand
// 21 - Odisha
// 22 - Chhattisgarh
// 23 - Madhya Pradesh
// 33 - Tamil Nadu
// 34 - Puducherry
gen isInProgressState = hv024==3
replace isInProgressState = 1 if hv024==5
replace isInProgressState = 1 if hv024==6
replace isInProgressState = 1 if hv024==7
replace isInProgressState = 1 if hv024==8
replace isInProgressState = 1 if hv024==9
replace isInProgressState = 1 if hv024==12
replace isInProgressState = 1 if hv024==20
replace isInProgressState = 1 if hv024==21
replace isInProgressState = 1 if hv024==22
replace isInProgressState = 1 if hv024==23
replace isInProgressState = 1 if hv024==33
replace isInProgressState = 1 if hv024==34
gen afterCovidStarted = datetime >= 22200

histogram datetime, width(10) start(21700) freq xlabel(21700 "2019/05/31" 21800 "2019/08/09" 21900 "2019/12/17" 22000 "2020/03/26" 22100 "2020/07/04" 22200 "2020/10/12" 22300 "2020/01/20" 22400 "2021/04/30", angle(forty_five)) ylabel (5000 "5000" 10000 "10 000" 15000 "15 000" 20000 "20 000" 25000 "25 000") xtitle("Date") ytitle("Observations") fcolor(gs12) lcolor(gs12) addplot(histogram datetime if isInProgressState==1&afterCovidStarted==0,  width(10) start(21700) freq lcolor("255 204 203") fcolor("255 204 203") legend(off) title(DHS India 2019-21) || histogram datetime if isInProgressState==1&afterCovidStarted==1, freq lcolor(eltblue) fcolor(eltblue)  width(10) start(21700) || scatteri 0 21921 0 21994, recast(line) color(red) lwidth(thin) || scatteri 0 21921 25000 21921, recast(line) color(red) lwidth(thin) || scatteri 25000 21921 25000 21994, recast(line) color(red) lwidth(thin) || scatteri 0 21994 25000 21994, recast(line) color(red) lwidth(thin) || scatteri 0 22287 0 22359, recast(line) color(blue) lwidth(thin) || scatteri 25000 22287 0 22287, recast(line) color(blue) lwidth(thin) || scatteri 25000 22287 25000 22359, recast(line) color(blue)  lwidth(thin) || scatteri 25000 22359 0 22359, recast(line) color(blue) lwidth(thin))  bgcolor(white) graphregion(color(white)) saving(`graphName', replace)

// Why this gives "could not ifnd Graph window"...? need to export manually
//gr export `resultImageFolder'\`graphName'.`graphFormat', as(`graphFormat') name(`graphName', replace) replace
