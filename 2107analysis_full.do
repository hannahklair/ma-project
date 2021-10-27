***********
** Title: Thesis project analysis
** 1. Visualize data
** 2. Models & model figures
** 3. Diagnostics
** Project Contents: START > IMPORT > TIDY > TRANSFORM > VISUALIZE > MODEL
** Import data in file "prep", Tidy & transform data - in file "prep"
************
***NOTES****
** Path note: set WD ("/Users/hanna/OneDrive/Documents/projects") in setup & use subjective paths after ("$/data)
** save var & val labels as local macros, e.g., https://www.stata.com/support/faqs/data-management/apply-labels-after-reshape/
** some steps of the project prototype come from: https://machinelearningmastery.com/machine-learning-in-r-step-by-step/
** omitted descriptive elements: catvar level distribution bc only grouping vars (inc and debt) are categorical!
** OMMITTED CONTROLS: growth, inflation, unemployment, tax revenue, deficit, central gov grants, government spending (total, edu), effectiveness of spending
** ...CONT: urban, gnp, gini, trade open, democracy, corruption/inst quality, transparency
** files wide by year (y1234), long by indicator (indicatorname indicatorcode) unless marked "long"
** case IDs - countryname countrycode, year

*putexcel A1=matrix(r(C), names) using [model] 	// return list
*foreach v of var*{ 				// renaming year variables
*        local l`v' : variable label `v'
* }
*foreach v of varlist v* {
*   local x : variable label `v'
*   rename `v' y`x'
*}
*encode indicatorname, gen(indicator)		// encoding variables
*drop if indicator==.
*drop indicatorname
*replace indicatorname="Missing" if indicator==.
*replace indicatorcode="Missing" if indicator==.
************
***SETUP****
set more off
************
***MASTER***
clear mata 
clear matrix
set more off
set scheme plotplain
set seed 112233
capture log close
************
***PATHS****
global path "C:\Users\hanna\Onedrive\Documents\thesis" // HANNAH'S NOTEBOOK
global data `"$path\Stata"'
global dofiles `"$path\Stata"'
global figures `"$path"'
global temp `"$path\Stata"'
global out `"$path\Stata\out"'

** Visualize data -------------------------------------------------------------- 1
*************
***SUMMARY***
use "$data/LIC_base_merged.dta", clear
asdoc codebook, save(summary_sample09.doc) //dimensions and types
asdoc duplicates list countryname year, append //peek
asdoc duplicates list countrycode year, append //then look at data file
asdoc tab incomelab, append //catvar levels
*asdoc sum, detail append //stats sum of all vars
** add UM and/or H income for comparison in vioplots
*use "$data/fullset_merged_covars.dta" //use "$data/analysis.dta", clear
*	gen star = .
*	replace star = 1 if incomelab=="LM*"
*	replace star = 2 if incomelab==".." | incomelab==""
*	label define lbstar 1"LM*" 2".."
*	label values star lbstar
*	replace incomelab = "LM" if incomelab=="LM*"
*	replace incomelab = "" if incomelab==".."
*save "$data/figures.dta", replace
*asdoc, row(sum year, sum urban, sum gini, sum polyarchy) dec(2) title(table attempt)
asdoc sum, detail append save(summary_sample09.doc) title(codebook)
bysort incomelab: asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban, detail append //stats sum of all vars
bysort HIPC: asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban, detail append
bysort HIPCi: asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban, detail append
	
bysort incomelab: asdoc codebook, save(summary_sample09.doc) append //dimensions and types
	asdoc duplicates list countryname year, append //peek
	asdoc duplicates list countrycode year, append //then look at data file
	asdoc tab incomelab, append //catvar levels
** dimensions / types / peek /  stats sum of all vars
use "$data/LIC_base_merged.dta", clear
asdoc codebook, save(summary.doc) //dimensions and types
asdoc duplicates list countryname year, append //peek
asdoc duplicates list countrycode year, append //then look at data file
asdoc tab incomelab, append //catvar levels
asdoc sum, detail append //stats sum of all vars

** add UM and/or H income for comparison in vioplots
use "$data/analysis.dta", clear
	gen star = .
	replace star = 1 if incomelab=="LM*"
	replace star = 2 if incomelab==".."
	label define lbstar 1"LM*" 2".."
	label values star lbstar
	replace incomelab = "LM" if incomelab=="LM*"
	replace incomelab = "" if incomelab==".."
bysort incomelab: asdoc codebook, save(summary_fullpop.doc) //dimensions and types
	asdoc duplicates list countryname year, append //peek
	asdoc duplicates list countrycode year, append //then look at data file
	asdoc tab incomelab, append //catvar levels
bysort incomelab: asdoc sum, detail append //stats sum of all vars
** add debt category, if such a thing exists

*************
***DESCRIP*** Line plots
* Figure 1 Human capital index score by country group, 1980-2000
* Figure 2 Total public external debt and gross debt position by country group, 1980-2000
* Figure 3 Debt stock reduction by country group, 1980-2000 [+ ODA disbursements? See Fig. 9, UWU paper)
* Figure 4 Debt service paid by country group, 1980-2000
* Figure 5 Debt reduction and relief for HIPC decision point countries, XXXX
* Figure 6 GDP and trade openness by country group, 1990-2000
* Figure 7 Social spending of HIPC participant countries, 1980-2000
* Figure 8 GINI Index, democracy score, and urbanization score by country group, 1980-2000
*************
** 1 Human capital index score by country group, 1980-2000
************* income groups
twoway (line meanimhe_hc_mean3b year if incomelab=="L") (line meanimhe_hc_mean3b year if incomelab=="LM") ///
	(line meanimhe_hc_mean3b year if incomelab=="UM"), legend(label(1 "Low income countries") ///
	label(2 "Lower-middle income countries") label(3 "Upper-middle income countries")) ///
	ytitle("Human capital index score") legend(pos(6)) ///
	xlabel(1990(5)2020, angle(0) grid) 
graph export "$figures\LICHCI.png", as(png) replace
************* HIPC vs non-HIPC LICs
twoway (line Hmeanimhe_hc_mean3b year if HIPC==1) ///
	(line Hmeanimhe_hc_mean3b year if HIPC==0 & incomelab=="L") ///
	(line meanimhe_hc_mean3b year if incomelab=="LM", ///
	legend(label(1 "Highly-indebted poor countries") label(2 "Low income countries, excluding HIPC") ///
	label(3 "Upper-middle income countries")) ///
	ytitle("Human capital index score") legend(pos(6)) ///
	xlabel(1990(5)2020, angle(0) grid)
graph export "$figures\HIPCHCI.png", as(png) replace
*************
** 2 Total public external debt and gross debt position by country group, 1980-2000
************* income groups
twoway (line meandebtpos year if incomelab=="L") (line meandebtpos year if incomelab=="LM") ///
	(line meandebtpos year if incomelab=="UM"), legend(label(1 "Low income countries") ///
	label(2 "Lower-middle income countries") label(3 "Upper-middle income countries")) ///
	ytitle("Gross Debt Position") legend(pos(6)) ///
	xlabel(1990(5)2020, angle(0) grid) 
graph export "$figures\LICdebtpos.png", as(png) replace
*************
** 3 Debt stock reduction by country group, 1990-2000 [+ ODA disbursements? See Fig. 9, UWU paper)
************* income groups // debt position change
twoway (line meandebtchange year if incomelab=="L") (line meandebtchange year if incomelab=="LM") ///
	(line meandebtchange year if incomelab=="UM"), legend(label(1 "Low income countries") ///
	label(2 "Lower-middle income countries") label(3 "Upper-middle income countries")) ///
	ytitle("Annual change in gross debt position (% GDP)") legend(pos(6)) ///
	xlabel(1990(5)2020, angle(0) grid) 
graph export "$figures\LICdebtchange.png", as(png) replace
************* HIPC vs non-HIPC LICs // debt position change
twoway (line Hmeandebtchangep year if HIPC==1) (line Hmeandebtchangep year if HIPC==0 & incomelab=="L"), ///
	legend(label(1 "Highly-indebted poor countries") label(2 "Low income countries, excluding HIPC") ///
	label(3 "Upper-middle income countries")) ///
	ytitle("Annual % change in gross debt position") legend(pos(6)) ///
	xlabel(1990(5)2020, angle(0) grid)
graph export "$figures\HIPCdebtchange.png", as(png) replace
************* income groups // debt stock reduction
twoway (line meandebtstockreduction year if incomelab=="L") (line meandebtstockreduction year if incomelab=="LM") ///
	(line meandebtstockreduction year if incomelab=="UM"), legend(label(1 "Low income countries") ///
	label(2 "Lower-middle income countries") label(3 "Upper-middle income countries")) ///
	ytitle("Debt stock reduction") legend(pos(6)) ///
	xlabel(1990(5)2020, angle(0) grid) 
graph export "$figures\LICdebtreduction.png", as(png) replace
*************
** 4 Debt service paid by country group, 1990-2000
************* income groups // mean external debt service 
twoway (line meanextdebtservice year if incomelab=="L") (line meanextdebtservice year if incomelab=="LM") ///
	(line meanextdebtservice year if incomelab=="UM"), legend(label(1 "Low income countries") ///
	label(2 "Lower-middle income countries") label(3 "Upper-middle income countries")) ///
	ytitle("Total external debt service (USD)") legend(pos(6)) ///
	xlabel(1990(5)2020, angle(0) grid) 
graph export "$figures\LICdebtservice.png", as(png) replace
*************
** 5 Debt reduction and relief for HIPC decision point countries, XXXX
**debtreductionmultilateral = meandebtreductionIDA + meandebtreductionIBRD + meandebtreductionIMF
************* income groups // meandebtreductionmultilateral
twoway (line Hmeandebtredux year if HIPC==1) (line Hmeandebtredux year if HIPC==0) ///
	, legend(label(1 "Highly-indebted poor countries") label(2 "Non-HIPCs")) ///
	ytitle("Debt reduction, treatment group mean") legend(pos(6)) ///
	xlabel(2000(5)2015, angle(0) grid) 
graph export "$figures\HIPCdebtreductionmulti.png", as(png) replace
twoway (line meandebtredux year if incomelab=="L") (line meandebtredux year if incomelab=="LM") ///
	(line meandebtredux year if incomelab=="UM"), legend(label(1 "Low income countries") ///
	label(2 "Lower-middle income countries") label(3 "Upper-middle income countries")) ///
	ytitle("Debt reduction and forgiveness" "by large multilaterals, group mean") legend(pos(6)) ///
	xlabel(2000(5)2015, angle(0) grid) 
graph export "$figures\LICdebtreductionmulti.png", as(png) replace
************* HIPC vs non-HIPC LICs // Hmeandebtreductionmultilateral
twoway (line meandebtreductionmultilateral year if incomelab=="L") (line meandebtreductionmultilateral year if incomelab=="LM") ///
	(line meandebtreductionmultilateral year if incomelab=="UM"), legend(label(1 "Low income countries") ///
	label(2 "Lower-middle income countries") label(3 "Upper-middle income countries")) ///
	ytitle("Debt reduction and forgiveness, group mean") legend(pos(6)) ///
	xlabel(1990(5)2020, angle(0) grid) 
graph export "$figures\LICdebtreductionmulti.png", as(png) replace
*************
** 6 GDP and trade openness by country group, 1990-2000
************* income groups // mean per capita gdp
twoway (line meangdppcusdperc year if incomelab=="L") (line meangdppcusdperc year if incomelab=="LM") ///
	(line meangdppcusdperc year if incomelab=="UM"), ytitle("GDP per capita (USD XXXYEAR)")///	
	legend(label(1 "Low income countries") label(2 "Lower-middle income countries") ///
	label(3 "Upper-middle income countries")) legend(pos(6)) xlabel(1985(5)2020, angle(0) grid) 
graph export "$figures\LICGDP.png", as(png) replace
************* income groups // mean trade openness
twoway (line meanopen year if incomelab=="L") (line meanopen year if incomelab=="LM") ///
	(line meanopen year if incomelab=="UM"), ytitle("Trade openness, %GDP") ///	
	legend(label(1 "Low income countries") label(2 "Lower-middle income countries") ///
	label(3 "Upper-middle income countries")) legend(pos(6)) xlabel(1985(5)2020, angle(0) grid) 
graph export "$figures\LICtradeopen.png", as(png) replace
************* HIPC vs non-HIPC LICs // mean per capita gdp
 twoway (line Hmeangdppcusdperc year if HIPC==1) (line meangdppcusdperc if incomelab=="L")
	(line meangdppcusdperc if incomelab=="L" & HIPC==0), label(1 "Highly-indebted poor countries") ///
	(2 "Low income countries") (3 "Low income countries, excluding HIPC"))
graph export "$figures\HIPCGDP.png", as(png) replace
************* HIPC vs non-HIPC LICs // mean trade openness
twoway (line Hmeanopen year if HIPC==1) (line Hmeanopen year if HIPC==0 & incomelab=="L"), ///
	ytitle("Trade openness, %GDP")  xlabel(1985(5)2020, angle(0) grid) legend(pos(6)) ///
	legend(label(1 "Low income countries") label(2 "Lower-middle income countries")) 
graph export "$figures\HIPCtradeopen.png", as(png) replace
*************
** 7 Social spending of HIPC participant countries, 1990-2010
************* total gov spending:
twoway (line Hmeanspending year if HIPC==1) (line meanspending year if incomelab=="L") ///
	(line meanspending year if incomelab=="LM") (line meanspending year if incomelab=="UM"), ytitle("Public spending") ///	
	legend(label(1 "Highly-indebted poor countries") label(2 "Low income countries") label(3 "Lower-middle income countries") ///
	label(4 "Upper-middle income countries")) legend(pos(6)) xlabel(1990(5)2010, angle(0) grid) 
graph export "$figures\LICspending.png", as(png) replace
twoway (line Hmeanspending year if HIPC==1) (line Hmeanspending year if HIPC==0) , ytitle("Public spending") ///	
	legend(label(1 "Highly-indebted poor countries") label(2 "non-HIPC")) ///
	legend(pos(6)) xlabel(1990(5)2010, angle(0) grid) 
graph export "$figures\HIPCspending.png", as(png) replace
************* edu spending:
twoway (line HmeanedspendpercGDP year if HIPC==1) (line HmeanedspendpercGDP year if HIPC==0) ///
	, ytitle("Education spending, % GDP") xlabel(1990(5)2010, angle(0) grid) ///	
	legend(label(1 "Highly-indebted poor countries") label(2 "non-HIPC")) ///
	legend(pos(6))
graph export "$figures\HIPCeduspending.png", as(png) replace
*************
** 8 GINI Index, democracy score, and urbanization score by country group, 1980-2000
************* income groups // gini
twoway (line Hmeangini year if HIPC==1) (line meangini year if incomelab=="L") ///
	(line meangini year if incomelab=="LM") (line meangini year if incomelab=="UM"), ytitle("GINI") ///	
	legend(label(1 "Highly-indebted poor countries") label(2 "Low income countries") label(3 "Lower-middle income countries") ///
	label(4 "Upper-middle income countries")) legend(pos(6)) xlabel(1985(5)2020, angle(0) grid) 
graph export "$figures\LICgini.png", as(png) replace
************* income groups // urban pop
twoway (line Hmeanurban year if HIPC==1) (line meanurban year if incomelab=="L") ///
	(line meanurban year if incomelab=="LM") (line meanurban year if incomelab=="UM"), ytitle("Urban (% total population)") ///	
	legend(label(1 "Highly-indebted poor countries") label(2 "Low income countries") label(3 "Lower-middle income countries") ///
	label(4 "Upper-middle income countries")) legend(pos(6)) xlabel(1985(5)2020, angle(0) grid) 
graph export "$figures\LICurban.png", as(png) replace
************* income groups // demoperc
twoway (line meandemoperc year if incomelab=="L") (line meandemoperc year if incomelab=="LM") ///
	(line meandemoperc year if incomelab=="UM"), ytitle("Democracy score (0-100)") ///	
	legend(label(1 "Low income countries") label(2 "Lower-middle income countries") ///
	label(3 "Upper-middle income countries")) legend(pos(6)) xlabel(1985(5)2020, angle(0) grid) 
graph export "$figures\LICurban.png", as(png) replace

*************
***DESCRIP*** Violin plots
	** vars: HCI, gov debt, GDP, GINI, urban, trade, demo score, inst quality, edu attainment
	** grouping: by income category, 1990 and 2015 (or 2010 where 2015 data not available)
** outcomes - HCI
asdoc vioplot imhe_hc_mean3b imhe_hc_mean1m imhe_hc_mean2f ///
	if year==1990 | year==2015, over(year) over(incomelab) save(plots_full.doc)
** predictors
asdoc vioplot gini urban demoperc	if year==1990 | year==2015, over(year) over(incomelab) append
asdoc vioplot gdppcusdperc openperc if year==1990 | year==2015, over(year) over(incomelab) append
** macroecon indicators
asdoc vioplot gdpusdscale debtpos spending if ///
	(year==1990 | year==2010) & (incomelab=="LM" | incomelab=="L"), over(year) over(incomelab) append
asdoc vioplot gdpusdbil debtpos spending if ///
	(year==1990 | year==2010) & (incomelab=="UM" | incomelab=="H"), over(year) over(incomelab) append

** Model ----------------------------------------------------------------------- 2
** Create models, run diagnostics, compare accuracy
** ------------------------------------------------

** Write models
use "$/LIC_base_merged.dta", clear
local controls i.HIPCi gini urban open demoscore gdppcusd
local controlscale i.HIPCi gini urban open demoperc gdppcusdperc // demoperc (*10) gdppcusdperc (100s)
** -------------------------------------------------------
** simple DID model --------------------------------------
**reference: https://www.statalist.org/forums/forum/general-stata-discussion/general/1384611-difference-in-difference-with-panel-data
asdoc xtreg imhe_hc_mean3b i.HIPC##i.HIPCi `controls', re save(models.doc) title(Longitudinal regression)
asdoc xtreg imhe_hc_mean3b i.HIPC##i.HIPCi `controlscale', re append title(Longitudinal regression, scaled)
//treatment effects = i.treatment##i.post betas
**note: treatment = treatment group dummy; post = treatment before/after dummy

** approach from O Torres-Reyna 2015, Princeton tutorial
** reference(https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&ved=2ahUKEwja46zMjPrxAhVXsp4KHUmDCI8QFjAAegQIBBAD&url=https%3A%2F%2Fwww.princeton.edu%2F~otorres%2FDID101.pdf&usg=AOvVaw1U0URwurtJ2mGTKWKMNHfF)
	**treatment dummy for before/after treatment - HIPCi
	**treatment dummy for treatment/control group - HIPC
asdoc reg imhe_hc_mean3b i.HIPC##i.HIPCi, r append title(Treatment FX estimation, bivariate)
asdoc reg imhe_hc_mean3b i.HIPC##i.HIPCi `controls', r append title(Treatment FX estimation)
asdoc reg imhe_hc_mean3b i.HIPC##i.HIPCi `controlscale', r append title(Treatment FX estimation, scaled)

//treatment effects = i.HIPCi##i.HIPC betas

*ssc install diff
*diff imhe_hc_mean3b t(treatment group) p(treatment time)
asdoc diff imhe_hc_mean3b, treated(HIPC) period(treat1) append title(DID model test 1)
asdoc diff imhe_hc_mean3b, treated(HIPC) period(treat2) append title(DID model test 2)
asdoc diff imhe_hc_mean3b, treated(HIPC) period(treat3) append title(DID model test 3)

** proper DID modelling only available with STATA 17:
*xtdidregress (imhe_hc_mean3b `controls') (HIPCi), group(countryname) time(year) //should group be incomelab?
**add wild cluster bootstrap pvals:
*xtdidregress (imhe_hc_mean3b `controls') (HIPCi), group(countryname) time(year) ///
*	wildbootstrap
** DID - aggregation methods
** standard method
*xtdidregress (imhe_hc_mean3b `controls') (HIPCi), group(countryname) time(year) ///
*	aggregate(standard)
** Donald and Lang (2007) method (aggregates, computes ATET and SE):
*xtdidregress (imhe_hc_mean3b `controls') (HIPCi), group(countryname) time(year) ///
*	aggregate(dlang)
**-------------------------------------------------------
** simple regression model ------------------------------
**reference: section 14 of statsthinking21
**option: section 13.2 of statsthinking21 has examples of diagnostic tests
asdoc reg imhe_hc_mean3b year `controls', append title(Linear regression)
	asdoc rvfplot, append
	graph export "$figures\linear1_rvf.png", as(png) replace
	asdoc avplots, append
	graph export "$figures\linear1_avplots.png", as(png) replace
	asdoc estat hettest, append
	asdoc estat ovtest, append
asdoc reg imhe_hc_mean3b year `controlscale', append title(Linear regression, scaled)
	asdoc rvfplot, append
	graph export "$figures\linear1scaled_rvf.png", as(png) replace
	asdoc avplots, append
	graph export "$figures\linear1scaled_avplots.png", as(png) replace
	asdoc estat hettest, append
	asdoc estat ovtest, append
asdoc reg imhe_hc_mean3b year `controls' spending debtpos, append
	asdoc rvfplot, append
	graph export "$figures\linearb_rvf.png", as(png) replace
	asdoc avplots, append
	graph export "$figures\linearb_avplots.png", as(png) replace
	asdoc estat hettest, append
	asdoc estat ovtest, append
reg imhe_hc_mean1m year `controls'
	reg imhe_hc_mean1m year `controls' spending debtpos
reg imhe_hc_mean2f year `controls'
	reg imhe_hc_mean2f year `controls' spending debtpos
**-------------------------------------------------------
** treatment estimation model ---------------------------
** treatment effects estimators:
	** regression adjustment (RA) - estimates ATET instead of ATE
		**(avg treatment effect on the treated; i.e., using only obs from treatmtne group)
	** inverse probability weighting (IPW)
	** inverse probability weighting with regression adjustment (IPWRA)
	** augmented inverse probability weighting (AIPW)
asdoc teffects ra (imhe_hc_mean3b `controls') (HIPCi), pomeans append title(Treatment FX estimation)
asdoc teffects ra (imhe_hc_mean3b `controlscale') (HIPCi), pomeans append title(Treatment FX est, scaled)

**-------------------------------------------------------
** standard mixed effects model -------------------------
**application example: [https://www.rensvandeschoot.com/tutorials/lme4/](https://www.rensvandeschoot.com/tutorials/lme4/)
**theoretical example: [https://www.lifescied.org/doi/full/10.1187/cbe.17-12-0280]
	//"When the outcome is measured on students (not sections), student observations
	//are not truly independent from one another. Instead, students within a section
	//share experiences that are not shared across sections. This kind of nonindependence
	//is common in quasi-random experimental designs and is important to account for:
	//incorrectly assuming independence of observations can shrink standard errors
	//in a way that overestimates the accuracy of estimates
	//(Raudenbush and Bryk, 2002; Gelman and Hill, 2007; DeLeeuw and Meijer, 2008).
	//A common way to account for this type of clustering is by fitting multilevel models
	//that include both fixed effects (parameters of interest, e.g., “treatment”)
	//and random effects (variables by which students are clustered, in this example, “section”;
	//Gelman and Hill, 2007; Bolker et al., 2009).
	//Multilevel models are so named because they account for variation at multiple levels—
	//level 1 with fixed effects (treatment) and levels 2+ with random effects (section, year, etc.).
asdoc mixed imhe_hc_mean3b `controls' || countryname: || incomelab: , append title(Mixed effects model)
asdoc mixed imhe_hc_mean3b `controlscale' || countryname: || incomelab: , append title(Mixed effects model, scaled controls)

**------------------------------------------------------- // DO NEXT - AFTER FIXING DIFF COMMAND
** Bayesian mixed effects model (brms) ------------------
**example: [https://www.rensvandeschoot.com/tutorials/brms-started/](https://www.rensvandeschoot.com/tutorials/brms-started/)
**-------------------------------------------------------
**apply bayes prefix to existing models:
bayes: reg imhe_hc_mean3b year `controls'
	bayesgraph
bayes: taffects ra (imhe_hc_mean3b `controls') (HIPCi), pomeans
	bayesgraph
bayes: mixed imhe_hc_mean3b `controls' || countryname: || incomelab:
	bayesgraph

**specifying a bayes model
bayes imhe_hc_mean3b `controls', likelihood(normal(var))
//check y distribution to find likelihood variance model type
** alt: lognormal(var) or lnormal(var), exp, mvnormal(sigma) (=multivar normal reg with covar matrix sigma)
**reference: help bayesmh##modelspec



**modelname ← brm(Y ~ 1 + X1 + X2 + X3 + (1 + X1 + X2 | L2ID),
**data = data frame)
**options: warmup = 1000, iter = 3000, cores = 2, chains = 2, seed = 123
**warmup = throwaway samples
**iter = keep samples
**(total 4000 samples taken to estimate probability distribution)
**core = CPU
**chains = number of simultaneous runs
**seed = random initialization (start value)
**note: needs follow-up tests to check output

**  -------------------------------------------------------
** Evaluate models
** Make some predictions
