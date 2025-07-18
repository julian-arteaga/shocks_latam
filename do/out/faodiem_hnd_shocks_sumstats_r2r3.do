* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute shock incidence summary statistics FAODIEM HTI Rounds 3-6

cd "$projdir/dta/cln/FAODIEM_HND"
use "faodiem_HND_mean_incidence_preinc.dta", clear

foreach t in any lostjob natdisast accident-illness criminality {

	twoway connected inclag_shock q if shock == "`t'", 	   				   ///
		lcolor(black) mcolor(black) lpattern(solid)    	   			       ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(off)							       						   ///
		xtitle("pre-shock income level quintile") 			       	       ///
		title("`t'")

	cd "$projdir/out/faodiem"
	graph export "faodiem_hnd_`t'_preinc.png", replace

	twoway connected inc_shock q if shock == "`t'", 	   	   			   ///
		lcolor(black) mcolor(black) lpattern(solid) 					   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(off)							       						   ///
		xtitle("post-shock income level quintile") 			       		   ///
		title("`t'")

	cd "$projdir/out/faodiem"
	graph export "faodiem_hnd_`t'_postinc.png", replace
}

* -------------------------------------------------------------------