* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build shock incidence by expenditure quintile:

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_hhpanel_02_05_09.dta", clear

xtset hhid year
sort hhid year 

drop if  exp_pc_q_baseline == .

foreach var of varlist shock_* {

	bys rural_baseline exp_pc_q_baseline: egen explag_`var' = mean(`var')
	bys rural exp_pc_q: egen exp_`var' = mean(`var')

	bys exp_pc_q_pre_all: egen expall_`var' = mean(`var')

	foreach q in 1 2 3 4 5 {

		bys rural_baseline: egen explag_`var'_q`q' = 					   ///
				mean(cond(exp_pc_q_baseline == `q', explag_`var', .))

		bys rural: egen exp_`var'_q`q' = 					       	   	   ///  
				mean(cond(exp_pc_q == `q', exp_`var', .))		

		egen expall_`var'_q`q' = 						   	   ///
				mean(cond(exp_pc_q_pre_all == `q', expall_`var', .))
	}

	drop exp_`var' explag_`var' expall_`var'
}

bys rural_baseline: keep if _n == 1

drop exp_pc_q exp_pc_q_baseline  			   							   ///
	 exp_pc_q_pre_all year numys hhid percexp shock* rural 		   		   ///
	 exp_pc_all_q

gen i = _n

reshape long explag_shock_ exp_shock_     	   							   ///
		expall_shock_, i(i) j(shock) string

foreach i in 1 2 3 4 5 {

	replace shock = "accident-illness_q`i'" if shock == "accident_illnss_q`i'"
}

split shock, parse("_")
rename shock2 qstr
drop shock
rename shock1 shock

gen q = substr(qstr,2,1)
destring q, replace 

rename *_ *

compress 
cd "$projdir/dta/cln/ENNVIH"
save "ennvih_mean_incidence_preexp.dta", replace

* -------------------------------------------------------------------
