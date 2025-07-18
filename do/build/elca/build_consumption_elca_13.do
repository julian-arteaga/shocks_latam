* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ELCA household Consumption level 2010-2013-2016 

* This comes from 3_consumption.do in the ELCA_2016 folder (20170515)

* -----------------
* 2013

/* II. 2013
	 a) Rural & Urbano (las dos encuestas son idénticas) */
 
cd "$projdir/dta/src/ELCA/ELCA_10_13_16"

use "2013/Urbano/Ugastos_hogar.dta", clear
append using "2013/Rural/Rgastos_hogar.dta"

tempfile gastos
save `gastos'
	 
use "2013/Rural/Rhogar.dta", clear
append using "2013/Urbano/Uhogar.dta"

keep llave t_personas consecutivo_c region vr_gtos_mensuales vr_gtos_mens_alim

merge 1:m llave using `gastos'
		  		  
recode vr_obtenido 99=.
recode vr_obtenido 98=.
recode vr_compra 98=.
recode vr_compra 99=.
recode vr_obtenido 99999999=.
recode vr_obtenido 99998=.	 

* (no hay ninguno de esos valores en esta base)

/* en esta encuesta hay algunos cambios respecto a R2010:
   i) cod_art 35 es nuevo y puede tener cualquier periodicidad.
   ii) cod_art 59 y cod_art 60 en R2010 se vuelve un solo cod_art ahora (59)
   iii) cod_art 69 en R2010 ya no se pregunta
   iv) cod_art 72 en R2010 es ahora cod_art 67
   v) cod_art 71 y 72 en R2013 son cosas nuevas que no estaban antes.
   
   (de todas formas no cambia mucho el dofile) */
 
rename vr_compra_2013 vr_compra

gen vr_compra_mes=.
replace vr_compra_mes=vr_compra*30 if per_compra==1 & cod_articulo<36
replace vr_compra_mes=vr_compra*4.4285 if per_compra==2 & cod_articulo<36
replace vr_compra_mes=vr_compra*2 if per_compra==3 & cod_articulo<36
replace vr_compra_mes=vr_compra*1 if per_compra==4 & cod_articulo<36
replace vr_compra_mes=vr_compra/2 if per_compra==5 & cod_articulo<36
replace vr_compra_mes=vr_compra/3 if per_compra==6 & cod_articulo<36
replace vr_compra_mes=vr_compra/6 if per_compra==7 & cod_articulo<36
replace vr_compra_mes=vr_compra/12 if per_compra==8 & cod_articulo<36

* Para los Siguientes Items Definidos Mensual, Trimestral y Anual

*Gastos mensuales
replace vr_compra_mes=vr_compra if cod_articulo>=36 & cod_articulo<=48
		
*Gastos trimestrales
replace vr_compra_mes=vr_compra/3 if cod_articulo>=49 & cod_articulo<=54
		
*Gastos anuales 
replace vr_compra_mes=vr_compra/12 if cod_articulo>=55
	 
/*Indicador de bienes durables:

  Respecto a R2010, los cÛdigos de bienes durables cambian asÌ:
  
  cod_articulo=54 --> 55 ; cod_articulo=58 --> 59 ; cod_articulo=61 --> 61
  cod_articulo=62 --> 62 ; cod_articulo=64 --> 64 ;
  cod_articulo=65 --> 65 ; cod_articulo=68 --> 68 ;
  cod_articulo=69 --> No hay ; cod_articulo=71 --> 70. */			

gen ind_articulo = 1 /* if inlist(cod_articulo,55,59,61,62,64,65,68,70)

recode ind_articulo .=1

drop if ind_articulo==0	 */

*Arreglamos gasto en servicios publicos: input de Margarita*

tab  per_compra if cod_articulo==32
			
bys consecutivo_c: egen m_ser=mean(vr_compra_mes) if per_compra==4			///
	& cod_articulo==32
bys consecutivo_c: egen mm_ser=max(m_ser) if cod_articulo==32
			
bys consecutivo_c: egen s_ser=sd(vr_compra_mes) if per_compra==4			///
	& cod_articulo==32
bys consecutivo_c: egen ss_ser=max(s_ser) if cod_articulo==32
			
gen indicador_cambio=cond(vr_compra_mes>mm_ser+2*ss_ser,1,0)
tab indicador per_compra
			
sort vr_compra_mes 
				
recode per_compra 1=4 if cod_articulo==32 & indicador_cambio==1
replace vr_compra_mes=vr_compra if per_compra==4 & cod_articulo==32

* Types of consumption:

gen alimento = inrange(cod_articulo, 1, 22)
gen personal = inrange(cod_articulo, 23, 37) | 							   ///
			   inrange(cod_articulo, 39, 42) |		   					   ///
			   inlist(cod_articulo, 44, 45, 46, 49, 50, 51, 52, 53, 57)	|  ///
			   inlist(cod_articulo, 58, 63, 64, 65, 69) 

			   // soap, newspaper, tobacco, clothes, etc. 
gen educatio = inlist(cod_articulo, 48, 72)
gen health   = inlist(cod_articulo, 38, 47, 71)
gen durables = inlist(cod_articulo, 55, 56, 59, 61, 62, 68, 70)
			   // furniture, appliances, motorbikes, etc.
gen insuranc = inlist(cod_articulo, 66, 67)
gen leisure  = inlist(cod_articulo, 43, 54, 60)

* Obtenidos: 

/* No hay que cambiar nada en el valor obtenido de articulos que no se puedan
  "obtener" sin pagar: */
  
foreach i in obtuvo_finca obtuvo_pago obtuvo_regalo {

tab vr_obtenido if `i'!=. & cod_articulo>16 | inlist(cod_articulo,7,14,15)
}
	 
gen vr_obtenido_mes=vr_obtenido*2 if obtuvo_finca!=. | obtuvo_pago!=. | 	///
									 obtuvo_regalo!=.
	 
*generar serie de regalos y produccion* 

gen vr_regalo_mes=vr_obtenido*2 if obtuvo_regalo==1

gen vr_hogar_mes=vr_obtenido*2 if obtuvo_finca==1

* Sumar con no comprados y comprados

egen vr_total_mes=rowtotal(vr_obtenido_mes vr_compra_mes)
		
* Sacamos la proporción de valores de compras al mes sobre el total
bys llave: egen total=sum(vr_compra_mes) 
gen prop=vr_compra_mes /total

* Sacamos el total de compras al mes percápita
replace total=total/t_personas
				
* generamos la secuencia de hogares
bys llave: egen s=seq()

* Anualizando
foreach i in vr_compra_mes vr_obtenido_mes vr_hogar_mes vr_regalo_mes {
	
	gen a_`i'=`i'*12
}
	
* Sumar con no comprados y comprados
	
egen a_vr_total=rowtotal(a_vr_obtenido_mes a_vr_compra_mes)

* Agregar todos los gastos
	
foreach i in a_vr_total  a_vr_compra_mes a_vr_obtenido_mes a_vr_regalo_mes  ///
		     a_vr_hogar_mes vr_total_mes vr_compra_mes vr_obtenido_mes	    ///
			 vr_regalo_mes vr_hogar_mes {
			 
	bys llave: egen t_`i'=total(`i')
}

* Agregar por tipo de gasto:

foreach type in alimento personal educatio health 						   ///
				durables insuranc leisure {

	gen t_`type' = a_vr_total if `type' == 1
	bys llave: egen t_vr_`type'_a = total(t_`type')
	drop t_`type'
}

keep if s==1

rename t_a_vr_total ctotal_a
rename t_a_vr_compra_mes ccompra_a
rename t_a_vr_obtenido_mes obtenido_a
rename t_a_vr_hogar_mes hhobtenido_a
rename t_a_vr_regalo_mes regalo_a
rename t_vr_total_mes ctotal_m 
rename t_vr_compra_mes ccompra_m
rename t_vr_obtenido_mes obtenido_m
rename t_vr_regalo_mes regalo_m
rename t_vr_hogar_mes hhobtenido_m
	
foreach x of varlist ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a   ///
					 ctotal_m ccompra_m obtenido_m regalo_m hhobtenido_m   ///
					 t_vr_*_a {
					 
	gen `x'_per=`x'/t_personas
}

*Terminando
format ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a ctotal_m 		///
	   ccompra_m obtenido_m regalo_m hhobtenido_m t_vr_*_a %18.0g
	   
/* Poner en precios de 2016
	variacion de IPC (a√±o corrido):
	2010: 3,17%
	2011: 3,73%
	2012: 2,44% 
	2013: 1.94%
	2014: 3.66%
	2015: 6.77%		*/

local variables ctotal_a ccompra_a obtenido_a ctotal_m ccompra_m  		   ///
      obtenido_m regalo_m hhobtenido_m hhobtenido_a regalo_a		       ///
	  t_vr_alimento_a t_vr_personal_a t_vr_educatio_a 		   			   ///
	  t_vr_durables_a t_vr_health_a t_vr_insuranc_a 			   		   ///
	  t_vr_leisure_a vr_gtos_mensuales vr_gtos_mens_alim

foreach var of local variables {
	
	replace `var'=`var'*(1.0194)*(1.0366)*(1.0677)
}		

keep ola zona consecutivo llave ctotal_a ccompra_a obtenido_a hhobtenido_a /// 
     regalo_a t_personas t_vr_*_a vr_gtos_mensuales vr_gtos_mens_alim
	
/* En vez de eliminar la observaciÛn de ccompra_a==0 voy a dejar los valores 
  en missing para tener m·s claro cÛmo va el merge */

foreach i in ctotal_a obtenido_a hhobtenido_a regalo_a {
	// replace `i'=. if ccompra_a==0
}

// replace ccompra_a=. if ccompra_a==0

rename ctotal_a consumo_total
rename ccompra_a consumo_purchased
rename hhobtenido_a consumo_selfcons
rename regalo_a consumo_transfers

rename t_vr_*_a consumo_*

*check:
gen check = consumo_alimento + consumo_personal + consumo_educatio +	   ///
			consumo_health + consumo_durables + consumo_insuranc +		   ///
			consumo_leisure

format check %15.0f

assert abs(check - consumo_total) < 20 // 20 pesos

drop check 

* On sources: some obs have a discrepancy (>20) between total exp and 
* the sum of consumption sources (purchased, selfcons, transfers). Assume
* differenece is self consumption:

rename consumo_total hh_totexp

gen check = consumo_purchased + consumo_transfers + consumo_selfcons
gen diff = hh_totexp - check 

replace consumo_selfcons = consumo_selfcons + diff if abs(diff) > 20
replace consumo_selfcons = 0 if consumo_selfcons < 0 // 24 obs with ~-1

gen check2 = consumo_purchased + consumo_transfers + consumo_selfcons

assert abs(check2 - hh_totexp) < 20 // 20 pesos

drop check check2 diff

gen year = 2013 

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_consump_hhlvl_13.dta", replace

* -------------------------------------------------------------------