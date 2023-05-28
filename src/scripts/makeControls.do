//******************************************************************************
//
// A helper to generate used interaction, control variables and stratum
//
// Arguments:
//   * afterCovidStarted - Dummy to indicate if observation has been collected
//                         before or after March 22, 2020
//   * isPoorState       - Dummy to indicate wealth state of individual
//   * states            - Indian state
//   * urbanRural        - Dummy to indicate if iterviewee lives in urban area
//   * religion          - DHS dataset variable to indicate religion
//   * ethnicity         - DHS dataset variable to indicate if scheduled caste
//                         or tribe
//******************************************************************************

args afterCovidStarted isPoorState states urbanRural religion ethnicity

// Generate interaction term. We want to do it separately, instead of using ##-notation, in order to better tabulate the results
gen afterAndPoor = `afterCovidStarted'*`isPoorState'

// Generate stratum to be used when clustering standard errors. v024 is for states, and v025 for urban/rural
egen stratum = group(`states' `urbanRural')

gen isHindu = .
replace isHindu = 1 if `religion' == 1
replace isHindu = 0 if `religion' != 1 & `religion' != .
gen isMuslim = .
replace isMuslim = 1 if `religion' == 2
replace isMuslim = 0 if `religion' != 2 & `religion' != .
gen isChristian = .
replace isChristian = 1 if `religion' == 3
replace isChristian = 0 if `religion' != 3 & `religion' != .
gen isSikh = .
replace isSikh = 1 if `religion' == 4
replace isSikh = 0 if `religion' != 4 & `religion' != .

// Women s116, sm118 s116 sh49
//            1 Schedule caste
//            2 Schedule tribe
//            3 OBC
//            4 None of them
//            8 Don't know
gen isCaste = .
replace isCaste = 1 if `ethnicity' == 1
replace isCaste = 0 if `ethnicity' != 1 & `ethnicity' != .
gen isTribe = .
replace isTribe = 1 if `ethnicity' == 2
replace isTribe = 0 if `ethnicity' != 2 & `ethnicity' != .

// Extra variables for stringency analysis
gen highStringencyState = (v024 == 7 | v024 == 20 | v024 == 34 | v024 == 3 | v024 == 8)
gen highStringencyAndPoor = highStringencyState*isPoorState
gen afterAndHighStringency = highStringencyState*afterCovidStarted
gen afterPoorHighStringency = highStringencyState*afterCovidStarted*isPoorState