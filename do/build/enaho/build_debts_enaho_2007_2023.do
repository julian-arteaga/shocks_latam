* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Import ENAHO household debt indicator -- 2020-2023

cd "$projdir/dta/src/ENAHO/"

forvalues y = 2020(1)2023 {

	use "`y'/enaho01a-`y'-500.dta", clear

	gen requestloan  = p558e2_1 == 1
	gen receivedloan = requestloan == 1 & p558e3_1 == 1

	gen receivedremit = p5563a == 1

	bys conglome vivienda hogar: egen request_loan = max(requestloan)
	bys conglome vivienda hogar: egen receive_loan = max(receivedloan)

	bys conglome vivienda hogar: egen receive_remit = max(receivedremit)

	bys conglome vivienda hogar: keep if _n == 1

	keep conglome vivienda hogar request_loan receive_loan receive_remit

	gen year = `y' 

	tempfile loan`y'
	save `loan`y''
}

use `loan2020'

append using `loan2021'
append using `loan2022'
append using `loan2023'

compress 

cd "$projdir/dta/cln/ENAHO"
save "enaho_debts_hhlvl_07_23.dta", replace

* -------------------------------------------------------------------