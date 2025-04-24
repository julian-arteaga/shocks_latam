* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ELCA household Consumption level 2010-2013-2016 

* This comes from 3_consumption.do in the ELCA_2016 folder (20170515)

* -----------------

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
	 
use "2010/Rural/Rgastos_hogar.dta", clear

merge m:1 consecutivo using "2010/Rural/Rhogar.dta", 						///
		  keepus(consecutivo t_personas region)

recode vr_obtenido 99=.
recode vr_obtenido 98=.
recode vr_compra 98=.
recode vr_compra 99=.0
recode vr_obtenido 99999999=.
recode vr_obtenido 99998=.
	
*COMPRA
		
*Valores mensuales para 34 primeros Items: Alimentos y Articulos Generales*
*Un mes son 4.4285 semanas*
gen vr_compra_mes=.
replace vr_compra_mes=vr_compra*30 if per_compra==1 & cod_articulo<35
replace vr_compra_mes=vr_compra*4.4285 if per_compra==2 & cod_articulo<35
replace vr_compra_mes=vr_compra*2 if per_compra==3 & cod_articulo<35
replace vr_compra_mes=vr_compra*1 if per_compra==4 & cod_articulo<35
replace vr_compra_mes=vr_compra/2 if per_compra==5 & cod_articulo<35
replace vr_compra_mes=vr_compra/3 if per_compra==6 & cod_articulo<35
replace vr_compra_mes=vr_compra/6 if per_compra==7 & cod_articulo<35
replace vr_compra_mes=vr_compra/12 if per_compra==8 & cod_articulo<35
replace vr_compra_mes=0 if per_compra==9
	
*Para los Siguientes Items Definidos Mensual, Trimestral y Anual*
*Gastos mensuales
replace vr_compra_mes=vr_compra if per_compra!=9							///
		& cod_articulo>=35 & cod_articulo<48
*Gastos trimestrales
replace vr_compra_mes=vr_compra/3 if per_compra!=9							///
		& cod_articulo>=48 & cod_articulo<54
*Gastos anuales 
replace vr_compra_mes=vr_compra/12 if per_compra!=9							///
		& cod_articulo>=54 & cod_articulo<73 
	
/*
Generamos un indicador para los articulos que vamos a Incluir:
Excluimos Bienes Durables segun definidos por Ana Maria (12.02.14.)
*/

gen ind_articulo= 1 if cod_articulo!=54 & cod_articulo!=58 &				///
cod_articulo!=61 & cod_articulo!=62 & cod_articulo!=64 & cod_articulo!=65   ///
& cod_articulo!=68 & cod_articulo!=69 & cod_articulo!=71 					

recode ind_articulo .=0

drop if ind_articulo==0
		
*Arreglamos gasto en servicios publicos: input de Margarita*
*LM: ¿es porque solo se paga mensual?
*1. ver periodicidad problematica
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
	
/* Dudas con respecto a consecutivo 123221 gasto $2000. */
			
recode per_compra 1=4 if cod_articulo==32 & indicador_cambio==1
replace vr_compra_mes=vr_compra if per_compra==4 & cod_articulo==32
			

*OBTENIDO: PAGO, PRODUCCION Y REGALOS
		
/*Identificamos bienes producidos en el hogar y pago en especie para sumarlos
  Todos los articulos no pagados estan quincenales
	
además: se vuelven missings los valores que hayan sido obtenidos y sean items 
mayores a 16, 7, 14 o 15 para que sea compatible
con la Ola 2013: muy importante! se logran eliminar outliers muy grandes. */
	
replace vr_obtenido=. if (donde_obtuvo==1 & (cod_articulo>16				///
	| cod_articulo==7 | cod_articulo==14 | cod_articulo==15)) 
replace vr_obtenido=. if (donde_obtuvo==2 & (cod_articulo>16				///
	| cod_articulo==7 | cod_articulo==14 | cod_articulo==15)) 
replace vr_obtenido=. if (donde_obtuvo==3 & (cod_articulo>16				///
	| cod_articulo==7 | cod_articulo==14 | cod_articulo==15)) 
	
gen vr_obtenido_mes=vr_obtenido*2 if donde_obtuvo==1 | donde_obtuvo==2		///
	| donde_obtuvo==3

*generar serie de regalos y produccion* 

gen vr_regalo=vr_obtenido if donde_obtuvo==3
gen vr_regalo_mes=vr_obtenido*2 if donde_obtuvo==3
gen vr_hogar=vr_obtenido if donde_obtuvo==1
gen vr_hogar_mes=vr_hogar*2 
	
*Sumar con no comprados y comprados*

egen vr_total_mes=rowtotal(vr_obtenido_mes vr_compra_mes)

	**Identificamos otros hogares problematicos**
		
		*Sacamos la proporción de valores de compras al mes sobre el total
		bys consecutivo: egen total=sum(vr_compra_mes) 
		gen prop=vr_compra_mes /total
			
		*percentil de compras
		xtile percentil=total, nq(20)
			
		*Sacamos el total de compras al mes percápita
		replace total=total/t_personas
			
		*Sacamos percentiles de el valor del obtenido y compra de mes
		bys consecutivo: egen total_obt=sum(vr_obtenido_mes)
		*y percentil de obtenidos
		xtile percentil_obt=total_obt, nq(20)
			
		*generamos la secuencia de hogares
		bys consecutivo: egen s=seq()

	
*Anualizando*
foreach i in vr_compra_mes vr_obtenido_mes vr_hogar_mes vr_regalo_mes {
	gen a_`i'=`i'*12
	}
*Sumar con no comprados y comprados
	
	egen a_vr_total=rowtotal(a_vr_obtenido_mes a_vr_compra_mes)

	*Agregar todos los gastos
	
foreach i in a_vr_total  a_vr_compra_mes a_vr_obtenido_mes a_vr_regalo_mes  ///
		     a_vr_hogar_mes vr_total_mes vr_compra_mes vr_obtenido_mes	    ///
			 vr_regalo_mes vr_hogar_mes {
			 
	bys consecutivo: egen t_`i'=sum(`i')
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
	
foreach x of varlist ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a    ///
					 ctotal_m ccompra_m obtenido_m regalo_m hhobtenido_m {
					 
gen `x'_per=`x'/t_personas
}

/*ELIMINAR OUTLIERS

  Esta forma de quitar outliers ya no cambia la base (seguro la arreglaron). 
  Solo sirve en Urbanos_2010

 drop if ccompra_a==0
	
/* Vamos a eliminar las observaciones que tienen muy pocas compras 
   (lo hacemos con los mensuales)*/
  
bys percentil: egen mean_ccompra_m_per=mean(ccompra_m_per)
bys percentil: egen sd_ccompra_m_per=sd(ccompra_m_per)

gen eliminar_outlier=0
replace eliminar_outlier=1 if ccompra_m_per < mean_ccompra_m_per            ///
	    - 2*sd_ccompra_m_per & percentil==1 
				
sort ccompra_m_per

*Se eliminan 14 observaciones: que sólo compran de 885.7 a 40'600
drop if eliminar_outlier==1
drop eliminar_outlier
	
*Vamos a eliminar las observaciones que tienen muchas compras*
gen eliminar_outlier=0
replace eliminar_outlier=1 if ccompra_m_per>3000000
br if eliminar_outlier==1
drop if eliminar_outlier==1
drop eliminar_outlier

*/
	
*Terminando
keep consecutivo ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a	///
ctotal_m ccompra_m obtenido_m regalo_m hhobtenido_m fexhog region			///
t_personas ola zona
	
/* Poner en precios de 2016
	variacion de IPC (año corrido):
	2010: 3,17%
	2011: 3,73%
	2012: 2,44% 
	2013: 1.94%
	2014: 3.66%
	2015: 6.77%		*/

local variables ctotal_a ccompra_a obtenido_a ctotal_m ccompra_m obtenido_m ///
      regalo_m hhobtenido_m hhobtenido_a regalo_a
	  
	foreach var of local variables {
	
		replace `var'=`var'*(1.0317)*(1.0373)*(1.0244)*						///
							(1.0194)*(1.0366)*(1.0677)
		}
sort consecutivo
	
format ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a ctotal_m 		///
	   ccompra_m obtenido_m regalo_m hhobtenido_m %18.0g
		
keep consecutivo ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a  ///
	 ola zona t_personas
	
*** Hasta aquÌ va el dofile original de Laura 

/* En vez de eliminar la observaciÛn de ccompra_a==0 voy a dejar los valores en
  missing para tener m·s claro cÛmo va el merge */

foreach i in ctotal_a obtenido_a hhobtenido_a regalo_a {
	replace `i'=. if ccompra_a==0
}
replace ccompra_a=. if ccompra_a==0

rename ctotal_a consumo_total
rename ccompra_a consumo_purchased
rename hhobtenido_a consumo_selfcons
rename regalo_a consumo_transfers

*voy a guardar esto en una base provisional

tempfile consumo_R2010

save `consumo_R2010'

/* I. 2010
	b) Urbano  */
	
use "2010/Urbano/Ugastos_hogar.dta", clear

merge m:1 consecutivo using "2010/Urbano/Uhogar.dta",					   ///
		  keepus(consecutivo t_personas region)

drop if _merge==2

recode vr_obtenido 99=.
recode vr_obtenido 98=.
recode vr_compra 98=.
recode vr_compra 99=.
recode vr_obtenido 99999999=.
recode vr_obtenido 99998=.

* en esta base solo hay 35 bienes.
gen vr_compra_mes=.
replace vr_compra_mes=vr_compra*30 if per_compra==1 & cod_articulo<21
replace vr_compra_mes=vr_compra*4.4285 if per_compra==2 & cod_articulo<21
replace vr_compra_mes=vr_compra*2 if per_compra==3 & cod_articulo<21
replace vr_compra_mes=vr_compra*1 if per_compra==4 & cod_articulo<21
replace vr_compra_mes=vr_compra/2 if per_compra==5 & cod_articulo<21
replace vr_compra_mes=vr_compra/3 if per_compra==6 & cod_articulo<21
replace vr_compra_mes=vr_compra/6 if per_compra==7 & cod_articulo<21
replace vr_compra_mes=vr_compra/12 if per_compra==8 & cod_articulo<21
replace vr_compra_mes=0 if per_compra==9

* No hay bienes en los que pregunten especificamente periodicidad mensual.

*Gastos trimestrales
replace vr_compra_mes=vr_compra/3 if per_compra!=9							///
		& cod_articulo>=21 & cod_articulo<26
*Gastos anuales 
replace vr_compra_mes=vr_compra/12 if per_compra!=9							///
		& cod_articulo>=26 & cod_articulo<36

/* El cuestionario es distinto entre Urbano y Rural en 2010. Los cÛdigos de
  artÌculos correspondientes a los bienes durables son: 
  
  cod_articulo=54 --> 26 ; cod_articulo=58 --> 30 ; cod_articulo=61 --> 33
  cod_articulo=62 --> 34 ; cod_articulo=64 --> No hay ;
  cod_articulo=65 --> No hay ; cod_articulo=68 --> No hay ;
  cod_articulo=69 --> No hay ; cod_articulo=71 --> No hay. */
  					
gen ind_articulo=0 if inlist(cod_articulo,26,30,33,34) 					

recode ind_articulo .=1

drop if ind_articulo==0

*Arreglamos gasto en servicios publicos: input de Margarita

tab  per_compra if cod_articulo==16
			
bys consecutivo_c: egen m_ser=mean(vr_compra_mes) if per_compra==4			///
	& cod_articulo==16
bys consecutivo_c: egen mm_ser=max(m_ser) if cod_articulo==16
			
bys consecutivo_c: egen s_ser=sd(vr_compra_mes) if per_compra==4			///
	& cod_articulo==16
bys consecutivo_c: egen ss_ser=max(s_ser) if cod_articulo==16
			
gen indicador_cambio=cond(vr_compra_mes>mm_ser+2*ss_ser,1,0)
tab indicador per_compra
			
sort vr_compra_mes

recode per_compra 1=4 if cod_articulo==16 & indicador_cambio==1
replace vr_compra_mes=vr_compra if per_compra==4 & cod_articulo==16

*

/* Quitar observaciones de tipos de bienes que no se pueden "obtener" de la
   finca o negocio propio sin pagar.
   (Como esta encuesta es distinta a las otras tres algunos cÛdigos de
   artÌculos no son completamente comparables. se dejan solo los primeros
   5 articulos como "obtenibles" sin pagar.)*/ 

replace vr_obtenido=. if donde_obtuvo!=. & cod_articulo>5
	
gen vr_obtenido_mes=vr_obtenido*2 if donde_obtuvo!=.

* regalos y self-production:

gen vr_regalo_mes=vr_obtenido*2 if donde_obtuvo==3

gen vr_hogar_mes=vr_obtenido*2 if donde_obtuvo==1 

egen vr_total_mes=rowtotal(vr_obtenido_mes vr_compra_mes)

*Sacamos la proporción de valores de compras al mes sobre el total
bys consecutivo: egen total=sum(vr_compra_mes) 
gen prop=vr_compra_mes /total
			
*percentil de compras
xtile percentil=total, nq(20)
			
*Sacamos el total de compras al mes percápita
replace total=total/t_personas
			
*Sacamos percentiles de el valor del obtenido y compra de mes
bys consecutivo: egen total_obt=sum(vr_obtenido_mes)
*y percentil de obtenidos
xtile percentil_obt=total_obt, nq(20)
			
*generamos la secuencia de hogares
bys consecutivo: egen s=seq()

*Anualizando
foreach i in vr_compra_mes vr_obtenido_mes vr_hogar_mes vr_regalo_mes {
	gen a_`i'=`i'*12
	}
	
*Sumar no comprados y comprados
egen a_vr_total=rowtotal(a_vr_obtenido_mes a_vr_compra_mes)

*Agregar todos los gastos
	
foreach i in a_vr_total  a_vr_compra_mes a_vr_obtenido_mes a_vr_regalo_mes  ///
		     a_vr_hogar_mes vr_total_mes vr_compra_mes vr_obtenido_mes	    ///
			 vr_regalo_mes vr_hogar_mes {
			 
	bys consecutivo: egen t_`i'=sum(`i')
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
	
foreach x of varlist ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a    ///
					 ctotal_m ccompra_m obtenido_m regalo_m hhobtenido_m {
					 
gen `x'_per=`x'/t_personas
}

/*ELIMINAR OUTLIERS (JAV: Esta es la única base (Urbano_2010) donde sí
					toca hacer esto (hay consumos diarios muy altos:
					consecutivo 184001 gasta 7'000,000 diarios en carne) */
					
/* Vamos a eliminar las observaciones que tienen muy pocas compras 
   (lo hacemos con los mensuales)*/

bys percentil: egen mean_ccompra_m_per=mean(ccompra_m_per)
bys percentil: egen sd_ccompra_m_per=sd(ccompra_m_per)

gen eliminar_outlier=0
replace eliminar_outlier=1 if ccompra_m_per < mean_ccompra_m_per            ///
	    - 2*sd_ccompra_m_per & percentil==1 
				
*14 observaciones

sort ccompra_m_per

* Observaciones que tienen muchas compras

replace eliminar_outlier=1 if ccompra_m_per>3000000

*Terminando
keep consecutivo ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a		///
ctotal_m ccompra_m obtenido_m regalo_m hhobtenido_m fexhog region			///
t_personas ola zona eliminar_outlier
	
/* Poner en precios de 2016
	variacion de IPC (a√±o corrido):
	2010: 3,17%
	2011: 3,73%
	2012: 2,44% 
	2013: 1.94%
	2014: 3.66%
	2015: 6.77%		*/

local variables ctotal_a ccompra_a obtenido_a ctotal_m ccompra_m obtenido_m ///
      regalo_m hhobtenido_m hhobtenido_a regalo_a
	  
	foreach var of local variables {
	
		replace `var'=`var'*(1.0317)*(1.0373)*(1.0244)*						///
							(1.0194)*(1.0366)*(1.0677)
		}
*
sort consecutivo
	
format ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a ctotal_m 		///
	   ccompra_m obtenido_m regalo_m hhobtenido_m %18.0g
		
keep consecutivo ola zona ctotal_a ccompra_a obtenido_a				///
	 hhobtenido_a regalo_a eliminar_outlier t_personas

*set outliers to missing
foreach i in ctotal_a obtenido_a hhobtenido_a regalo_a {
	replace `i'=. if ccompra_a==0
	replace `i'=0 if eliminar_outlier==1
}
replace ccompra_a=. if ccompra_a==0 | eliminar_outlier==1
drop eliminar_outlier

rename ctotal_a consumo_total
rename ccompra_a consumo_purchased
rename hhobtenido_a consumo_selfcons
rename regalo_a consumo_transfers

append using `consumo_R2010'

tempfile consumo_2010
save `consumo_2010'

/* II. 2013
	 a) Rural & Urbano (las dos encuestas son idénticas) */
 
use "2013/Urbano/Ugastos_hogar.dta", clear
append using "2013/Rural/Rgastos_hogar.dta"

tempfile gastos
save `gastos'
	 
use "2013/Rural/Rhogar.dta", clear
append using "2013/Urbano/Uhogar.dta"

keep llave t_personas consecutivo_c region

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

gen ind_articulo=0 if inlist(cod_articulo,55,59,61,62,64,65,68,70)

recode ind_articulo .=1

drop if ind_articulo==0	

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
			 
	bys llave: egen t_`i'=sum(`i')
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
	
foreach x of varlist ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a    ///
					 ctotal_m ccompra_m obtenido_m regalo_m hhobtenido_m {
					 
gen `x'_per=`x'/t_personas
}

*Terminando
	
format ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a ctotal_m 		///
	   ccompra_m obtenido_m regalo_m hhobtenido_m %18.0g
	   
/* Poner en precios de 2016
	variacion de IPC (a√±o corrido):
	2010: 3,17%
	2011: 3,73%
	2012: 2,44% 
	2013: 1.94%
	2014: 3.66%
	2015: 6.77%		*/

local variables ctotal_a ccompra_a obtenido_a ctotal_m ccompra_m obtenido_m ///
      regalo_m hhobtenido_m hhobtenido_a regalo_a
	  
	foreach var of local variables {
	
		replace `var'=`var'*(1.0194)*(1.0366)*(1.0677)
		}		
*
keep ola zona consecutivo llave ctotal_a ccompra_a obtenido_a hhobtenido_a  /// 
     regalo_a t_personas
	
/* En vez de eliminar la observaciÛn de ccompra_a==0 voy a dejar los valores en
  missing para tener m·s claro cÛmo va el merge */

foreach i in ctotal_a obtenido_a hhobtenido_a regalo_a {
	replace `i'=. if ccompra_a==0
}
replace ccompra_a=. if ccompra_a==0

rename ctotal_a consumo_total
rename ccompra_a consumo_purchased
rename hhobtenido_a consumo_selfcons
rename regalo_a consumo_transfers

tempfile consumo_2013
save `consumo_2013'

*****

/* II. 2016
	 a) Rural & Urbano (las dos encuestas son idénticas) */

 * 2016:

use "2016/Urbano/Ugastos_hogar.dta", clear
append using "2016/Rural/Rgastos_hogar.dta"

tempfile gastos
save `gastos'
	 
use "2016/Rural/Rhogar.dta", clear
append using "2016/Urbano/Uhogar.dta"

keep llave llave_n16 t_personas consecutivo_c

merge 1:m llave_n16 using `gastos'
		  		  
		  
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
 
rename vr_compra_2016 vr_compra

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

  Respecto a R2010, los c√≥digos de bienes durables cambian as√≠:
  
  cod_articulo=54 --> 55 ; cod_articulo=58 --> 59 ; cod_articulo=61 --> 61
  cod_articulo=62 --> 62 ; cod_articulo=64 --> 64 ;
  cod_articulo=65 --> 65 ; cod_articulo=68 --> 68 ;
  cod_articulo=69 --> No hay ; cod_articulo=71 --> 70. */			

gen ind_articulo=0 if inlist(cod_articulo,55,59,61,62,64,65,68,70)

recode ind_articulo .=1

drop if ind_articulo==0	

*Arreglamos gasto en servicios publicos: input de Margarita*

tab  per_compra if cod_articulo==32
			
bys consecutivo_c: egen m_ser=mean(vr_compra_mes) if per_compra==4		   ///
	& cod_articulo==32
bys consecutivo_c: egen mm_ser=max(m_ser) if cod_articulo==32
			
bys consecutivo_c: egen s_ser=sd(vr_compra_mes) if per_compra==4		   ///
	& cod_articulo==32
bys consecutivo_c: egen ss_ser=max(s_ser) if cod_articulo==32
			
gen indicador_cambio=cond(vr_compra_mes>mm_ser+2*ss_ser,1,0)
tab indicador per_compra
			
sort vr_compra_mes 
				
recode per_compra 1=4 if cod_articulo==32 & indicador_cambio==1
replace vr_compra_mes=vr_compra if per_compra==4 & cod_articulo==32

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
		
* Sacamos la proporci√≥n de valores de compras al mes sobre el total
bys llave_n16: egen total=sum(vr_compra_mes) 
gen prop=vr_compra_mes /total

* Sacamos el total de compras al mes per c√°pita
replace total=total/t_personas
				
* generamos la secuencia de hogares
bys llave_n16: egen s=seq()

* Anualizando
foreach i in vr_compra_mes vr_obtenido_mes vr_hogar_mes vr_regalo_mes {
	gen a_`i'=`i'*12
	}
	
* Sumar con no comprados y comprados
	
egen a_vr_total=rowtotal(a_vr_obtenido_mes a_vr_compra_mes)

* Agregar todos los gastos
	
foreach i in a_vr_total  a_vr_compra_mes a_vr_obtenido_mes a_vr_regalo_mes ///
		     a_vr_hogar_mes vr_total_mes vr_compra_mes vr_obtenido_mes	   ///
			 vr_regalo_mes vr_hogar_mes {
			 
	bys llave_n16: egen t_`i'=sum(`i')
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
					 ctotal_m ccompra_m obtenido_m regalo_m hhobtenido_m {
					 
gen `x'_per=`x'/t_personas
}

*Terminando
	
format ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a ctotal_m 	   ///
	   ccompra_m obtenido_m regalo_m hhobtenido_m %18.0g
		
keep ola consecutivo llave llave_n16 ctotal_a ccompra_a obtenido_a		   ///
	 hhobtenido_a regalo_a t_personas
	
/* En vez de eliminar la observación de ccompra_a==0 voy a dejar los valores 
  en missing para tener más claro cómo va el merge */

foreach i in ctotal_a obtenido_a hhobtenido_a regalo_a {
	replace `i'=. if ccompra_a==0
}
replace ccompra_a=. if ccompra_a==0

rename ctotal_a consumo_total
rename ccompra_a consumo_purchased
rename hhobtenido_a consumo_selfcons
rename regalo_a consumo_transfers

***

append using `consumo_2013'
append using `consumo_2010'

foreach i in consumo_total consumo_purchased obtenido_a consumo_transfers  /// 
			 consumo_selfcons t_personas {
			 
		gen `i'_2=`i' if ola==1	
		bys consecutivo: egen `i'_2010=max(`i'_2)
		drop `i'_2
			 
		gen `i'_2=`i' if ola==2	
		bys llave: egen `i'_2013=max(`i'_2)
		drop `i'_2
		 
		rename `i' `i'_2016
}

foreach i in 2010 2013 2016 {

	gen perc_purchased_`i'=consumo_purchased_`i'/consumo_total_`i'
	gen perc_transfers_`i'=consumo_transfers_`i'/consumo_total_`i'
	gen perc_selfcons_`i'=consumo_transfers_`i'/consumo_total_`i'
	* consumo total en millones
	replace consumo_total_`i'=consumo_total_`i'/1000000
	
}

cd "$projdir/dta/cln/ELCA"
merge m:1 llave_n16 using "elca_householdchars_10_13_16.dta"

drop if _merge != 3
drop _merge 

foreach i in 2010 2013 2016 {
	
	gen consumo_total_pc_`i'=consumo_total_`i'/numperh_`i'
}

*

cd "$projdir/dta/cln/ELCA"
save "elca_consumption_hhlvl_10_13_16.dta", replace

* -------------------------------------------------------------------