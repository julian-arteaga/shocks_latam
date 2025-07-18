* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute shock incidence summary statistics ENNVIH 2005-2009:

* -----------------

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_yr_incidence_02_09.dta", replace 

scatter mean_shock_natdisast mean_shock_accident_illnss mean_shock_lostjob ///
	    mean_shock_criminality											   ///
	    year if rural == 1, 								   			   ///
		xlab(2002 2005 2009) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") col(1))   		   						   ///
	 	ytit("Yearly Incidence") xtit("")

cd "$projdir/out/ennvih/"
graph export "ennvih_shocks_incidence.png", replace

twoway connected mean_shock_any year if rural == 1, 					   ///		
	   lpattern(solid) mcolor(black) lcolor(black)|| 					   ///
	   connected shock_any year if rural == 1, 							   ///
	   lpattern(dash) mcolor(stblue) lcolor(stblue) msymbol(t)|| 		   ///
	   connected shock_any year if rural == 0, 							   ///
	   lpattern(dash_dot) mcolor(stred) lcolor(stred)	msymbol(s)		   ///
	   xlab(2002 2005 2009) 	   										   ///
	   legend(order(1 "Any shock" 										   ///
					2 "Any shock (rural)" 								   ///
					3 "Any shock (urban)"))   							   ///
	 	ytit("Yearly Incidence") xtit("")

cd "$projdir/out/ennvih/"
graph export "ennvih_anyshock_incidence.png", replace

scatter shock_natdisast shock_accident_illnss shock_lostjob 			   ///
	    shock_criminality  								    			   ///
	    year if rural == 1, 								   			   ///
		xlab(2002 2005 2009) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") pos(6) row(2))    						   ///
	 	ytit("Yearly Incidence") xtit("") tit("Rural") ylab(0(0.03)0.12)

cd "$projdir/out/ennvih/"
graph save g1.gph, replace

scatter shock_natdisast shock_accident_illnss shock_lostjob 			   ///
	    shock_criminality  								    			   ///
	    year if rural == 0, 								   			   ///
		xlab(2002 2005 2009) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") pos(6) row(2))    						   ///
	 	ytit("Yearly Incidence") xtit("") tit("Urban") ylab(0(0.03)0.12)

cd "$projdir/out/ennvih/"
graph save g2.gph, replace

grc1leg g1.gph g2.gph

graph export "ennvih_shocks_incidence_ruralurban.png", replace

erase g1.gph 
erase g2.gph

* ----- 


cd "$projdir/dta/cln/ENNVIH"
use "ennvih_mean_incidence_rural_inc_q.dta", clear

foreach t in any lostjob natdisast accident-illness criminality {

	twoway connected explag_shock q if rural == 1 & shock == "`t'", 	   ///
		lcolor(black) mcolor(black) lpattern(solid) || 					   ///
		connected explag_shock q if rural == 0 & shock == "`t'",    	   ///
		lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	       ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "Rural" 2 "Urban"))							       ///
		xtitle("pre-shock expenditure level quintile") 			       	   ///
		title("`t'")

	cd "$projdir/out/ennvih"
	graph export "ennvih_`t'_preexp.png", replace

	twoway connected exp_shock q if rural == 1 & shock == "`t'", 	   	   ///
		lcolor(black) mcolor(black) lpattern(solid) || 					   ///
		connected exp_shock q if rural == 0 & shock == "`t'",    	   	   ///
		lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	       ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "Rural" 2 "Urban"))							       ///
		xtitle("post-shock expenditure level quintile") 			       ///
		title("`t'")

	cd "$projdir/out/ennvih"
	graph export "ennvih_`t'_postexp.png", replace
}

* -------------------------------------------------------------------

	twoway connected explag_shock q if rural_ == 0 & shock == "any", 	   ///
		lcolor(black) mcolor(black) lpattern(solid) 					   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "All households"))							       ///
		xtitle("pre-shock expenditure level quintile") 			       	   ///
		title("All shocks")

* -------------------------------------------------------------------