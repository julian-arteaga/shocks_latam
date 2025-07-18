* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* lookup ELCA 2013 and 2016 shock module

* -----------------

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"

* 2010
	 
use "2010/Rural/Rchoques_hogar.dta",clear    
numlabel, add

/* tab choque_1
     Durante los �ltimos 12 meses en el |
                  hogar, �se present�:  |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
1. Enfermedad de alg�n miembro del hoga |        617       36.68       36.68
2. Accidente de alg�n miembro del hogar |        128        7.61       44.29
3. Muerte del que era jefe del hogar o  |         22        1.31       45.60
4. Muerte de alg�n(os) otro(s) miembro( |         33        1.96       47.56
5. Abandono del que era jefe del hogar  |         20        1.19       48.75
6. Abandono del hogar por parte de un m |         16        0.95       49.70
          7. Separaci�n de los c�nyuges |         19        1.13       50.83
  8. El jefe del hogar perdi� su empleo |         59        3.51       54.34
         9. El c�nyuge perdi� su empleo |         17        1.01       55.35
10. Otro miembro del hogar perdi� su em |         13        0.77       56.12
11. Tuvieron que abandonar su lugar de  |         31        1.84       57.97
12. Quiebra(s) y/o cierre(s) del(los) n |         10        0.59       58.56
       13. P�rdida o recorte de remesas |          6        0.36       58.92
14. P�rdida de fincas, lotes, terrenos  |         12        0.71       59.63
       15. Plagas o p�rdida de cosechas |        506       30.08       89.71
       16. P�rdida o muerte de animales |        136        8.09       97.80
17. Robo, incendio o destrucci�n de bie |         33        1.96       99.76
    18. Fueron v�ctimas de la violencia |          4        0.24      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,682      100.00			*/

merge m:1 consecutivo using "2010/Rural/Rhogar.dta", 					   ///
	keepus(zona choquec_1 choquec_2 choquec_3 choquec_4 choquec_5)
drop _merge

/* tab choquec_1
     Durante los �ltimos 12 meses en el |
       hogar, en esta zona o vereda �se |
                             present�:  |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
19. Enfrentamientos entre grupos armado |         15        1.31        1.31
     20. Pandillas o delincuencia com�n |         65        5.67        6.97
              21. Atentados terroristas |         10        0.87        7.85
              22. Robos a las viviendas |        292       25.46       33.30
                            23. Atracos |         43        3.75       37.05
                           24. Abigeato |         68        5.93       42.98
                        25. Extorsiones |          5        0.44       43.42
                       26. Inundaciones |        155       13.51       56.93
                          27. Derrumbes |         40        3.49       60.42
                         28. Terremotos |          3        0.26       60.68
          29. Otros desastres naturales |         38        3.31       63.99
       30. Quiebra o cierre de empresas |          1        0.09       64.08
31. Epidemias que mataron varios animal |        105        9.15       73.23
                  32. Epidemias humanas |         10        0.87       74.11
             33. Plagas en las cosechas |        295       25.72       99.83
34. Masacres, enfrentamientos o ataques |          2        0.17      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,147      100.00			*/

forvalues i = 1/5 {

	local j = `i' + 6
	rename choquec_`i' choque_`j'
	local `i'++
}

keep ola zona region consecutivo_c consecutivo choque_*

reshape long choque_, i(consecutivo) j(num_choque) 

keep if num_choque == 1 | choque_ != . 

gen shock_enfermedad   = inlist(choque_, 1, 2)
gen shock_deathmember  = inlist(choque_, 3, 4)
gen shock_abandon	   = inlist(choque_, 5, 6) 
gen shock_divorce      = inlist(choque_, 7)

gen shock_empleo_jefe  = inlist(choque_, 8)
gen shock_empleo_cony  = inlist(choque_, 9)
gen shock_empleo_otro  = inlist(choque_, 10)
gen shock_quiebra	   = inlist(choque_, 12)

gen shock_abandonhouse = inlist(choque_, 11)
gen shock_lostremit    = inlist(choque_, 13)
gen shock_lostland	   = inlist(choque_, 14)
gen shock_failharvest  = inlist(choque_, 15)
gen shock_lostanimals  = inlist(choque_, 16)
gen shock_bienes       = inlist(choque_, 17)
gen shock_violencia	   = inlist(choque_, 18)

gen shock_desastre	   = inlist(choque_, 26, 27, 28, 29) // inundaciones, 
												   		 // derrumbes, 
												   		 // terremotos, otros

// aggregate at household level														 										
foreach var of varlist shock_* {

	bys consecutivo: egen hh`var' = max(`var')
	drop `var'
	rename hh`var' `var'
}

bys consecutivo: keep if _n == 1
drop choque_

tempfile Choques_R2010 
save `Choques_R2010'

use "2010/Urbano/Uchoques_hogar.dta",clear    
numlabel, add

/*. tab choque_1

     Durante los �ltimos 12 meses en el |
                  hogar, �se present�:  |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
1. Enfermedad de alg�n miembro del hoga |        668       38.75       38.75
2. Accidente de alg�n miembro del hogar |        138        8.00       46.75
3. Muerte del que era jefe del hogar o  |         21        1.22       47.97
4. Muerte de alg�n(os) otro(s) miembro( |         45        2.61       50.58
5. Abandono del que era jefe del hogar  |         40        2.32       52.90
6. Abandono del hogar por parte de un m |          7        0.41       53.31
          7. Separaci�n de los c�nyuges |         52        3.02       56.32
  8. El jefe del hogar perdi� su empleo |        238       13.81       70.13
         9. El c�nyuge perdi� su empleo |         81        4.70       74.83
10. Otro miembro del hogar perdi� su em |        111        6.44       81.26
11. Llegada o acogida de un familiar en |        149        8.64       89.91
12. Tuvieron que abandonar su lugar de  |         27        1.57       91.47
13. Quiebra(s) y/o cierre(s) del(los) n |         36        2.09       93.56
             14. P�rdida de la vivienda |          5        0.29       93.85
       15. P�rdida o recorte de remesas |         21        1.22       95.07
16. Robo, incendio o destrucci�n de bie |         59        3.42       98.49
    17. Fueron v�ctimas de la violencia |         26        1.51      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,724      100.00*/


merge m:1 consecutivo using "2010/Urbano/Uhogar.dta",					   ///
	keepus(zona inundacion avalancha creciente hundimiento terremoto)
drop _merge

keep ola zona region consecutivo_c consecutivo choque_* 				   ///
		 inundacion avalancha creciente hundimiento terremoto

reshape long choque_, i(consecutivo) j(num_choque) 

keep if num_choque == 1 | choque_ != . 

gen shock_enfermedad   = inlist(choque_, 1, 2)
gen shock_deathmember  = inlist(choque_, 3, 4)
gen shock_abandon	   = inlist(choque_, 5, 6) 
gen shock_divorce      = inlist(choque_, 7)

gen shock_empleo_jefe  = inlist(choque_, 8)
gen shock_empleo_cony  = inlist(choque_, 9)
gen shock_empleo_otro  = inlist(choque_, 10)
gen shock_quiebra	   = inlist(choque_, 13)

gen shock_new_arrival  = inlist(choque_, 11)
gen shock_abandonhouse = inlist(choque_, 12, 14)
gen shock_lostremit    = inlist(choque_, 15)
gen shock_bienes       = inlist(choque_, 16)
gen shock_violencia	   = inlist(choque_, 17)

gen shock_desastre	   = inlist(1, inundacion, avalancha, creciente, 	   ///
								   hundimiento, terremoto) // inundaciones, 
														   // derrumbes, 
														   // terremotos, otros
														   // 2-YEAR period

// aggregate at household level														 										
foreach var of varlist shock_* {

	bys consecutivo: egen hh`var' = max(`var')
	drop `var'
	rename hh`var' `var'
}

bys consecutivo: keep if _n == 1
drop choque_

append using `Choques_R2010'

gen shock_lostjob = inlist(1, shock_empleo_jefe, shock_empleo_cony, 	   ///
							  shock_quiebra, shock_empleo_otro)

gen shock_accident_illnss   = shock_enfermedad

gen shock_criminality		= inlist(1, shock_bienes, shock_violencia)

gen shock_natdisast = inlist(1, shock_desastre) 

gen year = 2010
rename zona zona_2010 

gen urban = zona_2010 == 1

keep year ola zona urban shock_natdisast shock_accident_illnss 			   ///
	 shock_lostjob shock_criminality shock_deathme consecutivo 

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_shocks_hhlvl_10.dta", replace 

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
     empleo_cony empleo_otro llegada residencia quiebra	               	   ///
     remesas tierras cosechas animales bienes desastre violencia zona_2013 ///
	 imp_econ1

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
		   empleo_cony empleo_otro llegada residencia quiebra	           ///
		   vivienda remesas bienes violencia desastre {
	
	recode `var' (2=0)
}
	

gen zona_2013 = zona 
keep llave consecutivo ola choques enfermedad muerte_jefe muerte_otro      ///
     separacion empleo_jefe empleo_cony empleo_otro llegada residencia     ///
     quiebra vivienda remesas bienes violencia desastre zona_2013 imp_econ1

append using `Choques_R2013'

gen shock_deathmember 	    = inlist(1, muerte_jefe, muerte_otro)

gen shock_lostjob = inlist(1, empleo_jefe, empleo_cony, quiebra, empleo_otro)

gen shock_accident_illnss   = enfermedad

gen shock_criminality		= inlist(1, bienes, violencia)

gen shock_natdisast = inlist(1, desastre) 

gen year = 2013 

gen urban = zona_2013 == 1

keep year ola zona shock_natdisast shock_accident_illnss urban		   	   ///
	 shock_lostjob shock_criminality shock_deathme consecutivo llave

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_shocks_hhlvl_13.dta", replace 

* -----------------

*2016

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
	 
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
     temblor sequia violencia zona_2016 imp_econ1

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

keep llave zona_2016 llave_n16 consecutivo ola choques enfermedad          ///
     muerte_otro separacion empleo_jefe empleo_cony empleo_otro llegada    ///
     residencia quiebra vivienda remesas bienes desastre temblor           ///
     sequia violencia muerte_jefe imp_econ1

append using `Choques_R2016'

gen shock_deathmember 	    = inlist(1, muerte_jefe, muerte_otro)

gen shock_lostjob = inlist(1, empleo_jefe, empleo_cony, quiebra, empleo_otro)

gen shock_accident_illnss   = enfermedad

gen shock_criminality		= inlist(1, bienes, violencia)

gen shock_natdisast         = inlist(1, desastre, temblor, sequia) 

gen year = 2016

gen urban = zona_2016 == 1

keep year ola zona shock_natdisast shock_accident_illnss urban		   	   ///
	 shock_lostjob shock_criminality shock_deathme consecutivo llave llave_n16

cd "$projdir/dta/cln/ELCA"
save "elca_shocks_hhlvl_16.dta", replace 

* -----------------
 
append using "elca_shocks_hhlvl_13.dta"

/* gen shock_deathmember 	    = inlist(1, muerte_jefe, muerte_otro)
// gen shock_arrivalmember 	= P2116S3 == 1 
gen shock_divorce 			= separacion
gen shock_abandonhouse 		= residencia
gen shock_losthouse 		= vivienda
//gen shock_lostland 			= P2116S10 == 1
gen shock_lostremit 		= remesas
// gen shock_failharvest 		= P2116S14 == 1
// gen shock_lostanimals 		= P2116S15 == 1
gen shock_floodlandslide 	= desastre
gen shock_earthquake 		= temblor
gen shock_drought 			= sequia
gen shock_violence 			= violencia

* -----------------

* Harmonize shock categories:

gen shock_lostjob 			= inlist(1, empleo_jefe, empleo_otro)

gen shock_bankrupcy 		= quiebra

gen shock_accident_illnss   = enfermedad

/* gen shock_abandonmember 	= P2116S2 == 1 */

gen shock_criminality		= inlist(1, bienes, violencia)

gen shock_natdisast = inlist(1, shock_earthquake, shock_drought, 		   ///
							 shock_floodlandslide /*shock_failharvest*/) */

append using "elca_shocks_hhlvl_10.dta"

cd "$projdir/dta/cln/ELCA"
save "elca_shock_prevalence_hhlvl_10_13_16.dta", replace 

* -------------------------------------------------------------------