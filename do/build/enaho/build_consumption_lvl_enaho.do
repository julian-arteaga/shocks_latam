* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Import ENAHO consumption measures -- 2014-2023

* 2013:
use "$projdir/dta/src/ENAHO/2013/SUMARIA-2013.dta", clear
numlabel, add

gen percinc = inghog2d / (mieperho*12)
label var percinc "Net household percapita monthly income"

gen percexp = gashog2d / (mieperho*12)
label var percexp "Total household percapita monthly expenditure"

sum percinc percexp 

forvalues y = 2014(1)2023 {

	use "$projdir/dta/src/ENAHO/`y'/sumaria-`y'.dta", clear
	numlabel, add

	gen percinc = inghog2d / (mieperho*12)
	label var percinc "Net household percapita monthly income"

	gen percexp = gashog2d / (mieperho*12)
	label var percexp "Total household percapita monthly expenditure"

	sum percinc percexp 
}


use "$projdir/dta/src/ENAHO/2017/sumaria-2017.dta", clear
numlabel, add

* Build (area + region + dominio) poverty lines to impute to census:
gen area=estrato
recode area (1/5=1)(6/8=2)
lab define labarea 1"Urban" 2"Rural"
lab val area labarea

gen arealima=.
replace arealima=2         if real(ubigeo)>=150100 & real(ubigeo)<160000
replace arealima=1         if real(ubigeo)>=150100 & real(ubigeo)<=150143

gen region= real(substr(ubigeo,1,2))

gen provincia = substr(ubigeo,1,4)

// Lima* is Lima Metropolitana and Callao
replace region=15 if region==7
replace region=26 if arealima==2
label define region 1"Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa"           ///
                    5"Ayacucho" 6"Cajamarca" 8"Cusco" 9"Huancavelica"       ///
                    10"Huanuco" 11"Ica" 12"Junin" 13"La Libertad"           ///
                    14"Lambayeque" 15"Lima*" 16"Loreto" 17"Madre de Dios"   ///
                    18"Moquegua" 19"Pasco" 20"Piura" 21"Puno"               ///
                    22"San Martin" 23"Tacna" 24"Tumbes" 25"Ucayali"         ///
                    26"Lima provincias"

label values region region

decode region, gen(region_name)

/* preserve

keep region area dominio linea linpe
distinct linea // 82
bys region area dominio: keep if _n == 1 // 82. ok.
numlabel, remove
decode dominio, gen(dominio_s)

saveold 																	///
	"$projdir_box/dta/cln/enaho/dominio_area_region_povline_list_2017.dta", ///
	replace

restore */

rename ubigeo dist_code

gen percexp = gashog2d / (mieperho*12)
label var percexp "Gross household percapita monthly expenditure"

rename gashog2d total_hhexp
label var total_hhexp "Gross household expenditure"

label var linea "Total poverty line"
label var linpe "Extreme poverty line"
// label var lineav "Vulnerability poverty line" // not available

/*
tab pobreza
             pobreza |      Freq.     Percent        Cum.
--------------------+-----------------------------------
   1. pobre extremo |      1,212        3.50        3.50
2. pobre no extremo |      5,246       15.17       18.67
        3. no pobre |     28,126       81.33      100.00
--------------------+-----------------------------------
              Total |     34,584      100.00
*/

gen pobre_extremo = pobreza == 1
gen pobre_no_extremo = pobreza == 2
gen no_pobre = pobreza == 3

gen popweight = factor07*mieperho
/*
sum pobre_extremo pobre_no_extremo no_pobre [aw=factor07*mieperho]

 Variable |     Obs      Weight        Mean   Std. dev.       Min        Max
-------------+-----------------------------------------------------------------
pobre_extr~o |  34,584  32106270.1    .0378628   .1908672          0          1
pobre_no_e~o |  34,584  32106270.1    .1791371   .3834726          0          1
no_pobre 	 |  34,584  32106270.1    .7830001   .4122085          0          1
*/
