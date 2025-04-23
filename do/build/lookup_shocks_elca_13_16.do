* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* lookup ELCA 2013 and 2016 shock module

* -----------------

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"

* 2013
	 
use "2013/Rural/Rchoques_hogar.dta",clear    

merge m:1 llave using "2013/Rural/Rhogar.dta", keepus(zona)

drop _merge

gen shock=.
replace shock=1 if tuvo_choque==1
bys llave: egen choques= total(shock)

sort llave choque
	
/*	
								601. Orden. |      Freq.     Percent     
----------------------------------------+---------------------------
1	Accidente o enfermedad de algún miembro |      4,351        5.88       
2	Muerte del que era jefe del hogar o del |      4,351        5.88      
3	Muerte de algún(os) otro(s) miembro(s)  |      4,351        5.88   
4	             Separación de los cónyuges |      4,351        5.88      
5		 El jefe del hogar perdió su empleo |      4,351        5.88      
6            	El cónyuge perdió su empleo |      4,351        5.88       
7	Otro miembro del hogar perdió su empleo |      4,351        5.88   
8	Llegada o acogida de un familiar en el  |      4,351        5.88     
9	Tuvieron que abandonar su lugar de resi |      4,351        5.88    
10	Quiebra(s) y/o cierre(s) del(los) negoc |      4,351        5.88    
11	           Pérdida o recorte de remesas |      4,351        5.88    
12	Pérdida de fincas, lotes, terrenos, o p |      4,351        5.88    
13	           Plagas o pérdida de cosechas |      4,351        5.88   
14	           Pérdida o muerte de animales |      4,351        5.88     
15	Robo, incendio o destrucción de bienes  |      4,351        5.88    
16	Sufrieron inundaciones, avalanchas, der |      4,351        5.88   
17	        Fueron víctimas de la violencia |      4,351        5.88    
----------------------------------------+---------------------------
*/

gen veces=.
	replace veces=1 if ano_1!=.
	replace veces=2 if ano_2!=.
	replace veces=3 if ano_3!=.
	replace veces=4 if ano_4!=.
	replace veces=5 if ano_5!=.
	replace veces=6 if ano_6!=.
	replace veces=7 if ano_7!=.
	replace veces=8 if ano_8!=.
	replace veces=9 if ano_9!=.
	replace veces=10 if ano_10!=.
	replace veces=11 if ano_11!=.
	replace veces=12 if ano_12!=.

drop mes* ano* shock
	
reshape wide tuvo_choque imp_econ veces hizo_princ, i(llave choques) j (choque)

rename tuvo_choque1 enfermedad
rename tuvo_choque2 muerte_jefe	
rename tuvo_choque3 muerte_otro
rename tuvo_choque4 separacion
rename tuvo_choque5 empleo_jefe
rename tuvo_choque6 empleo_cony
rename tuvo_choque7 empleo_otro
rename tuvo_choque8 llegada
rename tuvo_choque9 residencia
rename tuvo_choque10 quiebra
rename tuvo_choque11 remesas 
rename tuvo_choque12 tierras
rename tuvo_choque13 cosechas
rename tuvo_choque14 animales
rename tuvo_choque15 bienes
rename tuvo_choque16 desastre
rename tuvo_choque17 violencia

foreach var in enfermedad muerte_jefe muerte_otro separacion empleo_jefe   ///
		   empleo_cony empleo_otro llegada residencia quiebra	         ///
		   remesas tierras cosechas animales bienes desastre           ///
               violencia {
	
	recode `var' (2=0)
}

*Categorias agregadas
	
gen salud=enfermedad==1
gen familia=inlist(1,muerte_jefe,muerte_otro,separacion,llegada)
gen empleo=inlist(1,empleo_jefe,empleo_cony,empleo_otro)
gen produccion=inlist(1,quiebra,cosechas,animales)
gen vivienda_activos=inlist(1,residencia,tierras,remesas,bienes)

gen zona_2013 = zona 
keep llave consecutivo ola choques                                         ///
     enfermedad muerte_jefe muerte_otro separacion empleo_jefe             ///
     empleo_cony empleo_otro llegada residencia quiebra	               ///
     remesas tierras cosechas animales bienes desastre violencia zona_2013

tempfile Choques_R2013
save `Choques_R2013'

/* I. 2013
	  b) Urbano */
	 
use "2013/Urbano/Uchoques_hogar.dta",clear    
merge m:1 llave using "2013/Urbano/Uhogar.dta", keepus(zona)

drop _merge

gen shock=.
replace shock=1 if tuvo_choque==1
bys llave: egen choques= total(shock)

sort llave choque

/*
 cod_choque | 
------------+--
          1 | Accidente o enfermedad de algún miembro 
          2 | Muerte del que era jefe del hogar o del   
          3 | Muerte de algún(os) otro(s) miembro(s) 
          4 | Separación de los cónyuges    
          5 | El jefe del hogar perdió su empleo    
          6 | El cónyuge perdió su empleo   
          7 | Otro miembro del hogar perdió su empleo 
          8 | Llegada o acogida de un familiar en el    
          9 | Tuvieron que abandonar su lugar de resi  
         10 | Quiebra(s) y/o cierre(s) del(los) negoc     
         11 | Pérdida de la vivienda  
         12 | Pérdida o recorte de remesas    
         13 | Robo, incendio o destrucción de bienes 
         14 | Fueron víctimas de la violencia    
         15 | Sufrieron inundaciones, avalanchas, der   
------------+-----------------------------------
      Total |     73,650      100.00
*/
gen veces=.
replace veces=1 if ano_1!=.
replace veces=2 if ano_2!=.
replace veces=3 if ano_3!=.
replace veces=4 if ano_4!=.
replace veces=5 if ano_5!=.
replace veces=6 if ano_6!=.
replace veces=7 if ano_7!=.
replace veces=8 if ano_8!=.
replace veces=9 if ano_9!=.
replace veces=10 if ano_10!=.
replace veces=11 if ano_11!=.
replace veces=12 if ano_12!=.

drop mes* ano* shock
	
reshape wide tuvo_choque imp_econ veces hizo_princ, i(llave choques) j (choque)

rename tuvo_choque1 enfermedad
rename tuvo_choque2 muerte_jefe
rename tuvo_choque3 muerte_otro
rename tuvo_choque4 separacion
rename tuvo_choque5 empleo_jefe
rename tuvo_choque6 empleo_cony
rename tuvo_choque7 empleo_otro
rename tuvo_choque8 llegada
rename tuvo_choque9 residencia
rename tuvo_choque10 quiebra
rename tuvo_choque11 vivienda	
rename tuvo_choque12 remesas
rename tuvo_choque13 bienes
rename tuvo_choque14 violencia
rename tuvo_choque15 desastre

foreach var in enfermedad muerte_jefe muerte_otro separacion empleo_jefe   ///
		   empleo_cony empleo_otro llegada residencia quiebra	         ///
		   vivienda remesas bienes violencia desastre {
	
	recode `var' (2=0)
}
	

gen zona_2013 = zona 
keep llave consecutivo ola choques enfermedad muerte_jefe muerte_otro      ///
     separacion empleo_jefe empleo_cony empleo_otro llegada residencia     ///
     quiebra vivienda remesas bienes violencia desastre zona_2013 

append using `Choques_R2013'

gen year = 2013 

tempfile Choques_2013
saveold `Choques_2013'

*2016
*Rural
	 
use "2016/Rural/Rchoques_hogar.dta",clear 
merge m:1 llave_n16 using "2016/Rural/Rhogar.dta", keepus(zona_2016)

drop _merge

gen shock=.
replace shock=1 if tuvo_choque==1
bys llave_n16: egen choques= total(shock)

/*
 cod_choque | 
------------+--
          1 | Accidente o enfermedad de algún miembro 
          2 | Muerte del que era jefe del hogar o del   
          3 | Muerte de algún(os) otro(s) miembro(s) 
          4 | Separación de los cónyuges    
          5 | El jefe del hogar perdió su empleo    
          6 | El cónyuge perdió su empleo   
          7 | Otro miembro del hogar perdió su empleo 
          8 | Llegada o acogida de un familiar en el    
          9 | Tuvieron que abandonar su lugar de resi  
         10 | Quiebra(s) y/o cierre(s) del(los) negoc     
         11 | Pérdida o recorte de remesas   
         12 | Pérdida de fincas, lotes, terrenos o pe    
         13 | Plagas o pérdida de cosechas 
         14 | Pérdida o muerte de animales  
         15 | Robo, incendio o destrucción de bienes  
		 16 | Sufrieron inundaciones, avalanchas, der
         17 | Sufrieron temblores o terremotos 
         18 | Sufrieron sequías 
         19 | Fueron víctimas de la violencia
------------+-----------------------------------
      Total |     74,727      100.00

*/	
egen veces=rowtotal(veces_2013 veces_2014 veces_2015 veces_2016),m

drop veces_* shock

reshape wide tuvo_choque imp_econ veces hizo_princ,							///
		i(llave_n16 choques) j(choque)

rename tuvo_choque1 enfermedad
rename tuvo_choque2 muerte_jefe	
rename tuvo_choque3 muerte_otro
rename tuvo_choque4 separacion
rename tuvo_choque5 empleo_jefe
rename tuvo_choque6 empleo_cony
rename tuvo_choque7 empleo_otro
rename tuvo_choque8 llegada
rename tuvo_choque9 residencia
rename tuvo_choque10 quiebra
rename tuvo_choque11 remesas 
rename tuvo_choque12 tierras
rename tuvo_choque13 cosechas
rename tuvo_choque14 animales
rename tuvo_choque15 bienes
rename tuvo_choque16 desastre
rename tuvo_choque17 temblor
rename tuvo_choque18 sequia
rename tuvo_choque19 violencia


foreach var in enfermedad muerte_jefe muerte_otro separacion empleo_jefe   ///
				empleo_cony empleo_otro llegada residencia quiebra ///
				remesas tierras cosechas animales bienes desastre  ///
				temblor sequia violencia {
	
	recode `var' (2=0)
}

*Categorias agregadas
	
gen salud=enfermedad==1
gen familia=inlist(1,muerte_jefe,muerte_otro,separacion,llegada)
gen empleo=inlist(1,empleo_jefe,empleo_cony,empleo_otro)
gen produccion=inlist(1,quiebra,cosechas,animales)
gen vivienda_activos=inlist(1,residencia,tierras,remesas,bienes)
 
keep llave llave_n16 consecutivo ola choques enfermedad muerte_jefe        ///
     muerte_otro separacion empleo_jefe empleo_cony empleo_otro llegada    ///
     residencia quiebra remesas tierras cosechas animales bienes desastre  ///
     temblor sequia violencia zona_2016

tempfile Choques_R2016
save `Choques_R2016'

* urbano 

use "2016/Urbano/Uhogar.dta",clear
keep zona_2016 llave_n16
tempfile hogs_u16
save `hogs_u16'
	 
use "2016/Urbano/Uchoques_hogar.dta",clear 

merge m:1 llave_n16 using `hogs_u16'

drop _merge

gen shock=.
replace shock=1 if tuvo_choque==1
bys llave_n16: egen choques= total(shock)

/*
 cod_choque | 
------------+--
          1 | Accidente o enfermedad de algún miembro 
          2 | Muerte del que era jefe del hogar o del   
          3 | Muerte de algún(os) otro(s) miembro(s) 
          4 | Separación de los cónyuges    
          5 | El jefe del hogar perdió su empleo    
          6 | El cónyuge perdió su empleo   
          7 | Otro miembro del hogar perdió su empleo 
          8 | Llegada o acogida de un familiar en el    
          9 | Tuvieron que abandonar su lugar de resi  
         10 | Quiebra(s) y/o cierre(s) del(los) negoc     
         11 | Pérdida de la vivienda  
         12 | Pérdida o recorte de remesas    
         13 | Robo, incendio o destrucción de bienes 
         14 | Fueron víctimas de la violencia    
         15 | Sufrieron inundaciones, avalanchas, der
		 16 | Sufrieron temblores o terremotos
		 17 | Sufrieron sequías
------------+-----------------------------------
	  Total |     81,991      100.00
*/	

egen veces=rowtotal(veces_2013 veces_2014 veces_2015 veces_2016),m
drop veces_* shock

reshape wide tuvo_choque imp_econ veces hizo_princ,							///
		i(llave_n16 choques) j(choque)
		
rename tuvo_choque1 enfermedad
rename tuvo_choque2 muerte_jefe
rename tuvo_choque3 muerte_otro
rename tuvo_choque4 separacion
rename tuvo_choque5 empleo_jefe
rename tuvo_choque6 empleo_cony
rename tuvo_choque7 empleo_otro
rename tuvo_choque8 llegada
rename tuvo_choque9 residencia
rename tuvo_choque10 quiebra
rename tuvo_choque11 vivienda	
rename tuvo_choque12 remesas
rename tuvo_choque13 bienes
rename tuvo_choque14 violencia
rename tuvo_choque15 desastre
rename tuvo_choque16 temblor
rename tuvo_choque17 sequia

foreach var in enfermedad muerte_jefe muerte_otro separacion empleo_jefe   ///
		   empleo_cony empleo_otro llegada residencia quiebra	         ///
		   vivienda remesas bienes desastre temblor sequia violencia {
	
	recode `var' (2=0)
}
*Categorias agregadas

gen salud=enfermedad==1
gen familia=inlist(1,muerte_jefe,muerte_otro,separacion,llegada)		 
gen empleo=inlist(1,empleo_jefe,empleo_cony,empleo_otro)
gen produccion=quiebra==1
gen vivienda_activos=inlist(1,residencia,vivienda,remesas,bienes)

keep llave zona_2016 llave_n16 consecutivo ola choques enfermedad          ///
     muerte_otro separacion empleo_jefe empleo_cony empleo_otro llegada    ///
     residencia quiebra vivienda remesas bienes desastre temblor           ///
     sequia violencia muerte_jefe

append using `Choques_R2016'

gen year = 2016 

append using `Choques_2013'

gen shock_deathmember 	    = inlist(1, muerte_jefe, muerte_otro)
// gen shock_abandonmember 	= P2116S2 == 1
// gen shock_arrivalmember 	= P2116S3 == 1 
gen shock_accident_illnss   = enfermedad
gen shock_divorce 			= separacion
gen shock_lostjob 			= inlist(1, empleo_jefe, empleo_otro)
gen shock_abandonhouse 		= residencia
gen shock_bankrupcy 		= quiebra
gen shock_losthouse 		= vivienda
//gen shock_lostland 			= P2116S10 == 1
gen shock_lostremit 		= remesas
gen shock_theftlostassets 	= bienes
gen shock_robbery 			= bienes
// gen shock_failharvest 		= P2116S14 == 1
// gen shock_lostanimals 		= P2116S15 == 1
gen shock_floodlandslide 	= desastre
gen shock_earthquake 		= temblor
gen shock_drought 			= sequia
gen shock_violence 			= violencia
