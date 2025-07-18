* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ENNVIH household debt levels 2002

* -----------------

cd "$projdir/dta/src/ENNVIH"
use "ehh02dta_all/ehh02dta_b3b/iiib_cr.dta",clear 

gen v_creditcard = max(cr03_2, 0)
gen v_merchgoods = max(cr07a_2 - cr07b_2, 0)
gen v_alldebt    = max(cr26_2, 0)

foreach var in creditcard merchgoods alldebt {

	bys folio: egen vr_`var' = total(v_`var')
}

bys folio: keep if _n == 1

keep folio  vr_* 

tempfile cr0 
save `cr0'

use "ehh02dta_all/ehh02dta_b3b/iiib_cr1.dta",clear
// only answered by households reporting having asked for credit 
// dta is at the hh-person-credit level: isid folio ls secuencia

gen vcreditloan = max(cr19 - cr20_2, 0)

bys folio: egen vr_creditloan = total(vcreditloan)

bys folio: keep if _n == 1 

keep folio vr_creditloan 

merge 1:1 folio using `cr0'

replace vr_creditloan = 0 if _merge == 2

drop _merge 

gen debt_dummy = vr_alldebt > 0 
gen debt_value = vr_alldebt 

gen year = 2002  

gen folio_02 = string(folio, "%08.0f")

keep folio_02 year debt_value debt_dummy 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_debt_hhlvl_02.dta", replace

* -----------------

cd "$projdir/dta/src/ENNVIH"
use "ehh05dta_all/ehh05dta_b3b/iiib_cr.dta",clear 

gen v_creditcard = max(cr03_2, 0)
gen v_merchgoods = max(cr07a_2 - cr07b_2, 0)
gen v_alldebt    = max(cr26_2, 0)

foreach var in creditcard merchgoods alldebt {

	bys folio: egen vr_`var' = total(v_`var')
}

bys folio: keep if _n == 1

keep folio  vr_* 

tempfile cr0 
save `cr0'

use "ehh05dta_all/ehh05dta_b3b/iiib_cr1.dta",clear
// only answered by households reporting having asked for credit 
// dta is at the hh-person-credit level: isid folio ls secuencia

gen vcreditloan = max(cr19 - cr20_2, 0)

bys folio: egen vr_creditloan = total(vcreditloan)

bys folio: keep if _n == 1 

keep folio vr_creditloan 

merge 1:1 folio using `cr0'

replace vr_creditloan = 0 if _merge == 2

drop _merge 

gen debt_dummy = vr_alldebt > 0 
gen debt_value = vr_alldebt 

gen year = 2005

rename folio folio_05

keep folio_05 year debt_value debt_dummy 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_debt_hhlvl_05.dta", replace


* -----------------

cd "$projdir/dta/src/ENNVIH"
use "ehh09dta_all/ehh09dta_b3b/iiib_cr.dta",clear 

gen v_creditcard = max(cr03_2, 0)
//gen v_merchgoods = max(cr07a_2 - cr07b_2, 0)
gen v_alldebt    = max(cr26_2, 0)

foreach var in creditcard /*merchgoods*/ alldebt {

	bys folio: egen vr_`var' = total(v_`var')
}

bys folio: keep if _n == 1

keep folio  vr_* 

tempfile cr0 
save `cr0'

use "ehh09dta_all/ehh09dta_b3b/iiib_cr1.dta",clear
// only answered by households reporting having asked for credit 
// dta is at the hh-person-credit level: isid folio ls secuencia

gen vcreditloan = max(cr19_2 - cr20_2, 0)

bys folio: egen vr_creditloan = total(vcreditloan)

bys folio: keep if _n == 1 

keep folio vr_creditloan 

merge 1:1 folio using `cr0'

replace vr_creditloan = 0 if _merge == 2

drop _merge 

gen debt_dummy = vr_alldebt > 0 
gen debt_value = vr_alldebt 

rename folio folio_09

gen year = 2009 

keep folio_09 year debt_value debt_dummy 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_debt_hhlvl_09.dta", replace

* -----------------