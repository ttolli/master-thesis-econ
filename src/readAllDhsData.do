//******************************************************************************
//
// Reads all DHS data from 2019-21, 2015-16 and 2005-6 DHS surveys, and saves
// them into running folder. Stored .dta-files are used in later analyses.
// 
// To read all the data once
//
// * Download india DHS data from all the three survey rounds. Please pick the
//   ones that includes Flat ASCII data (.dat)
//     * Download data for Individual, Children, Men and Household Member
//       Recordes
//
// * Arrange them into yearly folders, like
//
//      basePath/data/dhs/2021/IAPR7DFL
//      basePath/data/dhs/2021/IAIR7DFL
//      basePath/data/dhs/2021/IAMR7DFL
//      basePath/data/dhs/2021/IAKR7DFL
//      basePath/data/dhs/2016/IAPR74FL
//      basePath/data/dhs/2016/IAIR74FL
//      basePath/data/dhs/2016/IAMR74FL
//      basePath/data/dhs/2016/IAKR74FL
//      basePath/data/dhs/2006/IAPR52FL
//      basePath/data/dhs/2006/IAIR52FL
//      basePath/data/dhs/2006/IAMR52FL
//      basePath/data/dhs/2006/IAKR52FL
//
//    Please note that the dataset is fairly big, approx 32GB
//
//  * Unfortunately, there are some hard-coded lines in dhs import .do-files, so
//    one needs to modify those lines. I made a script to do that, so no need to
//    update them manually on each folder. One can find it from
//    src/scripts/fixDhsImportData.py --, and run it as:
//
//      python -c "from fixDhsImportData import fixPaths; fixPaths(\"full_path\")'"
//
//    where full path is the basePath/data/dhs above. E.g.,:
//      C:/Users/ttoll/Documents/src/git/aalto/aalto_thesis/data/dhs
//
//    If one want's to modify the paths manually instead, that can be done as
//    follows:
//      * Modify the path for .dct file in the first line of the only .do-files
//        that are in unzipped folder to match your location
//      * Modify the path for .dat-file in the first line of the only .dct-files
//        that are in unzipped folder to match your location
//
//  * If one wants to run edge analysis, india gps data needs to be downloaded
//    as well. Download it under
//
//      basePath/data/dhs/india_gps/IAGE7AFL
//
//  * Run this readAllDhsData, with a correct basePath as an input. Please see
//    runAll.do for a reference usage if needed
//
// Arguments:
//   * basePath         - repository base path
//   * runEdgeAnalysis  - 1 ~ run edge analysis, 0 ~ do not run and report
//******************************************************************************
args basePath runEdgeAnalysis

local baseDataFolder `basePath'/data/dhs
local gpsDir "`baseDataFolder'/india_gps/IAGE7AFL/"
local dataFolder `baseDataFolder'/2021

local exportGpsDataToCls 2

local year 2021
if (`runEdgeAnalysis' > 0) {
    // If edge analysis is used, we need to import and convert gps data. This is
    // quite some work, so please make sure you have both time as well as good
    // enough workstation. Please note that to find out distances, a brute-force
    // implementation is done, which takes an additional ~2h on high-performance
    // PC. No gpu-implementation has been done for distance calculations as of
    // yet.

    // Convert shape boundary files to stata
    shp2dta using "`gpsDir'IAGE7AFL.shp", database(gpsInputs) coordinates(gpsCoord) genid(id) replace

    // Rename dhs clusters to be equal with the rest of the data
    use gpsInputs, clear
    rename DHSCLUST v001
    sort v001
    save gpsInputs.dta, replace

    // import first dataset in order to find out states that are affected, as
    // well as before-after states
    local prefix h
    local outputPrefix hhMember
    run `basePath'/src/scripts/readDhsData "`dataFolder'/IAPR7DFL/IAPR7DFL.DO" sv270s `outputPrefix' `year' `exportGpsDataToCls' `prefix'
    save `outputPrefix'2021.dta, replace

    // Run python script to calculate the distance to the nearest cluster of the
    // opposite group
    // ATTENTION: apparently it seems Stata somehow caches python scripts. If
    // the script is modified, please re-start your Stata-session to re-run it,
    // just in case.
    // Script uses couple of python libs. Please make sure they are installed.
    // There's requirements.txt under scripts. You may for example run
    // 'pip install -r requirements.txt'
    python script `basePath'/src/scripts/findEdges.py

    // Import results with distances
    clear
    import delimited using gpsIndiaIncludingStatesDistanceToBorderInsideState

    // Drop variables that are not needed anymore, and save the distances. They
    // are later on merged for each four different 2021-datasets (women,
    // children, men, household)
    drop latnum longnum aftercovidstarted v024
    sort v001
    save borderDistances.dta, replace
}

**** DHS 2019-21 ***************************************************************

// 2021 household
local prefix h
local outputPrefix hhMember
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAPR7DFL/IAPR7DFL.DO" sv270s `outputPrefix' `year' `runEdgeAnalysis' `prefix'

// 2021 women
local prefix
local outputPrefix women
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAIR7DFL/IAIR7DFL.DO" s190s `outputPrefix' `year' `runEdgeAnalysis' `prefix'
gen wd = d005/1000000
save `outputPrefix'2021.dta, replace

// 2021 men
local prefix m
local outputPrefix men
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAMR7DFL/IAMR7DFL.DO" sm190s `outputPrefix' `year' `runEdgeAnalysis' `prefix'

// 2021 children
local prefix
local outputPrefix children
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAKR7DFL/IAKR7DFL.DO" s190s `outputPrefix' `year' `runEdgeAnalysis' `prefix'

**** DHS 2015-16 ***************************************************************
local dataFolder `baseDataFolder'/2016
local year 2016
// Switch on edge analysis for other than 2021-data
local runEdgeAnalysisPrevDhs 0

// 2016 household
local prefix h
local outputPrefix hhMember
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAPR74FL/IAPR74FL.DO" sv270s `outputPrefix' `year' `runEdgeAnalysisPrevDhs' `prefix'

// 2016 women
local prefix
local outputPrefix women
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAIR74FL/IAIR74FL.DO" s190s `outputPrefix' `year' `runEdgeAnalysisPrevDhs' `prefix'
gen wd = d005/1000000
save `outputPrefix'2016.dta, replace

// 2016 men
local prefix m
local outputPrefix men
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAMR74FL/IAMR74FL.DO" sm190s `outputPrefix' `year' `runEdgeAnalysisPrevDhs' `prefix'

// 2016 children
local prefix
local outputPrefix children
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAKR74FL/IAKR74FL.DO" s190s `outputPrefix' `year' `runEdgeAnalysisPrevDhs' `prefix'

**** DHS 2005-6 ****************************************************************
local dataFolder `baseDataFolder'/2006
local year 2006

// 2006 household
local prefix h
local outputPrefix hhMember
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAPR52FL/IAPR52FL.DO" hv270 `outputPrefix' `year' `runEdgeAnalysisPrevDhs' `prefix'

// 2006 women
local prefix
local outputPrefix women
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAIR52FL/IAIR52FL.DO" v190 `outputPrefix' `year' `runEdgeAnalysisPrevDhs' `prefix'
gen wd = d005/1000000
save `outputPrefix'2006.dta, replace

// 2006 men
local prefix m
local outputPrefix men
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAMR52FL/IAMR52FL.DO" mv190 `outputPrefix' `year' `runEdgeAnalysisPrevDhs' `prefix'

// 2006 children
local prefix
local outputPrefix children
run `basePath'/src/scripts/readDhsData "`dataFolder'/IAKR52FL/IAKR52FL.DO" v190 `outputPrefix' `year' `runEdgeAnalysisPrevDhs' `prefix'

// Special handling is needed for BMI data extraction in order to drop women if pregnant, or if gave birth in the 2 months preceding the date of the interview
run `basePath'/src/scripts/mergeMenAndWomenForBMI `basePath' `runEdgeAnalysis'