* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Import ENAHO consumption measures -- 2014-2023

* 2013:
use "$projdir/dta/src/ENAHO/2013/SUMARIA-2013.dta", clear
numlabel, add

gen percinc = inghog2d / (mieperho*12)
label var percinc "Net household percapita monthly income"

gen percexp = gashog2d / (mieperho*12)
label var percexp "Total household percapita monthly expenditure"

gen year = 2013

sum percinc percexp 

keep conglome vivienda hogar year percinc percexp

tempfile incexp_2013
save `incexp_2013'

forvalues y = 2014(1)2023 {

	use "$projdir/dta/src/ENAHO/`y'/sumaria-`y'.dta", clear
	numlabel, add

	gen percinc = inghog2d / (mieperho*12)
	label var percinc "Net household percapita monthly income"

	gen percexp = gashog2d / (mieperho*12)
	label var percexp "Total household percapita monthly expenditure"

	gen year = `y'

	sum percinc percexp 

	keep conglome vivienda hogar year percinc percexp

	tempfile incexp_`y'
	save `incexp_`y''
}

use `incexp_2013', clear 

forvalues y = 2014(1)2023 {

	append using `incexp_`y''
}

cd "$projdir/dta/cln/ENAHO"
save "enaho_income_expendit_hhlvl_13_23.dta", replace

* -------------------------------------------------------------------