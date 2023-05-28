//******************************************************************************
//
// Creates vaccination variables.
//
// Script creates vaccination variables for loaded DHS data.
//
// Output variables are all the "basic" six antigens that are used to define a
// fully vaccinated child since the early 1980s according to the Expanded
// Programme on Immunization (EPI), namely BCG (hasBCT), 3 doses of DTP
// (hasDTP1/2/3), 3 doses of polio (hasPolio1/2/3) and measles(hasMeasles).
//
// In addition to single variables, a variable is created to indicate fully
// vaccination (hasAllVaccinations) and never vaccinated (hasNoneVaccination)
// status, according to the EPI programme ("WHO. Harmonizing vaccination
// coverage measures in household surveys: a primer. Geneva: World Health
// Organization, 2019.")
//
// Reference results denotes results from reference state, and results from
// in-progress states
//******************************************************************************

gen isNotFullyVacc = .
gen neverVacc = .

// Note: as per reference paper, missing values or 'do not know's classified treated as having not received vaccination. I.e., 0 ~ no, 8 ~ Don't know and . ~ missing --> no vaccination
gen hasBCG = (h2 == 1 | h2 == 2 | h2 == 3 | h2 == 4)
gen hasDPT1 = (h3 == 1 | h3 == 2 | h3 == 3 | h3 == 4)
gen hasDPT2 = (h4 == 1 | h4 == 2 | h4 == 3 | h4 == 4)
gen hasDPT3 = (h5 == 1 | h5 == 2 | h5 == 3 | h5 == 4)
gen hasPolio1 = (h6 == 1 | h6 == 2 | h6 == 3 | h6 == 4)
gen hasPolio2 = (h7 == 1 | h7 == 2 | h7 == 3 | h7 == 4)
gen hasPolio3 = (h8 == 1 | h8 == 2 | h8 == 3 | h8 == 4)
gen hasMeasles = (h9 == 1 | h9 == 2 | h9 == 3 | h9 == 4)

gen doesNotHaveBCG = hasBCG == 0
gen doesNotHaveDPT1 = hasDPT1 == 0
gen doesNotHaveDPT2 = hasDPT2 == 0
gen doesNotHaveDPT3 = hasDPT3 == 0
gen doesNotHavePolio1 = hasPolio1 == 0
gen doesNotHavePolio2 = hasPolio2 == 0
gen doesNotHavePolio3 = hasPolio3 == 0
gen doesNotHaveMeasles = hasMeasles == 0

replace isNotFullyVacc = 0 if hasBCG == 1 & hasDPT1 == 1 & hasDPT2 == 1 & hasDPT3 == 1 & hasPolio1 == 1 & hasPolio2 == 1 & hasPolio3 == 1 & hasMeasles == 1
replace isNotFullyVacc = 1 if (hasBCG == 0 | hasDPT1 == 0 | hasDPT2 == 0 | hasDPT3 == 0 | hasPolio1 == 0 | hasPolio2 == 0 | hasPolio3 == 0 | hasMeasles == 0)
replace neverVacc = 1 if hasBCG == 0 & hasDPT1 == 0 & hasDPT2 == 0 & hasDPT3 == 0 & hasPolio1 == 0 & hasPolio2 == 0 & hasPolio3 == 0 & hasMeasles == 0 
replace neverVacc = 0 if (hasBCG == 1 | hasDPT1 == 1 | hasDPT2 == 1 | hasDPT3 == 1 | hasPolio1 == 1 | hasPolio2 == 1 | hasPolio3 == 1 | hasMeasles == 1)

gen is_1_12 = .
replace is_1_12 = 1 if hw1 >= 1 & hw1 < 12
replace is_1_12 = 0 if hw1 >= 12 & hw1 < 24

gen age = hw1