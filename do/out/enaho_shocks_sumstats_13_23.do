* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute shock incidence summary statistics ENAHO 2013-2023:

* -----------------

cd "$projdir/dta/cln/ENAHO"
use "enaho_shock_prevalence_hhlvl_13_23.dta", clear

gen shock_any = shock_natdisast + shock_accident_illnss  		   		   ///
	    	   + shock_lostjob + shock_criminality 				   		   ///
			   + shock_bankrupcy > 0

foreach var of varlist shock_* {

	bys year: egen mean_`var' = mean(`var')
}

collapse mean_* shock_*, by(year rural)

* -----------------

cd "$projdir/out"

scatter mean_shock_natdisast mean_shock_accident_illnss mean_shock_lostjob ///
	    mean_shock_criminality mean_shock_bankrupcy 					   ///
	    year if rural == 1, 								   			   ///
		xlab(2013(2)2023) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality"  5 "Bankrupcy") col(1))   		   ///
	 	ytit("Yearly Incidence") xtit("")

graph export "enaho_shocks_incidence.png", replace

twoway connected mean_shock_any year if rural == 1, 					   ///		
	   lpattern(solid) mcolor(black) lcolor(black)|| 					   ///
	   connected shock_any year if rural == 1, 							   ///
	   lpattern(dash) mcolor(stblue) lcolor(stblue) msymbol(t)|| 		   ///
	   connected shock_any year if rural == 0, 							   ///
	   lpattern(dash_dot) mcolor(stred) lcolor(stred)	msymbol(s)		   ///
	   xlab(2013(2)2023) 	   											   ///
	   legend(order(1 "Any shock" 										   ///
					2 "Any shock (rural)" 								   ///
					3 "Any shock (urban)"))   							   ///
	 	ytit("Yearly Incidence") xtit("")

graph export "elca_anyshock_incidence.png", replace

twoway scatter mean_shock_any year if rural == 1, 						   ///
        connect(line) mcolor(black) lcolor(black) msymbol(circle) 		   ///
    || scatter shock_any year if rural == 1, 							   ///
        connect(dash) mcolor(navy) lcolor(navy) msymbol(triangle) 		   ///
    || scatter shock_any year if rural == 0, 							   ///
        connect(dot) mcolor(maroon) lcolor(maroon) msymbol(square) 		   ///
    , xlab(2013(2)2023) xtitle("") ytitle("Yearly Incidence") 			   ///
	legend(order(1 "Mean shock (rural)" 2 "Shock (rural)" 				   ///  
				 3 "Shock (urban)")) 

scatter shock_natdisast shock_accident_illnss shock_lostjob 			   ///
	    shock_criminality shock_bankrupcy 			   					   ///
	    year if rural == 1, 								   			   ///
		xlab(2013(2)2023) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality"  5 "Bankrupcy") pos(6) row(2))    		   ///
	 	ytit("Yearly Incidence") xtit("") tit("Rural") ylab(0(0.05)0.2)

cd "$projdir/out"
graph save g1.gph, replace

scatter shock_natdisast shock_accident_illnss shock_lostjob 			   ///
	    shock_criminality shock_bankrupcy 			   					   ///
	    year if rural == 0, 								   			   ///
		xlab(2013(2)2023) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality"  5 "Bankrupcy") pos(6) row(2))    		   ///
	 	ytit("Yearly Incidence") xtit("") tit("Urban") ylab(0(0.05)0.2)

cd "$projdir/out"
graph save g2.gph, replace

grc1leg g1.gph g2.gph

graph export "enaho_shocks_incidence_ruralurban.png", replace

erase g1.gph 
erase g2.gph

* -----------------------------------------------

* Correlate with consumption levels (2013-2016 only)

