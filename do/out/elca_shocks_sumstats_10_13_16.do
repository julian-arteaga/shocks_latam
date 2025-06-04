* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute shock incidence summary statistics ELCA 2013-2019:

* -----------------

cd "$projdir/dta/cln/ELCA"
use "elca_shock_prevalence_hhlvl_13_16.dta", clear

gen elca_hh = 1

append using "elca_shock_prevalence_hhlvl_19.dta"
drop transfer*
drop if elca_hh != 1

replace year = 2019 if ola == .

gen rural = urban == 0 |  zona_2016 == 2 | zona_2013 == 2

keep shock_natdisast shock_accident_illnss 								   ///
	 shock_lostjob shock_criminality shock_deathme llave_n16 llave year rural

drop if inlist(., shock_lostjob, shock_accident_illnss,    				   ///
				  shock_criminality, shock_natdisast, shock_deathmember)

replace shock_accident_illnss = 										    ///
		inlist(1, shock_accident_illnss, shock_deathmember)

drop shock_deathmember

gen shock_any = shock_natdisast + shock_accident_illnss  		   		   ///
	    	   + shock_lostjob + shock_criminality > 0			   		   
			   
foreach var of varlist shock_* {

	bys year: egen mean_`var' = mean(`var')
}

collapse mean_* shock_*, by(year rural)

foreach var of varlist shock_* mean_* {

	replace `var' = `var'/3 // go from 3-yearly to yearly incidence
}

cd "$projdir/out/elca/"

scatter mean_shock_natdisast mean_shock_accident_illnss mean_shock_lostjob ///
	    mean_shock_criminality 											   ///
	    year if rural == 1, 								   			   ///
		xlab(2013(3)2019) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") col(1))   		   			   			   ///
	 	ytit("Yearly Incidence") xtit("")

graph export "elca_shocks_incidence.png", replace

twoway connected mean_shock_any year if rural == 1, 					   ///		
	   lpattern(solid) mcolor(black) lcolor(black)|| 					   ///
	   connected shock_any year if rural == 1, 							   ///
	   lpattern(dash) mcolor(stblue) lcolor(stblue) msymbol(t)|| 		   ///
	   connected shock_any year if rural == 0, 							   ///
	   lpattern(dash_dot) mcolor(stred) lcolor(stred)	msymbol(s)		   ///
	   xlab(2013(3)2019) 	   											   ///
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
    , xlab(2013(3)2019) xtitle("") ytitle("Yearly Incidence") 			   ///
	legend(order(1 "Mean shock (rural)" 2 "Shock (rural)" 				   ///  
				 3 "Shock (urban)")) 

scatter shock_natdisast shock_accident_illnss shock_lostjob 			   ///
	    shock_criminality  								    			   ///
	    year if rural == 1, 								   			   ///
		xlab(2013(3)2019) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") pos(6) row(2))    						   ///
	 	ytit("Yearly Incidence") xtit("") tit("Rural") ylab(0(0.05)0.2)

cd "$projdir/out/elca/"
graph save g1.gph, replace

scatter shock_natdisast shock_accident_illnss shock_lostjob 			   ///
	    shock_criminality  								    			   ///
	    year if rural == 0, 								   			   ///
		xlab(2013(3)2019) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") pos(6) row(2))    						   ///
	 	ytit("Yearly Incidence") xtit("") tit("Urban") ylab(0(0.05)0.2)

cd "$projdir/out/elca/"
graph save g2.gph, replace

grc1leg g1.gph g2.gph

graph export "elca_shocks_incidence_ruralurban.png", replace

erase g1.gph 
erase g2.gph

* -----------------------------------------------

* Correlate with income and consumption levels (2013-2016 only)

cd "$projdir/dta/cln/ELCA"
use "elca_shock_prevalence_hhlvl_13_16.dta", clear

gen zona = zona_2016 
replace zona = zona_2013 if zona == . 

gen rural = zona == 2 

keep llave_n16 llave ola rural											   ///
	 shock_natdisast shock_accident_illnss shock_lostjob 			   	   ///
	 shock_criminality shock_deathmember

foreach i of varlist shock_* rural {
			 
		gen `i'_2=`i' if ola==2	
		bys llave: egen `i'_2013=max(`i'_2)
		drop `i'_2
		 
		rename `i' `i'_2016
}

drop if llave_n16 == .

merge 1:1 llave_n16 using "vars_elca_private.dta"
drop if _merge != 3
drop _merge

drop consumo_total_pc* // update with new consumption

merge 1:1 llave_n16 using "elca_consumption_hhlvl_10_13_16.dta"
drop if _merge != 3
drop _merge 

gen rural_2010 = zona_2010 == 2

gen percinc_2010 = ingtot_2010 / numperh_2010
gen percinc_2013 = ingtot_2013 / numperh_2013
gen percinc_2016 = ingtot_2016 / numperh_2016

rename consumo_total_pc_2010 percexp_2010
rename consumo_total_pc_2013 percexp_2013
rename consumo_total_pc_2016 percexp_2016

keep llave_n16  llave rural* shock_natdisast* shock_accident_illnss*       ///
	 shock_lostjob* shock_criminality* shock_deathmember* percexp_* 	   ///
	 percinc_*

reshape long rural_											   			   ///
	 shock_natdisast_ shock_accident_illnss_ shock_lostjob_			   	   ///
	 shock_criminality_ shock_deathmember_ percinc_ percexp_, 			   ///
	 i(llave_n16) j(year) string

rename *_ *

destring year, replace 

drop if year != 2010 & inlist(., shock_lostjob, shock_accident_illnss,     ///
				  shock_criminality, shock_natdisast, shock_deathmember)

* Keep only households with at least two years of responses:

bys llave_n16: gen numys = _N 
keep if numys > 1 // left with 21,777 obs across 7735 households

egen hhid = group(llave_n16)

xtset hhid year
sort hhid year 

gen rural_baseline = rural[_n-1] if hhid == hhid[_n-1]

egen inc_pc_q = xtile(percinc), n(5) by(rural year) 

egen exp_pc_q = xtile(percexp), n(5) by(rural year) 

egen exp_pc_all_q = xtile(percexp), n(5) by(year) 

drop if inlist(., percinc, percexp) // 0 obs

xtset llave_n16 year
sort llave_n16 year 

gen percexp_baseline = percexp[_n-1] if hhid == hhid[_n-1]

gen inc_pc_q_baseline = inc_pc_q[_n-1] if hhid == hhid[_n-1]
gen exp_pc_q_baseline = exp_pc_q[_n-1]  if hhid == hhid[_n-1]
gen exp_pc_q_pre_all = exp_pc_all_q[_n-1]  if hhid == hhid[_n-1]

drop if inc_pc_q_baseline == . | exp_pc_q_baseline == .

replace shock_accident_illnss = 										    ///
		inlist(1, shock_accident_illnss, shock_deathmember)

drop shock_deathmember

gen shock_any = shock_natdisast + shock_accident_illnss  		   		   ///
	    	   + shock_lostjob + shock_criminality > 0

distinct hhid // 8314
bys rural_baseline: distinct hhid  // 4285 urban; 4273 rural

cd "$projdir/dta/cln/ELCA"
save "elca_hhchars_shock_panel.dta", replace

foreach var of varlist shock_* {

	bys rural_baseline inc_pc_q_baseline: egen inclag_`var' = mean(`var')
	bys rural inc_pc_q: egen inc_`var' = mean(`var')

	bys rural_baseline exp_pc_q_baseline: egen explag_`var' = mean(`var')
	bys rural exp_pc_q: egen exp_`var' = mean(`var')

	bys exp_pc_q_pre_all: egen expall_`var' = mean(`var')

	* 3-yearly to yearly incidence:
	replace inclag_`var' = inclag_`var' / 3
	replace inc_`var' = inc_`var' / 3
	replace explag_`var' = explag_`var' / 3
	replace exp_`var' = exp_`var' / 3
	replace expall_`var' = expall_`var' / 3

	foreach q in 1 2 3 4 5 {

		bys rural_baseline: egen inclag_`var'_q`q' = 					   ///
				mean(cond(inc_pc_q_baseline == `q', inclag_`var', .))

		bys rural: egen inc_`var'_q`q' = 					       	   	   ///  
				mean(cond(inc_pc_q == `q', inc_`var', .))

		bys rural_baseline: egen explag_`var'_q`q' = 					   ///
				mean(cond(exp_pc_q_baseline == `q', explag_`var', .))

		bys rural: egen exp_`var'_q`q' = 					       	   	   ///  
				mean(cond(exp_pc_q == `q', exp_`var', .))		

		egen expall_`var'_q`q' = 						   	   			   ///
				mean(cond(exp_pc_q_pre_all == `q', expall_`var', .))
	}

	drop  inclag_`var' inc_`var' exp_`var' explag_`var' expall_`var'
}

bys rural_baseline: keep if _n == 1

drop inc_pc_q inc_pc_q_baseline	exp_pc_q exp_pc_q_baseline 			 	   ///
	 exp_pc_q_pre_all year numys hhid percinc percexp shock* rural 		   ///
	 exp_pc_all_q

gen i = _n

reshape long inclag_shock_ inc_shock_ explag_shock_ 					   ///
		exp_shock_ expall_shock_, i(i) j(shock) string

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

* -----
compress 
cd "$projdir/dta/cln/ELCA"
save "elca_mean_incidence_rural_inc_q.dta", replace
* -----

foreach t in any lostjob natdisast accident-illness criminality {

	twoway connected inclag_shock q if rural == 1 & shock == "`t'", 	   ///
		lcolor(black) mcolor(black) lpattern(solid) || 					   ///
		connected  inclag_shock q if rural == 0 & shock == "`t'",    	   ///
		lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "Rural" 2 "Urban"))							       ///
		xtitle("pre-shock income level quintile") 			      		   ///
		title("`t'")

	cd "$projdir/out/elca"
	graph export "elca_`t'_preinc.png", replace

	twoway connected inc_shock q if rural == 1 & shock == "`t'", 	   	   ///
		lcolor(black) mcolor(black) lpattern(solid) || 					   ///
		connected  inc_shock q if rural == 0 & shock == "`t'",    	   	   ///
		lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "Rural" 2 "Urban"))							       ///
		xtitle("post-shock income level quintile") 			       		   ///
		title("`t'")

	cd "$projdir/out/elca"
	graph export "elca_`t'_postinc.png", replace

	twoway connected explag_shock q if rural == 1 & shock == "`t'", 	   ///
		lcolor(black) mcolor(black) lpattern(solid) || 					   ///
		connected explag_shock q if rural == 0 & shock == "`t'",    	   ///
		lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "Rural" 2 "Urban"))							       ///
		xtitle("pre-shock expenditure level quintile") 			       	   ///
		title("`t'")

	cd "$projdir/out/elca"
	graph export "elca_`t'_preexp.png", replace

	twoway connected exp_shock q if rural == 1 & shock == "`t'", 	   	   ///
		lcolor(black) mcolor(black) lpattern(solid) || 					   ///
		connected exp_shock q if rural == 0 & shock == "`t'",    	   	   ///
		lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "Rural" 2 "Urban"))							       ///
		xtitle("post-shock expenditure level quintile") 			       ///
		title("`t'")

	cd "$projdir/out/elca"
	graph export "elca_`t'_postexp.png", replace
}

* -------------------------------------------------------------------

	twoway connected explag_shock q if rural_ == 0 & shock == "any", 	   ///
		lcolor(black) mcolor(black) lpattern(solid) 					   ///  
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "All households"))							       ///
		xtitle("pre-shock expenditure level quintile") 			       	   ///
		title("All shocks")