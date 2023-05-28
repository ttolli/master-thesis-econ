//******************************************************************************
//
// Reads requested DHS survey data, and saves the output as
// `output'`dhsYear'.dta
//
// Arguments:
//   * filename         - .do-file from DHS dataset to be used to import data
//   * wealth           - DHS wealth index variable to be used to create wealth
//                        dummy
//   * output           - output file name prefix
//   * dhsYear          - 2006 for DHS-3, 2016 for DHS-4 and 2021 for DHS-5
//   * gpsDataHandling  - 0 ~ no gps data handling for edge analysis
//                        1 ~ merge calculated distances for final .dta:s
//                        2 ~ find out in-progress states and before-after
//                            status for edge area calculation
//   * prefix           - variable prefix (h ~ household member, m ~ men, empty
//                        for women and children)
//******************************************************************************

args filename wealth output dhsYear gpsDataHandling prefix

clear
do `filename'

local clusterNumber `prefix'v001
local month `prefix'v006
local day `prefix'v016
local year `prefix'v007
local sampleWeight `prefix'v005
local region `prefix'v025
local state `prefix'v024
gen datetime = mdy(`month',`day',`year')

drop if datetime == .

gen wt = `sampleWeight'/1000000

// Generate in-progress and reference states
// Note that state indices are different in 2015-16 as compared to 2005-6 and
// 2019-21 data
if (`dhsYear' == 2016) {
    // 28 - Punjab
    // 34 - Uttarakhand
    // 12 - Haryana
    // 25 - Delhi
    // 29 - Rajasthan
    // 33 - Uttar Pradesh
    // 3  - Arunachal Pradesh
    // 15 - Jharkhand
    // 26 - Odisha
    // 7  - Chhattisgarh
    // 19 - Madhya Pradesh
    // 31 - Tamil Nadu
    // 27 - Puducherry
    gen isInProgressState = `state' == 28
    replace isInProgressState = 1 if `state' == 34
    replace isInProgressState = 1 if `state' == 12
    replace isInProgressState = 1 if `state' == 25
    replace isInProgressState = 1 if `state' == 29
    replace isInProgressState = 1 if `state' == 33
    replace isInProgressState = 1 if `state' == 3
    replace isInProgressState = 1 if `state' == 15
    replace isInProgressState = 1 if `state' == 26
    replace isInProgressState = 1 if `state' == 7
    replace isInProgressState = 1 if `state' == 19
    replace isInProgressState = 1 if `state' == 31
    replace isInProgressState = 1 if `state' == 27
}
else {
    // 3  - Punjab
    // 5  - Uttarakhand
    // 6  - Haryana
    // 7  - Nct Of Delhi
    // 8  - Rajasthan
    // 9  - Uttar Pradesh
    // 12 - Arunaachal Pradehs
    // 20 - Jharkhand
    // 21 - Odisha
    // 22 - Chhattisgarh
    // 23 - Madhya Pradesh
    // 33 - Tamil Nadu
    // 34 - Puducherry
    gen isInProgressState = `state' == 3
    replace isInProgressState = 1 if `state' == 5
    replace isInProgressState = 1 if `state' == 6
    replace isInProgressState = 1 if `state' == 7
    replace isInProgressState = 1 if `state' == 8
    replace isInProgressState = 1 if `state' == 9
    replace isInProgressState = 1 if `state' == 12
    replace isInProgressState = 1 if `state' == 20
    replace isInProgressState = 1 if `state' == 21
    replace isInProgressState = 1 if `state' == 22
    replace isInProgressState = 1 if `state' == 23
    replace isInProgressState = 1 if `state' == 33
    // Note that there exist no Puducherry yet on 2006
    if (`dhsYear' == 2021) {
        replace isInProgressState = 1 if `state' == 34
        gen afterCovidStarted = datetime >= 22200
        // Generate dummy to limit dates on Jan-March
        gen isWinterMonths = (datetime >= 21921 & datetime < 21994) | (datetime > 22287 & datetime < 22359)
    }
}

rename `clusterNumber' v001
if (`gpsDataHandling' == 2) {
    sort v001
    rename `prefix'v024 v024
    merge v001 using gpsInputs.dta
    duplicates drop v001, force
    export delimited LATNUM LONGNUM afterCovidStarted v001 v024 using "gpsIndiaIncludingStates" if isInProgressState == 1, replace
}
else if (`gpsDataHandling' == 1) {
    // Merge distances to before-after borders. This has been pre-calculated using
    // scripts that can be found from scripts/findEdge*.py
    sort v001
    merge v001 using borderDistances.dta
    drop _merge
}
// Otherwise, gps-analysis not used

// Generate region-dummy
gen isUrban = .
replace isUrban = 1 if `region' == 1
replace isUrban = 0 if `region' == 2

// Generate wealth state
gen isPoorState = .
replace isPoorState = 0 if `wealth' == 3 | `wealth' == 4 | `wealth' == 5
replace isPoorState = 1 if `wealth' == 1 | `wealth' == 2

save `output'`dhsYear'.dta, replace