/* ----------------------------------------------------------------------------

# Shocks LatAm
# Julian Arteaga
# 2025

----------------------------------------------------------------------------*/

* Compute preliminary stats of El Salvador survey using pre-built panel shared
* by LT 

cd "$projdir/dta/cln/ENNVIH"
use "ltslv_yr_incidence_11_13.dta", replace 

scatter mean_shock_natdisast mean_shock_accident_illnss mean_shock_lostjob ///
	    mean_shock_criminality year, 								   	   ///
		xlab(2011(2)2013) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") col(1))   		   			   			   ///
	 	ytit("Yearly Incidence") xtit("")

cd "$projdir/out/ltslv/"
graph export "ltslv_shocks_incidence_11_13.png", replace

* -----------------------------------------------

* Correlate with consumption levels:

cd "$projdir/dta/cln/LTSLV"
use "ltslv_mean_incidence_preexp.dta", clear

foreach t in any lostjob natdisast accident-illness criminality {

	twoway connected explag_shock q if shock == "`t'", 	   				   ///
		lcolor(black) mcolor(black) lpattern(solid)						   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(off)							       						   ///
		xtitle("pre-shock expenditure level quintile") 			       	   ///
		title("`t'")

	cd "$projdir/out/ltslv"
	graph export "ltslv_`t'_preexp.png", replace

	twoway connected exp_shock q if shock == "`t'", 	   	   			   ///
		lcolor(black) mcolor(black) lpattern(solid)						   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(off)							       						   ///
		xtitle("post-shock expenditure level quintile") 			       ///
		title("`t'")

	cd "$projdir/out/ltslv"
	graph export "ltslv_`t'_postexp.png", replace
}

* -------------------------------------------------------------------
