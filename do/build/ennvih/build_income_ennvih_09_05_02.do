* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ENNVIH household income level 2002-2005-2009

* -----------------

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_income_hhlvl_09.dta", clear

rename folio folio09

gen folio_1 = substr(folio09, 1, 6)

gen folio_2 = substr(folio09, 7, 2)

gen folio_3 = substr(folio09, 9, 2)

gen folio = folio_1 + folio_3

keep folio* percinc  

rename percinc percinc_2009

* From https://ennvih-mxfls.org/faq.html: 

/* En la ENNViH-3, el folio consta de 10 dígitos. Los primeros seis dígitos 
   son números que identifican al hogar panel a partir del cual se generó dicho 
   hogar. El séptimo dígito indica la ronda en la que se abrió ese hogar por 
   primera vez. Este dígito puede tomar el valor de “A” en el caso de hogares 
   panel (abiertos en 2002), “B”  en el caso de hogares nuevos abiertos en 2005 
   (debido a la separación o desprendimiento de algún miembro panel de su hogar 
   original del 2002), o “C” en el caso de hogares nuevos abiertos en la 
   tercera ronda de la ENNVIH. El octavo dígito indica si el hogar pertenece a 
   un miembro panel, en cuyo caso le corresponde la letra “P”, o si el hogar 
   pertenece a un miembro nuevo, en cuyo caso le corresponde la letra “H”. De 
   acuerdo a los protocolos de campo de la ENNVIH, únicamente se abren hogares 
   que pertenezcan a miembros nuevos en caso de que sean hijos de algún miembro 
   panel y que hayan nacido después del 2002. Los últimos dos dígitos permiten 
   identificar de manera única los nuevos hogares que surgen a partir de la 
   separación de un miembro panel del hogar en el que fue originalmente 
   entrevistado en el 2002.  En el caso de hogares panel, estos dos dígitos son 
   igual a “00”. En el caso de nuevos hogares, estos dos dígitos corresponden 
   al LS (i.e. identificador personal) del miembro panel que se separó del 
   hogar original. Si hay más de una persona del hogar original en el nuevo 
   hogar, se usa el LS que tenga el valor más bajo. Para mayor información 
   referente al folio y para conocer los casos que requirieron un tratamiento 
   especial en la generación de folio favor de consultar la Guía de Usuario. */
 
* drop households included in 2009 with same folio as older households

duplicates tag folio, gen(dup)
drop if dup > 0 & folio_2 == "CP"
drop dup 

merge 1:1 folio using "ennvih_income_hhlvl_05.dta"
gen merge_0905 = _merge
drop if _merge == 1 // "CP" households included in 2009
drop _merge // _merge == 2: households in 2005 not in 2009

isid folio

keep folio* percinc* merge

rename percinc percinc_2005

merge 1:1 folio using "ennvih_income_hhlvl_02.dta"
gen merge_0502 = _merge 
drop if _merge == 2 // households in 2002 not in 2005 or 2009
drop _merge 

isid folio 

keep folio* percinc* merge*

rename percinc percinc_2002 

drop if merge_0502 == 1 & merge_0905 == 2

* prevalence of zero income is high ~ 15%-18%
gen income09zero = percinc_2009 == 0
gen income05zero = percinc_2005 == 0
gen income02zero = percinc_2002 == 0

egen suminc = rowtotal(percinc_2009 percinc_2005 percinc_2002)
drop if suminc == 0 // 

* still quite high...

drop folio_* folio09 folio05 folio02 income0* merge_0* suminc

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_income_hhlvl_09_05_02.dta", replace

* -------------------------------------------------------------------
