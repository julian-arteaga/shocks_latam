* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute shock incidence summary statistics ENAHO 2013-2023:

* -----------------

cd "$projdir/dta/cln/ENAHO"
use "enaho_yr_incidence_13_23.dta", clear

scatter mean_shock_natdisast mean_shock_accident_illnss mean_shock_lostjob ///
	    mean_shock_criminality 					    					   ///
	    year if rural == 1, 								   			   ///
		xlab(2013(2)2023) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") col(1))   		   						   ///
	 	ytit("Yearly Incidence") xtit("")

cd "$projdir/out/enaho"
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

cd "$projdir/out/enaho"
graph export "enaho_anyshock_incidence.png", replace

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
	    shock_criminality  			   					   				   ///
	    year if rural == 1, 								   			   ///
		xlab(2013(2)2023) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality") pos(6) row(2))    		   				   ///
	 	ytit("Yearly Incidence") xtit("") tit("Rural") ylab(0(0.05)0.25)

cd "$projdir/out/enaho"
graph save g1.gph, replace

scatter shock_natdisast shock_accident_illnss shock_lostjob 			   ///
	    shock_criminality 				 			   					   ///
	    year if rural == 0, 								   			   ///
		xlab(2013(2)2023) connect(line line line line line line)		   ///
	 	legend(order(1 "Nat. Disaster" 2 "Accident/Illness" 3 "Job Loss"   ///
	 		   4 "Criminality" ) pos(6) row(2))    		   				   ///
	 	ytit("Yearly Incidence") xtit("") tit("Urban") ylab(0(0.05)0.25)

cd "$projdir/out/enaho"
graph save g2.gph, replace

grc1leg g1.gph g2.gph

graph export "enaho_shocks_incidence_ruralurban.png", replace

erase g1.gph 
erase g2.gph

* -----------------------------------------------

* Correlate with consumption levels (2013-2016 only)

cd "$projdir/dta/cln/ENAHO"
use "enaho_shock_prevalence_hhlvl_13_23.dta", clear

drop shock_bankrupcy // keep only 4 shock categories

merge 1:1 year conglome vivienda hogar using 							   ///
	"$projdir/dta/cln/ENAHO/enaho_income_expendit_hhlvl_13_23"

drop _merge // all == 3

egen hhid = group(conglome vivienda hogar)

drop if inlist(., shock_lostjob, shock_accident_illnss,    				   ///
				  shock_criminality, shock_natdisast, shock_deathmember)

* Keep only households with at least two years of responses:

bys hhid: gen numys = _N 
keep if numys > 1 // left with 110,770 obs across 36,452 households

xtset hhid year
sort hhid year 

gen percexp_baseline = percexp[_n-1] if hhid == hhid[_n-1]

gen rural_baseline = rural[_n-1] if hhid == hhid[_n-1]

egen inc_pc_q = xtile(percinc), n(5) by(rural year) 

egen exp_pc_q = xtile(percexp), n(5) by(rural year) 

egen exp_pc_all_q = xtile(percexp), n(5) by(year) 

gen inc_pc_q_baseline = inc_pc_q[_n-1]  if hhid == hhid[_n-1]
gen exp_pc_q_baseline = exp_pc_q[_n-1]  if hhid == hhid[_n-1]
gen exp_pc_q_pre_all = exp_pc_all_q[_n-1]  if hhid == hhid[_n-1]

drop if inc_pc_q_baseline == . | exp_pc_q_baseline == .

replace shock_accident_illnss = 								   	    ///
		inlist(1, shock_accident_illnss, shock_deathmember)

drop shock_deathmember

gen shock_any = shock_natdisast + shock_accident_illnss  		   		   ///
	    	   + shock_lostjob + shock_criminality > 0 

distinct hhid // 36452
bys rural_baseline: distinct hhid  // 21761 urban; 14691 rural

cd "$projdir/dta/cln/ENAHO"
save "enaho_hhchars_shock_panel.dta", replace

// drop if year > 2019 // pre-covid

foreach var of varlist shock_* {

	bys rural_baseline inc_pc_q_baseline: egen inclag_`var' = mean(`var')
	bys rural inc_pc_q: egen inc_`var' = mean(`var')

	bys rural_baseline exp_pc_q_baseline: egen explag_`var' = mean(`var')
	bys rural exp_pc_q: egen exp_`var' = mean(`var')

	bys exp_pc_q_pre_all: egen expall_`var' = mean(`var')

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

drop inc_pc_q inc_pc_q_baseline exp_pc_q exp_pc_q_baseline 				   ///
	 vivienda hogar year numys hhid percinc percexp						   ///
	 shock* conglome rural exp_pc_all_q

gen i = _n

reshape long inclag_shock_ inc_shock_ explag_shock_ exp_shock_ 			   ///
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

* -----
compress 
cd "$projdir/dta/cln/ENAHO"
save "enaho_mean_incidence_rural_inc_q.dta", replace
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

	cd "$projdir/out/enaho"
	graph export "enaho_`t'_preinc.png", replace

	twoway connected inc_shock q if rural == 1 & shock == "`t'", 	   	   ///
		lcolor(black) mcolor(black) lpattern(solid) || 					   ///
		connected  inc_shock q if rural == 0 & shock == "`t'",    	   	   ///
		lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "Rural" 2 "Urban"))							       ///
		xtitle("post-shock income level quintile") 			       		   ///
		title("`t'")

	cd "$projdir/out/enaho"
	graph export "enaho_`t'_postinc.png", replace

	twoway connected explag_shock q if rural == 1 & shock == "`t'", 	   ///
		lcolor(black) mcolor(black) lpattern(solid) || 					   ///
		connected explag_shock q if rural == 0 & shock == "`t'",    	   ///
		lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "Rural" 2 "Urban"))							       ///
		xtitle("pre-shock expenditure level quintile") 			       	   ///
		title("`t'")

	cd "$projdir/out/enaho"
	graph export "enaho_`t'_preexp.png", replace

	twoway connected exp_shock q if rural == 1 & shock == "`t'", 	   	   ///
		lcolor(black) mcolor(black) lpattern(solid) || 					   ///
		connected exp_shock q if rural == 0 & shock == "`t'",    	   	   ///
		lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "Rural" 2 "Urban"))							       ///
		xtitle("post-shock expenditure level quintile") 			       ///
		title("`t'")

	cd "$projdir/out/enaho"
	graph export "enaho_`t'_postexp.png", replace

}

* -------------------------------------------------------------------

	twoway connected explag_shock q if rural_ == 0 & shock == "any", 	   ///
		lcolor(black) mcolor(black) lpattern(solid) 
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "All households"))							       ///
		xtitle("pre-shock expenditure level quintile") 			       	   ///
		title("All shocks")
