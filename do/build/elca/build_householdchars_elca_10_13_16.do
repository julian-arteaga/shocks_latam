* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ELCA household characteristics 2010-2013-2016 

* Based on 2_household characteristics.do in the ELCA_2016 folder (20170504)

* -----------------

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"

* 2010:

use "2010/Rural/Rpersonas.dta", clear
drop razon_na_c
tostring cred_cual,replace
append using "2010/Urbano/Upersonas.dta"

* Number of persons in household:

bys consecutivo: egen numperh=count(llave_ID_lb) 

collapse ola llave zona numperh /* edad_jh mujer_jh educ_max hog_edad*     ///	
		 jh_ocupado jh_desempleado sp_ocupado sp_desempleado			   ///
		 sector_sp sector_jh jh_vivia_5 jh_vivia_12_14 */, by(consecutivo)
		 
tempfile Hh_chars_10
save `Hh_chars_10'

 * 2013:
 
use "2013/Rural/Rpersonas.dta", clear
rename descrip_activ1 descripcion_ciiu
append using "2013/Urbano/Upersonas.dta"

* Number of persons in household:

bys llave: egen numperh=count(llaveper) 

collapse consecutivo ola zona numperh /* edad_jh mujer_jh jh_ocupado       ///
		 jh_desempleado sp_ocupado	sp_desempleado educ_max hog_edad* 	   ///
		 sector_sp sector_jh*/, by(llave)
		 
tempfile Hh_chars_13
save `Hh_chars_13'

 * 2016:
 
use "2016/Rural/Rpersonas.dta", clear
cap drop zona
gen zona=2
rename descrip_activ1 descripcion_ciiu
append using "2016/Urbano/Upersonas.dta"
replace zona=1 if zona!=2

* Number of persons in household:

bys llave_n16: egen numperh=count(llaveper_n16) 

collapse consecutivo llave ola zona numperh /* edad_jh mujer_jh jh_ocupado ///
		 sp_ocupado														   ///
	     jh_desempleado sp_desempleado educ_max hog_edad* 				   ///
		 sector_sp sector_jh (max) t_dejoestudio*/, by(llave_n16)		 
		
append using `Hh_chars_13'
append using `Hh_chars_10'

foreach i in numperh zona {
	
		/*edad_jh mujer_jh educ_max hog_edad0_5 hog_edad6_17			   ///
			 hog_edad18_65 hog_edad65  jh_ocupado jh_desempleado		   ///
			 sp_ocupado sp_desempleado sector_jh sector_sp jh_vivia_5 	   ///
			 jh_vivia_12_14 { */
			 
		gen `i'_2=`i' if ola==1	
		bys consecutivo: egen `i'_2010=max(`i'_2)
		drop `i'_2

		gen `i'_2=`i' if ola==2	
		bys llave: egen `i'_2013=max(`i'_2)
		drop `i'_2
		 
		rename `i' `i'_2016
}

keep if llave_n16 != . 

keep if zona_2013 != . // drop households that are in 10 and 16 but not in 13

drop llave_ID_lb



*
cd "$projdir/dta/cln/ELCA"
save "elca_householdchars_10_13_16.dta", replace

* -------------------------------------------------------------------