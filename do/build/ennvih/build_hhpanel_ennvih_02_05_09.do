* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENNVIH hh level dta 2002-2005-2009
* Sample of households with data for least two waves  

* -----------------

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_hhrosterlist_02_05_09.dta", clear

foreach var in rural mieperho cvegeo 									   ///
			   hhead_female singleheaded share_hh_female share_hh_old      ///
			   share_hh_young hhead_educ {

	rename `var' `var'_
}

reshape wide rural_ mieperho_ cvegeo_									   ///
			 hhead_female_ singleheaded_ share_hh_female_ share_hh_old_    ///
			 share_hh_young_ hhead_educ_, i(allwaveid) j(year)

* -----------------------------------------------

* Merge in Shocks:

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_09 using "ennvih_shocks_hhlvl_09.dta"
drop if _merge == 2 
drop _merge year rural

foreach i in shock_deathmember shock_accident_illnss shock_lostjob 		   ///
		     shock_natdisast shock_criminality {

	rename `i' `i'_2009
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_05 using "ennvih_shocks_hhlvl_05.dta"
drop if _merge == 2 
drop _merge year rural

foreach i in shock_deathmember shock_accident_illnss shock_lostjob 		   ///
		     shock_natdisast shock_criminality {

	rename `i' `i'_2005
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_02 using "ennvih_shocks_hhlvl_02.dta"
drop if _merge == 2 
drop _merge year rural

foreach i in shock_deathmember shock_accident_illnss shock_lostjob 		   ///
		     shock_natdisast shock_criminality {

	rename `i' `i'_2002
}

* -----------------------------------------------

* Merge in consumption:

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_09 using "ennvih_consump_hhlvl_09.dta"
drop if _merge == 2 
drop _merge year

foreach i in consumo_health consumo_alimento consumo_personal 			   ///
			 consumo_educatio consumo_durables consumo_leisure 			   ///
			 consumo_purchased consumo_transfers hh_totexp {

	rename `i' `i'_2009
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_05 using "ennvih_consump_hhlvl_05.dta"
drop if _merge == 2 
drop _merge year

foreach i in consumo_health consumo_alimento consumo_personal 			   ///
			 consumo_educatio consumo_durables consumo_leisure 			   ///
			 consumo_purchased consumo_transfers hh_totexp {

	rename `i' `i'_2005
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_02 using "ennvih_consump_hhlvl_02.dta"
drop if _merge == 2 
drop _merge year

foreach i in consumo_health consumo_alimento consumo_personal 			   ///
			 consumo_educatio consumo_durables consumo_leisure 			   ///
			 consumo_purchased consumo_transfers hh_totexp {

	rename `i' `i'_2002
}

* -----------------------------------------------

* Merge in income:

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_09 using "ennvih_income_hhlvl_09.dta"
drop if _merge == 2 
drop _merge year

foreach i in hh_totincome {

	rename `i' `i'_2009
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_05 using "ennvih_income_hhlvl_05.dta"
drop if _merge == 2 
drop _merge year

foreach i in hh_totincome {

	rename `i' `i'_2005
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_02 using "ennvih_income_hhlvl_02.dta"
drop if _merge == 2 
drop _merge year

foreach i in hh_totincome {

	rename `i' `i'_2002
}

* -----------------------------------------------

* Merge in debts:

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_09 using "ennvih_debt_hhlvl_09.dta"
drop if _merge == 2 
drop _merge year

foreach i in debt_dummy debt_value {

	rename `i' `i'_2009
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_05 using "ennvih_debt_hhlvl_05.dta"
drop if _merge == 2 
drop _merge year

foreach i in debt_dummy debt_value {

	rename `i' `i'_2005
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_02 using "ennvih_debt_hhlvl_02.dta"
drop if _merge == 2 
drop _merge year

foreach i in debt_dummy debt_value {

	rename `i' `i'_2002
}

* -----------------------------------------------

* Merge in govt programs:

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_09 using "ennvih_govtprog_hhlvl_09.dta"
drop if _merge == 2 
drop _merge year

foreach i in govt_prog {

	rename `i' `i'_2009
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_05 using "ennvih_govtprog_hhlvl_05.dta"
drop if _merge == 2 
drop _merge year

foreach i in govt_prog {

	rename `i' `i'_2005
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_02 using "ennvih_govtprog_hhlvl_02.dta"
drop if _merge == 2 
drop _merge year

foreach i in govt_prog {

	rename `i' `i'_2002
}

* -----------------------------------------------

* Merge in schooling indicator for underage:

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_09 using "ennvih_noschool_minors_hhlvl_09.dta"
drop if _merge == 2 
drop _merge year

foreach i in minor_no_school {

	rename `i' `i'_2009
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_05 using "ennvih_noschool_minors_hhlvl_05.dta"
drop if _merge == 2 
drop _merge year

foreach i in minor_no_school {

	rename `i' `i'_2005
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 folio_02 using "ennvih_noschool_minors_hhlvl_02.dta"
drop if _merge == 2 
drop _merge year

foreach i in minor_no_school {

	rename `i' `i'_2002
}

* -----------------------------------------------

* Merge in migration:

gen migrante_2002  = 0 
gen migrazona_2002 = 0
gen migramun_2002  = 0 

cd "$projdir/dta/cln/ENNVIH"
merge m:1 allwaveid using "ennvih_migration_hhlvl_09.dta"
drop if _merge == 2 
drop _merge year

foreach i in migrante migrazona migramun {

	rename `i' `i'_2009
}

cd "$projdir/dta/cln/ENNVIH"
merge m:1 allwaveid using "ennvih_migration_hhlvl_05.dta"
drop if _merge == 2 
drop _merge year

foreach i in migrante migrazona migramun {

	rename `i' `i'_2005
}

* -----------------------------------------------

reshape long rural_ mieperho_ cvegeo_ 							 	   	   ///
			 hhead_female_ singleheaded_ share_hh_female_ 				   ///
			 share_hh_old_ share_hh_young_ hhead_educ_					   ///
			 ///
		     shock_deathmember_ shock_accident_illnss_ shock_lostjob_ 	   ///
		     shock_natdisast_ shock_criminality_ 		   				   ///
			 ///
			 consumo_health_ consumo_alimento_ consumo_personal_ 		   ///
			 consumo_educatio_ consumo_durables_ consumo_leisure_ 		   ///
			 consumo_purchased_ consumo_transfers_ hh_totexp_			   ///
			 ///
			 debt_dummy_ debt_value_									   ///
			 ///
			 hh_totincome_												   ///
			 ///
			 govt_prog_													   ///
			 ///
			 minor_no_school_											   ///
			 ///
			 migrante_ migramun_ migrazona_, i(allwaveid) j(year) 

rename *_ *

drop if folio_09 == "9999999999" & year == 2009

* -----------------------------------------------

* Merge in municipal characteristics:

gen admincode = cvegeo

merge m:1 admincode using "$projdir/dta/cln/ENNVIH/mex_munic_sea_distances.dta"
drop if _merge == 2
drop _merge // 11 obs with undefined admincodes

merge m:1 admincode using "$projdir/dta/cln/ENNVIH/mex_munic_povrate.dta"
drop if _merge == 2 
drop _merge 

merge m:1 admincode using "$projdir/dta/cln/ENNVIH/mex_munic_healthaccess.dta"
drop if _merge == 2 
drop _merge 

* -----------------------------------------------

* Build harmonized vars

gen cty = "MEX"

rename hh_totincome hh_totinc 

replace consumo_personal = consumo_personal 						   	   ///
						  + consumo_educatio 

drop consumo_educatio

foreach var of varlist consumo_health consumo_alimento consumo_personal    ///
			  		   consumo_durables consumo_leisure   		   		   ///
			 		   consumo_purchased consumo_transfers debt_value 	   ///
			 		   hh_totexp hh_totinc  {

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

replace shock_criminality = . if year == 2002 

rename hh_totexp_pc percexp
rename debt_* debts_*

* Keep only households with at least two years of responses:
bys allwaveid: gen numys = _N 
keep if numys > 1 // left with 21,777 obs across 7735 households

egen hhid = group(allwaveid)

drop shock_deathmember

distinct hhid // 8196
bys rural: distinct hhid  // 5122 urban; 3807 rural

xtset hhid year
sort hhid year 

gen rural_baseline = rural[_n-1] if hhid == hhid[_n-1]

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

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_hhpanel_02_05_09.dta", replace 

* -------------------------------------------------------------------
