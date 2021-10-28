************* Title: Thesis project analysis
** Project contents: START > IMPORT > TIDY > TRANSFORM > VISUALIZE > MODEL
*************
** File contents:
** 1. Descriptives
** 2. Figures
** 3. Models
** 4. Diagnostics // last step
** Import, tidy, transform in file "prep"
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
*******************----------------------------------------------------------------------- Describe 1
***DESCRIPTIVES***
use "$data/figures.dta", clear
asdoc codebook, save(summary.doc) //dimensions and types
asdoc duplicates list countryname year, append //peek
asdoc duplicates list countrycode year, append //then look at data file
asdoc tab incomelab, append //catvar levels
asdoc sum, detail append //stats sum of all vars
	gen star = .
	replace star = 1 if incomelab=="LM*"
	replace star = 2 if incomelab==".." | incomelab==""
	label define lbstar 1"LM*" 2".."
	label values star lbstar
	replace incomelab = "LM" if incomelab=="LM*"
	replace incomelab = "" if incomelab==".."
save "$data/figures.dta"
asdoc, row(sum year, sum urban, sum gini, sum polyarchy) dec(2) title(Main Controls Sum Stats)
asdoc sum, detail append save(summary.doc) title(codebook)

bysort HIPC: asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban, detail replace save(descrip.doc)
bysort HIPC: asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban if year==1990, detail append
bysort HIPC: asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban if year==2016, detail append

bysort incomelab: asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban, detail append //stats sum of all vars
bysort incomelab: asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban if year==1990, detail append //stats sum of all vars
bysort incomelab: asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban if year==2016, detail append //stats sum of all vars

asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban if year==1990, detail append
asdoc sum imhe_hc_mean3b debtpos gini gdpgrowth gdpusd gdppcusd ///
	open spending edspendperc edspendpercGDP demoperc urban if year==2016, detail append

asdoc sum, detail append save(summary_sample09.doc) title(codebook)
bysort incomelab: asdoc codebook, save(summary_sample09.doc) append //dimensions and types
	asdoc duplicates list countryname year, append //peek
	asdoc duplicates list countrycode year, append //then look at data file
	asdoc tab incomelab, append //catvar levels
**************----------------------------------------------------------------------- Figures 2
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
* Figure 1 Human capital index score by country group, 1980-2000
twoway (line Hmeanimhe_hc_mean3b year if HIPC==1) (line meanimhe_hc_mean3b year if incomelab=="L") ///
	(line meanimhe_hc_mean3b year if incomelab=="LM") (line meanimhe_hc_mean3b year if incomelab=="UM") ///
	, legend(label(1 "HIPC Countries") label(2 "Low income countries") ///
	label(3 "Lower-middle income countries") label(4 "Upper-middle income countries")) ///
	ytitle("Human capital index score") legend(pos(6)) xlabel(1990(5)2020, angle(0) grid)
	graph export "$figures\lineHCI.png", as(png) replace
* Figure 2a Total public external debt and gross debt position by country group, 1980-2000
twoway (line Hmeandebtpos year if HIPC==1) (line meandebtpos year if incomelab=="L") ///
	(line meandebtpos year if incomelab=="LM") (line meandebtpos year if incomelab=="UM") ///
	, legend(label(1 "HIPC Countries") label(2 "Low income countries") ///
	label(3 "Lower-middle income countries") label(4 "Upper-middle income countries")) ///
	ytitle("Gross Debt Position") legend(off) xlabel(1990(5)2020, angle(0) grid) name(alldebtpos)
	graph export "$figures\linedebtpos.png", as(png) replace
* Figure 2b GDP
twoway (line Hmeangdppcusdscaled year if HIPC==1) (line meangdppcusdscaled year if incomelab=="L") ///
	(line meangdppcusdscaled year if incomelab=="LM") (line meangdppcusdscaled year if incomelab=="UM") ///
	, legend(label(1 "Highly-indebted poor countries") label(2 "Low income countries") ///
	label(3 "Lower-middle income countries") label(4 "Upper-middle income countries")) ///
	ytitle("GDP per capita, 1000s USD") legend(off) xlabel(1985(5)2020, angle(0) grid) name(allGDP)
	graph export "$figures\LICGDP.png", as(png) replace
* Figure 2c Social spending of HIPC participant countries, 1980-2000
twoway (line Hmeanspending year if HIPC==1) (line Hmeanspending year if HIPC==0) ///
	, legend(label(1 "Highly-indebted poor countries") label(2 "Other countries")) ///
	ytitle("Public spending") legend(off) xlabel(1985(5)2010, angle(0) grid) name(allspending)
	graph export "$figures\HIPCspending.png", as(png) replace
* Figure 2c Edu spending of country groups
twoway (line HmeanedspendpercGDP year if HIPC==1) (line HmeanedspendpercGDP year if HIPC==0) ///
	, legend(label(1 "Highly-indebted poor countries") label(2 "Other countries")) ///
	legend(off) ytitle("Education spending, % GDP") xlabel(1985(5)2020, angle(0) grid) name(alleduspending)
	graph export "$figures\linespendinged.png", as(png) replace
*** FIGURE 2 DEBT + SPENDING
graph combine alldebtpos allGDP allspending alleduspending
	graph export "$figures\dist_debt_spending.png", as(png) replace
* Figure 3 Debt stock reduction by country group, 1980-2000 [+ ODA disbursements? See Fig. 9, UWU paper)
twoway (line Hgroupchangedebtpos year if HIPC==1) (line groupchangedebtpos year if incomelab=="L") ///
	(line groupchangedebtpos year if incomelab=="LM") (line groupchangedebtpos year if incomelab=="UM") ///
	, legend(label(1 "HIPC Countries") label(2 "Low income countries") ///
	label(3 "Lower-middle income countries") label(4 "Upper-middle income countries")) ///
	ytitle("Annual change in gross debt position (% GDP)") legend(pos(6)) xlabel(1990(5)2020, angle(0) grid)
graph export "$figures\linedebtchange.png", as(png) replace

twoway (scatter debtpos year, jitter(3) msize(tiny)) (lfitci debtpos year), legend(pos(5)) name(debttime)
twoway (scatter gdppcusdscaled year, jitter(3) msize(tiny)) (lfitci gdppcusdscaled year), legend(pos(5)) name(gdptime)
twoway (scatter spending year, jitter(3) msize(tiny)) (lfitci spending year), legend(pos(5)) name(spendtime)
twoway (scatter imhe_hc_mean3b year, jitter(3) msize(tiny)) (lfitci imhe_hc_mean3b year), legend(pos(5)) name(hctime)
graph combine debttime gdptime spendtime hctime

foreach covar in debtpos gdppcusdscaled spending {
reg imhe_hc_mean3b `covar'
local b`covar': display %10.3f _b[`covar']
}
twoway (scatter imhe_hc_mean3b debtpos, msize(tiny) text(20 300 "_b= -0.007** (0.002)")) ///
	(lfitci imhe_hc_mean3b debtpos), ytitle("Human Capital Index") xtitle("Total debt") legend(off) name(adebthcv)
twoway (scatter imhe_hc_mean3b gdppcusdscaled, msize(tiny) text(30 5 "_b= 0.29*** (0.005)")) ///
	(lfitci imhe_hc_mean3b gdppcusdscaled), ytitle("Human Capital Index") xtitle("GDP USD") legend(off) name(agdphcv)
twoway (scatter imhe_hc_mean3b spending, msize(tiny) text(20 80 "_b= 0.23*** (0.008)")) ///
	(lfitci imhe_hc_mean3b spending), ytitle("Human Capital Index") xtitle("Total spending") legend(off) name(aspendhcv)
graph combine adebthcv agdphcv aspendhcv

* Figure 8a GINI
twoway (line Hmeangini year if HIPC==1) (line meangini year if incomelab=="L") (line meangini year if incomelab=="LM") (line meangini year if incomelab=="UM") ///
	, legend(label(1 "Highly-indebted poor countries") label(2 "Low income countries") label(3 "Lower-middle income countries") label(4 "Upper-middle income countries")) ///
	ytitle("GINI") legend(off) xlabel(1985(5)2020, angle(0) grid) name(LICgini)
	graph export "$figures\linegini.png", as(png) replace
* Figure 8b Urban pop
twoway (line Hmeanurban year if HIPC==1) (line meanurban year if incomelab=="L") (line meanurban year if incomelab=="LM") (line meanurban year if incomelab=="UM") ///
	, legend(label(1 "Highly-indebted poor countries") label(2 "Low income countries") label(3 "Lower-middle income countries") label(4 "Upper-middle income countries")) ///
	ytitle("Urban (% total population)") legend(off) xlabel(1985(5)2020, angle(0) grid) name(LICurban)
	graph export "$figures\lineurban.png", as(png) replace
* Figure 8c Trade openness by country group, 1990-2000
twoway (line Hmeanopen year if HIPC==1) (line meanopen year if incomelab=="L") (line meanopen year if incomelab=="LM") (line meanopen year if incomelab=="UM") ///
	, legend(label(1 "Highly-indebted poor countries") label(2 "Low income countries") ///
	label(3 "Lower-middle income countries") label(4 "Upper-middle income countries")) ///
	ytitle("Trade openness, %GDP") legend(off) xlabel(1985(5)2020, angle(0) grid) name(LICopenoff)
	graph export "$figures\lineopen.png", as(png) replace
* Figure 8d Democracy score by country group, 1980-2000
twoway (line Hmeandemoperc year if HIPC==1) (line meandemoperc year if incomelab=="L") ///
	(line meandemoperc year if incomelab=="LM") (line meandemoperc year if incomelab=="UM") ///
	, legend(label(1 "Highly-indebted poor countries") label(2 "Low income countries") ///
	label(3 "Lower-middle income countries") label(4 "Upper-middle income countries")) ///
	ytitle("Democracy score (0-100)") legend(pos(6)) xlabel(1985(5)2020, angle(0) grid) name(LICdemo)
	graph export "$figures\linedemoc.png", as(png) replace
*** FIGURE 8
graph combine LICgini LICurban LICopenoff LICdemo
	graph export "$figures\dist_demovars.png", as(png) replace
*************
***DESCRIP*** Violin plots
	** vars: HCI, gov debt, GDP, GINI, urban, trade, demo score, inst quality, edu attainment
	** grouping: by income category, 1990 and 2015 (or 2010 where 2015 data not available)
label var imhe_hc_mean3b "Human Capital Index"
asdoc vioplot imhe_hc_mean3b gini if year==1990 | year==2015 /// range 0-30
	, over(ilab) over(year) ytitle(Human capital and GINI index density) save(plots_510.doc)
asdoc vioplot gdppcusd if year==1990 & ilab!=4 & ilab!=3 | year==2019 & ilab!=4 & ilab!=3 ///
	, over(year) over(ilab) ytitle(Growth density) append
asdoc vioplot spending if year==1990 | year==2010 & incomelab!="H" ///
	, over(year) over(ilab) legend(pos(6)) ytitle(Spending density) append
asdoc vioplot edspendpercGDP if year==1995 | year==2015 & incomelab!="H" ///
	, over(year) over(ilab) legend(pos(6)) ytitle(Education spending density) append
asdoc vioplot open debtpos if year==1990 | year==2019 ///
	, over(year) over(ilab) legend(pos(6)) ytitle(Debt and growth density) append
asdoc vioplot urban demoperc if year==1990 | year==2015 ///
	, over(ilab) over(year) legend(pos(6)) ylabel(-25(25)100, angle(0) grid) append
asdoc vioplot gini if year==1990 | year==2019 & incomelab!="H" ///
	, over(ilab) over(year) ytitle(GINI coefficient density) save(plots_510.doc)
asdoc vioplot gini urban demoperc if year==1990 | year==1995 | year==2000 | year==2005 | year==2010 | year==2015 ///
	, over(ilab) over(year) legend(label(1 "GINI coef") label(2 "Urban population") label(3 "Democracy score, scaled 0-100")) ///
	ytitle(Social and political controls, density) save(plots_510.doc)
asdoc vioplot gdpusdscale debtpos spending if ///
	(year==1990 | year==2010) & (incomelab=="LM" | incomelab=="L"), over(year) over(ilab) append
asdoc vioplot gdpusdbil debtpos spending if ///
	(year==1990 | year==2010) & (incomelab=="UM" | incomelab=="H"), over(year) over(ilab) append

*******************----------------------------------------------------------------------- Model 3
***SETUP***
use "$/sample analysis.dta", clear
global covars gdppcusdscaled gini demoperc open urban year
*global covarscale gini urban open demoperc gdppcusdperc // gdppcusdperc(100s)
***********
***HYP 1***
set more off
asdoc, text(Main models, Equations 1 and 2) replace save(models10.doc)
// time effect
foreach covar in debtpos gdpusdscaled gdppcusdscaled spending imhe_hc_mean3b {
asdoc reg `covar' year, append title(Reg EQ1 `covar' biv) //save(models10.doc) 
}
// bivar associations //gdpusdscaled
foreach covar in debtpos gdppcusdscaled spending i.HIPCi {
asdoc reg imhe_hc_mean3b `covar' year, append title(Reg EQ1 `covar' biv) //save(models10.doc)
}
// lagged regs to test directionality
preserve
encode countryname, gen(cnum)
xtset cnum year
foreach covar in debtpos gdppcusdscaled spending edspendperc {
asdoc reg imhe_hc_mean3b year `covar' L.`covar', append title(Reg EQ1 `covar' biv) //save(models10.doc)
asdoc reg imhe_hc_mean3b year `covar' L5.`covar', append title(Reg EQ1 `covar' biv) //save(models10.doc)
asdoc reg `covar' year imhe_hc_mean3b L.imhe_hc_mean3b, append title(Reg EQ1 `covar' biv) //save(models10.doc) 
asdoc reg `covar' year imhe_hc_mean3b L5.imhe_hc_mean3b, append title(Reg EQ1 `covar' biv) //save(models10.doc) 
}
restore
***********
***HYP 2***
//linreg
foreach covar in debtpos gdpusdscaled gdppcusdscaled spending imhe_hc_mean3b {
asdoc reg `covar' i.HIPCi year, append title(Reg EQ1 biv treatment effect) //save(models10.doc)
}
foreach covar in debtpos spending imhe_hc_mean3b {
asdoc reg `covar' i.HIPCi $covars, append title(Reg EQ1) //save(models10.doc) //debt or debt reduction?
}
asdoc reg gdpusdscaled i.HIPCi gini urban open egaldem, append title(Reg EQ2) //save(models10.doc) // gdp or gdp growth?
asdoc reg gdppcusdscaled i.HIPCi gini urban open egaldem, append title(Reg EQ2) //save(models10.doc) // consider scaled (gdppcusdscaled)

//me models
foreach outcome in debtpos spending imhe_hc_mean3b {
asdoc mixed `outcome' i.HIPCibin || countryname: , append title(ME `outcome' bin) //save(memodels10.doc)
asdoc mixed `outcome' i.HIPCi || countryname: , append title(ME `outcome')
asdoc mixed `outcome' i.HIPCi gdppcusdscaled gini egaldem open urban year || countryname: , append title(ME `outcome' covs)
asdoc mixed `outcome' i.HIPCi gdppcusdscaled gini egaldem open urban year || countryname: R.HIPCi , append title(RE `outcome')
**asdoc mixed `outcome' i.HIPCi gdppcusdscaled gini egaldem open urban year || countryname: R.HIPCi || countryname: $covars, append title(RE `outcome' covs)
}
asdoc mixed gdppcusdscaled i.HIPCi || countryname: , append title(ME gdppcusdscaled)
asdoc mixed gdppcusdscaled i.HIPCi gini egaldem open urban year || countryname: , append title(ME gdppcusdscaled covs)
asdoc mixed gdppcusdscaled i.HIPCi gini egaldem open urban year || countryname: R.HIPCi , append title(RE gdppcusdscaled covs)

***********
***HYP 3***
set more off
asdoc, text(Main models, Equation 3) append //save(models10.doc)

//linreg
asdoc reg imhe_hc_mean3b i.HIPCibin debtpos gdppcusdscaled spending year, append title(Reg EQ3 bin) //save(models10.doc)
asdoc reg imhe_hc_mean3b i.HIPCibin debtpos spending $covars c.gdppcusdscaled#c.gini, append title(Reg EQ3 covars bin) //save(models10.doc)
asdoc reg imhe_hc_mean3b i.HIPCi debtpos spending gdppcusdscaled year, append title(Reg EQ3 no treat) //save(models10.doc)
asdoc reg imhe_hc_mean3b i.HIPCi debtpos spending $covars c.gdppcusdscaled#c.gini, append title(Reg EQ3 covars treat) //save(models10.doc)

//fe models
asdoc mixed imhe_hc_mean3b i.HIPCibin debtpos spending $covars c.gdppcusdscaled#c.gini ///
	|| countryname: , append title(ME RIFS bin) //save(models10.doc)
estimates store febivbin
asdoc estat ic, append //save(models10.doc)
asdoc estat icc, append //save(models10.doc)
asdoc mixed imhe_hc_mean3b i.HIPCi debtpos spending $covars c.gdppcusdscaled#c.gini ///
	|| countryname: , append title(ME RIFS cat) //save(models10.doc)
estimates store febiv
asdoc estat ic, append //save(models10.doc)
asdoc estat icc, append //save(models10.doc)

//me models
asdoc mixed imhe_hc_mean3b i.HIPCibin debtpos spending $covars c.gdppcusdscaled#c.gini ///
	|| countryname: debtpos spending gdppcusdscaled gini egaldem open urban year ///
	, append title(ME RIRS bin) //save(models10.doc)
estimates store rebin
asdoc estat ic, append //save(models10.doc)
asdoc estat icc, append //save(models10.doc)
asdoc mixed imhe_hc_mean3b i.HIPCi debtpos spending $covars c.gdppcusdscaled#c.gini ///
	|| countryname: debtpos spending gdppcusdscaled gini egaldem open urban year ///
	, append title(ME RIRS cat) //save(models10.doc)
estimates store refull
asdoc estat ic, append //save(models10.doc)
asdoc estat icc, append //save(models10.doc)
***************
***TREATMENT***
** treatment effects estimators:
	** regression adjustment (RA) - estimates ATET instead of ATE
		**(avg treatment effect on the treated; i.e., using only obs from treatmtne group)
	** inverse probability weighting (IPW)
	** inverse probability weighting with regression adjustment (IPWRA)
	** augmented inverse probability weighting (AIPW)

** regression adjustment
asdoc teffects ra (imhe_hc_mean3b) (HIPCibin), append title(taffects regression adjustment)
asdoc teffects ra (imhe_hc_mean3b debtpos gdppcusdscaled) (HIPCibin), append title(taffects regression adjustment)
asdoc teffects ra (imhe_hc_mean3b $covars) (HIPCibin), append title(taffects regression adjustment +covars)
asdoc teffects ra (imhe_hc_mean3b debtpos $covars) (HIPCibin), append title(taffects regression adjustment +covars)
** a? inverse probability weighted
teffects aipw (imhe_hc_mean3b) (HIPCibin)
taffects aipw (imhe_hc_mean3b debtpos gdppcusdscaled) (HIPCibin)
teffects aipw (imhe_hc_mean3b $covars) (HIPCibin)
teffects aipw (imhe_hc_mean3b debtpos $covars) (HIPCibin)
** inverse probability weighted + regression adjustment
teffects ipwra (imhe_hc_mean3b) (HIPCibin)
taffects ipwra (imhe_hc_mean3b debtpos gdppcusdscaled) (HIPCibin)
teffects ipwra (imhe_hc_mean3b $covars) (HIPCibin)
teffects ipwra (imhe_hc_mean3b debtpos $covars) (HIPCibin)

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
