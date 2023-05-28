//******************************************************************************
//
// A script to import OxGRT-stringency data, and visualize it, arranged by
// mean stringency values.
//
// All states are re-labeled by attaching corresponding mean Stringency index.
//
// Finally, a stringency visualization is visualized using heatmap.
//
// Saving the image needs to be done manually, though. It seems to be impossible
// to change all the background colors to white in any other way except
// manually...
//******************************************************************************
insheet using "https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/India/OxCGRT_IND_latest.csv", clear

ren regionname state

// Make the date format sensible
tostring date, gen(date2)
drop date
gen date = date(date2,"YMD")
format date %tdyyyy/Mon/DD
drop date2

// Let's limit the scale from Jan, 2020 to March, 2021
drop if date < 21915
drop if date > 22359

order state date

// Find out in-progress states, and keep them only
gen inProgressState=.
replace inProgressState = 1 if state == "Punjab" | state == "Uttarakhand" | state == "Haryana" | state == "Delhi" | state == "Rajasthan" | state == "Uttar Pradesh" | state == "Arunachal Pradesh" | state == "Jharkhand" | state == "Odisha" | state == "Chhattisgarh" | state == "Madhya Pradesh" | state == "Tamil Nadu" | state == "Puducherry"
keep if inProgressState==1
drop inProgressState

// Find mean stringency, and attach it to the state labels
sort state
encode state , gen(state2)
egen mean = mean(stringencyindex_average), by(state2)
egen tag = tag(state2)
gsort -tag -mean
sort mean
egen state3 = rank(mean), by(date)
// Note: labmask-package needs to be installed
labmask state3, val(state)
// TODO: This labeling needs to be automated! I just haven't yet found out the correct solution on how to do it, thus so far I had to do it manually :(
// Let's find out first the values:
list state2 mean if tag, noobs
// Then relabel them
label define state3cat 1 "Haryana - 51.02" 2 "Madhya Pradesh - 56.03" 3 "Chhattisgarh - 56.68" 4 "Tamil Nadu - 57.01" 5 "Uttarakhand - 57.13" 6 "Odisha - 60.30" 7 "Arunachal Pradesh - 61.17" 8 "Uttar Pradesh - 61.32" 9 "Delhi - 61.43" 10 "Jharkhand - 61.47" 11 "Puducherry - 61.72" 12 "Punjab - 63.32" 13 "Rajasthan - 64.89", modify
// Actual relabeling
label values state3 state3cat

summ date
local x1 = `r(min)'
local x2 = `r(max)'

// color(white red)
// color(inferno, reverse)
local colorTheme color(inferno, reverse)

ren stringencyindex_average_fordispl Stringency
heatplot Stringency i.state3 date, yscale(noline) ylabel(, nogrid labsize(*0.7)) xlabel(`x1'(10)`x2', labsize(*0.6) angle(vertical) format(%tdyyyy/NN/DD) nogrid) `colorTheme' cuts(0(10)100) ramp(right space(10) label(0(10)100)) ytitle("") xtitle("", size(vsmall)) title("COVID-19 Policy Stringency Index") note("Data source: Oxford COVID-19 Government Response Tracker.", size(vsmall)) name(stringencyIndex, replace) saving(stringencyIndex, replace)