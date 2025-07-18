* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ELCA household Income level 2010-2013-2016 

* ----------

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
	
use "2010/Rural/Rhogar.dta",clear    
append using "2010/Urbano/Uhogar.dta"

egen ingtot=rowtotal(ing_trabajo ing_pensiones ing_arriendos			   ///
					 ing_intereses_div ing_ayudas ing_otros_nrem)

keep consecutivo ingtot					 

replace ingtot=ingtot*(1.0317)*(1.0373)*(1.0244)*						   ///
					  (1.0194)*(1.0366)*(1.0677)
					 
replace ingtot = ingtot * 12 // convert to annual			 

rename ingtot hh_totinc

gen year = 2010

cd "$projdir/dta/cln/ELCA/"
save "elca_income_hhlvl_10.dta", replace

* 2013
	
cd "$projdir/dta/src/ELCA/ELCA_10_13_16"

use "2013/Rural/Rhogar.dta",clear    
append using "2013/Urbano/Uhogar.dta"

egen ingtot=rowtotal(ing_trabnoagr ing_trabagr ing_pensiones ing_arriendos	///
					 ing_intereses_div ing_ayudas ing_otros_nrem)
					 
egen ingtot_u=rowtotal(ing_trabajo ing_pensiones ing_arriendos				///
					    ing_intereses_div ing_ayudas ing_otros_nrem)		///
						if zona==1
						
replace ingtot=ingtot_u if zona==1

replace ingtot=ingtot*(1.0317)*(1.0373)*(1.0244)

replace ingtot = ingtot * 12 // convert to annual

replace ing_trabagr=ing_trabagr*(1.0317)*(1.0373)*(1.0244)
					
replace ing_trabagr = ing_trabagr * 12 // convert to annual		

gen perc_ingagro=ing_trabagr/ingtot
replace perc_ingagro=0 if ing_trabagr==.

keep consecutivo llave ingtot 		

rename ingtot hh_totinc

gen year = 2013

cd "$projdir/dta/cln/ELCA/"
save "elca_income_hhlvl_13.dta", replace

* 2016

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"

use "2016/Rural/Rhogar.dta",clear    
append using "2016/Urbano/Uhogar.dta"

egen ingtot=rowtotal(ing_trabnoagr ing_trabagr ing_pensiones ing_arriendos	///
					 ing_intereses_div ing_ayudas ing_otros_nrem)
					 
egen ingtot_u=rowtotal(ing_trabajo ing_pensiones ing_arriendos				///
					    ing_intereses_div ing_ayudas ing_otros_nrem)		///
						if zona_2016==1
						
replace ingtot=ingtot_u if zona_2016==1
					
replace ingtot = ingtot * 12 // convert to annual
	
gen perc_ingagro=ing_trabagr/ingtot
replace perc_ingagro=0 if ing_trabagr==.

keep consecutivo llave llave_n16 ingtot 		

rename ingtot hh_totinc

gen year = 2016

cd "$projdir/dta/cln/ELCA/"
save "elca_income_hhlvl_16.dta", replace


*-------------------------------------------------------------------