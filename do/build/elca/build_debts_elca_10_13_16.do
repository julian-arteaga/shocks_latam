* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ELCA household Debts and savings level 2010-2013-2016 

* -----------------

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
	 
use "2010/Rural/Rhogar.dta", clear

keep consecutivo tienen_deudas vr_saldo_*

gen debts_dummy = tienen_deudas == 1 

unab vrsaldo: vr_saldo_*

foreach var of varlist `vrsaldo' {

	replace `var' = . if inlist(`var', 12, 97, 98, 99, 88888888, 99999999)
}

egen debts_value = rowtotal(`vrsaldo')

format debts_value %15.0f

keep consecutivo debts_dummy debts_value 

tempfile debtsR10
save `debtsR10'

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
	 
use "2010/Urbano/Uhogar.dta", clear

keep consecutivo tienen_deudas vr_saldo_*

gen debts_dummy = tienen_deudas == 1 

unab vrsaldo: vr_saldo_*

foreach var of varlist `vrsaldo' {

	replace `var' = . if inlist(`var', 12, 97, 98, 99, 88888888, 99999999)
}

egen debts_value = rowtotal(`vrsaldo')

format debts_value %15.0f

append using `debtsR10'

keep consecutivo debts_dummy debts_value 

// set at 2016 prices
foreach var of varlist debts_value {
	
		replace `var'=`var'*(1.0317)*(1.0373)*(1.0244)*					   ///
							(1.0194)*(1.0366)*(1.0677)
}

format debts_value %15.0f
sort debts_value
gen year = 2010

compress 

saveold "$projdir/dta/cln/ELCA/elca_hhdebt_10.dta", replace

* -----------------

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
	 
use "2013/Rural/Rhogar.dta", clear

keep consecutivo llave tienen_creditos vr_saldo_*  retpag* 

gen debts_dummy = tienen_creditos == 1 | 								   ///
				  inlist(1, retpag_pub, retpag_salud, retpag_educ, 		   ///
				  			retpag_arren, retpag_almac, retpag_compra,     ///
							retpag_tend, retpag_efinan, retpag_otro) 
							// delay in payments

unab vrsaldo: vr_saldo_*

unab vrretpag: retpag_*_vr

foreach var of varlist `vrsaldo' `vrretpag' {

	replace `var' = . if inlist(`var', 12, 97, 98, 99, 88888888, 99999999)
}

egen saldo_value = rowtotal(`vrsaldo')
egen retpag_value = rowtotal(`vrretpag')

gen debts_value = saldo_value + retpag_value

keep consecutivo llave debts_dummy debts_value 

tempfile debtsR13
save `debtsR13'

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
	 
use "2013/Urbano/Uhogar.dta", clear

keep consecutivo llave tienen_creditos vr_saldo_*  retpag* 

gen debts_dummy = tienen_creditos == 1 | 								   ///
				  inlist(1, retpag_pub, retpag_salud, retpag_educ, 		   ///
				  			retpag_arren, retpag_almac, retpag_compra,     ///
							retpag_tend, retpag_efinan, retpag_otro) 
							// delay in payments

unab vrsaldo: vr_saldo_*

unab vrretpag: retpag_*_vr

foreach var of varlist `vrsaldo' `vrretpag' {

	replace `var' = . if inlist(`var', 12, 97, 98, 99, 88888888, 99999999)
}

egen saldo_value = rowtotal(`vrsaldo')
egen retpag_value = rowtotal(`vrretpag')

gen debts_value = saldo_value + retpag_value

append using `debtsR13'

keep consecutivo llave debts_dummy debts_value 

format debts_value %15.0f
sort debts_value
gen year = 2013

// set at 2016 prices
foreach var of varlist debts_value {
	
		replace `var'=`var'*(1.0194)*(1.0366)*(1.0677)
}

compress 

saveold "$projdir/dta/cln/ELCA/elca_hhdebt_13.dta", replace

* -----------------

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
	 
use "2016/Rural/Rhogar.dta", clear

keep consecutivo llave llave_n16 tienen_creditos vr_saldo_*  retpag* 

gen debts_dummy = tienen_creditos == 1 | 								   ///
				  inlist(1, retpag_pub, retpag_salud, retpag_educ, 		   ///
				  			retpag_arren, retpag_almac, retpag_compra,     ///
							retpag_tend, retpag_efinan, retpag_otro) 
							// delay in payments

unab vrsaldo: vr_saldo_*

unab vrretpag: retpag_*_vr

foreach var of varlist `vrsaldo' `vrretpag' {

	replace `var' = . if inlist(`var', 12, 97, 98, 99, 88888888, 99999999)
}

egen saldo_value = rowtotal(`vrsaldo')
egen retpag_value = rowtotal(`vrretpag')

gen debts_value = saldo_value + retpag_value

keep consecutivo llave llave_n16 debts_dummy debts_value 

sort debts_value
format debts_value %15.0f

tempfile debtsR16
save `debtsR16'

use "2016/Urbano/Uhogar.dta", clear

keep consecutivo llave llave_n16 tienen_creditos vr_saldo_*  retpag* 

gen debts_dummy = tienen_creditos == 1 | 								   ///
				  inlist(1, retpag_pub, retpag_salud, retpag_educ, 		   ///
				  			retpag_arren, retpag_almac, retpag_compra,     ///
							retpag_tend, retpag_efinan, retpag_otro) 
							// delay in payments

unab vrsaldo: vr_saldo_*

unab vrretpag: retpag_*_vr

foreach var of varlist `vrsaldo' `vrretpag' {

	replace `var' = . if inlist(`var', 12, 97, 98, 99, 88888888, 99999999)
}

egen saldo_value = rowtotal(`vrsaldo')
egen retpag_value = rowtotal(`vrretpag')

gen debts_value = saldo_value + retpag_value

append using `debtsR16'

keep consecutivo llave llave_n16 debts_dummy debts_value 

format debts_value %15.0f
sort debts_value
gen year = 2016

compress 

saveold "$projdir/dta/cln/ELCA/elca_hhdebt_16.dta", replace

* -------------------------------------------------------------------

append using "$projdir/dta/cln/ELCA/elca_hhdebt_13.dta"
append using "$projdir/dta/cln/ELCA/elca_hhdebt_10.dta"

bys consecutivo: egen debts_dummy_2010 = max(cond(year==2010, debts_dummy, .))
bys llave:       egen debts_dummy_2013 = max(cond(year==2013, debts_dummy, .))
bys llave_n16:   egen debts_dummy_2016 = max(cond(year==2016, debts_dummy, .))

bys consecutivo: egen debts_value_2010 = max(cond(year==2010, debts_value, .))
bys llave:       egen debts_value_2013 = max(cond(year==2013, debts_value, .))
bys llave_n16:   egen debts_value_2016 = max(cond(year==2016, debts_value, .))

keep consecutivo llave llave_n16 debts_dummy_* debts_value_*

cd "$projdir/dta/cln/ELCA"
merge m:1 llave_n16 using "elca_householdchars_10_13_16.dta"

drop if _merge != 3
drop _merge 

foreach i in 2010 2013 2016 {
	
	foreach v in debts_value {

		gen `v'_pc_`i'= `v'_`i' / numperh_`i'
	}
}

*

cd "$projdir/dta/cln/ELCA"
save "elca_debts_hhlvl_10_13_16.dta", replace

* -------------------------------------------------------------------