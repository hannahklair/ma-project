** Thesis analysis

**************
**PSEUDOCODE** 
** call model results: return list // putexcel A1=matrix(r(C), names) using [model]

*foreach v of var*{
*        local l`v' : variable label `v'
* }

*foreach v of varlist v* {
*   local x : variable label `v'
*   rename `v' y`x'
*}

*encode indicatorname, gen(indicator)
*drop if indicator==.
*drop indicatorname
*replace indicatorname="Missing" if indicator==.
*replace indicatorcode="Missing" if indicator==.

// long-hand way to check for duplicates in countrycode:
*encode countryname, gen(num)
*forvalues c = 1/250 {
*	tab countrycode if num==`c'
*} // note duplicates here:
*drop num
*encode countrycode, gen(num)
*forvalues c = 1/250 {
*	tab countryname if num==`c'
*} // note duplicates here:
*drop num
// then fix duplicates manually:
*replace countrycode = "BLR" if countryname=="Belarus"
*replace countrycode = "CZE" if countryname=="Czech Republic"

* to merge the two education files:
*merge 1:1 countryname year using ///
*"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longspendingedu.dta", gen(mergespend2)

* resource/ reference compare coverage to owid:
* https://ourworldindata.org/grapher/share-of-education-in-government-expenditure

************
***NOTES****

**Path note** set working directory ("/Users/hanna/OneDrive/Documents/projects")
** All files in code should be specified with SUBJECTIVE FILE LOCATIONS!!!

** save var & val labels as local macros
** https://www.stata.com/support/faqs/data-management/apply-labels-after-reshape/

*IDs - countryname countrycode, year
*files wide by year (y1234), long by indicator (indicatorname indicatorcode)
*unless marked "long"

***L2 CONTROLS - EDU OUTCOME***
** urban, gnp, gini, trade open, democracy, corruption/inst quality, transparency

***OMITTED CONTROLS - EDU SPENDING***
** growth, debt, inflation, unemployment, tax revenue, deficit, central gov grants
** government spending (total, edu), effectiveness of spending

** COUNTRY NAMES
* Afghanistan Albania Algeria Angola Argentina Armenia Azerbaijan
* Bangladesh Belarus Belize Benin Bhutan Bolivia
* Bosnia and Herzegovina
* Botswana Brazil Bulgaria Burkina Faso Burundi Cambodia Cameroon
* Chad Chile Colombia Comoros Republic Costa Rica Croatia Cuba 
* Djibouti Dominica Dominican Republic
* Ecuador Egypt El Salvador Equatorial Guinea Eritrea Estonia
* Eswatini Ethiopia Fiji
* Georgia Ghana Grenada Guatemala Guinea Guinea-Bissau Guyana
* Haiti Honduras India Indonesia Iraq 
* Jamaica Jordan Kazakhstan Kenya Kiribati Kosovo Kyrgyz Republic
* Latvia Lebanon Lesotho Liberia Lithuania
* Madagascar Malawi Malaysia Maldives Mali Marshall Islands
* Mauritania Mauritius Mayotte Mexico Micronesia Moldova
* Mongolia Morocco Mozambique Myanmar Namibia Nepal 
* Nicaragua Niger Nigeria North Korea North Macedonia Northern Mariana Islands
* Pakistan Panama Papua New Guinea Paraguay Peru Philippines Poland
* Romania Russian Federation Rwanda
* Samoa Senegal Serbia and Montenegro Sierra Leone Slovak Republic
* Solomon Islands Somalia South Africa South Sudan
* Sri Lanka St. Lucia St. Vincent and the Grenadines
* Sudan Suriname São Tomé and Principe 
* Tajikistan Tanzania Thailand Timor-Leste Togo Tonga
* Tunisia Turkey Turkmenistan Tuvalu
* USSR (former) Uganda Ukraine Uzbekistan 
* Vanuatu Vietnam West Bank and Gaza
* Yugoslavia (former) Zambia Zimbabwe

*****************
**COUNTRY NAMES**
*replace countryname="Bahamas" if countryname=="Bahamas, The"
*replace countryname="Brunei" if countryname=="Brunei Darussalam"
*replace countryname="Cape Verde" if countryname=="Cabo Verde"
*replace countryname="China" if countryname=="China, People's Republic of"
*replace countryname="Democratic Republic of Congo" if countryname=="Congo, Dem. Rep."
*replace countryname="Central African Republic" if countryname=="CAR"
*replace countryname="Congo Republic" if countryname=="Congo, Rep."
*replace countryname="Côte d'Ivoire" if countryname=="Cote d'Ivoire"
*replace countryname="Egypt" if countryname=="Egypt, Arab Rep."
*replace countryname="Faroe Islands" if countryname=="Faeroe Islands"
*replace countryname="Gambia" if countryname=="Gambia, The"
*replace countryname="Hong Kong" if countryname=="Hong Kong SAR, China" | countryname=="Hong Kong, China"
*replace countryname="Iran" if countryname=="Iran, Islamic Rep."
*replace countryname="Laos" if countryname=="Lao PDR"
*replace countryname="Macao" if countryname=="Macao SAR, China" | countryname=="Macao, China"
*replace countryname="Netherlands Antilles" if countryname=="Netherlands Antilles (former)"
*replace countryname="North Korea" if countryname=="Korea, Dem. Rep."
*replace countryname="South Korea" if countryname=="Korea, Rep."
*replace countryname="Serbia and Montenegro" if countryname=="Serbia and Montenegro (former)"
*replace countryname="Syria" if countryname=="Syrian Arab Republic"
*replace countryname="Taiwan" if countryname=="Taiwan, China"
*replace countryname="UAE" if countryname==" United Arab Emirates"
*replace countryname="Venezuela" if countryname=="Venezuela, RB"
*replace countryname="Virgin Islands" if countryname=="Virgin Islands (U.S.)"
*replace countryname="Virgin Islands" if countryname=="British Virgin Islands"
*replace countryname="Yemen" if countryname=="Yemen, Rep."

** Contents: START > IMPORT > TIDY > TRANSFORM
** VISUALIZE & MODEL in file "analysis_full_0707.ado"

** Title: Thesis project data prep
** 0. Setup
** 1. Import data
** 2. Tidy & transform data
** 3. Merge

************
***START****
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
global figures `"$path\Stata"'
global temp `"$path\Stata"'
global out `"$path\Stata"'

***************************
****IMPORT - PREDICTORS****
************************************************************ED OUTCOME CONTROLS*
** GINI
import excel ///
"C:\Users\hanna\OneDrive\Documents\thesis\Gapminder_GINI_ORIG.xlsx", sheet("data-for-countries-etc-by-year") ///
gen countrycode = upper(geo)
drop geo
label variable countrycode "Country Code ISO-3"
rename name countryname
label variable countryname "Country Name"
rename time year
label variable year "Year"
rename Gini gini
label variable gini "GINI coefficient"
save "$data\GINI.dta"

** URBAN - % population urban (urbanization)
** (source: WDI from WB, updated 19-03-21)
import excel "C:\Users\hanna\OneDrive\Documents\thesis\POPURBAN.xls", sheet("Data") firstrow
rename CountryName countryname
rename CountryCode countrycode
foreach v of varlist E-BM {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\urbanpop.dta", replace
drop IndicatorName IndicatorCode
reshape long y, i(countryname countrycode) j(year)
rename y urban
label variable urban "Urban Population %Total"
label variable year Year
save "$data\urbanpop.dta", replace

*** TRADE
import excel "C:\Users\hanna\OneDrive\Documents\thesis\TRADEOPEN.xls", sheet("Data") firstrow
rename CountryName countryname
rename CountryCode countrycode
foreach v of varlist E-AN {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\TRADEOPEN.dta", replace
drop IndicatorName IndicatorCode
reshape long y, i(countryname countrycode) j(year)
rename y open
label variable open "Trade openness (%GDP)"
label variable year Year
save "$data\trade.dta", replace

** DEMOCRACY
use "C:\Users\hanna\OneDrive\Documents\thesis\DEMOCRACY.dta", clear
rename eiu_country countryname
label variable countryname "Country Name"
drop extended_country_name
rename eiu demoscore
label variable demoscore "Democracy Score 0-10"
rename in_GW_system insystem
label variable insystem "Independent and sovereign"
replace countryname="Cape Verde" if countryname=="Cabo Verde"
replace countryname="Côte d'Ivoire" if countryname=="Côte d’Ivoire"
drop GWn cown
save "$data\DEMOCRACYINDEX.dta"
********************************************************************************
** MERGE
use "$data\urbanpop.dta", clear
tab countryname if countrycode=="SWZ" | countrycode=="MKD" | countrycode=="LAO" | countrycode=="PRK"
replace countryname="North Korea" if countrycode=="PRK"
*duplicates tag countryname year, gen(dup)
*duplicates list countryname countrycode year
*duplicates drop countryname countrycode year if countryname=="Eswatini" & dup==1, force
*duplicates drop countryname countrycode year if countryname=="Macedonia" & dup==1, force
*duplicates drop countryname countrycode year if countryname=="North Korea" & dup==1, force
*drop dup
save "$data\urbanpop.dta", replace

use "$data\GINI.dta", clear
tab countryname if countrycode=="SWZ" | countrycode=="MKD" | countrycode=="LAO" | countrycode=="PRK"
replace countryname="Laos" if countryname=="Lao"
replace countryname="Macedonia" if countryname=="Macedonia, FYR"
replace countryname="Eswatini" if countryname=="Swaziland"
merge 1:1 countryname year using "$data\urbanpop.dta", gen(mergeurban)
save "$data\fullset_demo.dta", replace

use "$data\fullset_demo.dta", clear
merge 1:1 countryname year using "$data\trade.dta", gen(mergetrade)
duplicates list countryname year
duplicates list countrycode year

use "$data\trade.dta", clear
replace countryname="North Korea" if countrycode=="PRK"
save "$data\trade.dta", replace

use "$data\fullset_demo.dta", clear
merge 1:1 countryname year using "$data\DEMOCRACYINDEX.dta", gen(mergedemo)
duplicates list countryname year
duplicates list countrycode year

use "$data\DEMOCRACYINDEX.dta", clear
replace countryname="Bosnia and Herzegovina" if countryname=="Bosnia and Hercegovina"
replace countryname="Saudi Arabia" if countryname=="Saudi"
replace countryname="Timor-Leste" if countryname=="Timor Leste"
save "$data\DEMOCRACYINDEX.dta", replace

use "$data\fullset_demo.dta", clear
merge 1:1 countryname year using "$data\urbanpop.dta", gen(mergeurban)
merge 1:1 countryname year using "$data\trade.dta", gen(mergetrade)
merge 1:1 countryname year using "$data\DEMOCRACYINDEX.dta", gen(mergedemo)
replace countryname="Saudi Arabia" if countryname=="Saudia Arabia"
replace countrycode="SAU" if countryname=="Saudi Arabia"
replace countrycode="TWN" if countryname=="Taiwan"
save "$data\fullset_demo.dta", replace

************************************************************ED SPENDING CONTROLS*
** DEMOGRAPHIC INDICATORS

** fraction elderly
import delimited C:\Users\hanna\OneDrive\Documents\thesis\POP65.csv, varnames(1) clear 
rename ïcountryname countryname
label variable countryname "Country Name"
foreach v of varlist v* {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\pop65.dta", replace
drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y pop65
label variable pop65 "Population age 65+ (% total)"
label variable year Year
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
replace countryname="Kyrgyzstan" if countryname=="Kyrgyz Republic"
replace countryname="Macedonia" if countryname=="North Macedonia"
replace countryname="Russia" if countryname=="Russian Federation"
replace countryname="São Tomé and Principe" if countryname=="Sao Tome and Principe"
replace countryname="Slovakia" if countryname=="Slovak Republic"
replace countryname="UAE" if countryname=="United Arab Emirates"
replace countryname="Palestine" if countryname=="West Bank and Gaza"
save "$data\longpop65.dta", replace

** population density
import delimited C:\Users\hanna\OneDrive\Documents\thesis\POPDENSITY.csv, varnames(1) clear 
rename ïcountryname countryname
label variable countryname "Country Name"
foreach v of varlist v* {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\popdensity.dta", replace
drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y popdens
label variable popdens "Population Density (per sqkm land)"
label variable year Year
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
save "$data\longpopdensity.dta", replace
********************************************************************************
** MERGE - ALL DEMOGRAPHIC INDICATORS
use "$data\fullset_demo.dta", clear
merge 1:1 countryname year using "$data\longpop65.dta", gen(mergepop65)
merge 1:1 countryname year using "$data\longpopdensity.dta", gen(mergedensity)
replace countryname="Micronesia" if countryname=="Micronesia, Fed. Sts."
save "$data\fullset_demo.dta", replace
************************************************************ED SPENDING CONTROLS*
** MACROECONOMIC INDICATORS
** GDP PPP
import delimited C:\Users\hanna\OneDrive\Documents\thesis\GDP_PPP.csv, varnames(1) clear
save "$data\income_debt_encoded.dta" // why did I call this like this?

tab year if countryname=="Czech Republic" | countryname=="Czechoslovakia (former)"
tab year if countryname=="Russian Federation"
replace countryname="Laos" if countryname=="Lao PDR"
replace countryname="Bahamas" if countryname=="Bahamas, The"
replace countryname="Virgin Islands" if countryname=="British Virgin Islands"
replace countryname="Brunei" if countryname=="Brunei Darussalam"
replace countryname="Cape Verde" if countryname=="Cabo Verde"
replace countryname="Democratic Republic of Congo" if countryname=="Congo, Dem. Rep."
replace countryname="Congo Republic" if countryname=="Congo, Rep."
replace countryname="Egypt" if countryname=="Egypt, Arab Rep."
replace countryname="Faroe Islands" if countryname=="Faeroe Islands"
replace countryname="Gambia" if countryname=="Gambia, The"
replace countryname="Hong Kong" if countryname=="Hong Kong SAR, China" | countryname=="Hong Kong, China"
replace countryname="Iran" if countryname=="Iran, Islamic Rep."
replace countryname="North Korea" if countryname=="Korea, Dem. Rep."
replace countryname="South Korea" if countryname=="Korea, Rep."
replace countryname="Macao" if countryname=="Macao SAR, China" | countryname=="Macao, China"
replace countryname="Netherlands Antilles" if countryname=="Netherlands Antilles (former)"
replace countryname="Serbia and Montenegro" if countryname=="Serbia and Montenegro (former)"
replace countryname="Syria" if countryname=="Syrian Arab Republic"
replace countryname="Taiwan" if countryname=="Taiwan, China"
replace countryname="UAE" if countryname==" United Arab Emirates"
replace countryname="Venezuela" if countryname=="Venezuela, RB"
replace countryname="Virgin Islands" if countryname=="Virgin Islands (U.S.)"
replace countryname="Yemen" if countryname=="Yemen, Rep."

replace income = 3 if ///
countryname=="Afghanistan" | countryname=="Bangladesh" | countryname=="Benin" ///
| countryname=="Burkina Faso" | countryname=="Congo Republic" ///
| countryname=="Burundi" | countryname=="Central African Republic" ///
| countryname=="Chad" | countryname=="Comoros" | countryname=="Côte d'Ivoire" ///
| countryname=="Democratic Republic of Congo" | countryname=="Eritrea" ///
| countryname=="Ghana" | countryname=="Guinea" | countryname=="Myanmar" ///
| countryname=="Ethiopia" | countryname=="Haiti" | countryname=="Honduras" ///
| countryname=="Guinea-Bissau" | countryname=="Mozambique" ///
| countryname=="Kenya" | countryname=="Kyrgyz Republic" ///
| countryname=="Lesotho" | countryname=="Liberia" | countryname=="Madagascar" ///
| countryname=="Mali" | countryname=="Malawi" | countryname=="Mauritania" ///
| countryname=="Nepal" | countryname=="Niger" | countryname=="Nigeria" ///
| countryname=="Pakistan" | countryname=="Papua New Guinea" ///
| countryname=="Rwanda" | countryname=="Senegal" | countryname=="Sierra Leone" ///
| countryname=="Somalia" | countryname=="South Sudan" | countryname=="Sudan" ///
| countryname=="Tajikistan" | countryname=="Tanzania" | countryname=="Gambia" ///
| countryname=="Togo" | countryname=="Uganda" | countryname=="Yemen" ///
| countryname=="Zambia" | countryname=="Zimbabwe" 

** GDP PPP "GDP, PPP (current international $)" gdpppp
import delimited C:\Users\hanna\OneDrive\Documents\thesis\GDP_PPP.csv, ///
varnames(1) clear
rename ïcountryname countryname
*rename indicatorname indicatornameGDPPPP
*rename indicatorcode indicatorcodeGDPPPP
foreach v of varlist v* {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\GDPppp_wb.dta", replace
use "C:\Users\hanna\OneDrive\Documents\thesis\Stata\GDPppp_wb.dta", clear
drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y gdpppp
	label variable gdpppp "GDP (current intl$)"
	label variable year Year
save "$data\longGDPppp_wb.dta", replace

** GDP USD "GDP (current US$)" gdpusd
import delimited C:\Users\hanna\OneDrive\Documents\thesis\GDP_USD.csv, ///
	varnames(1) clear
rename ïcountryname countryname
label variable countryname "Country Name"
	*rename indicatorname indicatornameGDPUSD
	*rename indicatorcode indicatorcodeGDPUSD
foreach v of varlist v* {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\GDPusd_wb.dta", replace

use "C:\Users\hanna\OneDrive\Documents\thesis\Stata\GDPusd_wb.dta", clear
	drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y gdpusd
	label variable gdpusd "GDP (current US$)"
	label variable year Year
save "$data\longGDPusd_wb.dta", replace

** GDP pc ppp intl "GDP per cap PPP (current intl$)" gdppcppp
import delimited C:\Users\hanna\OneDrive\Documents\thesis\GDPpcapppp_wb.csv, ///
varnames(1) clear
rename ïcountryname countryname
label variable countryname "Country Name"
*rename indicatorname indicatornameGDPPCPPP
*rename indicatorcode indicatorcodeGDPPCPPP
foreach v of varlist v* {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\GDPcapppp_wb.dta", replace
use "C:\Users\hanna\OneDrive\Documents\thesis\Stata\GDPcapppp_wb.dta", clear
drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y gdppcppp
	label variable gdppcppp "GDP per capita (current intl$)"
	label variable year Year
save "$data\longGDPcapppp_wb.dta", replace

** GDP pc USD - "GDP per capita (current US$)" gdppcusd
* url - https://data.worldbank.org/indicator/NY.GDP.PCAP.CD
import delimited C:\Users\hanna\OneDrive\Documents\thesis\GDPpcap_wb.csv, ///
varnames(1) clear
rename ïcountryname countryname
*rename indicatorname indicatornameGDPPCUSD
*rename indicatorcode indicatorcodeGDPPCUSD
foreach v of varlist v* {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\GDPcap_wb.dta", replace
use "C:\Users\hanna\OneDrive\Documents\thesis\Stata\GDPppp_wb.dta", clear
drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y gdppcusd
	label variable gdppcusd "GDP per capita (current US$)"
	label variable countryname "Country Name"
	label variable year Year
save "$data\longGDPcap_wb.dta", replace
********************************************************************************
** MERGE
use "$data\longGDPppp_wb.dta", clear
merge 1:1 countryname year using "$data\longGDPusd_wb.dta", gen(mergeGDP1u)
merge 1:1 countryname year using "$data\longGDPcapppp_wb.dta", gen(mergeGDP2p)
merge 1:1 countryname year using "$data\longGDPcap_wb.dta", gen(mergeGDP2u)
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
replace countryname="Micronesia" if countryname=="Micronesia, Fed. Sts."
save "$data\longGDP_merged.dta", replace
************************************************************************SPENDING*
** SPENDING - "Government Expenditure"
** source: IMF based on Mauro et al. (2015)
import delimited using "C:\Users\hanna\OneDrive\Documents\thesis\Data Archive\expenditure.csv", varnames(1) clear 
rename entity countryname
	label variable countryname "Country Name"
replace countryname="Eswatini" if countryname=="Swaziland"
save "$data\longspending_historic.dta", replace
drop if year<1950
save "$data\longspending.dta", replace

** EDU SPENDING - "Govt expenditure on education (% total)" edspendperc
import delimited C:\Users\hanna\OneDrive\Documents\thesis\eduexpenditure.csv, varnames(1) clear 
	*rename indicatorname indicatornameGDPPCUSD
	*rename indicatorcode indicatorcodeGDPPCUSD
rename ïcountryname countryname
	label variable countryname "Country Name"
foreach v of varlist v* {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\spendingedu.dta", replace
use "C:\Users\hanna\OneDrive\Documents\thesis\Stata\spendingedu.dta", clear
	drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y edspendperc
	label variable edspendperc "Govt expenditure on education (% total)"
	label variable year Year
replace countryname="Micronesia" if countryname=="Micronesia, Fed. Sts."
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
save "$data\longspendingedu.dta", replace

** EDU SPENDING - "Govt expenditure on education (% GDP)" edspendingpercGDP
import delimited C:\Users\hanna\OneDrive\Documents\thesis\eduexpenditureGDO.csv, varnames(1) clear 
rename ïcountryname countryname
	label variable countryname "Country Name"
foreach v of varlist v* {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\spendingeduGDP.dta", replace
	drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y edspendpercGDP
	label variable edspendpercGDP "Govt expenditure on education (% GDP)"
	label variable year Year
replace countryname="Micronesia" if countryname=="Micronesia, Fed. Sts."
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
save "$data\longspendingeduGDP.dta", replace

**DEBT $ - govt debt, "Gross debt position (% of GDP)"
import excel "C:\Users\hanna\OneDrive\Documents\thesis\debtposition.xls", sheet("G_XWDG_G01_GDP_PT") firstrow clear
	drop in 1
rename GrossdebtpositionofGDP countryname
	label variable countryname "Country Name"
foreach v of varlist B C D E F G H I J K L M N O P Q R S T U V W X Y Z ///
AA AB AC AD AE AF AG AH AI AJ AK {
   local x : variable label `v'
   rename `v' y`x'
}
reshape long y, i(countryname) j(year)
rename y debtpos
	label variable debtpos "Gross debt position (% GDP)"
	label variable year Year
label define lbdebt 1"Miss" 2"LIN - Less indebted" 3"LINa" 4"MIN - Moderately indebted" ///
	5"MIN*" 6"MINa" 7"NIN - Not classified" 8"SIN - Severely indebted"
	label values debt lbdebt
replace countryname="Eswatini" if countryname=="Swaziland"
replace countryname="Bahamas" if countryname=="Bahamas, The"
replace countryname="China" if countryname=="China, People's Republic of"
replace countryname="Democratic Republic of Congo" if countryname=="Congo, Dem. Rep."
replace countryname="Congo Republic" if countryname=="Congo, Rep."
replace countryname="Cape Verde" if countryname=="Cabo Verde"
replace countryname="Brunei" if countryname=="Brunei Darussalam"
replace countryname="Gambia" if countryname=="Gambia, The"
replace countryname="Hong Kong" if countryname=="Hong Kong SAR, China" | ///
	countryname=="Hong Kong SAR" | countryname=="Hong Kong, China"
replace countryname="South Korea" if countryname=="Korea, Rep."
replace countryname="Laos" if countryname=="Lao PDR"
replace countryname="Micronesia, Fed. Sts." if countryname=="Micronesia, Fed. States of"
replace countryname="St. Kitts and Nevis" if countryname=="Saint Kitts and Nevis"
replace countryname="St. Lucia" if countryname=="Saint Lucia"
replace countryname="St. Vincent and the Grenadines" if countryname=="Saint Vincent and the Grenadines"
replace countryname="South Sudan" if countryname=="South Sudan, Republic of"
replace countryname="São Tomé and Principe" if countryname=="São Tomé and Príncipe"
replace countryname="Taiwan" if countryname=="Taiwan Province of China"
replace countryname="UAE" if countryname==" United Arab Emirates"
replace countryname="Congo" if countryname=="Congo, Rep." | countryname=="Congo, Republic of "
replace countryname="DR Congo" if countryname=="Congo, Dem. Rep." | countryname=="Congo, Dem. Rep. of the"
replace countryname="South Korea" if countryname=="Korea, Republic of"
replace countryname="Laos" if countryname=="Lao P.D.R."
replace countryname="Macedonia" if countryname=="North Macedonia " | countryname=="North Macedonia"
replace countryname="Micronesia" if countryname=="Micronesia, Fed. Sts."
	drop if countryname=="" & debtpos==.
save "$data\longdebtposition.dta", replace

** TAXES - tax revenue "Taxes Revenue (% GDP)" taxperc
import delimited C:\Users\hanna\OneDrive\Documents\thesis\TAXES_PERC.csv, varnames(1) clear 
rename ïcountryname countryname
	label variable countryname "Country Name"
foreach v of varlist v* {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\taxes.dta", replace
	drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y taxesperc
	label variable taxesperc "Tax revenue(% GDP)"
	label variable year Year
replace countryname="Micronesia" if countryname=="Micronesia, Fed. Sts."
save "$data\longtaxes.dta", replace

** OMITTED OR LEFT OUT **
** other edu spending determinants: debt payments, deficit, inflation,
** social spending effectiveness, central gov grants, unemployment
********************************************************************************
** MERGE - ALL MACROECON INDICATORS
use "$data\longdebtposition.dta", clear
merge 1:1 countryname year using "$data\longspending.dta", gen(mergespend1)
merge 1:1 countryname year using "$data\longtaxes.dta", gen(mergetax)
merge 1:1 countryname year using "$data\longspendingedu.dta", gen(mergespend2)
merge 1:1 countryname year using "$data\longspendingeduGDP.dta", gen(mergespend3)
merge 1:1 countryname year using "$data\longGDP_merged.dta", gen(mergeGDPset)
save "$data\fullset_macroecon_merged.dta", replace
********************************************************************************
** MERGE - DEMOGRAPHIC + MACROECONOMIC
use "$data\fullset_demo.dta", replace
merge 1:1 countryname year using "$data\fullset_macroecon_merged.dta", gen(mergecovars)
save "$data\fullset_merged_covars.dta", replace
***************************************************************************CASES*
** income categories
import excel "C:\Users\hanna\OneDrive\Documents\thesis\income_classification_hist.xlsx" ///
, firstrow clear
drop AJ-IV
foreach v of varlist C-AI {
   local x : variable label `v'
   rename `v' y`x'
}
rename Countrycode countrycode
rename Country countryname
reshape long y, i(countryname countrycode) j(year)
	label variable year "Year"
rename y incomelab
	label variable incomelab "World Bank Income Category"
save "$data\income_lab_hist.dta", replace
** subset by income group
use "$data\income_lab_hist.dta", clear
drop if incomelab=="H" | incomelab==".." | incomelab=="UM"
replace incomelab = "LM" if incomelab=="LM*"
save "$data\LIC_base.dta", replace
***********************************************************************TREATMENT*
** HIPC start, end dates (year)
import excel "C:\Users\hanna\OneDrive\Documents\thesis\HIPCitreatment.xlsx" ///
, sheet("Sheet1") firstrow clear
rename CountryName countryname
save "C:\Users\hanna\OneDrive\Documents\thesis\Stata\HIPCitreatment.dta"
*************************************************************************OUTCOME*
** IMHE Human Capital Index
use "$data\IMHEHC.dta", clear
reshape wide imhe_hc_mean imhe_hc_lower imhe_hc_upper, i(countrynum countryname year) j(sex_id)
* Gender 1m 2f 3b
foreach var in imhe_hc_mean1 imhe_hc_lower1 imhe_hc_upper1 {
rename `var' `var'm
}
foreach var in imhe_hc_mean2 imhe_hc_lower2 imhe_hc_upper2 {
rename `var' `var'f
rename imhe_hc_mean3 imhe_hc_mean
}
rename imhe_hc_lower3 imhe_hc_lower
rename imhe_hc_upper3 imhe_hc_upper
// run next 3 line on base df, then clean/edit/resave = rename firstname finalname
rename imhe_hc_mean hc_mean
rename imhe_hc_lower hc_lower
rename imhe_hc_upper hc_upper
	label variable imhe_hc_mean3b "HCI mean"
	label variable imhe_hc_lower3b "HCI lower"
	label variable imhe_hc_upper3b "HCI upper"	
rename imhe_hc_mean1m hc_mean_m
rename imhe_hc_lower1m hc_lower_m
rename hc_upper_m hc_upper_m
	label variable hc_mean_m "HCI mean, M"
	label variable hc_lower_m "HCI lower, M"
	label variable hc_upper_m "HCI upper, M"
rename imhe_hc_mean2m hc_mean_f
rename imhe_hc_lower2f hc_lower_f
rename imhe_hc_upper2f hc_upper_f
	label variable imhe_hc_mean2f "HCI mean, F"
	label variable imhe_hc_lower2f "HCI lower, F"
	label variable imhe_hc_upper2f "HCI upper, F"


	
replace countryname="eSwatini" if countryname=="Swaziland"
replace countryname="São Tomé and Principe" if countryname=="Sao Tome and Principe"
replace countryname="Democratic Republic of Congo" if ///
	countryname=="Democratic Republic of the Congo" // Slovakia Russia Palestine Macedonia Kyrkgyzstan
** check for duplicates in countrynum(=/=countrycode) in "$data\IMHEHC_wide.dta"
duplicates list countrynum year
duplicates list countryname year
save "$data\IMHEHC_wide.dta", replace
*merge 1:1 countryname year using ///
*"C:\Users\hanna\OneDrive\Documents\thesis\Stata\mergedL2.dta", gen(combiimhe)
*save "$data\analysis.dta", replace
* // using which data? this doesn't make sense
*merge m:1 countryname year using ///
*"C:\Users\hanna\OneDrive\Documents\thesis\Stata\IMHEHC_wide.dta", gen(combiimhe) 
*save "$data\analysis.dta", replace
********************************************************************************
** MERGE - quick test
use "$data\income_lab_hist.dta", clear
merge 1:1 countryname year using "$data\fullset_merged_covars.dta", gen(mergefull)
save "$data\fullset_figures.dta", replace

***MERGE*** full pop - income cats + demos - for figures
use "$data\income_lab_hist.dta", clear
*drop duplicates of CZE/Czech Republic - examine manually
drop in 1717/1749
replace countrycode="RUS" if countryname=="Russia"
replace incomelab="UM" if countrycode=="RUS" & year==1991
replace incomelab="LM" if countrycode=="RUS" & year>1991
replace incomelab="UM" if countrycode=="RUS" & year>2003
replace incomelab="H" if countrycode=="RUS" & year>2011 & year<2015
replace countryname="British Virgin Islands" if countrycode=="VGB"
replace countryname="Micronesia" if countryname=="Micronesia, Fed. Sts."

merge 1:1 countryname year using "$data\fullset_demo.dta", gen(mergedemoset)
merge 1:1 countryname year using "$data\IMHEHC_wide.dta", gen(mergehc)
merge 1:1 countryname year using "$data\fullset_macroecon_merged.dta", gen(mergeecon)
save "$data\fullset_merged_allvars.dta", replace

* "$data\income_lab_hist.dta" + "$data\IMHEHC_wide.dta" +
* "$data\fullset_demo.dta" + "$data\fullset_macroecon_merged.dta"


***MERGE*** full pop, for descrips and illustrative graphs
use "$data\income_lab_hist.dta", clear
** remove duplicates
duplicates list countrycode year
**drop small economies and communist countries
drop if countryname=="Netherlands Antilles (former)"
drop if countryname=="Mayotte"
drop if countrycode=="CSK"
drop if countrycode=="SUN"
drop if countrycode=="YUG"

** fix country labels
replace countryname="Côte d'Ivoire" if countryname=="Cote d'Ivoire"
replace countryname="São Tomé and Principe" if countryname=="Sao Tome and Principe"
replace countryname="Brunei" if countryname=="Brunei Darussalam"
replace countryname="Cape Verde" if countryname=="Cabo Verde"
replace countryname="China" if countryname=="China, People's Republic of"
replace countryname="Congo" if countryname=="Congo Republic"
replace countryname="Congo" if countryname=="Congo, Rep." | countryname=="Congo, Republic of"
replace countryname="DR Congo" if countryname=="Democratic Republic of Congo" | countryname=="Democratic Republic of the Congo"
replace countryname="DR Congo" if countryname=="Congo, Dem. Rep." | countryname=="Congo, Dem. Rep. of the"
replace countryname="Czech Republic" if countryname=="Czechoslovakia (former)"
replace countryname="Egypt" if countryname=="Egypt, Arab Rep."
replace countryname="Eswatini" if countryname=="eSwatini"
replace countryname="Gambia" if countryname=="Gambia, The"
replace countryname="Iran" if countryname=="Iran, Islamic Rep."
replace countryname="North Korea" if countryname=="Korea, Dem. Rep."
replace countryname="Laos" if countryname=="Lao PDR"
replace countryname="Micronesia" if countryname=="Micronesia, Fed. States of"
replace countryname="Serbia and Montenegro" if countryname=="Serbia and Montenegro (former)"
replace countryname="St. Kitts and Nevis" if countryname=="Saint Kitts and Nevis"
replace countryname="St. Lucia" if countryname=="Saint Lucia"
replace countryname="St. Vincent and the Grenadines" if countryname=="Saint Vincent and the Grenadines"
replace countryname="South Sudan" if countryname=="South Sudan, Republic of"
replace countryname="São Tomé and Principe" if countryname=="São Tomé and Príncipe"
replace countryname="Taiwan" if countryname=="Taiwan Province of China"
replace countryname="Hong Kong" if ///
countryname=="Hong Kong SAR, China" | countryname=="Hong Kong, China"
replace countryname="Macao" if ///
countryname=="Macao SAR, China" | countryname=="Macao, China"
replace countryname="South Korea" if countryname=="Korea, Rep."
replace countryname="Kyrgyzstan" if countryname=="Kyrgyz Republic"
replace countryname="Macedonia" if countryname=="North Macedonia"
replace countryname="Palestine" if countryname=="West Bank and Gaza"
replace countryname="Russia" if countryname=="Russian Federation" | countryname=="USSR (former)"
replace countryname="Slovakia" if countryname=="Slovak Republic"
replace countryname="UAE" if countryname=="United Arab Emirates"

duplicates list countrycode countryname year incomelab
duplicates list countryname year
save "$data\fullset_base.dta", replace
save "$data\fullset_base_merged.dta", replace

use "$data\fullset_base_merged.dta", clear
** merge outcome
duplicates list countryname year
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\IMHEHC_wide.dta", gen(mergeimhe)
tab countryname if mergeimhe==2
duplicates list countrycode year
duplicates list countryname year

** merge growth
*use "$data\fullset_base_merged.dta", clear
duplicates list name year
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longGDPppp_wb.dta", gen(mergeGDP1)
tab countryname if mergeGDP1==2

merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longGDPusd_wb.dta", gen(mergeGDP2)
tab countryname if mergeGDP2==2

merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longGDPcapppp_wb.dta", gen(mergeGDP3)
merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longGDPcap_wb.dta", gen(mergeGDP4)
drop if mergeGDP3==2 | mergeGDP4==2
duplicates list countrycode year
duplicates list countryname year

** merge outcome covars (gini, urban, trade, democracy index)
merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\GINI.dta", gen(mergegini1)
merge m:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\urbanpop.dta", gen(mergeurban)
merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\trade.dta", gen(mergetrade)
drop if mergegini1==2 | mergeurban==2 | mergetrade==2

merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\DEMOCRACYINDEX.dta", gen(mergedemo)
drop if mergedemo==2

** merge spending
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longdebtposition.dta", gen(mergedebt1)
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longspending.dta", gen(mergespend1)
drop if mergedebt1==2 | mergespend1==2

** these have countryname year duplicates:
*merge 1:1 countryname year using ///
*"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longspendingedu.dta", gen(mergespend2)
*merge 1:1 countryname year using ///
*"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longspendingeduGDP.dta", gen(mergespend3)

** merge edu spending covars (taxes, elderly pop, pop density)
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longtaxes.dta", gen(mergetax1)
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longpop65.dta", gen(mergecontrol1)
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longpopdensity.dta", gen(mergecontrol2)

** save merged data into base file
save "$data\LIC_base_merged.dta", replace

********************************************************************************
***MERGE*** - L, LM only, for analysis and modelling
*use "$data\*mergedL2.dta", clear // previous merged file
*duplicates list countrycode countryname year debt income
*duplicates list countrycode countryname year debt income, force

** start with income classification list
use "$data\LIC_base.dta", clear // countryname countrycode year incomelab
duplicates list countrycode year
** remove duplicates
*replace countryname="Côte d'Ivoire" if countryname=="Cote d'Ivoire"
*replace countrycode="Democratic Republic of Congo" if countrycode=="Democratic Republic of the Congo"
*replace countryname="São Tomé and Principe" if countryname=="Sao Tome and Principe"

**drop small economies and communist countries
*drop if countryname=="Netherlands Antilles (former)"
*drop if countryname=="Mayotte"
*drop if countrycode=="CSK"
*drop if countrycode=="SUN"
*drop if countrycode=="YUG"

** fix country labels
replace countryname="Brunei" if countryname=="Brunei Darussalam"
replace countryname="Cape Verde" if countryname=="Cabo Verde"
replace countryname="China" if countryname=="China, People's Republic of"
replace countryname="Congo Republic" if countryname=="Congo, Rep."
replace countryname="Democratic Republic of Congo" if countryname=="Congo, Dem. Rep."
replace countryname="Czech Republic" if countryname=="Czechoslovakia (former)"
replace countryname="Egypt" if countryname=="Egypt, Arab Rep."
replace countryname="Gambia" if countryname=="Gambia, The"
replace countryname="Iran, Islamic Rep." if countryname=="Iran"
replace countryname="North Korea" if countryname=="Korea, Dem. Rep."
replace countryname="Laos" if countryname=="Lao PDR"
replace countryname="Micronesia" if countryname=="Micronesia, Fed. States of"
replace countryname="Serbia and Montenegro" if ///
countryname=="Serbia and Montenegro (former)"
replace countryname="St. Kitts and Nevis" if countryname=="Saint Kitts and Nevis"
replace countryname="St. Lucia" if countryname=="Saint Lucia"
replace countryname="St. Vincent and the Grenadines" if countryname=="Saint Vincent and the Grenadines"
replace countryname="South Sudan" if countryname=="South Sudan, Republic of"
replace countryname="São Tomé and Principe" if countryname=="São Tomé and Príncipe"
replace countryname="Taiwan" if countryname=="Taiwan Province of China"
replace countryname="UAE" if countryname==" United Arab Emirates" | countryname=="United Arab Emirates"
replace countryname="Hong Kong" if ///
countryname=="Hong Kong SAR, China" | countryname=="Hong Kong, China"
replace countryname="Macao" if ///
countryname=="Macao SAR, China" | countryname=="Macao, China"
replace countryname="South Korea" if countryname=="Korea, Rep."

duplicates list countrycode countryname year incomelab
save "$data\LIC_base.dta", replace
save "$data\LIC_base_merged.dta", replace

** merge outcome
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\IMHEHC_wide.dta", gen(combiimhe)
drop if combiimhe==2
duplicates list countrycode year
duplicates list countryname year

** merge growth
*use "$data\LIC_base_merged.dta", clear
merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longGDPppp_wb.dta", gen(mergeGDP1)
merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longGDPusd_wb.dta", gen(mergeGDP2)
merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longGDPcapppp_wb.dta", gen(mergeGDP3)
merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longGDPcap_wb.dta", gen(mergeGDP4)
drop if mergeGDP1==2 | mergeGDP2==2 | mergeGDP3==2 | mergeGDP4==2
duplicates list countrycode year
duplicates list countryname year

** merge outcome covars (gini, urban, trade, democracy index)
merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\GINI.dta", gen(mergegini1)
merge m:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\urbanpop.dta", gen(mergeurban)
merge 1:1 countrycode year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\trade.dta", gen(mergetrade)
drop if mergegini1==2 | mergeurban==2 | mergetrade==2

merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\DEMOCRACYINDEX.dta", gen(mergedemo)
drop if mergedemo==2

** merge spending
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longdebtposition.dta", gen(mergedebt1)
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longspending.dta", gen(mergespend1)
drop if mergedebt1==2 | mergespend1==2

** these have countryname year duplicates:
*merge 1:1 countryname year using ///
*"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longspendingedu.dta", gen(mergespend2)
*merge 1:1 countryname year using ///
*"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longspendingeduGDP.dta", gen(mergespend3)

** merge edu spending covars (taxes, elderly pop, pop density)
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longtaxes.dta", gen(mergetax1)
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longpop65.dta", gen(mergecontrol1)
merge 1:1 countryname year using ///
"C:\Users\hanna\OneDrive\Documents\thesis\Stata\longpopdensity.dta", gen(mergecontrol2)

** save merged data into base file
save "$data\LIC_base_merged.dta", replace

********************************************************************************
***SUBSET DATA***


** KEEP LICs
** income==L,LM,LM* / debt==moderate & severe / drop if income>3

*save "C:\Users\hanna\OneDrive\Documents\thesis\Stata\combiLIC.dta", replace
*use "$data\COMBImerge.dta", replace //I forget what COMBImerge is made from...it's not this .dta
use "$data\analysis.dta", clear
drop if year<1980
drop if year>2020
save "$data\mergedL2yrs19802020.dta" 
*or: save "$data\analysis.dta", replace

preserve
drop merge*
*keep if income==3 | income==4 | income==5 | debt==8 | debt==4
drop if income==2 | income==6 // income==1 is missing
drop if debt==1 | debt==2 | debt==7
save "$data\analysisLIC.dta", replace

* either of the following 2, to keep only LICs
*merge m:1 countryname year using "$data\income_debt_encoded.dta", keepusing(debt income)

gen income = 3 if ///
countryname=="Afghanistan" | countryname=="Bangladesh" | countryname=="Benin" ///
| countryname=="Burkina Faso" | countryname=="Congo Republic" ///
| countryname=="Burundi" | countryname=="Central African Republic" ///
| countryname=="Chad" | countryname=="Comoros" | countryname=="Côte d'Ivoire" ///
| countryname=="Democratic Republic of Congo" | countryname=="Eritrea" ///
| countryname=="Ghana" | countryname=="Guinea" | countryname=="Myanmar" ///
| countryname=="Ethiopia" | countryname=="Haiti" | countryname=="Honduras" ///
| countryname=="Guinea-Bissau" | countryname=="Mozambique" ///
| countryname=="Kenya" | countryname=="Kyrgyz Republic" ///
| countryname=="Lesotho" | countryname=="Liberia" | countryname=="Madagascar" ///
| countryname=="Mali" | countryname=="Malawi" | countryname=="Mauritania" ///
| countryname=="Nepal" | countryname=="Niger" | countryname=="Nigeria" ///
| countryname=="Pakistan" | countryname=="Papua New Guinea" ///
| countryname=="Rwanda" | countryname=="Senegal" | countryname=="Sierra Leone" ///
| countryname=="Somalia" | countryname=="South Sudan" | countryname=="Sudan" ///
| countryname=="Tajikistan" | countryname=="Tanzania" | countryname=="Gambia" ///
| countryname=="Togo" | countryname=="Uganda" | countryname=="Yemen" ///
| countryname=="Zambia" | countryname=="Zimbabwe" 
drop if income !=3

restore

****************************************************************************MISC*
** treatment group dummy var:
gen HIPC = 0
replace HIPC = 1 if countryname== "Afghanistan" | countryname== "Benin" | countryname== "Bolivia" ///
	| countryname== "Burkina Faso" | countryname== "Burundi" | countryname== "Cameroon" ///
	| countryname== "Central African Republic" | countryname== "Chad" | countryname== "Congo" ///
	| countryname== "DR Congo" | countryname== "Comoros" | countryname== "Côte d'Ivoire" ///
	| countryname== "Ethiopia" | countryname== "Gambia" | countryname== "Ghana" | countryname== "Guinea" ///
	| countryname== "Guinea-Bissau" | countryname== "Guyana" | countryname== "Haiti" ///
	| countryname== "Honduras" | countryname== "Liberia" | countryname== "Madagascar" ///
	| countryname== "Mali" | countryname== "Mauritania" | countryname== "Malawi" ///
	| countryname== "Mozambique" | countryname== "Nicaragua" | countryname== "Niger" ///
	| countryname== "Rwanda" | countryname== "São Tomé and Principe" | countryname== "Senegal" ///
	| countryname== "Sierra Leone" | countryname== "Togo" | countryname== "Uganda" | countryname== "Zambia" 

gen HIPCtest = 0
foreach country in "Afghanistan" "Benin" "Bolivia" "Burkina Faso" "Burundi" "Cameroon" ///
	"Central African Republic" "Chad" "Congo" "DR Congo" "Comoros" "Côte d'Ivoire" ///
	"Ethiopia" "Gambia" "Ghana" "Guinea" "Guinea-Bissau" "Guyana" "Haiti" "Honduras" ///
	"Liberia" "Madagascar" "Mali" "Mauritania" "Malawi" "Mozambique" "Nicaragua" "Niger" ///
	"Rwanda" "São Tomé and Principe" "Senegal" "Sierra Leone" "Togo" "Uganda" "Zambia" {
replace HIPCtest = 1 if countryname=="`country'"
}
label variable HIPCtest "HIPC during study period"

** time of treatment var
gen HIPCitest = 1
foreach country in "Bolivia" "Honduras" "Mauritania" "Mozambique" "Senegal" "Uganda" {
	replace HIPCitest = 2 if countryname=="`country'" & year>1999
}
foreach country in "Benin" "Burkina Faso" "Cameroon" "Chad" "Gambia" "Guinea" "Guinea-Bissau" "Guyana" ///
 "Madagascar" "Malawi" "Mali" "Nicaragua" "Niger" "Rwanda" "São Tomé and Principe" "Zambia" {
	replace HIPCitest = 2 if countryname=="`country'" & year>2000
}
replace HIPCitest = 2 if countryname== "Ghana" & year>2001 | countryname== "Sierra Leone" & year>2001 ///
	| countryname== "Ethiopia" & year>2001 | countryname== "Congo" & year>2003 ///
	| countryname== "Burundi" & year>2005 | countryname== "DR Congo" & year>2005 ///
	| countryname== "Haiti" & year>2006 | countryname== "Liberia" & year>2007 ///
	| countryname== "Afghanistan" & year>2007 | countryname== "Central African Republic" & year>2007 ///
	| countryname== "Côte d'Ivoire" & year>2008 | countryname== "Togo" & year>2008 | countryname== "Comoros" & year>2010

foreach country in "Uganda" "Bolivia" {
	replace HIPCitest = 3 if countryname=="`country'" & year>2000 
}
foreach country in "Mauritania" "Burkina Faso" "Mozambique" {
	replace HIPCitest = 3 if countryname=="`country'" & year>2001
}
foreach country in "Ethiopia" "Malawi" "Nicaragua" "Niger" "Senegal" "Guyana" {
	replace HIPCitest = 3 if countryname=="`country'" & year>2003
}
foreach country in "Rwanda" "Zambia" "Ghana" "Honduras" "Madagascar" {
	replace HIPCitest = 3 if countryname=="`country'" & year>2004 
}
replace HIPCitest = 3 if countryname== "Benin" & year>2002 | countryname== "Mali" & year>2002 ///
	| countryname== "Cameroon" & year>2005 | countryname== "Gambia, The" & year>2007 ///
	| countryname== "São Tomé and Principe" & year>2006 | countryname== "Sierra Leone" & year>2006 ///
	| countryname== "Burundi" & year>2008 | countryname== "Central African Republic" & year>2008 ///
	| countryname== "Haiti" & year>2009 | countryname== "Liberia" & year>2009 ///
	| countryname== "Afghanistan" & year>2009 | countryname== "Congo, Dem. Rep." & year>2009 ///
	| countryname== "Guinea-Bissau" & year>2010 | countryname== "Togo" & year>2010 ///
	| countryname== "Congo, Rep." & year>2010 | countryname== "Côte d'Ivoire" & year>2011 ///
	| countryname== "Comoros" & year>2012 | countryname== "Chad" & year>2014

label variable HIPCitest "HIPC Initiative Treatment 1-3"
*label define lbHIPCi 1"No treatment" 2"Decision point" 3"Completion point"
label values HIPCitest lbHIPCi
save "C:\Users\hanna\Onedrive\Documents\thesis\Stata\fullset_figures.dta", replace
*to add more detail (mo, qt), merge full dataset HIPCitreatment.dta:
*merge m:1 countryname using "C:\Users\hanna\OneDrive\Documents\thesis\Stata\HIPCitreatment.dta"

***********************************************************************PLOT PREP*
**violin plots
	*ssc install vioplot, replace
gen yeardum = year - 1989
	label variable yeardum "Dummy year, 1990=1" // or should 1990 be year 0?
** democracy score 0-10 must be put on 100 scale:
gen demoperc = demoscore*10
	label variable demoperc "Democracy score 0-100" 
** gdp pc (0-7000) and trade open (0-350) - put on similar scale
gen gdppcusdperc = gdppcusd / 100
	label variable gdppcusdperc "GDP per capita, in 100s USD"
gen openperc = open / 3.5
	label variable openperc "Trade openness, % GDP, scaled 0-100"
** gdp usd (very large) and gdp pc (0-7000) - put on similar scale
gen gdpusdscaled = gdpusd / 5000000000
	label var gdpusdscaled "GDP, in 1000s USD"
gen gdpusdbil = gdpusd / 10000000000
	label var gdpusdscaled "GDP, in 10Bs USD"
gen gdppcusdscaled = gdppcusd / 7
	label variable gdppcusdscaled "GDP per capita, in 1000s USD"

** line plots (means)
** year/incomelab mean vars:
foreach var in imhe_hc_mean1m imhe_hc_mean2f imhe_hc_mean3b ///
	imhe_hc_lower1m imhe_hc_lower2f imhe_hc_lower3b imhe_hc_upper1m imhe_hc_upper2f imhe_hc_upper3b ///
	gini urban open openperc demoscore demoperc gdpusd gdppcusd gdppcusdperc debtpos spending {
	bysort year incomelab, rc0: egen mean`var' = mean(`var')
}
gen treat1 = 0
replace treat1 = 1 if HIPCi==2
	label variable treat1 "HIPC Initiative, decision point"
gen treat2 = 0
replace treat2 = 1 if HIPCi==3
	label variable treat2 "HIPC Initiative, completion point"
gen treat3 = .
replace treat3 = 0 if HIPCi==2
replace treat3 = 1 if HIPCi==3
	label variable treat2 "HIPC Initiative, 0=decision, 1=completion"
save "$data\analysis.dta", replace

**xt setting for xt reg - run right before xt reg, then use xtset, clear to clear
encode incomelab, gen(incomegroup)
encode countryname, gen(countrypanel)
xtset countrypanel year, yearly //yearly 1987-2019, with gaps, delta=1yr
save "$data\analysis_xt.dta", replace
