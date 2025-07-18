* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Correlate weather shocks with self-reported nat disast shocks 

* ----------------------------------

* Build weather shock (external and selfreport) dataset for all countries:

* ----------
* [COL]

cd "$projdir/dta/src/ERA5"

use "tempshocks_elca_mpio_year.dta", clear

rename codmpio mpio
rename y year

foreach var of varlist tp* {

	replace `var' = `var' / 100
}	 

cd "$projdir/dta/cln/ELCA/"
merge 1:m mpio year using "elca_hhpanel_10_13_16.dta"
drop if _merge == 1 // mpios x years without elca hh
drop _merge 

keep mpio_dane mpio year allwaveid shock* rural* tp* stpag*

gen cty = "COL"
gen admincode = string(mpio_dane, "%05.0f")

tempfile col
save `col'

* ----------
* [PER]

cd "$projdir/dta/src/ERA5/20250618-pp-mex-per-Tempshocks/"
use "shocks_t2m_PER_1979-2023y.dta", clear

gen ubigeo = string(codmpio,"%06.0f")

gen year = y

cd "$projdir/dta/cln/ENAHO"
merge 1:m year ubigeo using "enaho_hhpanel_07_23_3yearly.dta"
drop if _merge == 1 // mpios x years without elca hh
drop _merge 

keep ubigeo year allwaveid shock* tp* stpag* rural*

gen cty = "PER"
gen admincode = ubigeo

tempfile per
save `per'

* ----------
* [MEX]

cd "$projdir/dta/src/ERA5"

use "20250618-pp-mex-per-Tempshocks/shocks_t2m_MEX_1979-2010y.dta", clear

gen cvegeo = string(codmpio, "%05.0f")

xtset codmpio y

rename y year

cd "$projdir/dta/cln/ENNVIH/"
merge 1:m cvegeo year using "ennvih_hhpanel_02_05_09.dta"
drop if _merge != 3 // 4 obs with no cvegeo
drop _merge 

keep cvegeo year allwaveid shock* tp* stpag* rural*

gen cty = "MEX"
gen admincode = cvegeo

tempfile mex
save `mex'

append using `col'
append using `per'

egen cty_id = group(cty)

reghdfe shock_natdisast c.stpag_l12##i.rural_baseline, absorb(allwaveid year##cty_id)

lincom stpag_l12 + 1.rural_baseline#c.stpag_l12