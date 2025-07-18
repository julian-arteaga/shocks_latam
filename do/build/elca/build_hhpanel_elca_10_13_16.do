* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ELCA hh level dta 2010-2013-2016
* Sample of households with data for least two waves  

* -----------------

cd "$projdir/dta/cln/ELCA"
use "elca_hhrosterlist_10_13_16.dta", clear

drop consecutivo_c des_comunidad 

foreach var in rural mieperho mpio 										   ///
			   hhead_female singleheaded share_hh_female share_hh_old      ///
			   share_hh_young hhead_educ {

	rename `var' `var'_
}

reshape wide rural_ mieperho_ mpio_										   ///
			 hhead_female_ singleheaded_ share_hh_female_ share_hh_old_    ///
			 share_hh_young_ hhead_educ_, i(allwaveid) j(year)

* -----------------------------------------------

* Merge in Shocks:

cd "$projdir/dta/cln/ELCA"
merge m:1 consecutivo using "elca_shocks_hhlvl_10.dta"
drop if _merge == 2 
drop _merge year urban

foreach i in shock_deathmember shock_accident_illnss shock_lostjob 		   ///
		     shock_natdisast shock_criminality {

	rename `i' `i'_2010
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave using "elca_shocks_hhlvl_13.dta"
drop if _merge == 2 
drop _merge year urban

foreach i in shock_deathmember shock_accident_illnss shock_lostjob 		   ///
		     shock_natdisast shock_criminality {

	rename `i' `i'_2013
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave_n16 using "elca_shocks_hhlvl_16.dta"
drop if _merge == 2 
drop _merge year urban

foreach i in shock_deathmember shock_accident_illnss shock_lostjob 		   ///
		     shock_natdisast shock_criminality {

	rename `i' `i'_2016
}


* -----------------------------------------------

* Merge in consumption:

cd "$projdir/dta/cln/ELCA"
merge m:1 consecutivo using "elca_consump_hhlvl_10.dta"
drop if _merge == 2 
drop _merge year

foreach i in consumo_health consumo_alimento consumo_personal 			   ///
			 consumo_educatio consumo_durables consumo_leisure 			   ///
			 consumo_purchased consumo_transfers consumo_selfcons		   ///
			 consumo_insuranc hh_totexp {

	rename `i' `i'_2010
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave using "elca_consump_hhlvl_13.dta"
drop if _merge == 2 
drop _merge year

foreach i in consumo_health consumo_alimento consumo_personal 			   ///
			 consumo_educatio consumo_durables consumo_leisure 			   ///
			 consumo_purchased consumo_transfers consumo_selfcons		   ///
			 consumo_insuranc hh_totexp {

	rename `i' `i'_2013
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave_n16 using "elca_consump_hhlvl_16.dta"
drop if _merge == 2 
drop _merge year

foreach i in consumo_health consumo_alimento consumo_personal 			   ///
			 consumo_educatio consumo_durables consumo_leisure 			   ///
			 consumo_purchased consumo_transfers consumo_selfcons		   ///
			 consumo_insuranc hh_totexp {

	rename `i' `i'_2016
}

* -----------------------------------------------

* Merge in income:

cd "$projdir/dta/cln/ELCA"
merge m:1 consecutivo using "elca_income_hhlvl_10.dta"
drop if _merge == 2 
drop _merge year

foreach i in hh_totinc {

	rename `i' `i'_2010
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave using "elca_income_hhlvl_13.dta"
drop if _merge == 2 
drop _merge year

foreach i in hh_totinc {

	rename `i' `i'_2013
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave_n16 using "elca_income_hhlvl_16.dta"
drop if _merge == 2 
drop _merge year

foreach i in hh_totinc {

	rename `i' `i'_2016
}

* -----------------------------------------------

* Merge in debts:

cd "$projdir/dta/cln/ELCA"
merge m:1 consecutivo using "elca_hhdebt_10.dta"
drop if _merge == 2 
drop _merge year

foreach i in debts_dummy debts_value {

	rename `i' `i'_2010
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave using "elca_hhdebt_13.dta"
drop if _merge == 2 
drop _merge year

foreach i in debts_dummy debts_value {

	rename `i' `i'_2013
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave_n16 using "elca_hhdebt_16.dta"
drop if _merge == 2 
drop _merge year

foreach i in debts_dummy debts_value {

	rename `i' `i'_2016
}

* -----------------------------------------------

* Merge in govt programs:

cd "$projdir/dta/cln/ELCA"
merge m:1 consecutivo using "elca_govtprog_hhlvl_10.dta"
drop if _merge == 2 
drop _merge year

foreach i in familias_accion programas_hogar programas_produccion 		   ///
			 programas_formacion {

	rename `i' `i'_2010
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave using "elca_govtprog_hhlvl_13.dta"
drop if _merge == 2 
drop _merge year

foreach i in familias_accion programas_hogar programas_produccion 		   ///
			 programas_formacion {

	rename `i' `i'_2013
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave_n16 using "elca_govtprog_hhlvl_16.dta"
drop if _merge == 2 
drop _merge year

foreach i in familias_accion programas_hogar programas_produccion 		   ///
			 programas_formacion {

	rename `i' `i'_2016
}

* -----------------------------------------------

* Merge in schooling indicator for underage:

cd "$projdir/dta/cln/ELCA"
merge m:1 consecutivo using "elca_noschool_minors_hhlvl_10.dta"
drop if _merge == 2 
drop _merge year

foreach i in minor_no_school {

	rename `i' `i'_2010
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave using "elca_noschool_minors_hhlvl_13.dta"
drop if _merge == 2 
drop _merge year

foreach i in minor_no_school {

	rename `i' `i'_2013
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave_n16 using "elca_noschool_minors_hhlvl_16.dta"
drop if _merge == 2 
drop _merge year

foreach i in minor_no_school {

	rename `i' `i'_2016
}

* -----------------------------------------------


* Merge in migration:

gen migrante_2010  = 0 
gen migrazona_2010 = 0
gen migraver_2010  = 0
gen migramun_2010  = 0 

cd "$projdir/dta/cln/ELCA"
merge m:1 llave using "elca_migration_hhlvl_13.dta"
drop if _merge == 2 
drop _merge year

foreach i in migrante migrazona migraver migramun {

	rename `i' `i'_2013
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave_n16 using "elca_migration_hhlvl_16.dta"
drop if _merge == 2 
drop _merge year

foreach i in migrante migrazona migraver migramun {

	rename `i' `i'_2016
}

* -----------------------------------------------

drop zona* ola*

reshape long rural_ mieperho_ mpio_ 							 	   	   ///
			 hhead_female_ singleheaded_ share_hh_female_ 				   ///
			 share_hh_old_ share_hh_young_ hhead_educ_					   ///
			 ///
		     shock_deathmember_ shock_accident_illnss_ shock_lostjob_ 	   ///
		     shock_natdisast_ shock_criminality_ 		   				   ///
			 ///
			 consumo_health_ consumo_alimento_ consumo_personal_ 		   ///
			 consumo_educatio_ consumo_durables_ consumo_leisure_ 		   ///
			 consumo_purchased_ consumo_transfers_ consumo_selfcons_	   ///
			 consumo_insuranc_ hh_totexp_								   ///
			 ///
			 hh_totinc_													   ///
			 ///
			 debts_dummy_ debts_value_  		   	   					   ///
			 ///
			 familias_accion_ programas_hogar_ programas_produccion_ 	   ///
			 programas_formacion_										   ///
			 ///
			 minor_no_school_ 											   ///
			 ///
			 migrante_ migrazona_ migraver_ migramun_, 		   			   ///
			 i(allwaveid) j(year) 

rename debts_* debt_*
rename *_ *

drop if llave_n16 == 9999999999 & year == 2016

* -----------------------------------------------

* Merge in municipal characteristics:

* replace mpio code for bogota localidades with bogota general code
replace mpio = 11001 if inrange(mpio, 11002, 11019)
gen admincode = string(mpio, "%05.0f")

merge m:1 admincode using "$projdir/dta/cln/ELCA/col_munic_sea_distances.dta"
drop if _merge == 2
drop _merge 

merge m:1 admincode using "$projdir/dta/cln/ELCA/col_munic_povrate.dta"
drop if _merge == 2 
drop _merge 

merge m:1 admincode using "$projdir/dta/cln/ELCA/col_munic_healthaccess.dta"
drop if _merge == 2 
drop _merge 

* -----------------------------------------------

* Build harmonized vars

gen cty = "COL"

replace consumo_personal = consumo_personal 						   ///
						  + consumo_educatio 						   ///
						  + consumo_insuranc

drop consumo_educatio consumo_insuranc

replace consumo_purchased = consumo_purchased + consumo_selfcons 

drop consumo_selfcons 

foreach var of varlist consumo_health consumo_alimento consumo_personal    ///
			  		   consumo_durables consumo_leisure   		   		   ///
			 		   consumo_purchased consumo_transfers debt_value      ///
			 		   hh_totexp hh_totinc {

	gen `var'_pc = `var' / mieperho
}

replace shock_accident_illnss = 1 if 									   ///
		shock_accident_illnss == 1 | shock_deathmember == 1			   
	   		   
gen allshockmiss = (shock_deathmember == . & shock_accident_illnss == . &  ///
					shock_lostjob == . & shock_natdisast == . &			   ///
					shock_criminality == .)

drop if allshockmiss == 1 

gen shock_any = shock_natdisast + shock_accident_illnss  		   		   ///
	    	   + shock_lostjob + shock_criminality > 0 	

rename hh_totexp_pc percexp
rename debt_* debts_*

gen govt_prog = 														   ///
	inlist(1, programas_hogar, programas_formacion, programas_produccion)

* Keep only households with at least two years of responses:
bys allwaveid: gen numys = _N 
keep if numys > 1 // left with 27,644 obs across 9613 households

egen hhid = group(allwaveid)

drop shock_deathmember

distinct hhid // 9613
bys rural: distinct hhid  // 5437 urban; 4848 rural

format year %10.0f

xtset hhid year
sort hhid year 

gen rural_baseline = rural[_n-1] if hhid == hhid[_n-1]

// egen inc_pc_q = xtile(percinc), n(5) by(rural year) 

egen exp_pc_q = xtile(percexp), n(5) by(rural year) 

egen exp_pc_all_q = xtile(percexp), n(5) by(year) 

gen percexp_baseline = percexp[_n-1] if hhid == hhid[_n-1]
gen exp_pc_q_baseline = exp_pc_q[_n-1]  if hhid == hhid[_n-1]
gen exp_pc_q_pre_all = exp_pc_all_q[_n-1]  if hhid == hhid[_n-1]

foreach var of varlist hhead_female singleheaded       					   ///
                       share_hh_female share_hh_old share_hh_young         ///
                       hhead_educ distance_to_sea_km poverty_rate_tot      ///
                       rate_nohealthaccess {

	sort hhid year
	gen `var'_baseline = `var'[_n-1] if hhid == hhid[_n-1]
}

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_hhpanel_10_13_16.dta", replace 

* -------------------------------------------------------------------
