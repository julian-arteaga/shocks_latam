* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Import ENAHO PER shock module -- 2014-2023

* -----------------
cd "$projdir/dta/src/ENAHO/"

forvalues y = 2007(1)2024 {

	cd "$projdir/dta/src/ENAHO/"

	use "`y'/Enaho01-`y'-200.dta", clear

	gen fallecio = p217 == 3
	bys conglome vivienda hogar: egen hog_fallecio = max(fallecio)
	bys conglome vivienda hogar: keep if _n == 1
	keep conglome vivienda hogar estrato hog_fallecio ubigeo

	gen year = `y'

	tempfile fallecio_`y'
	save `fallecio_`y''
}

use `fallecio_2007', clear 

forvalues y = 2008(1)2024 {

	append using `fallecio_`y''
}

tempfile fallecio_allys
save `fallecio_allys'

* -----

forvalues y = 2007(1)2024 {

	cd "$projdir/dta/src/ENAHO/"
	use "`y'/Enaho01b-`y'-2.dta", clear

	gen shock_lostjob   	  = p40_1 
	gen shock_bankrupcy 	  = p40_2 
	gen shock_accident_illnss = p40_3 
	// gen shock_abandonmember   = p40_4 // omit for now
	gen shock_criminality     = p40_5 
	gen shock_natdisast 	  = p40_6 

	keep conglome vivienda hogar estrato shock_* ubigeo

	gen year = `y'

	tempfile shocks_`y'
	save `shocks_`y''
}

use `shocks_2007', clear 

forvalues y = 2008(1)2024 {

	append using `shocks_`y''
}

merge 1:1 year conglome vivienda hogar estrato using `fallecio_allys'
drop if _merge != 3 // 30 OBS

rename hog_fallecio shock_deathmember

gen rural = inlist(estrato, 6, 7 ,8)
label var rural "Rural household"

keep conglome vivienda hogar rural shock_* year ubigeo

replace ubigeo = "120604" if ubigeo == "120699"

if year < 2014  {

	destring conglome, gen(congaux)
	gen cong_aux = string(congaux, "%06.0f") 
	drop conglome 
	rename cong_aux conglome
	order conglome
}

drop congaux

cd "$projdir/dta/cln/ENAHO"
save "enaho_shock_prevalence_hhlvl_07_24.dta", replace

* -------------------------------------------------------------------


