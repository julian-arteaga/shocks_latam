* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Import ENAHO PER shock module -- 2014-2023

* -----------------

forvalues y = 2013(1)2023 {

	cd "$projdir/dta/src/ENAHO/"
	use "`y'/Enaho01b-`y'-2.dta", clear

	gen shock_lostjob   	  = p40_1 
	gen shock_bankrupcy 	  = p40_2 
	gen shock_accident_illnss = p40_3 
	// gen shock_abandonmember   = p40_4 // omit for now
	gen shock_criminality     = p40_5 
	gen shock_natdisast 	  = p40_6 

	keep conglome vivienda hogar estrato shock_* 

	gen year = `y'

	tempfile shocks_`y'
	save `shocks_`y''
}

use `shocks_2013', clear 

forvalues y = 2014(1)2023 {

	append using `shocks_`y''
}

gen rural = inlist(estrato, 6, 7 ,8)
label var rural "Rural household"

keep conglome vivienda hogar rural shock_* year

cd "$projdir/dta/cln/ENAHO"
save "enaho_shock_prevalence_hhlvl_13_23.dta", replace

* -------------------------------------------------------------------

