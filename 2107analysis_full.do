**************
**PSEUDOCODE**

**												**call model results:
*return list
*putexcel A1=matrix(r(C), names) using [model]
**												**rename year variables with var labels:
*foreach v of var*{
*        local l`v' : variable label `v'
* }
*foreach v of varlist v* {
*   local x : variable label `v'
*   rename `v' y`x'
*}
**												**encoding var pseudocode
*encode indicatorname, gen(indicator)
*drop if indicator==.
*drop indicatorname
*replace indicatorname="Missing" if indicator==.
*replace indicatorcode="Missing" if indicator==.

************
***NOTES****

** HEIKO'S CODE:
** Heiko's barplots are useful for binary var percentages of a population
** but i don't have any binary/percentage variables
*preserve
*recode vot long_hours binarysched (1 = 100)
*collapse vot long_hours binarysched [pweight=dweight], by(cntry gendr)
*save "$temp\mean_mf.dta", replace
*restore
*preserve
*recode vot long_hours binarysched (1 = 100)
*collapse vot long_hours binarysched [pweight=dweight], by(cntry)
*append using "$temp\mean_mf.dta"
*gen population=.
*replace population=2 if gendr==.
*replace population=3 if gendr==0
*replace population=1 if gendr==1
*label define pop_lab 1 "F" 2 "T" 3 "M"
*label value population pop_lab
*foreach var of varlis vot long_hours binarysched {		
*		separate `var', by(population)
*}
*	graph bar vot1 vot2 vot3, over(population) over(cntry) xsize(3) ysize(1) ///
*ytitle("") nofill legend(off) ylabel(0(20)100) title("{bf:Electoral participation}") ///
*bar(1, color(black) fi(100)) bar(2, fcolor(white) lcolor(black) fi(100)) ///
*bar(3, fcolor(gs12) lcolor(black) fi(100)) name(vot, replace)
*	graph bar long_hours1 long_hours2 long_hours3, over(population) over(cntry) xsize(3) ysize(1) ///
*ytitle("") nofill legend(off) ylabel(0(20)100) title("{bf:Working long hours}") ///
*bar(1, color(black) fi(100)) bar(2, fcolor(white) lcolor(black) fi(100)) ///
*bar(3, fcolor(gs12) lcolor(black) fi(100)) name(long_hours, replace)
*	graph bar binarysched1 binarysched2 binarysched3, over(population) over(cntry) xsize(3) ysize(1) ///
*ytitle("") nofill legend(off) ylabel(0(20)100) title("{bf:Working unsocial hours}") ///
*bar(1, color(black) fi(100)) bar(2, fcolor(white) lcolor(black) fi(100)) ///
*bar(3, fcolor(gs12) lcolor(black) fi(100)) name(binarysched, replace)
*	graph combine vot long_hours binarysched, row(3)
*	graph export "$figures\descriptives.png", replace

** Path note: set working directory ("/Users/hanna/OneDrive/Documents/projects") in setup code
** then use subjective file paths throughout code ("$/data)

** save var & val labels as local macros
** https://www.stata.com/support/faqs/data-management/apply-labels-after-reshape/

** some steps of the project prototype come from: https://machinelearningmastery.com/machine-learning-in-r-step-by-step/

** omitted descriptive elements: levels of catvars / catvar level distribution
** catvar levels & distribution of levels only apply to catvars
** in this project, only grouping vars (inc and debt) are categorical!

***********
** Contents: START > IMPORT > TIDY > TRANSFORM > VISUALIZE > MODEL
** Import data - in file "prep"
** Tidy & transform data - in file "prep"

** Title: Thesis project analysis
** 0. Setup
** 1. Visualize data
** 2. Models & model figures
** 3. Diagnostics

***OMITTED CONTROLS - EDU SPENDING***
** growth, debt, inflation, unemployment, tax revenue, deficit, central gov grants
** government spending (total, edu), effectiveness of spending

***L2 CONTROLS - EDU OUTCOME***
** urban, gnp, gini, trade open, democracy, corruption/inst quality, transparency

***IDs - countryname countrycode, year
*files wide by year (y1234), long by indicator (indicatorname indicatorcode)
*unless marked "long"

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

** summary:

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

** graphs:
	** univariate plots -- violin / box for numeric vars; bar plots for cat vars
	** multivariate plots -- histograms / density plots
	** contents: violin plots / line plots / multivar plots

** 1 - violin plots:
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

** 2 - line plots
	** vars: HCI, gov debt, GDP, GINI, urban, trade, demo score, inst quality, edu attainment
	** grouping: by income category, 1987-2017
asdoc graph twoway line meanimhe_hc_mean1m meanimhe_hc_mean2f meanimhe_hc_mean3b year, by(incomelab) append
	graph export "$figures\HCI_mean_gender_lineplot_allgroups.png", as(png) replace
asdoc graph twoway line meangini meanurban meandemoperc year, by(incomelab) append
	graph export "$figures\predictors_social_lineplot_allgroups.png", as(png) replace
asdoc graph twoway line meangdppcusdperc meanopenperc year, by(incomelab) append
	graph export "$figures\predictors_gdp_lineplot_allgroups.png", as(png) replace
asdoc graph twoway line meandebtpos meanspending year, by(incomelab) append
	graph export "$figures\macroecon_lineplot_allgroups.png", as(png) replace

** Multivariate plots of relationships between attributes/vars


*featurePlot(x=x, y=y, plot="ellipse") ** scatterplot matrix (y in plots of every IV combo)
*featurePlot(x=x, y=y, plot="box") ** box and whisker plots for each attribute
*scales <- list(x=list(relation="free"), y=list(relation="free"))
*  featurePlot(x=x, y=y, plot="density", scales=scales) ** density plots for each attribute by class value

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
