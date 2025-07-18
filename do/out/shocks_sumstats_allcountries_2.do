* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Household-level regressions of shocks vs pre- and post-expenditure level

cd "$projdir/dta/cln/ENAHO"
use "enaho_hhchars_shock_panel.dta", clear

gen cty = "PER"

cd "$projdir/dta/cln/ELCA"
append using "elca_hhpanel_10_13_16.dta"

replace cty = "COL" if cty == ""

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_hhpanel_02_05_09.dta" 

replace cty = "MEX" if cty == ""

cd "$projdir/dta/cln/LTSLV"
append using "ltslv_hhpanel_11_13.dta" 

replace cty = "SLV" if cty == ""

cd "$projdir/dta/cln/FAODIEM_HTI"
append using "faodiem_HTI_hhpanel_r3r6.dta" 

replace cty = "HTI" if cty == ""

gen date = dofy(year)

bys round: egen med_date = median(round_date)

replace date = med_date if year == .

gen yq = qofd(date)
format yq %tq
sort yq cty

tab yq cty

rename shock_accident_illnss shock_health 

gen percses_baseline = percexp_baseline 

replace percses_baseline = percinc_baseline if percexp_baseline == . 

drop if  percses_baseline == .

* Express all in 2016 dollars:

foreach var of varlist percses_baseline {
    
    replace `var' = `var' if cty == "SAL" // Really need to check this
    replace `var' = (`var' / 57.210) * 4 if cty == "HTI" // make yearly
    replace `var' = (`var' / 3.307) * 12    if cty == "PER" // also make yearly
	replace `var' = `var' / 17.35290 if cty == "MEX"
	replace `var' = `var' / 3149.47 if cty == "COL"
}


keep cty yq shock_any shock_lostjob shock_health shock_natdisast shock_crim /// 
     percses_baseline rural_baseline 

replace rural_baseline = 1 if cty == "HTI"
replace rural_baseline = 0 if cty == "SLV"

gen logpercses_baseline = log(percses_baseline)

* -------------------------------------

egen cty_id =group(cty)

eststo m1: reg shock_any logpercses_baseline 
eststo m2: reg shock_any logpercses_baseline i.cty_id i.yq
eststo m3: reg shock_any logpercses_baseline i.cty_id i.yq rural_baseline

eststo m4: reg shock_any logpercses_baseline i.cty_id i.yq if rural_baseline == 0
eststo m5: reg shock_any logpercses_baseline i.cty_id i.yq if rural_baseline == 1

esttab m1 m2 m3 m4 m5, keep(logpercses_baseline) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations")) 

* Run regressions and store estimates
eststo m1: reg shock_any logpercses_baseline
estadd local cty_FE "No"
estadd local year_FE "No"
estadd local zone_FE "No"

eststo m2: reg shock_any logpercses_baseline i.cty_id i.yq
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "No"

eststo m3: reg shock_any logpercses_baseline i.cty_id i.yq rural_baseline
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "Yes"

eststo m4: reg shock_any logpercses_baseline i.cty_id i.yq if rural_baseline == 0
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "No"

eststo m5: reg shock_any logpercses_baseline i.cty_id i.yq if rural_baseline == 1
estadd local cty_FE "Yes"
estadd local year_FE "Yes"
estadd local zone_FE "No"

cd "$projdir/out/"
esttab m1 m2 m3 m4 m5 using "prob_anyshock_logpercses.tex", 			   ///
    keep(logpercses_baseline) se star(* 0.1 ** 0.05 *** 0.01) 			   ///
    mtitle("Any shock" "Any shock" "Any shock" 							   ///
           "Any shock - Urban" "Any shock - Rural") 				       ///
    varlabels(logpercses_baseline "Baseline Household SES") 	           ///
    stats(cty_FE year_FE zone_FE N, 									   ///
          labels("Country Fixed Effects" 								   ///
                 "Year Fixed Effects" 									   ///
                 "Zone Fixed Effects" "Observations")) 					   ///
    label nonotes replace

* ------

estimates clear

eststo a1: reg shock_any logpercses_baseline 
eststo a2: reg shock_any logpercses_baseline i.cty_id i.yq
eststo a3: reg shock_any logpercses_baseline i.cty_id i.yq rural_baseline

eststo b1: reg shock_lostjob logpercses_baseline 
eststo b2: reg shock_lostjob logpercses_baseline i.cty_id i.yq
eststo b3: reg shock_lostjob logpercses_baseline i.cty_id i.yq rural_baseline

eststo c1: reg shock_health logpercses_baseline 
eststo c2: reg shock_health logpercses_baseline i.cty_id i.yq
eststo c3: reg shock_health logpercses_baseline i.cty_id i.yq rural_baseline

eststo d1: reg shock_criminality logpercses_baseline 
eststo d2: reg shock_criminality logpercses_baseline i.cty_id i.yq
eststo d3: reg shock_criminality logpercses_baseline i.cty_id i.yq rural_baseline

eststo e1: reg shock_natdisast logpercses_baseline 
eststo e2: reg shock_natdisast logpercses_baseline i.cty_id i.yq
eststo e3: reg shock_natdisast logpercses_baseline i.cty_id i.yq rural_baseline

coefplot ///
    (a1, rename(logpercses_baseline = "Any Shock") ///
        offset(-0.2) mcolor(black) ///
        ciopts(lcolor(black))) ///
    (a2, rename(logpercses_baseline = "Any Shock") ///
        label("any_shock") offset(0) mcolor(stblue) ///
        ciopts(lcolor(stblue))) ///
    (a3, rename(logpercses_baseline = "Any Shock") ///
        label("any_shock") offset(0.2) mcolor(stred) ///
        ciopts(lcolor(stred))) ///
    (b1, rename(logpercses_baseline = "Employment Shock") ///
        label("Employment Shock") offset(-0.2) mcolor(black) ///
        ciopts(lcolor(black))) ///
    (b2, rename(logpercses_baseline = "Employment Shock") ///
        label("shock_lostjob") offset(0) mcolor(stblue) ///
        ciopts(lcolor(stblue))) ///
    (b3, rename(logpercses_baseline = "Employment Shock") ///
        label("shock_lostjob") offset(0.2) mcolor(stred) ///
        ciopts(lcolor(stred))) ///
    (c1, rename(logpercses_baseline = "Health Shock") ///
        label("shock_health") offset(-0.2) mcolor(black) ///
        ciopts(lcolor(black))) ///
    (c2, rename(logpercses_baseline = "Health Shock") ///
        label("shock_health") offset(0) mcolor(stblue) ///
        ciopts(lcolor(stblue))) ///
    (c3, rename(logpercses_baseline = "Health Shock") ///
        label("shock_health") offset(0.2) mcolor(stred) ///
        ciopts(lcolor(stred))) ///
    (d1, rename(logpercses_baseline = "Criminality") ///
        label("shock_criminality") offset(-0.2) mcolor(black) ///
        ciopts(lcolor(black))) ///
    (d2, rename(logpercses_baseline = "Criminality") ///
        label("shock_criminality") offset(0) mcolor(stblue) ///
        ciopts(lcolor(stblue))) ///
    (d3, rename(logpercses_baseline = "Criminality") ///
        label("shock_criminality") offset(0.2) mcolor(stred) ///
        ciopts(lcolor(stred))) ///
    (e1, rename(logpercses_baseline = "Nat. Disaster") ///
        label("shock_natdisast") offset(-0.2) mcolor(black) ///
        ciopts(lcolor(black))) ///
    (e2, rename(logpercses_baseline = "Nat. Disaster") ///
        label("shock_natdisast") offset(0) mcolor(stblue) ///
        ciopts(lcolor(stblue))) ///
    (e3, rename(logpercses_baseline = "Nat. Disaster") ///
        label("shock_natdisast") offset(0.2) mcolor(stred) ///
        ciopts(lcolor(stred))), ///
    keep(logpercses_baseline) xline(0, lcolor(black%50) lpattern(dash))    ///
    legend(order(2 "No FE" 												   ///
				 4 "Country and Year FE" 								   ///
				 6 "Country, Year, and Zone FE") pos(6) row(1))			   ///
	xtitle("{&Delta} Shock Probability")

cd "$projdir/out/"
graph export "coefplot_probshock_logpercses_pre.png", replace

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