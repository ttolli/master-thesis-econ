//******************************************************************************
//
// Visualize different dhs surveys in one single histogram, used in
// presentation.
// This is used to make data histogram in Figure 2, (a)
//
//******************************************************************************

use datetime.dta, clear

local graphName dhsHistogramAllDhs
local graphFormat eps
local basePath C:/Users/ttoll/Documents/src/git/aalto/mmaster-thesis-econ
local resultImageFolder `basePath'/doc/images/

histogram datetime if datetime < 18990, width(10) start(16337) freq xlabel(16437 "2005" 16802 "2006" 17167 "2007" 17532 "2008" 17898 "2009" 18263 "2010" 18628 "2011" 18993 "2012" 19359 "2013" 19724 "2015" 20089 "2015" 20454 "2016" 20820 "2017" 21185 "2018" 21550 "2019" 21915 "2020" 22281 "2021" 22646 "2022", angle(forty_five)) ylabel (10000 "10000" 20000 "20 000" 30000 "30 000") xtitle("Start of year") ytitle("Observations") lcolor("255 204 203") fcolor("255 204 203") addplot(histogram datetime if datetime > 18990 & datetime < 21382, freq lcolor(eltgreen) fcolor(eltgreen) || histogram datetime if datetime > 21382, freq lcolor(eltblue) fcolor(eltblue)) legend(order(1 "DHS-3" 2 "DHS-4" 3 "DHS-5") cols(3) pos(11) ring(0)) bgcolor(white) graphregion(color(white)) saving(`graphName', replace)

//fcolor(gs12) lcolor(gs12) addplot(histogram datetime if isInProgressState==1&afterCovidStarted==0,  width(10) start(21700) freq lcolor("255 204 203") fcolor("255 204 203") legend(off) title(DHS India 2019-21) || histogram datetime if isInProgressState==1&afterCovidStarted==1, freq lcolor(eltblue) fcolor(eltblue)  width(10) start(21700) || scatteri 0 21921 0 21994, recast(line) color(red) lwidth(thin) || scatteri 0 21921 25000 21921, recast(line) color(red) lwidth(thin) || scatteri 25000 21921 25000 21994, recast(line) color(red) lwidth(thin) || scatteri 0 21994 25000 21994, recast(line) color(red) lwidth(thin) || scatteri 0 22287 0 22359, recast(line) color(blue) lwidth(thin) || scatteri 25000 22287 0 22287, recast(line) color(blue) lwidth(thin) || scatteri 25000 22287 25000 22359, recast(line) color(blue)  lwidth(thin) || scatteri 25000 22359 0 22359, recast(line) color(blue) lwidth(thin))