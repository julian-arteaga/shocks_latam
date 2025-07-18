* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute shock incidence summary statistics ENAHO 2013-2023:

* -----------------

cd "$projdir/dta/cln/ENAHO"
use "enaho_hhpanel_07_23.dta", replace 

drop numobs

foreach var of varlist shock_* {

	bys year: egen mean_`var' = mean(`var')
}

bys year: gen numobs = _N 
collapse mean_* shock_* numobs, by(year rural)

cd "$projdir/dta/cln/ENAHO"
save "enaho_yr_incidence_13_23.dta", replace 

* -------------------------------------------------------------------