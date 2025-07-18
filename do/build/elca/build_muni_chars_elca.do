* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ELCA municipal-level characteristic vars:

* -----------------

* Distance to sea:

cd "$projdir/dta/cln/ELCA"
import delimited using "col_munic_sea_distances.csv", clear

gen muni = string(mpio_ccdgo, "%03.0f")
gen dep  = string(dpto_ccdgo, "%02.0f")

gen admincode = dep + muni

keep admincode distance_

cd "$projdir/dta/cln/ELCA"
save "col_munic_sea_distances.dta", replace

* -------------------------------------

* Muni poverty rates:

cd "$projdir/dta/src/LG"
import delimited using "poverty_adm2.csv", clear

keep if adm0_pcode == "COL"

gen admincode = substr(adm2_pcode, 3, .)

keep admincode poverty_rate_tot

cd "$projdir/dta/cln/ELCA"
save "col_munic_povrate.dta", replace 

* -------------------------------------

* ~dist~ province health access:

cd "$projdir/dta/src/LG"
import delimited using "health_acces_30min_adm2.csv", clear

keep if adm0_pcode == "CO"

gen admincode = substr(adm2_pcode, 3, .)

gen rate_nohealthaccess = no_access_off / pop_tot

keep admincode rate_nohealthaccess

label var rate_nohealthaccess 													   ///
	"Porcentaje de pob sin acceso a servicios de salud 30 minutos en automóvil"

cd "$projdir/dta/cln/ELCA"
save "col_munic_healthaccess.dta", replace 

* -------------------------------------------------------------------
