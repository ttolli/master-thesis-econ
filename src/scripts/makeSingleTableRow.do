//******************************************************************************
//
// A helper to tabulate single row into table (latex-format) for main analysis,
// namely for Tables 1-4 of thesis
//
// Arguments:
//   * varName              - name of variable used when storing the model with eststo
//   * outcomeVariableName  - variable full label
//   * resultTableFolder    - folder to store the table
//   * resultTableName      - name of output table. .tex is added by the script
//   * tableHeading         - short heading shown on the top of the table
//   * rowOrder             - 0 ~ first, 1 ~ middle, 2 ~ last row of the table
//   * model                - 0 ~ probit, 1 ~ ols
//   * runEdgeAnalysis      - 1 ~ run edge analysis, 0 ~ don't run edge analysis
//                            with latter one 4 and former 5 regression results
//
//******************************************************************************
args varName outcomeVariableName resultTableFolder resultTableName tableHeading rowOrder model runEdgeAnalysis

local independentVariables afterCovidStarted afterAndPoor

local preferredSpecification 4
if (`runEdgeAnalysis' == 1) {
    local numRegressions 5
    local numColumns 6
    local regressions `varName' `varName'Controls `varName'Month `varName'Ind `varName'BorderNear
    local edgeAdditionToCaption In (5), observations are limited on intra-state edges only.
}
else {
    local numRegressions 4
    local numColumns 5
    local regressions `varName' `varName'Controls `varName'Month `varName'Ind
}

local postCaption \caption*{\footnotesize \textbf{After} is the effect of after-lockdown-indicator, and \textbf{After x LowWealth} is the interaction between After and belonging to two lowest wealth quintiles. \textbf{Baseline High} and \textbf{Low Wealth} are before-lockdown-means of dependent variable of high and low wealth individuals, respectively. \textbf{Time Controls} are monthly or yearly dummies for month of interview, month of birth and age. \textbf{Individual Controls} include sex, ethnicity and religion background. `edgeAdditionToCaption' DHS sampling weights are used, and standard errors are clustered over districts.}  

if (`model' == 0) {
    local commonTableCommand fragment star(* 0.10 ** 0.05 *** 0.01) b(%8.3f) se(%8.3f) label nomtitles stat(Baseline BaselineLowWealth N PseudoR2, fmt(%8.3f %8.3f %8.0f %8.3f) labels("Baseline High Wealth" "Baseline Low Wealth" "N" "R-Square")) `indicateResult' coeflabels(afterCovidStarted "\textit{After}" afterAndPoor "\textit{After} x \textit{LowWealth}")
}
else {
    local commonTableCommand fragment star(* 0.10 ** 0.05 *** 0.01) b(%8.3f) se(%8.3f) label nomtitles stat(Baseline BaselineLowWealth N PseudoR2, fmt(%8.3f %8.3f %8.0f %8.3f) labels("Baseline High Wealth" "Baseline Low Wealth" "N" "R-Square")) `indicateResult' coeflabels(afterCovidStarted "\textit{After}" afterAndPoor "\textit{After} x \textit{LowWealth}")
}

local preheadCommandPre prehead("\begin{table}[htbp]\centering \footnotesize \renewcommand{\arraystretch}{0.3} \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}

// This is done manually, as we wan't to highlight the preferred specification column
// This requires the following renewcommand on tex for light gray background on
// preferred specification column:
// \newcolumntype{a}{%
//   >{\columncolor[gray]{.9}[0pt]}%
//   c%
// }
local preheadCommandMiddle \begin{tabular}{l
local preheadCommandPost } \hline\hline")
local columnCommand
forvalues i=1/`numRegressions' {
    if (`i'==`preferredSpecification') {
        local columnCommand `columnCommand'a
	}
    else {
        local columnCommand `columnCommand'c
    }
}

// Separate variables with dashed line (in case not topmost-one)
if (`rowOrder' == 0) {
    local horizontalLinetype \hline
}
else {
    local horizontalLinetype \hdashline
}

local postheadCommandPre posthead("`horizontalLinetype' \\ \multicolumn{`numColumns'}{l}{\textbf{

local postheadCommandPost }} \\\\[-1ex]")

local fullTableName "`resultTableFolder'/`resultTableName'`tabulatePost'.tex"

local tableCaption \caption{\label{tab:`resultTableName'} `tableHeading'}

local preheadCommand `preheadCommandPre'`tableCaption'`preheadCommandMiddle'`columnCommand'`preheadCommandPost'

local independentVariables afterCovidStarted afterAndPoor

local postHeadCommand `postheadCommandPre'`outcomeVariableName'`postheadCommandPost'
if (`rowOrder' == 0) {
    esttab `regressions' using `fullTableName', `preheadCommand' `postHeadCommand' `commonTableCommand' keep(`independentVariables') replace prefoot("[1em]")
}
else if (`rowOrder' == 1) {
    esttab `regressions' using `fullTableName', `postHeadCommand' `commonTableCommand' keep(`independentVariables') append nonumbers prefoot("[1em]")
}
else if (`rowOrder' == 2) {
    local controlCommand \hline\\ State Fixed & \cmark & \cmark & \cmark & \cmark & \cmark \\ Region & \xmark & \cmark & \cmark & \cmark & \cmark \\ Time Controls & \xmark & \xmark & \cmark & \cmark & \cmark \\ Individual Controls & \xmark & \xmark & \xmark & \cmark & \cmark \\

    local postTableCommand prefoot("[1em]") postfoot("`controlCommand' \hline\hline \multicolumn{4}{l}{\footnotesize Standard errors in parentheses \Tstrut}\\ \multicolumn{2}{l}{\footnotesize \sym{*} \(p<0.1\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)}\\ \end{tabular} \\ `postCaption' \end{table}")

    esttab `regressions' using `fullTableName', `postHeadCommand' `commonTableCommand' keep(`independentVariables') append nonumbers `postTableCommand'
}