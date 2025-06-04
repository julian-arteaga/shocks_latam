* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ENNVIH health expenditure level 2005

* -----------------

cd "$projdir/dta/src/ENNVIH"
use "ehh09dta_all/ehh09dta_b3b/iiib_ec.dta",clear // cronic disease

egen exp_crc_mth = rowtotal(ec03a_2 ec03b_2 ec03c_2 ec03d_2 		       ///
							   ec03e_2 ec03f_2 ec03g_2 ec03h_2 ec03i_2)

replace exp_crc_mth = exp_crc_mth / 3

bys folio: egen exp_month_cronic = total(exp_crc_mth)

bys folio: keep if _n == 1

keep folio exp_month_cronic

tempfile cronic 
save `cronic'

cd "$projdir/dta/src/ENNVIH"
use "ehh09dta_all/ehh09dta_b3b/iiib_ats.dta", clear // self-prescription

egen exp_ats_mth = rowtotal(ats02a1_2 ats02a2_2 ats02a3_2 ats02b_2 ats02c_2)

// replace exp_ats_mth = exp_cronic_mth 

bys folio: egen exp_month_autot = total(exp_ats_mth)

bys folio: keep if _n == 1

keep folio exp_month_autot

tempfile autot 
save `autot'

cd "$projdir/dta/src/ENNVIH"
use "ehh09dta_all/ehh09dta_b3b/iiib_ce1.dta", clear // external doctor visit

egen exp_cex_mth = rowtotal(ce19a_2 ce19b_2 ce19c_2 				   ///
							ce19d_2 ce19e_21 ce21_2 ce23a_2)

replace exp_cex_mth = ce19_2 if exp_cex_mth == 0 & ce19_2 != . 
		// use total cost if cost by item not recorded

replace exp_cex_mth = exp_cex_mth + ce17_2 // add transport cost

bys folio: egen exp_month_consult = total(exp_cex_mth)
						  
bys folio: keep if _n == 1

keep folio exp_month_consult

sum exp_month_consult, d

tempfile consult 
save `consult'

cd "$projdir/dta/src/ENNVIH"
use "ehh09dta_all/ehh09dta_b3b/iiib_hs1.dta", clear // hospitalization

foreach var of varlist hs16a_2 hs16b_2 hs16c_2 hs16d_2 hs16e_2 {

	replace `var' = . if `var' == 1
}

egen exp_hsp_mth = rowtotal(hs16a_2 hs16b_2 hs16c_2 hs16d_2 hs16e_2) 

replace exp_hsp_mth = hs16_2 if exp_hsp_mth == 0 & hs16_2 != . 
		// use total cost if cost by item not recorded

replace exp_hsp_mth = hs18_2 if hs18_2 != . // replace with deductible if != .

bys folio: egen exp_month_hospitl = total(exp_hsp_mth)

replace exp_month_hospitl = exp_month_hospitl / 12

bys folio: keep if _n == 1

keep folio exp_month_hospitl

tempfile hospitl 
save `hospitl'

merge 1:1 folio using `consult'
drop _merge 

merge 1:1 folio using `autot'
drop _merge 

merge 1:1 folio using `cronic'
drop _merge 

foreach var of varlist exp_* {

	replace `var' = 0 if `var' == .
}

gen exp_health_monthly = exp_month_hospitl + exp_month_consult +		   ///
						 exp_month_autot + exp_month_cronic

gen exp_health_yearly = exp_health_monthly * 12

gen year = 2009

compress

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_healthexp_hhlvl_09.dta", replace

* -------------------------------------------------------------------