//******************************************************************************
//
// Creates indicators for child nutrition.
//
// Script creates child nutrition indicator variables for loaded DHS data.
//
// Output variables are the following, separately for breastfed and
// non-breastfed children:
//     * Minimum dietary diversity
//     * Minimum meal frequency
//     * Minimum acceptable diet
//("WHO. Harmonizing vaccination
// coverage measures in household surveys: a primer. Geneva: World Health
// Organization, 2019.")
// Document has been created using the document: "Indicators for assessing
// infant and young child feeding practices: definitions and measurement
// methods", 2021 by WHO and UNICEF.
// Furthermore, DHS-specific instructions are given in https://dhsprogram.com/data/Guide-to-DHS-Statistics/Minimum_Dietary_Diversity_Minimum_Meal_Frequency_and_Minimum_Acceptable_Diet.htm
//
// Arguments:
//   * basePath       - repository base path
//******************************************************************************
args basePath

// Create Stunting, Underweight and Wasting main variables
run `basePath'/src/scripts/createChildNutritionMainVariables

// "Indicators for assessing infant and young child feeding practices -- Definitions and measurement methods":
// Minimum dietary diversity
// Minimum meal frequency
// Minimum acceptable diet
// Results separately for breast-feeding and non-breast-feeding
// A document above is used to calculate aforementioned indicators. DHS-specific instructions are given in https://dhsprogram.com/data/Guide-to-DHS-Statistics/Minimum_Dietary_Diversity_Minimum_Meal_Frequency_and_Minimum_Acceptable_Diet.htm

gen breastMilk = m4 == 95
gen graingsRootsTubers = 0
replace graingsRootsTubers = 1 if v412a == 1 | v414e == 1 | v414f == 1
gen legumesNuts = v414o == 1
gen dairyProducts = 0
replace dairyProducts = 1 if v411 == 1 | v411a == 1 | v414v == 1 | v414p == 1
// Note: v414h Gave child meat N/A for India DHS survey
gen fleshFoods = 0
replace fleshFoods = 1 if v414m == 1 | v414n == 1
gen eggs = v414g == 1
gen vitaminAFruitsAndVegetables = 0
replace vitaminAFruitsAndVegetables = 1 if v414i == 1 | v414j == 1 | v414k == 1
gen otherFruitsAndVegetables = v414l == 1

// Minimum dietary diversity, breast-feeding. Note that breast-feeding status is taken into account in analysis-phase, namely in analysisNutritionDetailed.do
gen minDietDiversityBFeed = (breastMilk + graingsRootsTubers + legumesNuts + dairyProducts + fleshFoods + eggs + vitaminAFruitsAndVegetables + otherFruitsAndVegetables) >= 5

// Minimum dietary diversity, non-breast-feeding. Please note that starting
// 2017, the figure is calculated similar to both breastfed and
// non-breastfed-children, namely 5 out of 8 for both, as compared to
// previous instructions, when there were 4 out of 7, and breastfed, 5 out of 8.
// Here, variables are kept separately as the figures are calculated separately
// for breastfed and non-breastfed children
gen minDietDiversityNonBFeed = (breastMilk + graingsRootsTubers + legumesNuts + dairyProducts + fleshFoods + eggs + vitaminAFruitsAndVegetables + otherFruitsAndVegetables) >= 5

// Minimum meal frequency, breast-feed
gen minMealFreqBFeed=.
replace minMealFreqBFeed = 1 if m4 == 95 & b19 >= 6 & b19 <= 8 & m39 >= 2 & m39 <= 7
replace minMealFreqBFeed = 1 if m4 == 95 & b19 >= 9 & b19 <= 23 & m39 >= 3 & m39 <= 7
replace minMealFreqBFeed = 0 if minMealFreqBFeed != 1 & m4 == 95

// Minimum meal frequency, non-breast-feed
gen powderedTinnedFreshMilk = 0
replace powderedTinnedFreshMilk = v469e if v469e >= 2 & v469e <= 7
gen childInfantFormula = 0
replace childInfantFormula = v469f if v469f >= 2 & v469f <= 7
gen childYogurt = 0
replace childYogurt = v469x if v469x >= 2 & v469x <= 7
gen totalMilkFeeds = powderedTinnedFreshMilk + childInfantFormula + childYogurt
gen solidSemiSolid = 0
replace solidSemiSolid = m39 if m39 >= 1 & m39 <= 7
gen totalFeeds = totalMilkFeeds + solidSemiSolid
gen minMealFreqNonBFeed = .
replace minMealFreqNonBFeed = 1 if totalFeeds  >= 4 & solidSemiSolid >=1 & m4 != 95
replace minMealFreqNonBFeed = 0 if minMealFreqNonBFeed != 1 & m4 != 95

// Minimum acceptable diet, breast-feed
gen minAcceptDietBFeed = minDietDiversityBFeed & minMealFreqBFeed

// Minimum acceptable diet, non-breast-feed
gen minAcceptDietNonBFeed = minDietDiversityNonBFeed & minMealFreqNonBFeed & totalMilkFeeds >= 2

// Gen doNotHave-variables, so that the direction is consistent for all the variables
gen nMinDietDiversityNonBFeed = minDietDiversityNonBFeed == 0
gen nMinDietDiversityBFeed = minDietDiversityBFeed == 0
gen nMinMealFreqBFeed = minMealFreqBFeed == 0
gen nMinMealFreqNonBFeed = minMealFreqNonBFeed == 0
gen nMinAcceptDietBFeed = minAcceptDietBFeed == 0
gen nMinAcceptDietNonBFeed = minAcceptDietNonBFeed == 0