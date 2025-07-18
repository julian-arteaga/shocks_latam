* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ELCA govt program access measures -- 2010-2013-2016

* from: IV) Government Programs - 20170515 *

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"

* 2010
* Rural
	 
use "2010/Rural/Rhogar.dta",clear    

/* Los que hay: 
familias_accion jovenes_accion sena red_juntos icbf sub_desempleo 
ayu_emergencias prg_adultomayor ayu_desplazados tit_baldios prg_tierras 	
caja_subsprest caja_saludrec agro_ingresos guardabosques leydevictimas     
oport_rural alianz_prod otro_prg_rural otro_programa */

gen programas_hogar=.
replace programas_hogar=1 if familias_accion==1 | jovenes_accion==1|       ///
							 red_juntos==1 | icbf==1 | sub_desempleo==1|   ///
							 prg_adultomayor==1|						   ///
							 ayu_desplazados==1			
recode programas_hogar (.=0)

gen programas_produccion=.
replace programas_produccion=1 if tit_baldios==1 | prg_tierras==1| 		   ///
								  agro_ingresos==1    
recode programas_produccion (.=0)

gen programas_formacion=.
replace programas_formacion=1 if sena==1
recode programas_formacion (.=0)

recode familias_accion (2 = 0)

keep consecutivo ola zona programas_hogar programas_produccion        	   /// 
	 programas_formacion familias_accion zona

tempfile prog_r2010
save `prog_r2010'

/* I. 2010
	b) Urbano  */

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
use "2010/Urbano/Uhogar.dta",clear

gen programas_hogar=.
replace programas_hogar=1 if familias_accion==1 | jovenes_accion==1| 		///
							 red_juntos==1 | icbf==1 | sub_desempleo==1|    ///
							 prg_adultomayor==1|		///
							 ayu_desplazados==1		

recode programas_hogar (. = 0)

gen programas_produccion = 0


gen programas_formacion=.
replace programas_formacion=1 if sena==1
recode programas_formacion (.=0)

recode familias_accion (2 = 0)

keep consecutivo ola zona programas_hogar programas_produccion        /// 
	 programas_formacion familias_accion zona

append using `prog_r2010'

gen year = 2010

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_govtprog_hhlvl_10.dta", replace

/* II. 2013
	 a) Rural */
	 
cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
use "2013/Rural/Rhogar.dta",clear

gen programas_hogar=.
replace programas_hogar=1 if familias_accion==1 | prg_adultomayor==1|		///
							 red_juntos==1 | icbf==1 |  ///
							 ayu_desplazados==1
recode programas_hogar (.=0)

gen programas_produccion=.
replace programas_produccion=1 if tit_baldios==1 | prg_tierras==1| 			///
		agro_ingresos==1 |			///
		otro_prg_rural==1
recode programas_produccion (.=0)

gen programas_formacion=.
replace programas_formacion=1 if sena==1
recode programas_formacion (.=0)

recode familias_accion (2 = 0)

keep llave consecutivo ola zona programas_hogar programas_produccion		///
	 programas_formacion familias_accion zona

tempfile prog_r2013
save `prog_r2013'

/* II. 2013
	 b) Urbano */

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
use "2013/Urbano/Uhogar.dta",clear

gen programas_hogar=.
replace programas_hogar=1 if familias_accion==1 |	///
		prg_adultomayor==1 | red_juntos==1 | icbf==1 | ///
		ayu_desplazados==1								
recode programas_hogar (.=0)

gen programas_formacion=.
replace programas_formacion=1 if sena==1
recode programas_formacion (.=0)

gen programas_produccion = 0

recode familias_accion (2 = 0)

keep llave ola zona consecutivo programas_hogar programas_formacion			///
	 programas_produccion familias_accion zona

append using `prog_r2013'

gen year = 2013

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_govtprog_hhlvl_13.dta", replace

* 2016
* Rural

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
use "2016/Rural/Rhogar.dta",clear

gen programas_hogar=.
replace programas_hogar=1 if familias_accion==1 | prg_adultomayor==1|		///
							 red_juntos==1 | icbf==1 |  ///
							 ayu_desplazados==1
recode programas_hogar (.=0)

gen programas_produccion=.
replace programas_produccion=1 if tit_baldios==1 | prg_tierras==1| 			///
		agro_ingresos==1 | 			///
		otro_prg_rural==1
recode programas_produccion (.=0)

gen programas_formacion=.
replace programas_formacion=1 if sena==1
recode programas_formacion (.=0)

rename zona_2016 zona		

recode familias_accion (2 = 0)

keep llave consecutivo llave_n16 ola programas_hogar						///
	 programas_produccion programas_formacion familias_accion zona

tempfile prog_R2016
save `prog_R2016'

* urbano

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
use "2016/Urbano/Uhogar.dta",clear

gen programas_hogar=.
replace programas_hogar=1 if familias_accion==1 | jovenes_accion==1| 		///
		prg_adultomayor==1 | red_juntos==1 | icbf==1 |  ///
		ayu_desplazados==1							
recode programas_hogar (.=0)

gen programas_formacion=.
replace programas_formacion=1 if sena==1
recode programas_formacion (.=0)

rename zona_2016 zona		

gen programas_produccion = 0

recode familias_accion (2 = 0)

keep llave ola llave_n16 consecutivo programas_hogar programas_formacion 	///
	 programas_produccion familias_accion zona

append using `prog_R2016'

gen year = 2016

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_govtprog_hhlvl_16.dta", replace

* -------------------------------------------------------------------
