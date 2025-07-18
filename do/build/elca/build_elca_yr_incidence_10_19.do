* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ELCA shock incidence 2010-2019

* -----------------

cd "$projdir/dta/cln/ELCA"
use "elca_hhpanel_10_13_16.dta", clear

gen elca_hh = 1

append using "elca_shocks_hhlvl_19.dta"
drop if elca_hh != 1

replace year = 2019 if year == .		   		   
			   
foreach var of varlist shock_* {

	bys year: egen mean_`var' = mean(`var')
}

bys year: gen numobs = _N

collapse mean_* shock_* numobs, by(year rural)

// natural disaster shock for urban 2010 is bi-yearly. Rest of 2010 is yearly
replace shock_natdisast = 1 - (1 - shock_natdisast)^(1/2) 				   ///
		if year == 2010 & rural == 0

replace mean_shock_natdisast = 1 - (1 - mean_shock_natdisast)^(1/2)		   ///
		if year == 2010 & rural == 0

foreach var of varlist shock_* mean_* {

	replace `var' = 1 - (1 - (`var'))^(1/3) if year != 2010 // go from 3-yearly
															//  to yearly risk
}

cd "$projdir/dta/cln/ELCA"
save "elca_yr_incidence_10_19.dta", replace 

* -------------------------------------------------------------------