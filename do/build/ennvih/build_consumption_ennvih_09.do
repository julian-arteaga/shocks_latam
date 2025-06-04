* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ENNVIH concumption level 2002-2005-2009

* -----------------

* [2009]

* Num household members: 
use "$projdir/dta/src/ENNVIH/ehh09dta_all/ehh09dta_b3a/iiia_portad.dta", clear

bys folio: gen mieperho = _N 

bys folio: keep if _n == 1 

keep folio mieperho 

tempfile mieperho 
save `mieperho'

* Consumption 0:  
use "$projdir/dta/src/ENNVIH/ehh09dta_all/ehh09dta_b1/i_cs.dta", clear

* Goods bought weekly:

foreach x in a b c d e {

	if "`x'" == "a" local numlist 1 2 3 4 5 6 7 8 
	if "`x'" == "b" local numlist 1 2 3 4 5 
	if "`x'" == "c" local numlist 1 2 3 4 5 6 7 8
	if "`x'" == "d" local numlist 1 2 3 4 5 
	if "`x'" == "e" local numlist 1 2 3 

	foreach i of local numlist {

		gen monthval_cs02_`x'`i' = 0
		replace monthval_cs02_`x'`i' = cs02`x'_`i'2 * 4 if cs02`x'_`i'2 != .

		gen monthval_cs04_`x'`i' = 0
		replace monthval_cs04_`x'`i' = cs04`x'_`i'2 * 4 if cs04`x'_`i'2 != .

		gen monthval_cs_`x'`i' = monthval_cs02_`x'`i' + monthval_cs04_`x'`i'

		drop monthval_cs02_`x'`i' monthval_cs04_`x'`i'
	}
}

egen monthval_cs0204 = rowtotal( 										   ///
	monthval_cs_a1 monthval_cs_a2 monthval_cs_a3 monthval_cs_a4 		   ///
	monthval_cs_a5 monthval_cs_a6 monthval_cs_a7 monthval_cs_a8 		   ///
	monthval_cs_b1 monthval_cs_b2 monthval_cs_b3 monthval_cs_b4 		   ///
	monthval_cs_b5 monthval_cs_c1 monthval_cs_c2 monthval_cs_c3 		   ///
	monthval_cs_c4 monthval_cs_c5 monthval_cs_c6 monthval_cs_c7 		   ///
	monthval_cs_c8 monthval_cs_d1 monthval_cs_d2 monthval_cs_d3 		   ///
	monthval_cs_d4 monthval_cs_d5 monthval_cs_e1 monthval_cs_e2 		   ///
	monthval_cs_e3)

* Goods that are asked at both weekly and monthly frequency:
foreach x in a b c d e f g h i j {

	gen monthval_cs08`x' = 0
	replace monthval_cs08`x' = cs15`x' * 4 if cs08`x' == 1 // weekly to monthly  
	replace monthval_cs08`x' = cs15`x' * 1 if cs09`x' == 1 // once a month (?)
}

egen monthval_cs08 = rowtotal(											   ///
	monthval_cs08a monthval_cs08b monthval_cs08e monthval_cs08f 		   ///
	monthval_cs08g monthval_cs08h monthval_cs08i monthval_cs08j 		   ///
	monthval_cs08c monthval_cs08d)

* Goods that are asked at monthly freq:
egen monthval_cs16 = rowtotal(cs16a_2 cs16b_2 cs16c_2 cs16d_2 cs16e_2 	   ///					   ///
							   cs16f_2 cs16g_2 cs16h_2 cs16i_2)

* Gifted/in kind payment goods
gen monthval_cs18 = 0 
replace monthval_cs18 = cs18_2 if cs18_2 != .

* aggregate all goods:
gen monthval_cs = monthval_cs0204 + monthval_cs08 + 					   ///
				  monthval_cs16 + monthval_cs18

keep folio monthval_cs

tempfile consumption_0 
save `consumption_0'

* -----------------

* Consumption 1: 
use "$projdir/dta/src/ENNVIH/ehh09dta_all/ehh09dta_b1/i_cs1.dta", clear

* Goods  asked at quarterly freq:
foreach x in a b c d e f g h {

	gen monthval_cs22_`x' = 0
	replace monthval_cs22_`x' = cs22`x'_2 / 3 if cs22`x'_2 != .

	gen monthval_cs24_`x' = 0
	replace monthval_cs24_`x' = cs24`x'_2 / 3 if cs24`x'_2 != .

	gen monthval_cs2224_`x' = monthval_cs22_`x' + monthval_cs24_`x'

	drop monthval_cs22_`x' monthval_cs24_`x'
}

* Goods asked at yearly freq:
egen monthval_cs27= rowtotal(cs27a_2 cs27b_2 cs27c_2 cs27d_2 cs27e_2 cs27f_2)
replace monthval_cs27 = monthval_cs27 / 12

* Gifted/in kind payment goods
gen monthval_cs29 = 0 
replace monthval_cs29 = cs29_2 / 12 if cs29_2 != .

* School expenses: 
egen monthval_csschool = rowtotal(cs34a_12 cs34a_22 cs34a_32 			   ///
							  	  cs35a_12 cs35a_22 cs35a_32 			   ///
							 	  cs36a_12 cs36a_22 cs36a_32)
replace monthval_csschool = monthval_csschool / 12

* aggregate all goods:
gen monthval_cs1 = monthval_cs27 + monthval_cs29 + monthval_csschool

keep folio monthval_cs1

tempfile consumption_1 
save `consumption_1'

* -----------------

use `mieperho', clear 

merge 1:1 folio using `consumption_0'
drop _merge 

merge 1:1 folio using `consumption_1'
drop _merge 

gen hh_totexp = (monthval_cs + monthval_cs1) * 12

gen percexp = hh_totexp / mieperho 

label var hh_totexp "Yearly household consumption (nominal pesos)"
label var percexp "Yearly household consumption per capita (nominal pesos)"

gen year = 2009

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_consump_hhlvl_09.dta", replace

* -------------------------------------------------------------------