* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute shock incidence summary statistics ENNVIH 2005-2009:

* -----------------

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_hhpanel_02_05_09.dta", replace 

foreach var of varlist shock_* {

	bys year: egen mean_`var' = mean(`var')
}

bys year: gen numobs = _N

collapse mean_* shock_* numobs, by(year rural)

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_yr_incidence_02_09.dta", replace 

* -------------------------------------------------------------------