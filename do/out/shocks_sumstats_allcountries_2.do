* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Household-level regressions of shocks vs pre- and post-expenditure level

cd "$projdir/dta/cln/ENAHO"
use "enaho_hhchars_shock_panel.dta", clear

gen country = "PER"
gen cty = "Peru"

cd "$projdir/dta/cln/ELCA"
append using "elca_hhchars_shock_panel.dta"

replace country = "COL" if country == ""
replace cty = "Colombia" if cty == ""

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_hhchars_shock_panel.dta"

replace country = "MEX" if country == ""
replace cty = "Mexico" if cty == ""

* -------------------------------------

egen cty_id =group(country)
gen logpercexp_baseline = log(percexp_baseline)

eststo m1: reg shock_any logpercexp_baseline 
eststo m2: reg shock_any logpercexp_baseline i.cty_id i.year
eststo m3: reg shock_any logpercexp_baseline i.cty_id i.year rural_baseline

eststo m4: reg shock_any logpercexp_baseline i.cty_id i.year if rural_baseline == 0
eststo m5: reg shock_any logpercexp_baseline i.cty_id i.year if rural_baseline == 1

esttab m1 m2 m3 m4 m5, keep(logpercexp_baseline) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations")) 
* Run regressions and store estimates
eststo m1: reg shock_any logpercexp_baseline
estadd local cty_FE "No"
estadd local year_FE "No"
estadd local zone_FE "No"

eststo m2: reg shock_any logpercexp_baseline i.cty_id i.year
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "No"

eststo m3: reg shock_any logpercexp_baseline i.cty_id i.year rural_baseline
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "Yes"

eststo m4: reg shock_any logpercexp_baseline i.cty_id i.year if rural_baseline == 0
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "No"

eststo m5: reg shock_any logpercexp_baseline i.cty_id i.year if rural_baseline == 1
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "No"

cd "$projdir/out/"
esttab m1 m2 m3 m4 m5 using "prob_anyshock_logpercexp.tex", 			   ///
    keep(logpercexp_baseline) se star(* 0.1 ** 0.05 *** 0.01) 			   ///
    mtitle("Any shock" "Any shock" "Any shock" 							   ///
           "Any shock - Urban" "Any shock - Rural") 				       ///
    varlabels(logpercexp_baseline "Baseline Household Expenditure") 	   ///
    stats(cty_FE year_FE zone_FE N, 									   ///
          labels("Country Fixed Effects" 								   ///
                 "Year Fixed Effects" 									   ///
                 "Zone Fixed Effects" "Observations")) 					   ///
    label nonotes replace

* ------

estimates clear

eststo a1: reg shock_any logpercexp_baseline 
eststo a2: reg shock_any logpercexp_baseline i.cty_id i.year
eststo a3: reg shock_any logpercexp_baseline i.cty_id i.year rural_baseline

eststo b1: reg shock_lostjob logpercexp_baseline 
eststo b2: reg shock_lostjob logpercexp_baseline i.cty_id i.year
eststo b3: reg shock_lostjob logpercexp_baseline i.cty_id i.year rural_baseline

eststo c1: reg shock_accident_illnss logpercexp_baseline 
eststo c2: reg shock_accident_illnss logpercexp_baseline i.cty_id i.year
eststo c3: reg shock_accident_illnss logpercexp_baseline i.cty_id i.year rural_baseline

eststo d1: reg shock_criminality logpercexp_baseline 
eststo d2: reg shock_criminality logpercexp_baseline i.cty_id i.year
eststo d3: reg shock_criminality logpercexp_baseline i.cty_id i.year rural_baseline

eststo e1: reg shock_natdisast logpercexp_baseline 
eststo e2: reg shock_natdisast logpercexp_baseline i.cty_id i.year
eststo e3: reg shock_natdisast logpercexp_baseline i.cty_id i.year rural_baseline

coefplot ///
    (a1, rename(logpercexp_baseline = "Any Shock") ///
        offset(-0.2) mcolor(black) ///
        ciopts(lcolor(black))) ///
    (a2, rename(logpercexp_baseline = "Any Shock") ///
        label("any_shock") offset(0) mcolor(stblue) ///
        ciopts(lcolor(stblue))) ///
    (a3, rename(logpercexp_baseline = "Any Shock") ///
        label("any_shock") offset(0.2) mcolor(stred) ///
        ciopts(lcolor(stred))) ///
    (b1, rename(logpercexp_baseline = "Employment Shock") ///
        label("Employment Shock") offset(-0.2) mcolor(black) ///
        ciopts(lcolor(black))) ///
    (b2, rename(logpercexp_baseline = "Employment Shock") ///
        label("shock_lostjob") offset(0) mcolor(stblue) ///
        ciopts(lcolor(stblue))) ///
    (b3, rename(logpercexp_baseline = "Employment Shock") ///
        label("shock_lostjob") offset(0.2) mcolor(stred) ///
        ciopts(lcolor(stred))) ///
    (c1, rename(logpercexp_baseline = "Health Shock") ///
        label("shock_health") offset(-0.2) mcolor(black) ///
        ciopts(lcolor(black))) ///
    (c2, rename(logpercexp_baseline = "Health Shock") ///
        label("shock_health") offset(0) mcolor(stblue) ///
        ciopts(lcolor(stblue))) ///
    (c3, rename(logpercexp_baseline = "Health Shock") ///
        label("shock_health") offset(0.2) mcolor(stred) ///
        ciopts(lcolor(stred))) ///
    (d1, rename(logpercexp_baseline = "Criminality") ///
        label("shock_criminality") offset(-0.2) mcolor(black) ///
        ciopts(lcolor(black))) ///
    (d2, rename(logpercexp_baseline = "Criminality") ///
        label("shock_criminality") offset(0) mcolor(stblue) ///
        ciopts(lcolor(stblue))) ///
    (d3, rename(logpercexp_baseline = "Criminality") ///
        label("shock_criminality") offset(0.2) mcolor(stred) ///
        ciopts(lcolor(stred))) ///
    (e1, rename(logpercexp_baseline = "Nat. Disaster") ///
        label("shock_natdisast") offset(-0.2) mcolor(black) ///
        ciopts(lcolor(black))) ///
    (e2, rename(logpercexp_baseline = "Nat. Disaster") ///
        label("shock_natdisast") offset(0) mcolor(stblue) ///
        ciopts(lcolor(stblue))) ///
    (e3, rename(logpercexp_baseline = "Nat. Disaster") ///
        label("shock_natdisast") offset(0.2) mcolor(stred) ///
        ciopts(lcolor(stred))), ///
    keep(logpercexp_baseline) xline(0, lcolor(black%50) lpattern(dash))    ///
    legend(order(2 "No FE" 												   ///
				 4 "Country and Year FE" 								   ///
				 6 "Country, Year, and Zone FE") pos(6) row(1))			   ///
	

cd "$projdir/out/"

graph export "coefplot_probshock_logpercexp_pre.png", replace

* -------------------------------------

egen hh_cty_id = group(hhid country)
xtset hh_cty_id year

sort hh_cty_id year 

gen ldiff_percexp = log(percexp/percexp_baseline)

eststo d1: reg ldiff_percexp shock_any i.cty_id i.year rural_baseline
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "Yes"

eststo d2: reg ldiff_percexp shock_lostjob i.cty_id i.year rural_baseline
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "Yes"

eststo d3: reg ldiff_percexp shock_accident_illnss 						   ///
			   i.cty_id i.year rural_baseline
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "Yes"

eststo d4: reg ldiff_percexp shock_criminality i.cty_id i.year rural_baseline
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "Yes"

eststo d5: reg ldiff_percexp shock_natdisast i.cty_id i.year rural_baseline
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "Yes"

cd "$projdir/out/"	
esttab d1 d2 d3 d4 d5 using "reg_ldiffpercexp_shocks.tex", 				   ///
	keep(shock_*) se star(* 0.1 ** 0.05 *** 0.01) nomtitle 				   ///
	mgroup("Log difference in household expenditure", pattern(1 0 0 0 0 )  ///
		   prefix(\multicolumn{@span}{c}{) suffix(}) 					   ///
		   span erepeat(\cmidrule(lr){@span}))							   ///
	varlabels(shock_any "Any Shock" shock_lostjob "Employment shock"	   ///
			  shock_accident_illness "Health Shock" 					   ///
			  shock_criminality "Criminality"							   ///
			  shock_natdisast "Natural Disaster") 						   ///
    stats(cty_FE year_FE zone_FE N, 									   ///	
          labels("Country Fixed Effects" "Year Fixed Effects" 			   ///
                 "Zone Fixed Effects" "Observations")) nonotes replace
		
* -------------------------------------------------------------------