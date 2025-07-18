* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENAHO municipal-level characteristic vars:

* -----------------

* Distance to sea:

cd "$projdir/dta/cln/ENAHO"
import delimited using "per_munic_sea_distances.csv", clear

sort ubigeo 
gen admincode = string(ubigeo, "%06.0f")

keep admincode distance_

cd "$projdir/dta/cln/ENAHO"
save "per_munic_sea_distances.dta", replace

* -------------------------------------

* ~dist~ province poverty rates:

cd "$projdir/dta/src/LG"
import delimited using "poverty_adm2.csv", clear

keep if adm0_pcode == "PER"

gen provincecode = substr(adm2_pcode, 3, .)

keep provincecode poverty_rate_tot

cd "$projdir/dta/cln/ENAHO"
save "per_province_povrate.dta", replace 

* -------------------------------------

* ~dist~ province health access:

cd "$projdir/dta/src/LG"
import delimited using "health_acces_30min_adm2.csv", clear

keep if adm0_pcode == "PER"

gen provincecode = substr(adm2_pcode, 3, .)

gen rate_nohealthaccess = no_access_off / pop_tot

keep provincecode rate_nohealthaccess

label var rate_nohealthaccess 													   ///
	"Porcentaje de pob sin acceso a servicios de salud 30 minutos en automóvil"

cd "$projdir/dta/cln/ENAHO"
save "per_province_healthaccess.dta", replace 

* -------------------------------------------------------------------
