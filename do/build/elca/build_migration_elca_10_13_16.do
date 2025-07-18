* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ELCA migration indicators -- 2010-2013-2016

* from: * I) Migration - 20170504

* -----------------

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"

* I. 2010-2013:

use "2010/Rural/Rhogar.dta", clear

decode des_comunidad,gen(descom)
drop des_comunidad
rename descom des_comunidad

append using "2010/Urbano/Uhogar.dta"

append using "2013/Rural/Rhogar.dta"
append using "2013/Urbano/Uhogar.dta"

* Hay que arreglar las localidades de bogotá que salen en U2010:
replace mpio=11001 if dpto==11

bys consecutivo: gen xx = _N
drop if xx==1
tab ola

* ola2 n==9261

gen split=( xx > 2 & ola == 2)

sort consecutivo ola
bys consecutivo: egen ordenhog=seq()

foreach i in ordenhog {

	gen migrazona = 1 if ola == 2 & (zona != zona[_n-`i'+1])
	gen migrampio = 1 if ola == 2 & (mpio != mpio[_n-`i'+1])

	gen migracomunidad = 1 if ola == 2 & 								   ///
		(consecutivo_c != consecutivo_c[_n-`i'+1])

	* No hay migracomunidad en urbanos:
	replace migracomunidad=0 if zona_2010==1
}

foreach var in migrazona migrampio migracomunidad {

	replace `var'=0 if `var'==.
}

replace migracomunidad = 1 if migrazona == 1 | migrampio == 1

/* Hay 5 posibilidades entonces: 
   
   i) Migrar solamente de comunidad
   ii) Migrar de municipio y comunidad siguiendo en la misma zona
   iii) Migrar de zona (y comunidad) en el mismo municipio
   iv) Migrar de zona y municipio (y por tanto comunidad)
   v) No migrar.  */

gen migra_i=(migrazona==0 & migrampio==0 & migracomunidad==1)
gen migra_ii=(migrazona==0 & migrampio==1 & migracomunidad==1)
gen migra_iii=(migrazona==1 & migrampio==0 & migracomunidad==1)
gen migra_iv=(migrazona==1 & migrampio==1 & migracomunidad==1)
gen migra_v=(migrazona==0 & migrampio==0 & migracomunidad==0)

* y las posibilidades tienen que ser mutuamente excluyentes:

foreach i in i ii iii iv v { 
	foreach j in i ii iii iv v {
		if "migra_`i'"!="migra_`j'" {
			count if migra_`i'==1 & migra_`j'
		}
	}
}

keep mpio dpto consecutivo consecutivo_c 		///
	 llave migra* ola proviene_2010 zona des_comunidad split

foreach var in zona mpio dpto consecutivo_c {

	gen v10=`var' if ola==1
	bys consecutivo: egen `var'_2010=max(v10)
	drop v10
}

label var mpio_2010 divipola3
keep if ola == 2

drop migrazona* migrampio* migracomunidad*

gen migramun   = migra_ii  == 1
gen migrazona  = migra_iii == 1 | migra_iv == 1
gen migraver   = migra_i   == 1
gen nomigra    = migra_v   == 1

gen migrante = inlist(1, migramun, migrazona, migraver)

keep consecutivo llave ola zona migra*

drop migra_i* migra_v* ola 

gen year = 2013

cd "$projdir/dta/cln/ELCA"
save "elca_migration_hhlvl_13.dta", replace


* II. 2013-2016:

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"

use "2013/Rural/Rhogar.dta", clear
append using "2013/Urbano/Uhogar.dta"
append using "2016/Rural/Rhogar.dta"
append using "2016/Urbano/Uhogar.dta"
	   
replace zona = zona_2016 if ola==3

gen p13 = zona if ola == 2
bys llave: egen proviene_2013 = max(p13)
keep if proviene_2013!=.

bys llave: gen xx = _N
tab xx  
drop if xx == 1
tab ola zona

gen split = (xx>2 & ola==3)

sort llave ola
bys llave: egen ordenhog=seq()

foreach i in ordenhog {

	gen migrazona=1 if ola==3 & (zona!=zona[_n-`i'+1])
	gen migrampio=1 if ola==3 & (mpio!=mpio[_n-`i'+1])
	gen migracomunidad=1 if ola==3 & (consecutivo_c!=consecutivo_c[_n-`i'+1])
	* No hay migracomunidad en urbanos:
	replace migracomunidad=0 if zona==1
}

foreach var in migrazona migrampio migracomunidad {
	replace `var'=0 if `var'==.
}
*
replace migracomunidad = 1 if migrazona == 1 | migrampio == 1 

gen migra_i   = cond(migrazona==0 & migrampio==0 & migracomunidad==1, 1, 0)
gen migra_ii  = cond(migrazona==0 & migrampio==1 & migracomunidad==1, 1, 0)
gen migra_iii = cond(migrazona==1 & migrampio==0 & migracomunidad==1, 1, 0)
gen migra_iv  = cond(migrazona==1 & migrampio==1 & migracomunidad==1, 1, 0)
gen migra_v   = cond(migrazona==0 & migrampio==0 & migracomunidad==0, 1, 0)

* y las posibilidades tienen que ser mutuamente excluyentes:

foreach i in i ii iii iv v { 
	foreach j in i ii iii iv v {
		if "migra_`i'"!="migra_`j'" {
			count if migra_`i'==1 & migra_`j'
		}
	}
}

foreach var of varlist des_comunidad{

	gen Z=lower(`var')
	drop `var'
	rename Z `var'
}

sort llave ordenhog 
foreach i in ordenhog {

	gen maybe=(ola==3 & (zona==zona[_n-`i'+1]) & (mpio==mpio[_n-`i'+1])    ///
					  & (consecutivo_c==consecutivo_c[_n-`i'+1]) 		   ///
					  & (des_comunidad!=des_comunidad[_n-`i'+1]))				   
}

bys llave: egen maybe_migra=max(maybe)

* consecutivo_c==8888888 problem: solo Rural.

*** Esto es porque puede haber hogares que migraron de 2010 a 2013 a una
*   comunidad que no fue encuestada en la elca (código del consecutivo_c queda
*	como 8888888), y luego entre 2013 y 2016 vuelve a migrar a otra comunidad
*   que tampoco fue encuestada (queda con el mismo código y pareciera
*   no migrante), pero con el nombre de las comunidades (des_comunidad) se
*   puede ver que sí migró. Para arreglar eso se hace lo siguiente:
 
preserve

	keep if maybe_migra==1 & consecutivo_c==8888888						   ///
			& inlist(0,migrazona,migracomunidad,migrampio)
	keep if zona==2
	split des_comunidad, parse("") gen(nomvereda)

	gen match = ""

	forvalues i=1(1)8 { 

		forvalues j=1(1)8 {

			replace match="`i'_`j'" 									   ///
					if nomvereda`i'[_n]==nomvereda`j'[_n-1]				   ///
					& nomvereda`i'!="" & ola==3
		}
	}

	gen nomig = match == ""
	bys llave: egen no_mig=min(nomig) 

	gen migra_i_nombre=no_mig>0 

	gen migracomunidad_nombre=no_mig>0

	** Arreglar esto así por ahora:

	foreach var in migra_i_nombre migracomunidad_nombre  {

		replace `var'=0 if inlist(llave,12226501,12325301,14111401		   ///
									,12214101,14735401,15212901,21415101   ///
									,12223701,20521201,21234801,22616201   ///
									,21232401,21232501,21234801,21415101)

		replace `var'=1 if inlist(llave,13319401,22325201)
	}

	keep if ola==3 
	keep if maybe==1
	keep llave_n16 migra_i_nombre migracomunidad_nombre ola

	tempfile migranom
	save `migranom'

restore

merge m:1 llave_n16 using `migranom'
replace migra_i=1 if migra_i_nombre==1
replace migra_v=0 if migra_i_nombre==1
replace migracomunidad=1 if migracomunidad_nombre==1

drop maybe* migra*_nombre _merge p13

keep mpio dpto  consecutivo_c consecutivo llave 						   ///
	 llave_n16 migra* ola proviene_2013 zona des_comunidad split
	  
keep if ola == 3

drop migrazona* migrampio* migracomunidad*

gen migramun   = migra_ii  == 1
gen migrazona  = migra_iii == 1 | migra_iv == 1
gen migraver   = migra_i   == 1
gen nomigra    = migra_v   == 1

gen migrante = inlist(1, migramun, migrazona, migraver)

keep consecutivo llave llave_n16 ola zona	migra*

drop migra_i* migra_v* ola 

gen year = 2016

cd "$projdir/dta/cln/ELCA"
save "elca_migration_hhlvl_16.dta", replace

* -------------------------------------------------------------------