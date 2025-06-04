* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute shock incidence summary statistics across surveys

* -------------------------------------
 
cd "$projdir/dta/cln/ENAHO"
use "enaho_mean_incidence_rural_inc_q.dta", clear

gen country = "PER"
gen cty = "Peru"

cd "$projdir/dta/cln/ELCA"
append using "elca_mean_incidence_rural_inc_q.dta"

replace country = "COL" if country == ""
replace cty = "Colombia" if cty == ""

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_mean_incidence_rural_inc_q.dta"

replace country = "MEX" if country == ""
replace cty = "Mexico" if cty == ""

* Overall incidence pooling rural and urban:
keep expall_shock shock country qstr rural_b cty
keep if rural_baseline == 0 // either category works for expall_shock

bys country shock: egen incidence_ = mean(expall_shock)
bys country shock: keep if _n == 1

drop rural_baseline expall_shock qstr

replace shock = "accident" if shock == "accident-illness"
reshape wide incidence_, i(country) j(shock) string

order country incidence_any incidence_accident incidence_lostjob  		   ///
			  incidence_natdisast incidence_criminality 

cd "$projdir/out/"

local c1 incidence_any(fmt(3)) incidence_accident incidence_lostjob  			   
local c2 incidence_natdisast incidence_criminality
estpost tabstat incidence_*, by(cty)
esttab using "shock_incidence_3countries.tex", cells("`c1' `c2'")  	   	   ///
	noobs nonum collabels("All shocks" "Health" "Employment"			   ///
						  "Nat. Disast." "Criminality") replace

* -------------------------------------
 
cd "$projdir/dta/cln/ENAHO"
use "enaho_mean_incidence_rural_inc_q.dta", clear

gen country = "PER"
gen cty = "Peru"

cd "$projdir/dta/cln/ELCA"
append using "elca_mean_incidence_rural_inc_q.dta"

replace country = "COL" if country == ""
replace cty = "Colombia" if cty == ""

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_mean_incidence_rural_inc_q.dta"

replace country = "MEX" if country == ""
replace cty = "Mexico" if cty == ""

* Overall incidence pooling rural and urban:
keep explag_shock shock country qstr rural_b cty

keep if shock == "any"

bys country rural_: egen incidence_ = mean(explag_shock)
bys country rural_: keep if _n == 1

gen zone = "rural" if rural == 1
replace zone = "urban" if rural == 0

drop  explag qstr shock rural country

reshape wide incidence_, i(cty) j(zone) string

cd "$projdir/out/"

estpost tabstat incidence_rural incidence_urban, by(cty)
esttab using "shock_incidence_3countries_urbrur.tex", 				   	   ///
	cells("incidence_rural(fmt(3)) incidence_urban(fmt(3))")  	   	   	   ///
	noobs nonum collabels("Rural" "Urban") replace tex

* -------------------------------------
 
cd "$projdir/dta/cln/ENAHO"
use "enaho_mean_incidence_rural_inc_q.dta", clear

gen country = "PER"

cd "$projdir/dta/cln/ELCA"
append using "elca_mean_incidence_rural_inc_q.dta"

replace country = "COL" if country == ""

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_mean_incidence_rural_inc_q.dta"

replace country = "MEX" if country == ""

twoway connected explag_shock q if rural == 1 & shock == "any" 			   ///
	& country == "COL", 	   											   ///
	lcolor(black) mcolor(black) lpattern(solid) || 					   	   ///
	connected explag_shock q if rural == 0 & shock == "any"				   ///
	& country == "COL",    	  	   										   ///
	lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	   	   ///
	ytitle("Yearly Incidence", size(large)) 							   ///
	legend(order(1 "Rural" 2 "Urban") pos(6) size(large) row(1)) xtit("")  ///
	title("COL")						   

cd "$projdir/out/"
graph save col_any_preexp.gph, replace


twoway connected explag_shock q if rural == 1 & shock == "any" 			   ///
	& country == "PER", 	   											   ///
	lcolor(black) mcolor(black) lpattern(solid) || 					   	   ///
	connected explag_shock q if rural == 0 & shock == "any"				   ///
	& country == "PER",   	   	   										   ///
	lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	   	   ///
	legend(order(1 "Rural" 2 "Urban")) ytit("")	xtit("")		     	   ///
	xtitle("" "pre-shock expenditure level quintile", size(large)) 		   ///
	title("PER")

cd "$projdir/out/"
graph save per_any_preexp.gph, replace

twoway connected explag_shock q if rural == 1 & shock == "any" 			   ///
	& country == "MEX", 	   											   ///
	lcolor(black) mcolor(black) lpattern(solid) || 					   	   ///
	connected explag_shock q if rural == 0 & shock == "any"				   ///
	& country == "MEX",									  	    	   	   ///
	lcolor(blue) lpattern(longdash) mcolor(blue) msymbol(s) 	   	   ///
	legend(order(1 "Rural" 2 "Urban")) ytit("")	xtit("") 				   ///
	title("MEX")						   
	
cd "$projdir/out/"
graph save mex_any_preexp.gph, replace

grc1leg col_any_preexp.gph per_any_preexp.gph mex_any_preexp.gph, row(1)

graph display, ysize(9) xsize(16)

cd "$projdir/out/"
graph export "anyshock_3countries_rururb_preexp.png", replace

erase col_any_preexp.gph 
erase per_any_preexp.gph 
erase mex_any_preexp.gph

* -------------------------------------

twoway  connected expall_shock q if rural_ == 0 & shock == "any" 		   ///
		& country == "PER", lcolor(black) mcolor(black) lpattern(solid) || /// 
		connected expall_shock q if rural_ == 0 & shock == "any" 		   ///
		& country == "COL", lcolor(stblue) mcolor(stblue) 				   ///
		msymbol(s) lpattern(dash) ||    								   ///
		connected expall_shock q if rural_ == 0 & shock == "any" 		   ///
		& country == "MEX", lcolor(stgreen) mcolor(stgreen) 			   ///
		msymbol(t) lpattern(longdash) 					   				   ///
		ytitle("Yearly Incidence") 							   			   ///
		legend(order(1 "PER" 2 "COL" 3 "MEX"))							   ///
		xtitle("Pre-shock expenditure level quintile") 			       	   

cd "$projdir/out/"
graph export "anyshock_3countries_preexp.png", replace

* -------------------------------------