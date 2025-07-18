* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENNVIH hh level dta 2002-2005-2009
* Sample of households with data for least two waves  

* -----------------

cd "$projdir/dta/cln/ENAHO"
use "enaho_hhrosterlist_0723.dta", clear

* -----------------------------------------------

* Merge in Shocks:

cd "$projdir/dta/cln/ENAHO"
merge 1:1 conglome vivienda hogar year using 							   ///
	"enaho_shock_prevalence_hhlvl_07_24.dta"
drop if _merge == 1 // 7 obs 
drop if _merge == 2 // non-panel hhs
drop _merge


* -----------------------------------------------

* Merge in Consumption:

cd "$projdir/dta/cln/ENAHO"
merge 1:1 conglome vivienda hogar year using 							   ///
	"enaho_consump_hhlvl_07_23.dta"
drop if _merge == 1 // 170 obs 
drop if _merge == 2 // non-panel hhs
drop _merge


* -----------------------------------------------

* Merge in Govt programs:

cd "$projdir/dta/cln/ENAHO"
merge 1:1 conglome vivienda hogar year using 							   ///
	"enaho_govtprog_hhlvl_07_23.dta"
drop if _merge == 2 // non-panel hhs

replace govt_food_prog = 0 if _merge == 1 
replace govt_nonfood_prog = 0 if _merge == 1
replace govt_covid_prog = 0 if _merge == 1

drop _merge

* -----------------------------------------------

* Merge in Debts:

/* cd "$projdir/dta/cln/ENAHO"
merge 1:1 conglome vivienda hogar year using 							   ///
	"enaho_debts_hhlvl_20_23.dta"
drop if _merge == 2 // non-panel hhs
// _merge == 1: years <= 2019
drop _merge */

* -----------------------------------------------

* Merge in schooling indicator for underage:

cd "$projdir/dta/cln/ENAHO"
merge 1:1 conglome vivienda hogar year using 							   ///
	"enaho_noschool_minors_hhlvl_0723.dta"
drop if _merge == 2 // non-panel hhs
// _merge == 1: years <= 2019
drop _merge

* -----------------------------------------------

* Merge in municipal characteristics:

* replace ubigeo codes that have changed across time
replace ubigeo = "120604" if ubigeo == "120699"
replace ubigeo = "160801" if ubigeo == "160109"

gen admincode = ubigeo

gen provincecode = substr(admincode,1, 4)

merge m:1 admincode using "$projdir/dta/cln/ENAHO/per_munic_sea_distances.dta"
drop if _merge == 2
drop _merge 

merge m:1 provincecode using "$projdir/dta/cln/ENAHO/per_province_povrate.dta"
drop _merge 

merge m:1 provincecode using 											   ///
				"$projdir/dta/cln/ENAHO/per_province_healthaccess.dta"
drop _merge 

* -----------------------------------------------

* Build harmonized vars

foreach var of varlist consumo_health consumo_alimento consumo_personal    ///
			 consumo_durables consumo_leisure   		   				   ///
			 consumo_purchased consumo_transfers 						   ///
			 hh_totexp hh_totinc  {

	gen `var'_pc = `var' / mieperho
}

replace shock_accident_illnss = 1 if 									   ///
		shock_accident_illnss == 1 | shock_deathmember == 1			   
	   		   
replace shock_lostjob = 1 if shock_lostjob == 1 | shock_bankrupcy == 1

gen allshockmiss = (shock_accident_illnss == . &  						   ///
					shock_lostjob == . & shock_natdisast == . &			   ///
					shock_criminality == .)

drop if allshockmiss == 1 

gen shock_any = shock_natdisast + shock_accident_illnss  		   		   ///
	    	   + shock_lostjob + shock_criminality > 0 	

rename hh_totexp_pc percexp

// gen debts_dummy = request_loan == 1 & receive_loan == 1

gen govt_prog = 														   ///
	inlist(1, govt_food_prog, govt_nonfood_prog, govt_covid_prog)
   
* Keep only households with at least two years of responses:
bys allwaveid: gen numys = _N 
keep if numys > 1 // left with 21,777 obs across 7735 households

egen hhid = group(allwaveid)

drop shock_deathmember shock_bankrupcy

distinct hhid // 52971
bys rural: distinct hhid  // 32473 urban; 20504 rural

xtset hhid year
sort hhid year 

gen rural_baseline = rural[_n-1] if hhid == hhid[_n-1]

egen exp_pc_q = xtile(percexp), n(5) by(rural year) 

egen exp_pc_all_q = xtile(percexp), n(5) by(year) 

gen percexp_baseline = percexp[_n-1] if hhid == hhid[_n-1]
gen exp_pc_q_baseline = exp_pc_q[_n-1]  if hhid == hhid[_n-1]
gen exp_pc_q_pre_all = exp_pc_all_q[_n-1]  if hhid == hhid[_n-1]

foreach var of varlist hhead_female singleheaded       					   ///
                       share_hh_female share_hh_old share_hh_young         ///
                       hhead_educ distance_to_sea_km poverty_rate_tot      ///
                       rate_nohealthaccess {

	sort hhid year
	gen `var'_baseline = `var'[_n-1] if hhid == hhid[_n-1]
}

compress 

cd "$projdir/dta/cln/ENAHO"
save "enaho_hhpanel_07_23.dta", replace 

* -----------------------------------------------

cd "$projdir/dta/cln/ENAHO"
use "enaho_hhpanel_07_23.dta", clear 

* Build 3-yearly panel

drop exp_pc_q exp_pc_all_q exp_pc_q_pre_all minyr maxyr hhid				   
drop *_baseline

egen hhid = group(allwaveid)

bys allwaveid: egen minyr = min(year)
bys allwaveid: egen maxyr = max(year)

gen year_gap = maxyr - minyr

drop if year_gap < 3
drop if year == minyr & year_gap == 4

xtset hhid year

foreach var of varlist shock_lostjob shock_accident_illnss 				   ///
					   shock_criminality shock_natdisast shock_any {

	gen `var'_3y = inlist(1, `var', L.`var', L2.`var', L3.`var')
}

br hhid year year_gap shock_any shock_any_3y // if hhid == 42526

drop numobs 

bys allwaveid: gen numobs = _N

drop if numobs < 3

bys hhid: egen min_year = min(year)
bys hhid: egen max_year = max(year)

tostring min_year, gen(minyrst)
tostring max_year, gen(maxyrst)

gen interval = maxyrst + "-" + minyrst 

drop if inlist(interval, "2011-2009", "2012-2010", "2015-2013", 		   ///
						 "2016-2014", "2017-2015", "2018-2016") |		   ///
		inlist(interval, "2019-2017", "2020-2018", "2021-2019",			   ///
						 "2022-2020", "2023-2021")

drop minyrst min_year minyr maxyrst max_year maxyr

bys hhid: egen min_year = min(year)
bys hhid: egen max_year = max(year)

keep if year == min_year | year == max_year

distinct hhid // 20336
bys rural: distinct hhid  // 11279 urban; 9057 rural

xtset hhid year
sort hhid year 

gen rural_baseline = rural[_n-1] if hhid == hhid[_n-1]

egen exp_pc_q = xtile(percexp), n(5) by(rural year) 

egen exp_pc_all_q = xtile(percexp), n(5) by(year) 

gen percexp_baseline = percexp[_n-1] if hhid == hhid[_n-1]
gen exp_pc_q_baseline = exp_pc_q[_n-1]  if hhid == hhid[_n-1]
gen exp_pc_q_pre_all = exp_pc_all_q[_n-1]  if hhid == hhid[_n-1]

foreach var of varlist hhead_female singleheaded       					   ///
                       share_hh_female share_hh_old share_hh_young         ///
                       hhead_educ distance_to_sea_km poverty_rate_tot      ///
                       rate_nohealthaccess {

	sort hhid year
	gen `var'_baseline = `var'[_n-1] if hhid == hhid[_n-1]
}

cd "$projdir/dta/cln/ENAHO"
save "enaho_hhpanel_07_23_3yearly.dta", replace 

* -------------------------------------------------------------------