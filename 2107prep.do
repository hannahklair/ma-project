** Thesis analysis - Data pull and prep/tidy
** Contents: START > IMPORT > TIDY > TRANSFORM
** VISUALIZE & MODEL in file "analysis_full_0707.ado"
** Title: Thesis project data prep
** 0. Setup
** 1. Import data
** 2. Tidy & transform data
** 3. Merge
************
***NOTES****
**set working directory ("/Users/hanna/OneDrive/Documents/projects"); files use subjective file locations throughout
** save var & val labels as local macros
*** IDs - countryname countrycode, year
*files wide by year (y1234), long by indicator (indicatorname indicatorcode)
*unless marked "long"
*** L2 CONTROLS - EDU OUTCOME***
** urban, gnp, gini, trade open, democracy, corruption/inst quality, transparency
*** OMITTED CONTROLS - EDU SPENDING***
** growth, debt, inflation, unemployment, tax revenue, deficit, central gov grants
** government spending (total, edu), effectiveness of spending

** TO DO: add/update dependent file to clean country names

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
*******************************
****START - BASE POPULATION****
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
***************************
****IMPORT - PREDICTORS****
************************************************************ED INEQUALITY CONTROLS*
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
drop if year<1987
use "$data\GINI.dta", clear
tab countryname if countrycode=="SWZ" | countrycode=="MKD" | countrycode=="LAO" | countrycode=="PRK"
replace countryname="Laos" if countryname=="Lao"
replace countryname="Macedonia" if countryname=="Macedonia, FYR"
replace countryname="Eswatini" if countryname=="Swaziland"
drop if year<1987
save "$data\samplegini.dta", replace

** URBAN - % population urban (urbanization), (source: WDI from WB, updated 19-03-21)
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
*tab countryname if countrycode=="SWZ" | countrycode=="MKD" | countrycode=="LAO" | countrycode=="PRK"
*replace countryname="North Korea" if countrycode=="PRK"
*duplicates tag countryname year, gen(dup)
*duplicates list countryname countrycode year
*duplicates drop countryname countrycode year if countryname=="Eswatini" & dup==1, force
*duplicates drop countryname countrycode year if countryname=="Macedonia" & dup==1, force
*duplicates drop countryname countrycode year if countryname=="North Korea" & dup==1, force
*drop dup
save "$data\urbanpop.dta", replace
drop if countryname=="Advanced economies" | countryname=="Advanced G-20" | countryname=="Central Europe and the Baltics" | countryname=="Early-demographic dividend" /// | 
	| countryname=="East Asia & Pacific" | countryname=="East Asia & Pacific (IDA & IBRD countries)" | countryname=="East Asia & Pacific (excluding high income)" | countryname=="Emerging G-20" ///
	| countryname=="Emerging Market and Middle-Income Economies" | countryname=="Emerging Market and Middle-Income Asia" ///
	| countryname=="Emerging Market and Middle-Income Europe" | countryname=="Emerging Market and Middle-Income Latin America" ///
	| countryname=="Emerging Market and Middle-Income Europe" | countryname=="Emerging Market and Middle-Income Middle East" ///
	| countryname=="Euro area" | countryname=="European Union" | countryname=="Late-demographic dividend" | countryname=="Europe & Central Asia" | countryname=="Europe & Central Asia (IDA & IBRD countries)" ///
	| countryname=="Europe & Central Asia (excluding high income)" | countryname=="Latin America & Caribbean" | countryname=="Latin America & the Caribbean (IDA & IBRD countries)" ///
	| countryname=="Latin America & Caribbean (excluding high income)" | countryname=="Low income" | countryname=="Low & middle income" | countryname=="Low-Income Developing Asia" ///
	| countryname=="Low-Income Developing Countries" | countryname=="Low-Income Developing Latin America" | countryname=="Low-Income Developing Oil Producers" | countryname=="Low-Income Developing Others" ///
	| countryname=="Low-Income Developing Sub-Saharan Africa" | countryname=="Lower middle income" | countryname=="Major advanced economies" | countryname=="Middle East & North Africa Middle income" ///
	| countryname=="Middle East & North Africa (IDA & IBRD countries)" | countryname=="Middle East & North Africa (excluding high income)" ///
	| countryname=="Not classified" | countryname=="OECD members" | countryname=="Pacific island small states" | countryname=="Small states" | countryname=="Other small states" | countryname=="South Asia" ///
	| countryname=="South Asia (IDA & IBRD)" | countryname=="Post-demographic dividend" | countryname=="Pre-demographic dividend" ///
	| countryname=="Sub-Saharan Africa" | countryname=="Sub-Saharan Africa (IDA & IBRD countries)" | countryname=="Sub-Saharan Africa (excluding high income)" ///
	| countryname=="Upper middle income" | countryname=="World" | countryname=="©IMF, 2021" | countryname=="Arab World" | countryname=="Caribbean small states" | countryname=="Emerging and Middle-Income Asia" ///
	| countryname=="Emerging and Middle-Income Europe" | countryname=="Emerging and Middle-Income Latin America" | countryname=="Emerging and Middle-Income Middle East" | countryname=="Fragile and conflict affected situations" ///
	| countryname=="Heavily indebted poor countries (HIPC)" | countryname=="High income" | countryname=="IBRD only" | countryname=="IDA & IBRD only" | countryname=="IDA blend" ///
	| countryname=="IDA only" | countryname=="IDA total" | countryname=="Least developed countries: UN classification" | countryname=="Major advanced economies (G7)" | countryname=="Middle East & North Africa"
drop if year<1987
replace countryname="Curaçao" if countryname=="Curacao"
save "$data\sampleurban.dta", replace

*** POP DENSITY
import excel "$path\Data Archive\POPDENS.xlsx", sheet("Data") firstrow
rename CountryName countryname
rename CountryCode countrycode
rename IndicatorName indicator
foreach v of varlist D-AH {
   local x : variable label `v'
   rename `v' y`x'
}
drop indicator
reshape long y, i(countryname countrycode) j(year)
rename y dens
label var dens "Population density (people per sq. km. land area)"
save "$data\POPDENS.dta", replace

*** TRADE
import excel "$data\TRADEOPEN.xls", sheet("Data") firstrow
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
replace countryname="North Korea" if countrycode=="PRK"
drop if countryname=="Holy See"
drop if year<1987
replace countryname="Curaçao" if countryname=="Curacao"
drop if countryname=="IDA & IBRD total" | countryname=="Middle income" | countryname=="North America"
save "$data\sampletrade.dta", replace

** DEMOCRACY
use "C:\Users\hanna\OneDrive\Documents\thesis\V-Dem-CY-Core-v11.1.dta", clear
rename country_name countryname
rename country_text_id countrycode
rename country_id countrynum
label variable countryname "Country Name"
replace countryname="Myanmar" if countryname=="Burma/Myanmar"
replace countryname="DR Congo" if countryname=="Democratic Republic of the Congo"
replace countryname="Congo" if countryname=="Republic of the Congo"
replace countryname="Côte d'Ivoire" if countryname=="Côte d’Ivoire" | countryname=="Ivory Coast"
replace countryname="Macedonia" if countryname=="North Macedonia"
replace countryname="São Tomé and Principe" if countryname=="Sao Tome and Principe"
replace countryname="UAE" if countryname=="United Arab Emirates"
drop if countryname=="German Democratic Republic"
tab year if countryname=="Palestine/Gaza"
tab year if countryname=="Palestine/West Bank"
replace countryname="Palestine" if countryname=="Palestine/West Bank"
drop if countryname=="Palestine/Gaza"
drop if countryname=="Somaliland"
drop if countryname=="South Yemen"
replace countryname="Gambia" if countryname=="The Gambia"
replace countryname="United States" if countryname=="United States of America"
drop if countryname=="Zanzibar"
*replace countryname="Cape Verde" if countryname=="Cabo Verde"
*replace countryname="Bosnia and Herzegovina" if countryname=="Bosnia and Hercegovina"
*replace countryname="Saudi Arabia" if countryname=="Saudi"
*replace countryname="Timor-Leste" if countryname=="Timor Leste"
*replace countryname="Saudi Arabia" if countryname=="Saudia Arabia"
drop if year<1987 
save "$data\sampledemocracy.dta", replace
**********************************************************************************MERGE*
use "$data\incomelab.dta", clear
replace countryname="Brunei" if countryname=="Brunei Darussalam"
replace countryname="Cape Verde" if countryname=="Cabo Verde"
replace countryname="Russia" if countryname=="Russian Federation"
replace countryname="UAE" if countryname=="United Arab Emirates"
replace countryname="Virgin Islands" if countryname=="Virgin Islands (U.S.)"
replace countryname="Micronesia, Fed. Sts." if countryname=="Micronesia"
duplicates list countryname year
duplicates list countrycode year
merge 1:1 countryname year using "$data\sampleurban.dta", gen(mergeurban)
merge 1:1 countryname year using "$data\sampletrade.dta", gen(mergetrade)
merge 1:1 countryname year using "$data\samplegini.dta", gen(mergegini)
merge 1:1 countryname year using "$data\sampledemocracy.dta", gen(mergedemo) ///
	keepus(countrycode codingstart codingend ///
	v2x_polyarchy v2x_polyarchy_sd v2x_libdem v2x_libdem_sd v2x_partipdem v2x_partipdem_sd ///
	v2x_delibdem v2x_delibdem_sd v2x_egaldem v2x_egaldem_sd v2x_api v2x_api_sd v2x_mpi v2x_mpi_sd)
rename v2x_polyarchy polyarchy
rename v2x_polyarchy_sd polyarchy_sd
label var polyarchy "Electoral democracy index"
rename v2x_libdem libdem
rename v2x_libdem_sd libdem_sd
label var libdem "Liberal democracy index"
rename v2x_partipdem partipdem
rename v2x_partipdem_sd partipdem_sd
label var partipdem "Participatory democracy index"
rename v2x_delibdem delibdem
rename v2x_delibdem_sd delibdem_sd
label var delibdem "Deliberative democracy index"
rename v2x_egaldem egaldem
rename v2x_egaldem_sd egaldem_sd
label var egaldem "Egalitarian democracy index"
rename v2x_api api
rename v2x_api_sd api_sd
label var api "Additive polyarchy index"
rename v2x_mpi mpi
rename v2x_mpi_sd mpi_sd
label var mpi "Multiplicative polyarchy index"
tab countryname mergedemo
merge 1:1 countryname year using "$data\POPDENS.dta", gen(mergedens)
drop if mergedens==2
bysort year: egen pc75 = pctile(dens), p(75)
gen pcdens = 0
replace pcdens=1 if dens>=pc75
label var pcdens "Population Density >/= 75th percentile"
save "$data\fullset_demo.dta", replace

**********************************************************************************ECON*
** GDP GROWTH (% ANNUAL)
import excel "$path\Data Archive\GDPGROWTH.xls", sheet("Data") firstrow clear
rename CountryName countryname
rename CountryCode countrycode
foreach v of varlist D-BK {
   local x : variable label `v'
   rename `v' y`x'
}
save "$data\GDPgrowth.dta", replace
reshape long y, i(countryname countrycode) j(year)
rename y gdpgrowth
label var gdpgrowth "GDP growth (annual %)"
drop IndicatorName
save "$data\longGDPgrowth.dta", replace
drop if year<1987
drop if countryname=="Africa Eastern and Southern" | countryname=="Africa Western and Central"
replace countryname="Brunei" if countryname=="Brunei Darussalam"
replace countryname="Cape Verde" if countryname=="Cabo Verde"
replace countryname="DR Congo" if countryname=="Congo, Dem. Rep."
replace countryname="Congo" if countryname=="Congo, Rep."
replace countryname="Côte d'Ivoire" if countryname=="Côte d’Ivoire" | countryname=="Ivory Coast" | countryname=="Cote d'Ivoire"
replace countryname="Egypt" if countryname=="Egypt, Arab Rep."
replace countryname="Gambia" if countryname=="Gambia, The"
replace countryname="Hong Kong" if countryname=="Hong Kong SAR, China"
replace countryname="Iran" if countryname=="Iran, Islamic Rep."
replace countryname="North Korea" if countryname=="Korea, Dem. People's Rep."
replace countryname="South Korea" if countryname=="Korea, Rep."
replace countryname="Macedonia" if countryname=="North Macedonia"
replace countryname="São Tomé and Principe" if countryname=="Sao Tome and Principe"
replace countryname="Syria" if countryname=="Syrian Arab Republic"
replace countryname="UAE" if countryname=="United Arab Emirates"
replace countryname="Venezuela" if countryname=="Venezuela, RB"
replace countryname="Virgin Islands" if countryname=="Virgin Islands (U.S.)"
replace countryname="Yemen" if countryname=="Yemen, Rep."
replace countryname="Bahamas" if countryname=="Bahamas, The"
replace countryname="Kyrgyzstan" if countryname=="Kyrgyz Republic"
replace countryname="Laos" if countryname=="Lao PDR"
replace countryname="Macao" if countryname=="Macao SAR, China"
replace countryname="Palestine" if countryname=="West Bank and Gaza"
replace countryname="Slovakia" if countryname=="Slovak Republic"
replace countryname="Russia" if countryname=="Russian Federation"

** GDP PPP "GDP, PPP (current international $)" gdpppp
import delimited C:\Users\hanna\OneDrive\Documents\thesis\GDP_PPP.csv, varnames(1) clear
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
drop if countryname=="Advanced economies" | countryname=="Advanced G-20" | countryname=="Central Europe and the Baltics" | countryname=="Early-demographic dividend" /// | 
	| countryname=="East Asia & Pacific" | countryname=="East Asia & Pacific (IDA & IBRD countries)" | countryname=="East Asia & Pacific (excluding high income)" | countryname=="Emerging G-20" ///
	| countryname=="Emerging Market and Middle-Income Economies" | countryname=="Emerging Market and Middle-Income Asia" | countryname=="Middle income" | countryname=="North America" ///
	| countryname=="Emerging Market and Middle-Income Europe" | countryname=="Emerging Market and Middle-Income Latin America" ///
	| countryname=="Emerging Market and Middle-Income Europe" | countryname=="Emerging Market and Middle-Income Middle East" ///
	| countryname=="Euro area" | countryname=="European Union" | countryname=="Late-demographic dividend" | countryname=="Europe & Central Asia" | countryname=="Europe & Central Asia (IDA & IBRD countries)" ///
	| countryname=="Europe & Central Asia (excluding high income)" | countryname=="Latin America & Caribbean" | countryname=="Latin America & the Caribbean (IDA & IBRD countries)" ///
	| countryname=="Latin America & Caribbean (excluding high income)" | countryname=="Low income" | countryname=="Low & middle income" | countryname=="Low-Income Developing Asia" ///
	| countryname=="Low-Income Developing Countries" | countryname=="Low-Income Developing Latin America" | countryname=="Low-Income Developing Oil Producers" | countryname=="Low-Income Developing Others" ///
	| countryname=="Low-Income Developing Sub-Saharan Africa" | countryname=="Lower middle income" | countryname=="Major advanced economies" | countryname=="Middle East & North Africa Middle income" ///
	| countryname=="Middle East & North Africa (IDA & IBRD countries)" | countryname=="Middle East & North Africa (excluding high income)" ///
	| countryname=="Not classified" | countryname=="OECD members" | countryname=="Pacific island small states" | countryname=="Small states" | countryname=="Other small states" | countryname=="South Asia" ///
	| countryname=="South Asia (IDA & IBRD)" | countryname=="Post-demographic dividend" | countryname=="Pre-demographic dividend" | countryname=="IDA & IBRD total" ///
	| countryname=="Sub-Saharan Africa" | countryname=="Sub-Saharan Africa (IDA & IBRD countries)" | countryname=="Sub-Saharan Africa (excluding high income)" ///
	| countryname=="Upper middle income" | countryname=="World" | countryname=="©IMF, 2021" | countryname=="Arab World" | countryname=="Caribbean small states" | countryname=="Emerging and Middle-Income Asia" ///
	| countryname=="Emerging and Middle-Income Europe" | countryname=="Emerging and Middle-Income Latin America" | countryname=="Emerging and Middle-Income Middle East" | countryname=="Fragile and conflict affected situations" ///
	| countryname=="Heavily indebted poor countries (HIPC)" | countryname=="High income" | countryname=="IBRD only" | countryname=="IDA & IBRD only" | countryname=="IDA blend" ///
	| countryname=="IDA only" | countryname=="IDA total" | countryname=="Least developed countries: UN classification" | countryname=="Major advanced economies (G7)" | countryname=="Middle East & North Africa"
save "$data\sampleGDPppp.dta", replace

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
use "$data\GDPusd_wb.dta", clear
	drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y gdpusd
	label variable gdpusd "GDP (current US$)"
	label variable year Year
save "$data\longGDPusd_wb.dta", replace
drop if countryname=="Advanced economies" | countryname=="Advanced G-20" | countryname=="Central Europe and the Baltics" | countryname=="Early-demographic dividend" /// | 
	| countryname=="East Asia & Pacific" | countryname=="East Asia & Pacific (IDA & IBRD countries)" | countryname=="East Asia & Pacific (excluding high income)" | countryname=="Emerging G-20" ///
	| countryname=="Emerging Market and Middle-Income Economies" | countryname=="Emerging Market and Middle-Income Asia" | countryname=="Middle income" | countryname=="North America" ///
	| countryname=="Emerging Market and Middle-Income Europe" | countryname=="Emerging Market and Middle-Income Latin America" | countryname=="Emerging and Middle-Income Middle East and North Africa and Pakistan" ///
	| countryname=="Emerging Market and Middle-Income Europe" | countryname=="Emerging Market and Middle-Income Middle East" ///
	| countryname=="Euro area" | countryname=="European Union" | countryname=="Late-demographic dividend" | countryname=="Europe & Central Asia" | countryname=="Europe & Central Asia (IDA & IBRD countries)" ///
	| countryname=="Europe & Central Asia (excluding high income)" | countryname=="Latin America & Caribbean" | countryname=="Latin America & the Caribbean (IDA & IBRD countries)" ///
	| countryname=="Latin America & Caribbean (excluding high income)" | countryname=="Low income" | countryname=="Low & middle income" | countryname=="Low-Income Developing Asia" ///
	| countryname=="Low-Income Developing Countries" | countryname=="Low-Income Developing Latin America" | countryname=="Low-Income Developing Oil Producers" | countryname=="Low-Income Developing Others" ///
	| countryname=="Low-Income Developing Sub-Saharan Africa" | countryname=="Lower middle income" | countryname=="Major advanced economies" | countryname=="Middle East & North Africa Middle income" ///
	| countryname=="Middle East & North Africa (IDA & IBRD countries)" | countryname=="Middle East & North Africa (excluding high income)" ///
	| countryname=="Not classified" | countryname=="OECD members" | countryname=="Pacific island small states" | countryname=="Small states" | countryname=="Other small states" | countryname=="South Asia" ///
	| countryname=="South Asia (IDA & IBRD)" | countryname=="Post-demographic dividend" | countryname=="Pre-demographic dividend" | countryname=="IDA & IBRD total" ///
	| countryname=="Sub-Saharan Africa" | countryname=="Sub-Saharan Africa (IDA & IBRD countries)" | countryname=="Sub-Saharan Africa (excluding high income)" ///
	| countryname=="Upper middle income" | countryname=="World" | countryname=="©IMF, 2021" | countryname=="Arab World" | countryname=="Caribbean small states" | countryname=="Emerging and Middle-Income Asia" ///
	| countryname=="Emerging and Middle-Income Europe" | countryname=="Emerging and Middle-Income Latin America" | countryname=="Emerging and Middle-Income Middle East" | countryname=="Fragile and conflict affected situations" ///
	| countryname=="Heavily indebted poor countries (HIPC)" | countryname=="High income" | countryname=="IBRD only" | countryname=="IDA & IBRD only" | countryname=="IDA blend" ///
	| countryname=="IDA only" | countryname=="IDA total" | countryname=="Least developed countries: UN classification" | countryname=="Major advanced economies (G7)" | countryname=="Middle East & North Africa"
drop if year<1987
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
save "$data\sampleGDPusd.dta", replace

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
drop if year<1987
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
save "$data\sampleGDPcapppp.dta", replace

** GDP pc USD - "GDP per capita (current US$)" gdppcusd, source: https://data.worldbank.org/indicator/NY.GDP.PCAP.CD
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
use "$data\GDPcap_wb.dta", clear
drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y gdppcusd
	label variable gdppcusd "GDP per capita (current US$)"
	label variable countryname "Country Name"
	label variable year Year
save "$data\longGDPcap_wb.dta", replace
drop if year<1987
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
save "$data\sampleGDPcapusd.dta", replace
**********************************************************************************MERGE*
use "$data\sampleGDPppp.dta", clear
merge 1:1 countryname year using "$data\sampleGDPusd.dta", gen(mergeGDPU)
merge 1:1 countryname year using "$data\sampleGDPcapppp.dta", gen(mergeGDPP)
merge 1:1 countryname year using "$data\sampleGDPcapusd.dta", gen(mergeGDPUPC)
replace countryname="Micronesia" if countryname=="Micronesia, Fed. Sts."
merge 1:1 countryname year using "$data\sampleGDPgrowth.dta", gen(mergegrowth)
save "$data\sampleGDP_merged.dta", replace
************************************************************************SPENDING*
** GOVERNMENT SPENDING TOTAL (source: IMF based on Mauro et al. (2015))
import delimited using "$path\Data Archive\expenditure.csv", varnames(1) clear // Total govt expenditure
rename entity countryname
	label variable countryname "Country Name"
replace countryname="Eswatini" if countryname=="Swaziland"
save "$data\longspending_historic.dta", replace
drop if year<1950
drop if year<1987
save "$data\longspending.dta", replace

** EDU SPENDING - "Govt expenditure on education (% total)" edspendperc
import delimited using "$path\Data Archive\eduexpenditure.csv", varnames(1) clear // edu/total spending
	*rename indicatorname indicatornameGDPPCUSD
	*rename indicatorcode indicatorcodeGDPPCUSD
rename ïcountryname countryname
	label variable countryname "Country Name"
foreach v of varlist v* {
   local x : variable label `v'
   rename `v' y`x'
}
save "$path\Data Archive\spendingedu.dta", replace
use "$path\Data Archive\spendingedu.dta", clear
	drop indicatorname indicatorcode
reshape long y, i(countryname countrycode) j(year)
rename y edspendperc
	label variable edspendperc "Govt expenditure on education (% total)"
	label variable year Year
replace countryname="Micronesia" if countryname=="Micronesia, Fed. Sts."
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
label variable spending "Total government spending"

save "$data\longspendingedu.dta", replace

** EDU SPENDING - "Govt expenditure on education (% GDP)" edspendingpercGDP
import delimited C:\Users\hanna\OneDrive\Documents\thesis\eduexpenditureGDP.csv, varnames(1) clear 
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
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
save "$data\longspendingeduGDP.dta", replace
drop if year<1987 //and drop non-country entities
save "$data\samplespendingeduGDP.dta", replace

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
drop if year<1987
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
replace countryname="North Korea" if countryname=="Korea, Dem. Peopleâs Rep."
replace countryname="Laos" if countryname=="Lao P.D.R."
replace countryname="Macedonia" if countryname=="North Macedonia " | countryname=="North Macedonia"
save "$data\sampletaxes.dta", replace
** OMITTED OR LEFT OUT **
** other edu spending determinants: debt payments, deficit, inflation,
** social spending effectiveness, central gov grants, unemployment

***************************************************************************DEBT*
import excel "$path\IDS_SELECTION.xlsx", sheet("Data") firstrow clear
rename CountryName countryname
rename CountryCode countrycode
drop SeriesCode CounterpartAreaCode
duplicates drop countryname countrycode CounterpartAreaName SeriesName, force
reshape long YR, i(countryname countrycode CounterpartAreaName SeriesName) j(year)
drop if countryname=="" & countrycode=="" & CounterpartAreaName==""
rename CounterpartAreaName counterpart
replace counterpart="IMF" if counterpart=="International Monetary Fund"
replace counterpart="WB-IBRD" if counterpart=="World Bank-IBRD                         "
replace counterpart="WB-IDA" if counterpart=="World Bank-IDA                         "
replace counterpart="Bilateral Other" if counterpart=="Other Bilateral"
replace counterpart="Multilateral Other" if counterpart=="Other Multilaterals"
drop if YR==".."
rename YR val
drop if SeriesName==""
encode SeriesName, gen(series)
drop SeriesName
drop if series==5 | series==6 | series==7 | series==11 | series==12 | series==15 ///
	| series==17 | series==18 | series==19  | series==20 | series==21 | series==25 ///
	| series==2 | series==9 | series==14 | series==22 | series==24 | series==26 | series==28
// 1 Debt buyback USD // 3 Debt forgiveness or reduction USD // 8 Debt stock reduction USD
// 4 External debt service, general // 10 Disbursements external debt, general
// 23 Multilateral debt service USD // 27 Total change external debt stock USD
// 13 External debt stocks % GNI // 16 External debt stocks total USD
save "$data\sampleIDS_DEBT.dta", replace //missing pre-2000 values
reshape wide val, i(countryname countrycode year counterpart) j(series)
label var year "Year"
label var val1 "Debt buyback (current USD)" 
label var val3 "Debt forgiveness or reduction (current USD)"
label var val8 "Debt stock reduction (current USD)"
label var val4 "External debt service, general"
label var val10 "Disbursements external debt, general"
label var val23 "Multilateral debt service (current USD)"
label var val27 "Total change external debt stock (current USD)"
label var val13 "External debt stocks (%GNI)"
label var val16 "External debt stocks, total (current USD)"
drop if counterpart=="Multiple Lenders" | counterpart=="Other Multiple Lenders"
replace counterpart="WBIDA" if counterpart=="WB-IDA"
replace counterpart="WBIBRD" if counterpart=="WB-IBRD"
reshape wide val*, i(countryname countrycode year) j(counterpart) string
replace countryname="Bahamas" if countryname=="Bahamas, The"
replace countryname="DR Congo" if countryname=="Democratic Republic of Congo" | "Congo, Dem. Rep."
replace countryname="Cape Verde" if countryname=="Cabo Verde"
replace countryname="Gambia" if countryname=="Gambia, The"
replace countryname="Laos" if countryname=="Lao PDR"
replace countryname="Macedonia" if countryname=="North Macedonia " | countryname=="North Macedonia"
replace countryname="Russia" if countryname=="Russian Federation"
replace countryname="Yemen" if countryname=="Yemen, Rep."
replace countryname="Venezuela" if countryname=="Venezuela, RB"
replace countryname="Syria" if countryname=="Syrian Arab Republic"
replace countryname="Kyrgyzstan" if countryname=="Kyrgyz Republic"
replace countryname="Iran" if countryname=="Iran, Islamic Rep."
replace countryname="Côte d'Ivoire" if countryname=="Cote d'Ivoire" 
replace countryname="Egypt" if countryname=="Egypt, Arab Rep."
replace countryname="São Tomé and Principe" if countryname=="Sao Tome and Principe"
drop if countryname=="Advanced economies" | countryname=="Advanced G-20" | countryname=="Central Europe and the Baltics" | countryname=="Early-demographic dividend" /// | 
	| countryname=="East Asia & Pacific" | countryname=="East Asia & Pacific (IDA & IBRD countries)" | countryname=="East Asia & Pacific (excluding high income)" | countryname=="Emerging G-20" ///
	| countryname=="Emerging Market and Middle-Income Economies" | countryname=="Emerging Market and Middle-Income Asia" | countryname=="Middle income" | countryname=="North America" ///
	| countryname=="Emerging Market and Middle-Income Europe" | countryname=="Emerging Market and Middle-Income Latin America" | countryname=="Emerging and Middle-Income Middle East and North Africa and Pakistan" ///
	| countryname=="Emerging Market and Middle-Income Europe" | countryname=="Emerging Market and Middle-Income Middle East" ///
	| countryname=="Euro area" | countryname=="European Union" | countryname=="Late-demographic dividend" | countryname=="Europe & Central Asia" | countryname=="Europe & Central Asia (IDA & IBRD countries)" ///
	| countryname=="Europe & Central Asia (excluding high income)" | countryname=="Latin America & Caribbean" | countryname=="Latin America & the Caribbean (IDA & IBRD countries)" ///
	| countryname=="Latin America & Caribbean (excluding high income)" | countryname=="Low income" | countryname=="Low & middle income" | countryname=="Low-Income Developing Asia" ///
	| countryname=="Low-Income Developing Countries" | countryname=="Low-Income Developing Latin America" | countryname=="Low-Income Developing Oil Producers" | countryname=="Low-Income Developing Others" ///
	| countryname=="Low-Income Developing Sub-Saharan Africa" | countryname=="Lower middle income" | countryname=="Major advanced economies" | countryname=="Middle East & North Africa Middle income" ///
	| countryname=="Middle East & North Africa (IDA & IBRD countries)" | countryname=="Middle East & North Africa (excluding high income)" ///
	| countryname=="Not classified" | countryname=="OECD members" | countryname=="Pacific island small states" | countryname=="Small states" | countryname=="Other small states" | countryname=="South Asia" ///
	| countryname=="South Asia (IDA & IBRD)" | countryname=="Post-demographic dividend" | countryname=="Pre-demographic dividend" | countryname=="IDA & IBRD total" ///
	| countryname=="Sub-Saharan Africa" | countryname=="Sub-Saharan Africa (IDA & IBRD countries)" | countryname=="Sub-Saharan Africa (excluding high income)" ///
	| countryname=="Upper middle income" | countryname=="World" | countryname=="©IMF, 2021" | countryname=="Arab World" | countryname=="Caribbean small states" | countryname=="Emerging and Middle-Income Asia" ///
	| countryname=="Emerging and Middle-Income Europe" | countryname=="Emerging and Middle-Income Latin America" | countryname=="Emerging and Middle-Income Middle East" | countryname=="Fragile and conflict affected situations" ///
	| countryname=="Heavily indebted poor countries (HIPC)" | countryname=="High income" | countryname=="IBRD only" | countryname=="IDA & IBRD only" | countryname=="IDA blend" ///
	| countryname=="IDA only" | countryname=="IDA total" | countryname=="Least developed countries: UN classification" | countryname=="Major advanced economies (G7)" | countryname=="Middle East & North Africa" ///
	| countryname=="Upper middle income" | countryname=="Middle income" | countryname=="Least developed countries: UN classification" ///
//keep using debt forgiveness or reduction val3IMF val3WBIDA val3WBIBRD
//keep using debt service val 4World
//keep using debt stock reduction val8World
//Figure X Debt reduction and relief for HIPC decision point countries, XXXX
//Figure X Debt service paid by country group, 1980-2020
//Debt stock reduction by country group, 1990-2020 [+ ODA disbursements? See Fig. 

save "$data\sampledebtids.dta", replace //missing pre-2000 values
**********************************************************************************MERGE*
** MERGE ALL MACROECON INDICATORS
use "$data\sampleGDP_merged.dta", clear
merge 1:1 countryname year using "$data\longdebtposition.dta", gen(mergedebt)
merge 1:1 countryname year using "$data\sampletaxes.dta", gen(mergetax)
merge 1:1 countryname year using "$data\longspending.dta", gen(mergespend1)
merge 1:1 countryname year using "$data\longspendingedu.dta", gen(mergespend2)
merge 1:1 countryname year using "$data\samplespendingeduGDP.dta", gen(mergespend3)
save "$data\sample_macroecon_merged.dta", replace
**********************************************************************************MERGE*
** MERGE DEMOGRAPHIC + MACROECONOMIC
use "$data\fullset_demo.dta", replace
merge 1:1 countryname year using "$data\sample_macroecon_merged.dta", gen(mergecovars)
save "$data\fullset_merged_covars.dta", replace
**********************************************************************************OUTCOME*
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
replace countryname="Eswatini" if countryname=="Swaziland"
replace countryname="São Tomé and Principe" if countryname=="Sao Tome and Principe"
replace countryname="Micronesia, Fed. Sts." if countryname=="Micronesia"
replace countryname="DR Congo" if countryname=="Democratic Republic of the Congo" // Slovakia Russia Palestine Macedonia Kyrkgyzstan
** check for duplicates in countrynum(=/=countrycode) in "$data\IMHEHC_wide.dta"
duplicates list countrynum year
duplicates list countryname year
save "$data\IMHEHC_wide.dta", replace
**********************************************************************************MERGE*
use "$data\fullset_merged_covars.dta", clear
merge 1:1 countryname year using "$data\IMHEHC_wide.dta", gen(mergehc)
save "$data\fullset_merged_full.dta", replace
drop if year<1990 | year>2019
duplicates list countryname year
duplicates list countrycode year

merge 1:1 countryname year using "$data\sampledebtids.dta", gen(mergedebtidc) ///
	keepusing(val3IMF val3WBIDA val3WBIBRD val4World val8World)
	//keep using:
	// debt reduction = val3IMF val3WBIDA val3WBIBRD
	// debt service = val4World
	// debt stock reduction = val8World
label var val3IMF "Debt forgiveness or reduction"
label var val3WBIDA "Debt forgiveness or reduction"
label var val3WBIBRD "Debt forgiveness or reduction"
label var val4World "Debt service, total external"
label var val8World "Debt stock reduction, total external"
save "$data\analysis.dta", replace

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

***********************************************************************TREATMENT*
** HIPC start, end dates (year)
import excel "C:\Users\hanna\OneDrive\Documents\thesis\HIPCitreatment.xlsx" ///
, sheet("Sheet1") firstrow clear
rename CountryName countryname
save "C:\Users\hanna\OneDrive\Documents\thesis\Stata\HIPCitreatment.dta"

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

***********************************************************************MERGE FIGURES DATASET*
** all country groups, for descriptives and distribution figures
use "$data\income_lab_hist.dta", clear
duplicates list countrycode year
**drop small economies and communist countries
drop if countryname=="Netherlands Antilles (former)" | countryname=="Mayotte" | countrycode=="CSK" | countrycode=="SUN" | countrycode=="YUG"
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

** PLOT PREP
**violin plots
	*ssc install vioplot, replace
gen yeardum = year - 1989
	label variable yeardum "Dummy year, 1990=1" // or should 1990 be year 0?
** democracy score 0-10 must be put on 100 scale:
gen demoperc = polyarchy*100
	label variable demoperc "Electoral democracy score, 0-100" 
** gdp pc (0-7000) and trade open (0-350) - put on similar scale
gen openperc = open / 8.6
	label variable openperc "Trade openness, % GDP, scaled 0-100"
** gdp usd (very large) and gdp pc (0-7000) - put on similar scale
gen gdpusdscaled = gdpusd / 1000
	label var gdpusdscaled "GDP, in 1000s USD"
gen gdpusdbil = gdpusd / 1000000000
	label var gdpusdscaled "GDP, in billions USD"
gen gdppcusdscaled = gdppcusd / 1000
	label variable gdppcusdscaled "GDP per capita, in 1000s USD"
gen gdppcusdperc = gdppcusd / 100
	label variable gdppcusdperc "GDP per capita, in 100s USD"

encode incomelab, gen(ilab)
label var ilab "Country income group" // this is numeric!
recode ilab (3=0) (4=3) (1=4) (2=1)
recode ilab (0=2)
label define ilabr 1"L" 2"LM" 3"UM" 4"H"
label values ilab ilabr
save "$data\figures.dta", replace
** line plots (means)
** year/incomelab mean vars:

foreach var in debtstockreduction extdebtservice debtreductionIDA debtreductionIMF debtreductionmultilateral {
	bysort year incomelab, rc0: egen mean`var' = mean(`var')
	bysort year HIPC, rc0: egen Hmean`var' = mean(`var') if incomelab=="L" | incomelab=="LM"
}

foreach var in imhe_hc_mean3b debtpos spending edspendperc edspendpercGDP ///
	gini urban open openperc polyarchy demoperc ///
	gdpusd gdpusdscaled gdpusdbil gdppcusd gdppcusdperc gdppcusdscaled {
	bysort year incomelab, rc0: egen mean`var' = mean(`var')
	bysort year HIPC, rc0: egen Hmean`var' = mean(`var')
}
//imhe_hc_lower1m imhe_hc_lower2f imhe_hc_lower3b imhe_hc_upper1m imhe_hc_upper2f imhe_hc_upper3b ///

** annual debtpos change per group:
*bysort year incomelab, rc0: egen meandebtpos = mean(debtpos)
bysort countryname (year), rc0: gen debtchange = (debtpos[_n]-debtpos[_n-1])
bysort year incomelab, rc0: egen meandebtchange = mean(debtchange)
bysort countryname (year): gen groupchangedebtpos=100*(meandebtpos[_n]-meandebtpos[_n-1])/meandebtpos[_n-1]
bysort countryname (year): gen Hgroupchangedebtpos=100*(Hmeandebtpos[_n]-Hmeandebtpos[_n-1])
label var groupchangedebtpos "Income group debt position annual change (% change)"
label var Hgroupchangedebtpos "Treatment group debt position annual change (% GDP)"
** annual debt change - per country:
bysort countryname (year): gen debtchangep=100*(debtpos[_n]-debtpos[_n-1])/debtpos[_n-1]
bysort countryname (year): gen debtchangeg=100*(debtpos[_n]-debtpos[_n-1])
label var debtchangep "Gross debt position annual change (% change)"
label var debtchangeg "Gross debt position annual change (% GDP)"
bysort year incomelab, rc0: egen meandebtchangep = mean(debtchangep)
bysort year HIPC, rc0: egen Hmeandebtchangep = mean(debtchangep)
save "$data\figures.dta", replace

********************************************************************************MERGE ANALYSIS DATASET*
** start with full sample
use "$data\figures.dta", clear // countryname countrycode year incomelab
duplicates list countrycode year // remove duplicates
drop if year<1990 | year>2020
drop merge* codingstart codingend libdem libdem_sd api api_sd mpi mpi_sd ///
	imhe_hc_lower1m imhe_hc_upper1m imhe_hc_lower2f imhe_hc_upper2f

// dropping higher-income countries (LM<UM and LM<10x)
drop if incomelab=="H" & countryname!="Russia" & countryname!="Romania" & countryname!="Equatorial Guinea"
drop if countryname=="American Samoa" | countryname=="Antigua and Barbuda" | countryname=="Argentina" ///
	| countryname=="Aruba" | countryname=="Bahrain" | countryname=="Barbados" | countryname=="Botswana" ///
	| countryname=="Brazil"| countryname=="Chile" | countryname=="Croatia" | countryname=="Czech Republic" ///
	| countryname=="Estonia" | countryname=="Gabon" | countryname=="Greece" | countryname=="Guam" ///
	| countryname=="Hungary" | countryname=="Isle of Man" | countryname=="Latvia" ///
	| countryname=="Lebanon" | countryname=="Libya" | countryname=="Lithuania" ///
	| countryname=="Macao" | countryname=="Malaysia" | countryname=="Malta" ///
	| countryname=="Mauritius" | countryname=="Mexico" | countryname=="New Caledonia" ///
	| countryname=="Oman" | countryname=="Palau" | countryname=="Panama" ///
	| countryname=="Poland" | countryname=="Portugal" | countryname=="Puerto Rico" ///
	| countryname=="Saudi Arabia" | countryname=="Seychelles" | countryname=="Slovakia" ///
	| countryname=="Slovenia" | countryname=="South Africa" | countryname=="South Korea" ///
	| countryname=="St. Kitts and Nevis" | countryname=="St. Lucia" | countryname=="Cayman Islands" ///
	| countryname=="Trinidad and Tobago" | countryname=="Uruguay" | countryname=="Venezuela"
// dropping non-sovereign territories
drop if countryname=="Anguilla" | countryname=="British Virgin Islands" ///
	| countryname=="Curaçao" | countryname=="Gibraltar" | countryname=="Northern Mariana Islands" ///
	|  countryname=="Sint Maarten (Dutch part)" | countryname=="St. Martin (French part)" ///
	| countryname=="Turks and Caicos Islands"
// dropping recently created states and states with populations below 1M:
drop if countryname=="Montenegro" | countryname=="Serbia" | countryname=="South Sudan" /// est. >2000
	| countryname=="Kosovo" | countryname=="Timor-Leste" ///
	| countryname=="Nauru" | countryname=="Tuvalu" | countryname=="San Marino" /// pop<1M
	| countryname=="Liechtenstein" | countryname=="Monaco" | countryname=="Micronesia, Fed. Sts." ///
	| countryname=="Marshall Islands" | countryname=="Dominica" | countryname=="Samoa" | countryname=="Brunei" ///
	| countryname=="Tonga" | countryname=="Kiribati" | countryname=="Grenada" | countryname=="Belize" ///
	| countryname=="Belize" | countryname=="Bhutan" | countryname=="Cabo Verde" | countryname=="Cape Verde" ///
	| countryname=="Comoros" | countryname=="São Tomé and Principe" | countryname=="St. Vincent and the Grenadines"
// fix country labels
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
tab countryname incomelab, m

save "$data\sampleanalysis.dta", replace

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
