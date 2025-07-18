* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Incidence figures tables summary stats and misc.

* ---------------------------
 
* Country (survey) average incidence by shock type

cd "$projdir/dta/cln/ENAHO"
use "enaho_yr_incidence_13_23.dta", clear

gen cty = "PER"

cd "$projdir/dta/cln/ELCA"
append using "elca_yr_incidence_10_19.dta"

replace cty = "COL-ELCA" if cty == ""

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_yr_incidence_02_09.dta"

replace cty = "MEX" if cty == ""

cd "$projdir/dta/cln/FAODIEM"
append using "faodiem_allcty_yr_incidence.dta"

replace cty = "COL-DIEM" if cty == "COL"

cd "$projdir/dta/cln/LTSLV"
append using "ltslv_yr_incidence_11_13.dta"

replace cty = "SLV" if cty == ""

rename mean_shock_accident_illnss mean_shock_health
rename m_shock_accident_illnss m_shock_health
rename shock_accident_illnss shock_health 

foreach v in any natdisast health lostjob criminality {

	gen incid_shock_`v' = mean_shock_`v' 
	replace incid_shock_`v' = m_shock_`v' if incid_shock_`v' == .

	drop mean_shock_`v' m_shock_`v' shock_`v'
}

foreach v in any natdisast health lostjob criminality {

	bys cty: egen allyr_incid_`v' = mean(incid_shock_`v')
	drop incid_shock_`v'
}

bys cty: keep if _n == 1

keep cty allyr_incid_any allyr_incid_health allyr_incid_lostjob  		   ///
		  allyr_incid_natdisast allyr_incid_criminality 

order cty allyr_incid_any allyr_incid_health allyr_incid_lostjob  		   ///
		  allyr_incid_natdisast allyr_incid_criminality 

drop if cty == "COL-DIEM"

replace cty = "COL" if cty == "COL-ELCA"

* Manually add CS countries from LT tables:

set obs 11

replace cty = "CHL" in 8 
replace allyr_incid_health    = .4895456 in 8 
replace allyr_incid_natdisast = .1039423 in 8 

replace cty = "ECU" in 9 
replace allyr_incid_lostjob      = .19  in 9
replace allyr_incid_natdisast   = .1863 in 9 
replace allyr_incid_criminality = .0416 in 9
replace allyr_incid_health      = .1436 in 9 

replace cty = "DOM" in 10 
replace allyr_incid_lostjob     = .0985 in 10
replace allyr_incid_natdisast   = (.0143 + 0.0023) in 10 // add fire 
replace allyr_incid_criminality = .0416 in 10
replace allyr_incid_health      = .0428 in 10 

drop allyr_incid_any

cd "$projdir/out/allcty"
estimates clear 

replace cty = "z_Average" in 11 

foreach var of varlist allyr_inc* {

	egen m_`var' = mean(`var')
	replace `var' = m_`var' in 11
	drop m_`var'
}

gen survey_type = inlist(cty, "COL", "MEX", "PER", "SLV", "HTI")
label define svtype 1 "Panel" 0 "Cross Section"
label values survey_type svtype 

replace survey_type = . if cty == "z_Average"

gen years = "2010, 2013, 2016" if cty == "COL"
replace years = "2021-2023" if inlist(cty, "GTM", "HND", "HTI")
replace years = "2002, 2005, 2009" if cty == "MEX"
replace years = "2007-2023" if cty == "PER"
replace years = "2011, 2013" if cty == "SLV"
replace years = "2022" if cty == "CHL"
replace years = "2005" if cty == "ECU"
replace years = "2004" if cty == "DOM"
replace years = "-" if cty == "Average"

local c1 survey_type allyr_incid_health allyr_incid_lostjob  			   
local c2 allyr_incid_natdisast allyr_incid_criminality

sort cty 
replace cty = "Avg." if cty == "z_Average"

estpost tabstat survey_type allyr_incid_*, by(cty)

esttab using "shock_incidence_allcty.tex", cells("`c1' `c2'")  	   	   	   ///
	noobs nonum collabels("Survey Type" "Health" "Employment"			   				   ///
						  "Nat. Disast." "Criminality") replace varlabels(`varlabels')

order cty survey_type years *_natdisast *_health *_lostjob *_criminality

 * ----------------------------------------------

 * By baseline SES

cd "$projdir/dta/cln/ENAHO"
use "enaho_mean_incidence_rural_inc_q.dta", clear

gen cty = "PER"

cd "$projdir/dta/cln/ELCA"
append using "elca_mean_incidence_preexp.dta"

replace cty = "COL" if cty == ""

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_mean_incidence_preexp.dta"

replace cty = "MEX" if cty == ""

cd "$projdir/dta/cln/FAODIEM_HND"
append using "faodiem_HND_mean_incidence_preinc.dta"

replace cty = "HND" if cty == ""

cd "$projdir/dta/cln/FAODIEM_HTI"
append using "faodiem_HTI_mean_incidence_preinc.dta"

replace cty = "HTI" if cty == ""

cd "$projdir/dta/cln/LTSLV"
append using "ltslv_mean_incidence_preexp.dta"

replace cty = "SLV" if cty == ""

keep qstr q cty shock inclag_shock explag_shock expall_shock rural

sort cty q shock rural

replace shock = "health" if shock == "accident-illness"

gen bsline_sse_shock = expall_shock 
replace bsline_sse_shock = inclag_shock if inlist(cty, "HTI", "HND")
replace bsline_sse_shock = explag_shock if inlist(cty, "SLV")

bys cty q shock: keep if _n == 1 // drop rural/urban distinction

* gen relative shock incidence var (wrt q1)
sort cty shock q
bys cty shock: egen shock_q1 = max(cond(q == 1, bsline_sse_shock, .))
gen bsline_sse_shock_relq1 = (bsline_sse_shock - shock_q1) * 100

* -------------------------------------

twoway ///
	connected bsline_sse_shock q if shock == "any" & cty == "PER", ///
		lcolor(black%75) mcolor(black%75) msymbol(O) ///
		lpattern(solid) || ///
	connected bsline_sse_shock q if shock == "any" & cty == "COL", ///
		lcolor(black%75) mcolor(black%75) msymbol(D) ///
		lpattern(dash) || ///
	connected bsline_sse_shock q if shock == "any" & cty == "MEX", ///
		lcolor(black%75) mcolor(black%75) msymbol(T) ///
		lpattern(dot) || ///
	connected bsline_sse_shock q if shock == "any" & cty == "HTI", ///
		lcolor(black%75) mcolor(black%75) msymbol(S) ///
		lpattern(longdash) || ///
	connected bsline_sse_shock q if shock == "any" & cty == "HND", ///
		lcolor(black%75) mcolor(black%75) msymbol(X) ///
		lpattern(shortdash) || ///
	connected bsline_sse_shock q if shock == "any" & cty == "SLV", ///
		lcolor(black%75) mcolor(black%75) msymbol(Oh) ///
		lpattern(dash_dot) ///
	ytitle("Yearly Incidence") ///
	ylab(0(0.25)1) ///
	xtitle("Pre-shock SES level quintile") ///
	legend(order(2 "COL" 5 "HND" 4 "HTI" 3 "MEX" 1 "PER" 4 "SLV"))

cd "$projdir/out/allcty"
graph export "incidence_anyshock_bsline_ses_6cty.png", replace


twoway ///
	connected bsline_sse_shock q if shock == "any" & cty == "PER", ///
		lcolor(black%75) mcolor(black%75) msymbol(O) ///
		lpattern(solid) || ///
	connected bsline_sse_shock q if shock == "any" & cty == "COL", ///
		lcolor(black%75) mcolor(black%75) msymbol(D) ///
		lpattern(dash) || ///
	connected bsline_sse_shock q if shock == "any" & cty == "MEX", ///
		lcolor(black%75) mcolor(black%75) msymbol(T) ///
		lpattern(dot) || ///
	connected bsline_sse_shock q if shock == "any" & cty == "SLV", ///
		lcolor(black%75) mcolor(black%75) msymbol(Oh) ///
		lpattern(dash_dot) ///
	ytitle("Yearly Incidence") ///
	ylab(0.15(0.05)0.3) ///
	xtitle("Pre-shock SES level quintile") ///
	legend(order(2 "COL" /*5 "HND" 4 "HTI"*/ 3 "MEX" 1 "PER" 4 "SLV"))


cd "$projdir/out/allcty"
graph export "incidence_anyshock_bsline_ses_4cty.png", replace

* -------------------------------------

twoway ///
	connected bsline_sse_shock_relq1 q if shock == "any" & cty == "PER", ///
		lcolor(black%75) mcolor(black%75) msymbol(O) ///
		lpattern(solid) || ///
	connected bsline_sse_shock_relq1 q if shock == "any" & cty == "COL", ///
		lcolor(black%75) mcolor(black%75) msymbol(D) ///
		lpattern(dash) || ///
	connected bsline_sse_shock_relq1 q if shock == "any" & cty == "MEX", ///
		lcolor(black%75) mcolor(black%75) msymbol(T) ///
		lpattern(dot) || ///
	connected bsline_sse_shock_relq1 q if shock == "any" & cty == "HTI", ///
		lcolor(black%75) mcolor(black%75) msymbol(S) ///
		lpattern(longdash) || ///
	connected bsline_sse_shock_relq1 q if shock == "any" & cty == "SLV", ///
		lcolor(black%75) mcolor(black%75) msymbol(Oh) ///
		lpattern(dash_dot) ///
	ytitle("Shock Incidence Relative to Q1 (p.p.)") ///
	xtitle("Pre-shock SES quintile") ///
	legend(order(2 "COL" 4 "HTI" 3 "MEX" 1 "PER" 5 "SLV") ///
	       position(8) ring(0) bmargin(5 5 5 5) ///
	       region(lstyle(solid))) ///
	ylab(-12.5(2.5)2.5) ///
	yline(0, lcolor(stred%75) lpattern(solid))

cd "$projdir/out/allcty"
graph export "incidence_anyshock_bsline_ses_relq1_5cty.png", replace

twoway ///
	connected bsline_sse_shock_relq1 q if shock == "health" & cty == "PER", ///
		lcolor(black%75) mcolor(black%75) msymbol(O) ///
		lpattern(solid) || ///
	connected bsline_sse_shock_relq1 q if shock == "health" & cty == "COL", ///
		lcolor(black%75) mcolor(black%75) msymbol(D) ///
		lpattern(dash) || ///
	connected bsline_sse_shock_relq1 q if shock == "health" & cty == "MEX", ///
		lcolor(black%75) mcolor(black%75) msymbol(T) ///
		lpattern(dot) || ///
	connected bsline_sse_shock_relq1 q if shock == "health" & cty == "HTI", ///
		lcolor(black%75) mcolor(black%75) msymbol(S) ///
		lpattern(longdash) || ///
	connected bsline_sse_shock_relq1 q if shock == "health" & cty == "SLV", ///
		lcolor(black%75) mcolor(black%75) msymbol(Oh) ///
		lpattern(dash_dot) ///
	ytitle("Shock Incidence Relative to Q1 (p.p.)") ///
	xtitle("Pre-shock SES quintile") ///
	legend(order(2 "COL" /*5 "HND"*/ 4 "HTI" 3 "MEX" 1 "PER" 5 "SLV") ///
	       position(8) ring(0) bmargin(5 5 5 5) ///
	       region(lstyle(solid))) ///
	yline(0, lcolor(stred%75) lpattern(solid))

cd "$projdir/out/allcty"
graph export "incidence_health_bsline_ses_relq1_5cty.png", replace


twoway ///
	connected bsline_sse_shock_relq1 q if shock == "lostjob" & ///
	cty == "PER", ///
	lcolor(black%75) mcolor(black%75) msymbol(O) ///
	lpattern(solid) || ///
	connected bsline_sse_shock_relq1 q if shock == "lostjob" & ///
	cty == "COL", ///
	lcolor(black%75) mcolor(black%75) msymbol(D) ///
	lpattern(dash) || ///
	connected bsline_sse_shock_relq1 q if shock == "lostjob" & ///
	cty == "MEX", ///
	lcolor(black%75) mcolor(black%75) msymbol(T) ///
	lpattern(dot) || ///
	connected bsline_sse_shock_relq1 q if shock == "lostjob" & ///
	cty == "HTI", ///
	lcolor(black%75) mcolor(black%75) msymbol(S) ///
	lpattern(longdash) || ///
	connected bsline_sse_shock_relq1 q if shock == "lostjob" & ///
	cty == "SLV", ///
	lcolor(black%75) mcolor(black%75) msymbol(Oh) ///
	lpattern(dash_dot) ///
	ytitle("Shock Incidence Relative to Q1 (p.p.)") ///
	xtitle("Pre-shock SES quintile") ///
	legend(order(2 "COL" /*5 "HND"*/ 4 "HTI" 3 "MEX" 1 "PER" 5 "SLV") ///
	       position(8) ring(0) bmargin(5 5 5 5) ///
	       region(lstyle(solid))) ///
	yline(0, lcolor(stred%75) lpattern(solid))

cd "$projdir/out/allcty"
graph export "incidence_lostjob_bsline_ses_relq1_5cty.png", replace


twoway ///
	connected bsline_sse_shock_relq1 q if shock == "natdisast" & ///
	cty == "PER", ///
	lcolor(black%75) mcolor(black%75) msymbol(O) ///
	lpattern(solid) || ///
	connected bsline_sse_shock_relq1 q if shock == "natdisast" & ///
	cty == "COL", ///
	lcolor(black%75) mcolor(black%75) msymbol(D) ///
	lpattern(dash) || ///
	connected bsline_sse_shock_relq1 q if shock == "natdisast" & ///
	cty == "MEX", ///
	lcolor(black%75) mcolor(black%75) msymbol(T) ///
	lpattern(dot) || ///
	connected bsline_sse_shock_relq1 q if shock == "natdisast" & ///
	cty == "HTI", ///
	lcolor(black%75) mcolor(black%75) msymbol(S) ///
	lpattern(longdash) || ///
	connected bsline_sse_shock_relq1 q if shock == "natdisast" & ///
	cty == "SLV", ///
	lcolor(black%75) mcolor(black%75) msymbol(Oh) ///
	lpattern(dash_dot) ///
	ytitle("Shock Incidence Relative to Q1 (p.p.)") ///
	xtitle("Pre-shock SES quintile") ///
	legend(order(2 "COL" /*5 "HND"*/ 4 "HTI" 3 "MEX" 1 "PER" 5 "SLV") ///
	       position(8) ring(0) bmargin(5 5 5 5) ///
	       region(lstyle(solid))) ///
	yline(0, lcolor(stred%75) lpattern(solid))

cd "$projdir/out/allcty"
graph export "incidence_natdisast_bsline_ses_relq1_5cty.png", replace


twoway ///
	connected bsline_sse_shock_relq1 q if shock == "criminality" & ///
	cty == "PER", ///
	lcolor(black%75) mcolor(black%75) msymbol(O) ///
	lpattern(solid) || ///
	connected bsline_sse_shock_relq1 q if shock == "criminality" & ///
	cty == "COL", ///
	lcolor(black%75) mcolor(black%75) msymbol(D) ///
	lpattern(dash) || ///
	connected bsline_sse_shock_relq1 q if shock == "criminality" & ///
	cty == "MEX", ///
	lcolor(black%75) mcolor(black%75) msymbol(T) ///
	lpattern(dot) || ///
	connected bsline_sse_shock_relq1 q if shock == "criminality" & ///
	cty == "HTI", ///
	lcolor(black%75) mcolor(black%75) msymbol(S) ///
	lpattern(longdash) || ///
	connected bsline_sse_shock_relq1 q if shock == "criminality" & ///
	cty == "SLV", ///
	lcolor(black%75) mcolor(black%75) msymbol(Oh) ///
	lpattern(dash_dot) ///
	ytitle("Shock Incidence Relative to Q1 (p.p.)") ///
	xtitle("Pre-shock SES quintile") ///
	legend(order(2 "COL" /*5 "HND"*/ 4 "HTI" 3 "MEX" 1 "PER" 5 "SLV") ///
	       position(11) ring(0) bmargin(5 5 5 5) ///
	       region(lstyle(solid))) ///
	ylab(-0.5(1)4.5) ///
	yline(0, lcolor(stred%75) lpattern(solid))

cd "$projdir/out/allcty"
graph export "incidence_crime_bsline_ses_relq1_5cty.png", replace

* -------------------------------------------------------------------