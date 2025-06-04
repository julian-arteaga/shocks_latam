* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ENNVIH concumption level 2002-2005-2009

* -----------------

* [2002]

* Num household members: 
use "$projdir/dta/src/ENNVIH/ehh02dta_all/ehh02dta_b3a/iiia_portad.dta", clear

bys folio: gen mieperho = _N 

bys folio: keep if _n == 1 

keep folio mieperho 

tempfile mieperho 
save `mieperho'

* Consumption 0:  
use "$projdir/dta/src/ENNVIH/ehh02dta_all/ehh02dta_b1/i_cs.dta", clear


* --------------
* Food expenses:

foreach x in a b c d {

	if "`x'" == "a" local numlist 1 2 3 4 5 6 7 8 
	if "`x'" == "b" local numlist 1 2 3 4 5 
	if "`x'" == "c" local numlist 1 2 3 4 5 6 7
	if "`x'" == "d" local numlist 1 2 3 4 

	foreach i of local numlist {

		gen monthval_cs02_`x'`i' = 0
		replace monthval_cs02_`x'`i' = cs02`x'_`i'2 * 4 if cs02`x'_`i'2 != .

		gen monthval_cs04_`x'`i' = 0
		replace monthval_cs04_`x'`i' = cs04`x'_`i'2 * 4 if cs04`x'_`i'2 != .

		gen monthval_cs_`x'`i' = monthval_cs02_`x'`i' + monthval_cs04_`x'`i'

		replace monthval_cs_`x'`i' = . if monthval_cs_`x'`i' >= 50000
	}
}

gen monthval_cs02_e3 = cs02e_32 * 4 if cs02e_32 != .

gen monthval_cs04_e3  = cs04e_32  * 4 if cs04e_32  != .
gen monthval_cs04_e4  = cs04e_42  * 4 if cs04e_42  != .
gen monthval_cs04_e5  = cs04e_52  * 4 if cs04e_52  != .
gen monthval_cs04_e6  = cs04e_62  * 4 if cs04e_62  != .
gen monthval_cs04_e7  = cs04e_72  * 4 if cs04e_72  != .
gen monthval_cs04_e8  = cs04e_82  * 4 if cs04e_82  != .
gen monthval_cs04_e9  = cs04e_92  * 4 if cs04e_92  != .
gen monthval_cs04_e10 = cs04e_102 * 4 if cs04e_102 != .
gen monthval_cs04_e11 = cs04e_112 * 4 if cs04e_112 != .
gen monthval_cs04_e12 = cs04e_122 * 4 if cs04e_122 != .
gen monthval_cs04_e13 = cs04e_132 * 4 if cs04e_132 != .

foreach var of varlist monthval_cs02_e* monthval_cs04_e* {

	replace `var' = . if `var' >= 50000
}

* Goods that are asked at both weekly and monthly frequency:
foreach x in a b c d e f g h i j {

	gen monthval_cs08`x' = 0
	replace monthval_cs08`x' = cs15`x' * 4 if cs08`x' == 1 // weekly to monthly  
	replace monthval_cs08`x' = cs15`x' * 1 if cs09`x' == 1 // once a month (?)

	replace monthval_cs08`x' = . if monthval_cs08`x' >= 40000 
}

* Up to here everything is food (except e1 and e2)
unab food_purch: monthval_cs02_* monthval_cs08*
unab food_transf: monthval_cs04_*

egen monthval_foodpurch  = rowtotal(`food_purch')
egen monthval_foodtransf = rowtotal(`food_transf')

gen monthval_food = monthval_foodpurch + monthval_foodtransf

drop monthval_cs02_* monthval_cs08* monthval_cs04_*

* --------------
* Personal / leisure expenses:

gen monthval_cs02_e1 = cs02e_12 * 4 if cs02e_12 != . // tobacco
gen monthval_cs02_e2 = cs02e_22 * 4 if cs02e_22 != . // transport
// gen monthval_cs04_e1  // not asked
gen monthval_cs04_e2  = cs04e_22  * 4 if cs04e_22  != . // transport transf

* Goods that are asked at monthly freq:

foreach var of varlist cs16a_2 cs16b_2 cs16c_2 cs16d_2 cs16e_2 	           ///
							   cs16f_2 cs16g_2 cs16h_2 cs16i_2 {

	replace `var' = . if `var' >= 50000
}

egen monthval_pers_purch = rowtotal(cs16a_2 cs16b_2 cs16c_2 cs16d_2 	   ///
									cs16e_2 cs16h_2 cs16i_2 			   ///
									monthval_cs02_e1 monthval_cs02_e2)

egen monthval_leis = rowtotal(cs16f_2 cs16g_2)

* Gifted/in kind payment goods
gen monthval_perstransf = 0 
replace monthval_perstransf = cs18_2 if cs18_2 != .

gen monthval_pers = monthval_pers_purch + monthval_perstransf

keep folio monthval_food* monthval_pers* monthval_leis 

tempfile consumption_0 
save `consumption_0'

* -----------------

* Consumption 1: 
use "$projdir/dta/src/ENNVIH/ehh02dta_all/ehh02dta_b1/i_cs1.dta", clear

* --------------
* Personal / leisure expenses asked at quarterly freq:

foreach x in a b c d e f g h {

	gen monthval_cs22_`x' = 0
	replace monthval_cs22_`x' = cs22`x'_2 / 3 if cs22`x'_2 != .

	gen monthval_cs24_`x' = 0
	replace monthval_cs24_`x' = cs24`x'_2 / 3 if cs24`x'_2 != .

	gen monthval_cs2224_`x' = monthval_cs22_`x' + monthval_cs24_`x'

	// drop monthval_cs22_`x' monthval_cs24_`x'
}

egen monthval_pers_purch2 = rowtotal(									   ///
	monthval_cs22_a monthval_cs22_b monthval_cs22_c monthval_cs22_d 	   ///
	monthval_cs22_e monthval_cs22_f monthval_cs22_g monthval_cs22_h)

egen monthval_pers_transf2 = rowtotal(									   ///
	monthval_cs24_a monthval_cs24_b monthval_cs24_c monthval_cs24_d 	   ///
	monthval_cs24_e monthval_cs24_f monthval_cs24_g monthval_cs24_h)

gen monthval_pers2 = monthval_pers_purch2 + monthval_pers_transf2

* --------------
* Durable goods

* Goods asked at yearly freq:

egen monthval_durab_purch = rowtotal(cs27a_2 cs27b_2 cs27c_2 			   ///
									 cs27d_2 cs27e_2 cs27f_2)

replace monthval_durab_purch = monthval_durab_purch / 12

* Gifted/in kind payment goods
gen monthval_durab_transf = 0 
replace monthval_durab_transf = cs29_2 / 12 if cs29_2 != .

* School expenses: 
egen monthval_school_purch = rowtotal(cs34a_12 cs34a_22 cs34a_32 		   ///
							  	  cs35a_12 cs35a_22 cs35a_32 			   ///
							 	  cs36a_12 cs36a_22 cs36a_32)
replace monthval_school_purch = monthval_school / 12

gen monthval_school = monthval_school_purch 

gen monthval_durab = monthval_durab_purch + monthval_durab_transf

keep folio monthval_pers2* monthval_durab* monthval_school* 			   ///
		   monthval_pers_purch2 monthval_pers_transf2

tempfile consumption_1 
save `consumption_1'

* -----------------

use `mieperho', clear 

merge 1:1 folio using `consumption_0'
drop _merge 

merge 1:1 folio using `consumption_1'
drop _merge 

gen year = 2002

rename folio folio02
gen str8 folio = string(folio02, "%08.0f")

* Merge-in health expenditures:
cd "$projdir/dta/cln/ENNVIH"
merge 1:1 folio using "ennvih_healthexp_hhlvl_02.dta"
drop if _merge == 2 

replace exp_health_yearly = 0 if _merge == 1

gen consumo_health = exp_health_yearly

gen consumo_alimento = monthval_food * 12
gen consumo_personal = (monthval_pers + monthval_pers2) * 12
gen consumo_educatio = monthval_school * 12
gen consumo_durables = monthval_durab * 12
gen consumo_leisure  = monthval_leis * 12

gen consumo_purchased = consumo_health +								   ///
					    (monthval_foodpurch + monthval_pers_purch + 	   ///
					    monthval_pers_purch2 + monthval_durab_purch +	   ///
						monthval_school_purch ) * 12 	

gen consumo_transfers = (monthval_perstransf + monthval_pers_transf2 +	   ///
				     	 monthval_durab_transf + monthval_foodtransf) * 12

gen hh_totexp = consumo_alimento + consumo_personal + consumo_health +	   ///
			    consumo_leisure + consumo_durables + consumo_educatio

gen percexp = hh_totexp / mieperho 

foreach v in consumo_alimento consumo_personal 	 		   				   ///
			 consumo_educatio consumo_health consumo_durables 		   	   ///
			 consumo_leisure consumo_transfers consumo_purchased {

	gen `v'_pc = `v' / mieperho
}

label var hh_totexp "Yearly household consumption (nominal pesos)"
label var percexp "Yearly household consumption per capita (nominal pesos)"

keep folio folio02 mieperho year consumo_* percexp hh_totexp

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_consump_hhlvl_02.dta", replace

* -------------------------------------------------------------------
