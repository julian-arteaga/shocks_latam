* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ELCA household Consumption level 2010-2013-2016 

* -----------------
* 2010

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
Bienes Durables segun definidos por Ana Maria (12.02.14.)
*/

gen ind_articulo= 1 /*if cod_articulo!=54 & cod_articulo!=58 &			   ///
cod_articulo!=61 & cod_articulo!=62 & cod_articulo!=64 & cod_articulo!=65  ///
& cod_articulo!=68 & cod_articulo!=69 & cod_articulo!=71 */				

recode ind_articulo .=0

drop if ind_articulo==0

* Types of consumption:

gen alimento = inrange(cod_articulo, 1, 22)
gen personal = inrange(cod_articulo, 23, 36) | 							   ///
			   inlist(cod_articulo, 38, 39, 40, 41, 43, 44, 45) |		   ///
			   inlist(cod_articulo, 48, 49, 50, 51, 63, 65) 
			   // soap, newspaper, tobacco, clothes, etc. 
gen educatio = cod_articulo == 47
gen health   = inlist(cod_articulo, 37, 46)
gen durables = inrange(cod_articulo, 54, 58) | 							   ///
			   inlist(cod_articulo, 52, 61, 62, 68, 69, 70, 71)		
			   // furniture, appliances, bikes, etc.
gen insuranc = inlist(cod_articulo, 64, 66, 67, 72)
gen leisure  = inlist(cod_articulo, 42, 53, 59, 60)

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
			
		*Sacamos el total de compras al mes percápita
		replace total=total/t_personas
			
		*Sacamos percentiles de el valor del obtenido y compra de mes
		bys consecutivo: egen total_obt=sum(vr_obtenido_mes)

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
			 
	bys consecutivo: egen t_`i'=total(`i')
}

* Agregar por tipo de gasto:

foreach type in alimento personal educatio health 						   ///
				durables insuranc leisure {

	gen t_`type' = a_vr_total if `type' == 1
	bys consecutivo: egen t_vr_`type'_a = total(t_`type')
	drop t_`type'
}

keep if s==1

rename t_a_vr_total ctotal_a
rename t_a_vr_compra_mes ccompra_a
rename t_a_vr_obtenido_mes obtenido_a
rename t_a_vr_hogar_mes hhobtenido_a
rename t_a_vr_regalo_mes regalo_a

*Terminando
keep consecutivo ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a       ///
	 fexhog region t_personas ola zona t_vr_*_a
	
/* Poner en precios de 2016
	variacion de IPC (año corrido):
	2010: 3,17%
	2011: 3,73%
	2012: 2,44% 
	2013: 1.94%
	2014: 3.66%
	2015: 6.77%		*/

local variables ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a		   ///
	   			t_vr_alimento_a t_vr_personal_a t_vr_educatio_a 		   ///
				t_vr_durables_a t_vr_health_a t_vr_insuranc_a 			   ///
				t_vr_leisure_a
	  
	foreach var of local variables {
	
		replace `var'=`var'*(1.0317)*(1.0373)*(1.0244)*					   ///
							(1.0194)*(1.0366)*(1.0677)
	}

sort consecutivo
	
format ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a %18.0g
		
keep consecutivo ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a  	   ///
	 ola zona t_personas t_vr_*_a
	
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

tempfile consumo_R2010
save `consumo_R2010'

use "2010/Rural/Rpersonas.dta", clear

foreach var of varlist vr_matricula vr_uniformes vr_utiles 			       ///
						 vr_complem vr_bono vr_pension 					   ///
						 vr_enfe vr_acci vr_odon vr_ciru vr_ult_hosp {
	recode `var' 99=.
	recode `var' 98=.
	recode `var' 99999999=.
	recode `var' 99998=.
}

replace vr_ult_hosp = vr_ult_hosp / 12 // yearly to monthly 

egen health_exp = rowtotal(vr_enfe vr_acci vr_odon vr_ciru vr_ult_hosp)
egen educ_exp = rowtotal(vr_matricula vr_uniformes vr_utiles 			   ///
						 vr_complem vr_bono vr_pension)

bys consecutivo: egen health_expenditure = total(health_exp)
bys consecutivo: egen educ_expenditure   = total(educ_exp)

bys consecutivo: keep if _n ==1 

// convert health exp from monthly to yearly:
replace health_expenditure = health_expenditure * 12

keep consecutivo health_expenditure educ_expenditure 

merge 1:1 consecutivo using `consumo_R2010'
drop _merge 

replace consumo_health = consumo_health + health_expenditure 
replace consumo_educ   = consumo_educ   + educ_expenditure 
replace consumo_total  = consumo_total + health_expenditure + educ_expenditure

replace consumo_purchased = consumo_purchased 							   ///
						    + health_expenditure + educ_expenditure

drop health_expenditure educ_expenditure

tempfile expendit_R2010
save `expendit_R2010'

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
  					
gen ind_articulo=1 /* if inlist(cod_articulo,26,30,33,34) 					

recode ind_articulo .=1
drop if ind_articulo==0 */

gen alimento = inrange(cod_articulo, 1, 7)
gen personal = inrange(cod_articulo, 8, 13)  | 							   ///
			   inrange(cod_articulo, 15, 18) |							   ///
			   inrange(cod_articulo, 21, 24) |							   ///
			   inlist(cod_articulo, 28, 29)
			   // soap, newspaper, tobacco, clothes, etc. 
gen educatio = cod_articulo == 19
gen health   = inlist(cod_articulo, 14, 20)
gen durables = inlist(cod_articulo, 26, 27, 30, 33, 34)		
			   // furniture, appliances, bikes, etc.
gen insuranc = inlist(cod_articulo, 35)
gen leisure  = inlist(cod_articulo, 25, 31, 32)

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
			 
	bys consecutivo: egen t_`i'=total(`i')
}
	
* Agregar por tipo de gasto:

foreach type in alimento personal educatio health 						   ///
				durables insuranc leisure {

	gen t_`type' = a_vr_total if `type' == 1
	bys consecutivo: egen t_vr_`type'_a = total(t_`type')
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
t_personas ola zona eliminar_outlier t_vr_*_a
	
/* Poner en precios de 2016
	variacion de IPC (a√±o corrido):
	2010: 3,17%
	2011: 3,73%
	2012: 2,44% 
	2013: 1.94%
	2014: 3.66%
	2015: 6.77%		*/

local variables ctotal_a ccompra_a obtenido_a ctotal_m ccompra_m  		   ///
      obtenido_m regalo_m hhobtenido_m hhobtenido_a regalo_a 			   ///
	  t_vr_alimento_a t_vr_personal_a t_vr_educatio_a 					   ///
	  t_vr_durables_a t_vr_health_a t_vr_insuranc_a t_vr_leisure_a
	  
foreach var of local variables {
	
		replace `var'=`var'*(1.0317)*(1.0373)*(1.0244)*					   ///
							(1.0194)*(1.0366)*(1.0677)
}
*

sort consecutivo
	
format ctotal_a ccompra_a obtenido_a hhobtenido_a regalo_a ctotal_m 	   ///
	   ccompra_m obtenido_m regalo_m hhobtenido_m %18.0g
		
keep consecutivo ola zona ctotal_a ccompra_a obtenido_a				       ///
	 hhobtenido_a regalo_a eliminar_outlier t_personas t_vr_*_a
	
*set outliers to missing
foreach i of varlist ctotal_a obtenido_a hhobtenido_a 					   ///
					 ccompra_a regalo_a t_vr_*_a {
	
	replace `i' = . if eliminar_outlier==1
}

drop eliminar_outlier

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

assert abs(check - consumo_total) < 40 if consumo_total != . // 40 pesos

drop check 

tempfile consumo_U2010
save `consumo_U2010'

use "2010/Urbano/Upersonas.dta", clear

foreach var of varlist vr_matricula vr_uniformes vr_utiles 			       ///
						 vr_complem vr_bono vr_pension 					   ///
						 vr_enfe vr_acci vr_odon vr_ciru vr_ult_hosp {
	recode `var' 99=.
	recode `var' 98=.
	recode `var' 99999999=.
	recode `var' 99998=.
}

replace vr_ult_hosp = vr_ult_hosp / 12 // yearly to monthly 

egen health_exp = rowtotal(vr_enfe vr_acci vr_odon vr_ciru vr_ult_hosp)

egen educ_exp = rowtotal(vr_matricula vr_uniformes vr_utiles 			   ///
						 vr_complem vr_bono vr_pension)

bys consecutivo: egen health_expenditure = total(health_exp)
bys consecutivo: egen educ_expenditure   = total(educ_exp)

bys consecutivo: keep if _n ==1 

// convert health exp from monthly to yearly:
replace health_expenditure = health_expenditure * 12

keep consecutivo health_expenditure educ_expenditure 

merge 1:1 consecutivo using `consumo_U2010'
drop _merge 

replace consumo_health = consumo_health + health_expenditure 
replace consumo_educ   = consumo_educ   + educ_expenditure 
replace consumo_total  = consumo_total + health_expenditure + educ_expenditure

replace consumo_purchased = consumo_purchased 							   ///
						    + health_expenditure + educ_expenditure

drop health_expenditure educ_expenditure

append using `expendit_R2010'

gen check = consumo_alimento + consumo_personal + consumo_educatio +	   ///
			consumo_health + consumo_durables + consumo_insuranc +		   ///
			consumo_leisure

format check %15.0f

assert abs(check - consumo_total) < 40 if check != . // 29 obs miss

drop check

* On sources: some obs have a discrepancy (>20) between total exp and 
* the sum of consumption sources (purchased, selfcons, transfers). Assume
* differenece is self consumption:

rename consumo_total hh_totexp

gen check = consumo_purchased + consumo_transfers + consumo_selfcons
gen diff = hh_totexp - check 

replace consumo_selfcons = consumo_selfcons + diff if abs(diff) > 20
replace consumo_selfcons = 0 if consumo_selfcons < 0 

gen check2 = consumo_purchased + consumo_transfers + consumo_selfcons

assert abs(check2 - hh_totexp) < 20 if check != . // 29 obs miss

drop check check2 diff

gen year = 2010 

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_consump_hhlvl_10.dta", replace

* -------------------------------------------------------------------
