* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Plot yearly incidence across all surveys all years:

* -----------------

cd "$projdir/dta/cln/ENAHO"
use "enaho_yr_incidence_13_23.dta", clear

gen cty = "PER"

cd "$projdir/dta/cln/ELCA"
append using "elca_yr_incidence_10_19.dta"

replace cty = "COL" if cty == ""

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_yr_incidence_02_09.dta"

replace cty = "MEX" if cty == ""

cd "$projdir/dta/cln/FAODIEM"
append using "faodiem_allcty_yr_incidence.dta"

cd "$projdir/dta/cln/LTSLV"
append using "ltslv_yr_incidence_11_13.dta"

replace cty = "SLV" if cty == ""

* ---

bys cty year round: keep if _n == 1
drop rural *bankrupcy idboleta round

gen date = dofy(year)
replace date = med_date if year == .

gen yq = qofd(date)
format yq %tq
sort yq cty

rename mean_shock_accident_illnss mean_shock_health
rename m_shock_accident_illnss m_shock_health
rename shock_accident_illnss shock_health 

foreach v in any natdisast health lostjob criminality {

	gen incid_shock_`v' = mean_shock_`v' 
	replace incid_shock_`v' = m_shock_`v' if incid_shock_`v' == .

	drop mean_shock_`v' m_shock_`v' shock_`v'
}

br cty yq incid*

local s msize(medlarge)

twoway ///
scatter incid_shock_any yq if cty == "COL" & year < 2020,  `s' color(stc1%65) || ///
scatter incid_shock_any yq if cty == "PER", color(stc2%65) `s'||   ///
scatter incid_shock_any yq if cty == "MEX",color(stc3%65)  `s' ||   ///
scatter incid_shock_any yq if cty == "SLV", color(stc4%65) `s' ||   ///
scatter incid_shock_any yq if cty == "COL" & year >= 2020, `s' msymbol(S) color(stc5%45)  || ///
scatter incid_shock_any yq if cty == "GTM", color(stc5%95) `s' msymbol(X)||   /// 
scatter incid_shock_any yq if cty == "HND", color(stc8%45) `s' msymbol(D)||   ///
scatter incid_shock_any yq if cty == "HTI", color(stc8%95) `s' msymbol(T)     ///
legend(order(1 "COL-ELCA" 2 "PER" 3 "MEX" 4 "SLV" 				///
			 5 "COL-DIEM" 6 "GTM-DIEM" 7 "HND-DIEM" 8 "HTI-DIEM") 		   ///
			 pos(6) row(2)) xtitle("") ytitle("Yearly Incidence") ylab(0(0.25)1)

cd "$projdir/out/allcty"
graph export "yearly_incidence_allcty_anyshock.png", replace

* -------------------------------------------------------------------