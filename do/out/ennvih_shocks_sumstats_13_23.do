* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute shock incidence summary statistics ENNVIH 2005-2009:

* -----------------

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_shock_prevalence_hhlvl_02_09.dta", clear

keep shock* folio year rural

drop if inlist(., shock_lostjob, shock_accident_illnss,    				   ///
				  shock_criminality, shock_natdisast)

gen shock_any = shock_natdisast + shock_accident_illnss  		   		   ///
	    	   + shock_lostjob + shock_criminality > 0			   		   
			   
foreach var of varlist shock_* {

	bys year: egen mean_`var' = mean(`var')
}

collapse mean_* shock_*, by(year rural)

foreach var of varlist shock_criminality mean_shock_criminality {

	replace `var' = `var'/5 // go from 5-yearly to yearly incidence
}

cd "$projdir/out/ennvih/"

scatter mean_shock_natdisast mean_shock_accident_illnss mean_shock_lostjob ///
	    mean_shock_criminality 											   ///
	    year if rural == 1, 								   			   ///
		xlab(2002 2005 2009) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") col(1))   		   						   ///
	 	ytit("Yearly Incidence") xtit("")

graph export "ennvih_shocks_incidence.png", replace

twoway connected mean_shock_any year if rural == 1, 					   ///		
	   lpattern(solid) mcolor(black) lcolor(black)|| 					   ///
	   connected shock_any year if rural == 1, 							   ///
	   lpattern(dash) mcolor(stblue) lcolor(stblue) msymbol(t)|| 		   ///
	   connected shock_any year if rural == 0, 							   ///
	   lpattern(dash_dot) mcolor(stred) lcolor(stred)	msymbol(s)		   ///
	   xlab(2002 2005 2009) 	   											   ///
	   legend(order(1 "Any shock" 										   ///
					2 "Any shock (rural)" 								   ///
					3 "Any shock (urban)"))   							   ///
	 	ytit("Yearly Incidence") xtit("")

graph export "ennvih_anyshock_incidence.png", replace

twoway scatter mean_shock_any year if rural == 1, 						   ///
        connect(line) mcolor(black) lcolor(black) msymbol(circle) 		   ///
    || scatter shock_any year if rural == 1, 							   ///
        connect(dash) mcolor(navy) lcolor(navy) msymbol(triangle) 		   ///
    || scatter shock_any year if rural == 0, 							   ///
        connect(dot) mcolor(maroon) lcolor(maroon) msymbol(square) 		   ///
    , xlab(2002 2005 2009) xtitle("") ytitle("Yearly Incidence") 			   ///
	legend(order(1 "Mean shock (rural)" 2 "Shock (rural)" 				   ///  
				 3 "Shock (urban)")) 

scatter shock_natdisast shock_accident_illnss shock_lostjob 			   ///
	    shock_criminality  								    			   ///
	    year if rural == 1, 								   			   ///
		xlab(2002 2005 2009) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") pos(6) row(2))    						   ///
	 	ytit("Yearly Incidence") xtit("") tit("Rural") ylab()

cd "$projdir/out/ennvih/"
graph save g1.gph, replace

scatter shock_natdisast shock_accident_illnss shock_lostjob 			   ///
	    shock_criminality  								    			   ///
	    year if rural == 0, 								   			   ///
		xlab(2002 2005 2009) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") pos(6) row(2))    						   ///
	 	ytit("Yearly Incidence") xtit("") tit("Urban") ylab()

cd "$projdir/out/ennvih/"
graph save g2.gph, replace

grc1leg g1.gph g2.gph

graph export "ennvih_shocks_incidence_ruralurban.png", replace

erase g1.gph 
erase g2.gph

/* -----------------------------------------------

* Correlate with income and consumption levels (2013-2016 only)

cd "$projdir/dta/cln/ELCA"
use "elca_shock_prevalence_hhlvl_13_16.dta", clear

gen zona = zona_2016 
replace zona = zona_2013 if zona == . 

gen rural = zona == 2 

keep llave_n16 llave ola rural											   ///
	 shock_natdisast shock_accident_illnss shock_lostjob 			   	   ///
	 shock_criminality   

gen shock_any = shock_natdisast + shock_accident_illnss  		   		   ///
	    	   + shock_lostjob + shock_criminality  > 0

foreach i of varlist shock_* rural {
			 
		gen `i'_2=`i' if ola==2	
		bys llave: egen `i'_2013=max(`i'_2)
		drop `i'_2
		 
		rename `i' `i'_2016
}

drop if llave_n16 == .

merge 1:1 llave_n16 using "vars_elca_private.dta"
drop if _merge != 3

gen rural_2010 = zona_2010 == 2
 
egen cons_pc_q_2010 = xtile(consumo_total_pc_2010), n(5) by(rural_2010) 

egen cons_pc_q_2013 = xtile(consumo_total_pc_2013), n(5) by(rural_2013) 


gen ingtot_pc_2010 = ingtot_2010 / numperh_2010
gen ingtot_pc_2013 = ingtot_2013 / numperh_2013

egen income_pc_q_2010 = xtile(ingtot_pc_2010), n(5) by(rural_2010) 

egen income_pc_q_2013 = xtile(ingtot_pc_2013), n(5) by(rural_2013) 


drop if inlist(., cons_pc_q_2010, cons_pc_q_2013) // 9 obs

keep llave_n16  llave rural* shock_natdisast* shock_accident_illnss*       ///
	 shock_lostjob* shock_criminality* 									   ///	
	 shock_any* cons_pc_q_* income_pc_q_*

reshape long rural_ shock_natdisast_ shock_accident_illnss_       		   ///
	 shock_lostjob_ shock_criminality_  								   ///	
	 shock_any_ cons_pc_q_ income_pc_q_, i(llave_n16) j(year)

sort llave_n16 year 

gen cons_pc_q_baseline = cons_pc_q[_n-1] if llave_n16 == llave_n16[_n-1]
gen income_pc_q_baseline = income_pc_q_[_n-1] if llave_n16 == llave_n16[_n-1]

drop cons_pc_q_ income_pc_q_
drop if year == 2010 

rename *_ * 

* -----

* Consumption:

preserve 

foreach var of varlist shock_* {

	bys year cons_pc_q_baseline: egen mean_`var' = mean(`var')
}


foreach var of varlist shock_* {

	bys rural cons_pc_q_baseline: egen mean_allys_`var' = mean(`var')
}

format year %5.0f

collapse mean_* shock_*, by(year rural cons_pc_q_baseline)

foreach var of varlist shock_* mean_* {

	replace `var' = `var'/3 // go from 3-yearly to yearly incidence
}

local s rural == 1
twoway connected mean_shock_any cons_pc_q_baselin if year == 2013 & `s' || ///
	   connected mean_shock_any cons_pc_q_baselin if year == 2016 & `s',   ///
	   ytitle("Yearly Incidence -- Any shock") 							   ///
	   legend(order(1 "2013" 2 "2016"))									   ///
	   xtitle("Baseline consumption level quintile")
	   
local s rural == 1
twoway connected shock_any cons_pc_q_baselin if year == 2013 & `s' || 	   ///
	   connected shock_any cons_pc_q_baselin if year == 2016 & `s',		   ///
	   ytitle("Yearly Incidence -- Any shock") 							   ///
	   legend(order(1 "2013" 2 "2016") row(1))							   ///
	   xtitle("Baseline consumption level quintile") title("Rural")		   ///

cd "$projdir/out/elca/"
graph save g1.gph, replace

local s rural == 0
twoway connected shock_any cons_pc_q_baselin if year == 2013 & `s' || 	   ///
	   connected shock_any cons_pc_q_baselin if year == 2016 & `s',		   ///
	   ytitle("Yearly Incidence -- Any shock") 							   ///
	   legend(order(1 "2013" 2 "2016") row(1))							   ///
	   xtitle("Baseline consumption level quintile") title("Urban")		   ///
	   ylab(0.16(0.02)0.26)
	   
cd "$projdir/out/elca/"
graph save g2.gph, replace

grc1leg g1.gph g2.gph

graph export "elca_anyshock_baselinecons_ruralurban.png", replace

erase g1.gph 
erase g2.gph

foreach type in lostjob accident_illnss 					   	   		   ///
				criminality natdisast {

	local s rural == 1
	twoway connected shock_`type' cons_pc_q_baselin 					   ///
		   if year == 2013 & `s' ||   								       ///
		connected shock_`type' cons_pc_q_baselin 						   ///
		   if year == 2016 & `s',	   									   ///
		ytitle("Yearly Incidence") 						       			   ///
		legend(order(1 "2013" 2 "2016") row(1))							   ///
		xtitle("Baseline consumption level quintile") 					   ///
		title("Rural -- `type'")	

	cd "$projdir/out/elca/"
	graph save g`type'_r.gph, replace

	cd "$projdir/out/elca/"
	graph export "elca_`type'_baselinecons_rural.png", replace

	local s rural == 0
	twoway connected shock_`type' cons_pc_q_baselin 					   ///
		if year == 2013 & `s' ||   										   ///
		connected shock_`type' cons_pc_q_baselin 						   ///
		if year == 2016 & `s',	   										   ///
		ytitle("Yearly Incidence") 						       			   ///
		legend(order(1 "2013" 2 "2016") row(1))							   ///
		xtitle("Baseline consumption level quintile") 					   ///
		title("Urban -- `type'")
		
	cd "$projdir/out/elca/"
	graph export "elca_`type'_baselinecons_urban.png", replace

	cd "$projdir/out/elca/"
	graph save g`type'_u.gph, replace

}

cd "$projdir/out/elca/"
grc1leg glostjob_r.gph gaccident_illnss_r.gph 							   ///
		gcriminality_r.gph gnatdisast_r.gph

graph export "elca_shocks_baselinecons_rural.png", replace

cd "$projdir/out/elca/"
grc1leg glostjob_u.gph gaccident_illnss_u.gph 							   ///
		gcriminality_u.gph gnatdisast_u.gph

graph export "elca_shocks_baselinecons_urban.png", replace

cd "$projdir/out/elca/"
grc1leg gnatdisast_r.gph gnatdisast_u.gph

foreach g in glostjob_r.gph gaccident_illnss_r.gph 						   ///
			 gcriminality_r.gph gnatdisast_r.gph						   ///
			 glostjob_u.gph gaccident_illnss_u.gph 						   ///
			 gcriminality_u.gph gnatdisast_u.gph {

	erase `g'
}

local s year == 2013
twoway connected mean_allys_shock_any cons_pc_q_baseli if rura == 1 & `s', ///
	   lcolor(black) mcolor(black) lpattern(solid)|| 					   ///
	   connected mean_allys_shock_any cons_pc_q_baseli if rura == 0 & `s', ///
	   lcolor(blue%50) lpattern(longdash) mcolor(blue%50) msymbol(s) 	   ///
	   ytitle("Yearly Incidence") 							   ///
	   legend(order(1 "Rural" 2 "Urban"))							       ///
	   xtitle("Baseline consumption level quintile") 					   ///
	   title("All shocks")

cd "$projdir/out/elca/"  
graph export "elca_anyshock_baselinecons_allys.png", replace

foreach type in lostjob accident_illnss 					   	   		   ///
				criminality natdisast {

local s year == 2013
twoway connected mean_allys_shock_`type' cons_pc_q_baselin 				   ///
	   if rural == 1 & `s', lcolor(black) mcolor(black) lpattern(solid)||  ///
	   connected mean_allys_shock_`type' cons_pc_q_baselin 				   ///
	   if rural == 0 & `s', 											   ///
	   lcolor(blue%50) lpattern(longdash) mcolor(blue%50) msymbol(s) 	   ///
	   ytitle("Yearly Incidence") 							   			   ///
	   legend(order(1 "Rural" 2 "Urban"))								   ///
	   xtitle("Baseline consumption level quintile") 					   ///
	   title("`type'")
	
	cd "$projdir/out/elca/"
	graph export "elca_`type'_baselinecons_allys.png", replace

}

restore

* -----------------

* income:
 
foreach var of varlist shock_* {

	bys year income_pc_q_baseline: egen mean_`var' = mean(`var')
}


foreach var of varlist shock_* {

	bys rural income_pc_q_baseline: egen mean_allys_`var' = mean(`var')
}

format year %5.0f

collapse mean_* shock_*, by(year rural income_pc_q_baseline)

foreach var of varlist shock_* mean_* {

	replace `var' = `var'/3 // go from 3-yearly to yearly incidence
}

local s rural == 1
twoway connected mean_shock_any income_pc_q_basel if year == 2013 & `s' || ///
	   connected mean_shock_any income_pc_q_basel if year == 2016 & `s',   ///
	   ytitle("Yearly Incidence -- Any shock") 							   ///
	   legend(order(1 "2013" 2 "2016"))									   ///
	   xtitle("Baseline income level quintile")
	   
local s rural == 1
twoway connected shock_any income_pc_q_baseline if year == 2013 & `s' ||   ///
	   connected shock_any income_pc_q_baseline if year == 2016 & `s',     ///
	   ytitle("Yearly Incidence -- Any shock") 							   ///
	   legend(order(1 "2013" 2 "2016") row(1))							   ///
	   xtitle("Baseline income level quintile") title("Rural")		       ///

cd "$projdir/out/elca/"
graph save g1.gph, replace

local s rural == 0
twoway connected shock_any income_pc_q_baseline if year == 2013 & `s' ||   ///
	   connected shock_any income_pc_q_baseline if year == 2016 & `s',	   ///
	   ytitle("Yearly Incidence -- Any shock") 							   ///
	   legend(order(1 "2013" 2 "2016") row(1))							   ///
	   xtitle("Baseline income level quintile") title("Urban")		       ///
	   ylab(0.16(0.02)0.26)
	   
cd "$projdir/out/elca/"
graph save g2.gph, replace

grc1leg g1.gph g2.gph

graph export "elca_anyshock_baselineinc_ruralurban.png", replace

erase g1.gph 
erase g2.gph

foreach type in lostjob accident_illnss 					   	   		   ///
				criminality natdisast {

	local s rural == 1
	twoway connected shock_`type' income_pc_q_baseline 					   ///
		   if year == 2013 & `s' ||   								       ///
		connected shock_`type' income_pc_q_baseline 					   ///
		   if year == 2016 & `s',	   									   ///
		ytitle("Yearly Incidence") 						       			   ///
		legend(order(1 "2013" 2 "2016") row(1))							   ///
		xtitle("Baseline income level quintile") 					   	   ///
		title("Rural -- `type'")	

	cd "$projdir/out/elca/"
	graph save g`type'_r.gph, replace

	cd "$projdir/out/elca/"
	graph export "elca_`type'_baselineinc_rural.png", replace

	local s rural == 0
	twoway connected shock_`type' income_pc_q_baseline 					   ///
		if year == 2013 & `s' ||   										   ///
		connected shock_`type' income_pc_q_baseline 					   ///
		if year == 2016 & `s',	   										   ///
		ytitle("Yearly Incidence") 						       			   ///
		legend(order(1 "2013" 2 "2016") row(1))							   ///
		xtitle("Baseline consumption level quintile") 					   ///
		title("Urban -- `type'")
		
	cd "$projdir/out/elca/"
	graph export "elca_`type'_baselineinc_urban.png", replace

	cd "$projdir/out/elca/"
	graph save g`type'_u.gph, replace

}

cd "$projdir/out/elca/"
grc1leg glostjob_r.gph gaccident_illnss_r.gph 							   ///
		gcriminality_r.gph gnatdisast_r.gph

graph export "elca_shocks_baselineinc_rural.png", replace

cd "$projdir/out/elca/"
grc1leg glostjob_u.gph gaccident_illnss_u.gph 							   ///
		gcriminality_u.gph gnatdisast_u.gph

graph export "elca_shocks_baselineinc_urban.png", replace

cd "$projdir/out/elca/"
grc1leg gnatdisast_r.gph gnatdisast_u.gph

foreach g in glostjob_r.gph gaccident_illnss_r.gph 						   ///
			 gcriminality_r.gph gnatdisast_r.gph						   ///
			 glostjob_u.gph gaccident_illnss_u.gph 						   ///
			 gcriminality_u.gph gnatdisast_u.gph {

	erase `g'
}

local s year == 2013
twoway connected mean_allys_shock_any income_pc_q_base if rura == 1 & `s', ///
	   lcolor(black) mcolor(black) lpattern(solid)|| 					   ///
	   connected mean_allys_shock_any income_pc_q_base if rura == 0 & `s', ///
	   lcolor(blue%50) lpattern(longdash) mcolor(blue%50) msymbol(s) 	   ///
	   ytitle("Yearly Incidence") 							   			   ///
	   legend(order(1 "Rural" 2 "Urban"))							       ///
	   xtitle("Baseline income level quintile") 					   	   ///
	   title("All shocks")

cd "$projdir/out/elca/"  
graph export "elca_anyshock_baselineinc_allys.png", replace

foreach type in lostjob accident_illnss 							   	   ///
				criminality natdisast {

local s year == 2013
twoway connected mean_allys_shock_`type' income_pc_q_base 				   ///
	   if rural == 1 & `s', lcolor(black) mcolor(black) lpattern(solid)||  ///
	   connected mean_allys_shock_`type' income_pc_q_base 				   ///
	   if rural == 0 & `s', 											   ///
	   lcolor(blue%50) lpattern(longdash) mcolor(blue%50) msymbol(s) 	   ///
	   ytitle("Yearly Incidence") 							   			   ///
	   legend(order(1 "Rural" 2 "Urban"))								   ///
	   xtitle("Baseline income level quintile") 					   	   ///
	   title("`type'")
	
	cd "$projdir/out/elca/"
	graph export "elca_`type'_baselineinc_allys.png", replace

}

* -------------------------------------------------------------------