* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENAHO govt program access measures -- 2007-2023

cd "$projdir/dta/src/ENAHO/"

forvalues y = 2007(1)2011 {

	use "$projdir/dta/src/ENAHO/`y'/enaho01-`y'-700.dta", clear
	numlabel, add

	gen foodprog = p703 != . 

	bys conglome vivienda hogar: egen govt_food_prog = max(foodprog)

	bys conglome vivienda hogar: keep if _n == 1 

	keep conglome vivienda hogar govt_food_prog

	gen year = `y'

	tempfile gvt`y'
	save `gvt`y''
}

forvalues y = 2012(1)2023 {

	use "$projdir/dta/src/ENAHO/`y'/enaho01-`y'-700.dta", clear
	numlabel, add

	local fprogvars p701_01, p701_02, p701_03, p701_04, 		   		   ///
				   p701_05, p701_06, p701_07, p701_08,		   			   ///
				   p701_09, p701_10

	if inrange(`y', 2014, 2023) local fprogvars p701_01, p701_02, p701_03, ///
											    p701_04, p701_05, p701_06, ///
											    p701_07, p701_08
	
	if inlist(`y', 2020, 2023) local fprogvars p701_01, p701_02, p701_03,  ///
											   p701_04, p701_05, p701_06,  ///
											   p701_07, p701_08, p701_10

	gen foodprog = inlist(1, `fprogvars')

	foreach var of varlist p710_* {
		replace `var' = 1 if `var' >= 1 & `var' != .
	}

	local nfprogvars p710_01, p710_02, p710_03, p710_04, 	   ///
					 p710_05, p710_06, p710_07, p710_08,	   ///
					 p710_09, p710_10, p710_11, p710_12 	   ///

	if inrange(`y', 2014, 2016) local nfprogvars `nfprogvars', p710_13 	   

	if inrange(`y', 2017,2023) local nfprogvars `nfprogvars', p710_13, p710_15 	   

	local covidprogvars  p710_16, p710_17, p710_18, p710_19, p710_20,      ///
						 p710_21, p710_22

	if `y' == 2021  local covidprogvars `covidprogvars', p710_29, p710_30
	
	if `y' == 2022  local covidprogvars `covidprogvars', p710_29, p710_30, ///
						  p710_31, p710_32, p710_33

	if `y' == 2023  local covidprogvars `covidprogvars', p710_29, p710_30, ///
						  p710_31, p710_32, p710_33

	gen nonfoodprog = inlist(1, `nfprogvars')

	if `y' < 2020 local covidprogvars 0 

	gen covidprog = inlist(1, `covidprogvars')
							
	bys conglome vivienda hogar: egen govt_food_prog = max(foodprog)

	bys conglome vivienda hogar: egen govt_nonfood_prog = max(nonfoodprog)

	bys conglome vivienda hogar: egen govt_covid_prog = max(covidprog)

	bys conglome vivienda hogar: keep if _n == 1

	keep conglome vivienda hogar govt_*_prog 

	gen year = `y'

	tempfile gvt`y'
	save `gvt`y''
}

use `gvt2007'

forvalues y = 2008(1)2023 {

	append using `gvt`y''
}

if year < 2014  {

	destring conglome, gen(congaux)
	gen cong_aux = string(congaux, "%06.0f") 
	drop conglome 
	rename cong_aux conglome
	order conglome
}

drop congaux

compress 

cd "$projdir/dta/cln/ENAHO"
save "enaho_govtprog_hhlvl_07_23.dta", replace

* -------------------------------------------------------------------

cd "$projdir/dta/cln/ENAHO"
use "enaho_govtprog_hhlvl_07_23.dta", clear

merge 1:1 conglome vivienda hogar year using ///
	"$projdir/dta/cln/ENAHO/enaho_hhrosterlist_0723.dta"

drop if _merge == 1

replace govt_food_prog = 0 if _merge == 2
replace govt_nonfood_prog = 0 if _merge == 2
replace govt_covid_prog = 0 if _merge == 2

replace govt_nonfood = . if year < 2012
replace govt_covid = . if year < 2020

gen somegovtprog = inlist(												   ///
	1, govt_food_prog, govt_nonfood_prog, govt_covid_prog)

keep conglome vivienda hogar year govt_* somegovtprog 

collapse govt_food_prog govt_nonfood_prog govt_covid_prog somegovtprog,    ///
	by(year)

twoway connect govt_food_prog govt_nonfood_prog govt_covid_prog 		   ///
	   somegovtprog year

* -------------------------------------------------------------------