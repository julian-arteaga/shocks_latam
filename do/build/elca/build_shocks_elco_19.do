* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* build ELCO 2019 shock module

* -----------------

cd "$projdir/"

use "dta/src/ELCA/ELCO_2019/B_DATOS DE LA VIVIENDA.dta", clear

keep CONSECUTIVO_DANE_ELCO_2019 CLASE

tempfile hh_clase
save `hh_clase'

use "dta/src/ELCA/ELCO_2019/E_RIESGOS Y CHOQUES DEL HOGAR.dta", clear

merge 1:1 CONSECUTIVO_DANE_ELCO_2019 using `hh_clase'

gen shock_deathmember 		= P2116S1 == 1
gen shock_abandonmember 	= P2116S2 == 1
gen shock_arrivalmember 	= P2116S3 == 1
gen shock_accident_illnss   = P2116S4 == 1
gen shock_divorce 			= P2116S5 == 1
gen shock_lostjob 			= P2116S6 == 1
gen shock_abandonhouse 		= P2116S7 == 1
gen shock_bankrupcy 		= P2116S8 == 1
gen shock_losthouse 		= P2116S9 == 1
gen shock_lostland 			= P2116S10 == 1
gen shock_lostremit 		= P2116S11 == 1
gen shock_theftlostassets 	= P2116S12 == 1
gen shock_robbery 			= P2116S13 == 1
gen shock_failharvest 		= P2116S14 == 1
gen shock_lostanimals 		= P2116S15 == 1
gen shock_floodlandslide 	= P2116S16 == 1
gen shock_earthquake 		= P2116S17 == 1
gen shock_drought 			= P2116S18 == 1
gen shock_violence 			= P2116S19 == 1

label variable shock_deathmember      "Death of a household member"
label variable shock_abandonmember    "Abandonment of a household member"
label variable shock_arrivalmember    "Arrival of a new household member"
label variable shock_accident_illnss  "Serious accident or illness of a member"
label variable shock_divorce          "Divorce or separation"
label variable shock_lostjob          "Loss of employment of a member"
label variable shock_abandonhouse     "Abandonment of the dwelling"
label variable shock_bankrupcy        "Bankruptcy or business failure"
label variable shock_losthouse        "Loss of housing (foreclosure/eviction)"
label variable shock_lostland         "Loss of land"
label variable shock_lostremit        "Loss or reduction of remittances"
label variable shock_theftlostassets  "Theft or loss of valuable assets"
label variable shock_robbery          "Robbery or burglary"
label variable shock_failharvest      "Crop failure or poor harvest"
label variable shock_lostanimals      "Loss of livestock or animals"
label variable shock_floodlandslide   "Flood or landslide"
label variable shock_earthquake       "Earthquake"
label variable shock_drought          "Drought"
label variable shock_violence         "Violence, conflict, or insecurity"

gen transfer_fenaccion = P2117S1 == 1 
gen transfer_colmayor  = P2117S2 == 1
gen transfer_jovaccion = P2117S3 == 1
gen transfer_disaster  = P2117S4 == 1 
gen transfer_displaced = P2117S5 == 1
gen transfer_sena      = P2117S6 == 1
gen transfer_restituc  = P2117S7 == 1
gen transfer_icbf      = P2117S8 == 1
gen transfer_redunidos = P2117S9 == 1
gen transfer_agroingre = P2117S10 == 1
gen transfer_minagric  = P2117S11 == 1
gen transfer_arenovter = P2117S12 == 1
gen transfer_titbaldio = P2117S13 == 1
gen transfer_adjtierra = P2117S14 == 1
gen transfer_othergov  = P2117S15 == 1
gen transfer_fndfamcol = P2118 == 1
gen transfer_fndfamext = P2119 == 1
gen transfer_alimony   = P2120 == 1
gen transfer_othrnogov = P2121 == 1

keep shock_* transfer_* CONSECUTIVO_* DIRECTORIO SECUENCIA_* ORDEN CLASE

gen elca_hh = CONSECUTIVO_DANE_2010 != "" |  ///
			  CONSECUTIVO_DANE_2013 != "" |  ///
			  CONSECUTIVO_DANE_2016 != ""

* -----------------

* Harmonize shock categories:

replace shock_lostjob = inlist(1, shock_lostjob, shock_bankrupcy)

replace shock_accident_illnss = inlist(									   ///
	1, shock_deathmember, shock_accident_illnss)

gen shock_criminality = inlist(											   ///
	1, shock_robbery, shock_theftlostassets, shock_violence)

gen shock_natdisast = inlist(1, shock_earthquake, shock_drought, 		   ///
							    shock_floodlandslide)

gen rural = CLASE != 1

drop transfer* 

keep CONSECUTIVO_DANE_2010-CLASE rural elca_hh							   ///
	 shock_accident_illnss shock_criminality shock_natdisast shock_lostjob

gen shock_any = shock_natdisast + shock_accident_illnss  		   		   ///
	    	   + shock_lostjob + shock_criminality > 0 	

cd "$projdir/dta/cln/ELCA"
save "elca_shocks_hhlvl_19.dta", replace

* -------------------------------------------------------------------