* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Import ENNVIH shock modules (2002-2005-2009)

* -----------------

* [2002]

* Crime shock is in different dataset:
use "$projdir/dta/src/ENNVIH/ehh02dta_all/ehh02dta_b2/ii_vlh.dta", clear

gen shock_crim_2	  	  = inlist(1, vlh12a, vlh12b, vlh14, vlh16)

keep folio shock_crim_2 

tempfile shockcrim2_2002
save `shockcrim2_2002'

use "$projdir/dta/src/ENNVIH/ehh02dta_all/ehh02dta_bc/c_portad.dta", clear

gen rural = estrato == 4

keep folio rural 
drop if folio == . // 3 obs
duplicates tag folio, gen(dup)
drop if dup > 0 // 2 obs
drop dup

merge 1:1 folio using 													   ///
	"$projdir/dta/src/ENNVIH/ehh02dta_all/ehh02dta_b2/ii_se.dta"
drop if _merge == 1
drop if _merge == 2 // 4 obs (?)
drop _merge 

gen anio = 2002

* Time distance between interview and shock occurrence:
gen tdist_accident_illnss = min(anio-se02ba_2, anio-se02bb_2, anio-se02bc_2)
gen tdist_lostjob = min(anio-se02ca_2, anio-se02cb_2, anio-se02cc_2)
gen tdist_natdisast = min(anio-se02da_2, anio-se02db_2, anio-se02dc_2,     ///
						  anio-se02ea_2, anio-se02eb_2, anio-se02ec_2)
gen tdist_crim_1 = min(anio-se02fa_2, anio-se02fb_2, anio-se02fc_2)

* Keep only shocks that occurred within the survey year and the year before
gen shock_accident_illnss = se01b == 1 & tdist_accident_illnss <= 1
gen shock_lostjob   	  = se01c == 1 & tdist_lostjob <= 1
gen shock_natdisast 	  = inlist(1, se01d, se01e) & tdist_natdisast <= 1
gen shock_crim_1	  	  = se01f == 1 // cannot subset for crime shock

keep folio rural shock_* 

gen year = 2002

merge 1:1 folio using `shockcrim2_2002'

gen shock_criminality = shock_crim_1 == 1 | shock_crim_2 == 1

drop shock_crim_*

keep folio year shock* rural

gen folio_aux = string(folio, "%08.0f")
drop folio 
rename folio_aux folio

tempfile shocks_2002
save `shocks_2002' 

* -------------------------------------

* [2005]

* Crime shock is in different dataset:
use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b2/ii_vlh.dta", clear

gen shock_crim_2	  	  = inlist(1, vlh12a_a, vlh12a_b, vlh14a, vlh16a)

keep folio shock_crim_2 

tempfile shockcrim2_2005
save `shockcrim2_2005'

use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_bc/c_portad.dta", clear

gen rural = estrato == 4
keep folio rural 

tempfile portada_2005
save `portada_2005'

use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_bc/c_conpor.dta", clear

drop if visita != 1
keep folio anio

replace anio = 2005 if anio == 5
replace anio = 2006 if anio == 6
replace anio = 2007 if anio == 7

merge 1:1 folio using `portada_2005'
drop _merge

merge 1:1 folio using 													   ///
	"$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b2/ii_se.dta" 
drop if _merge == 1
drop _merge 

* Time distance between interview and shock occurrence:
gen tdist_accident_illnss = min(anio-se02ba_2, anio-se02bb_2, anio-se02bc_2)
gen tdist_lostjob = min(anio-se02ca_2, anio-se02cb_2, anio-se02cc_2)
gen tdist_natdisast = min(anio-se02da_2, anio-se02db_2, anio-se02dc_2,     ///
						  anio-se02ea_2, anio-se02eb_2, anio-se02ec_2)
gen tdist_crim_1 = min(anio-se02fa_2, anio-se02fb_2, anio-se02fc_2)

* Keep only shocks that occurred within the survey year and the year before
gen shock_accident_illnss = se01b == 1 & tdist_accident_illnss <= 1
gen shock_lostjob   	  = se01c == 1 & tdist_lostjob <= 1
gen shock_natdisast 	  = inlist(1, se01d, se01e) & tdist_natdisast <= 1
gen shock_crim_1	  	  = se01f == 1 // cannot subset for crime shock

keep folio rural shock_* anio

gen year = 2005

merge 1:1 folio using `shockcrim2_2005'

gen shock_criminality = shock_crim_1 == 1 | shock_crim_2 == 1

drop shock_crim_*

keep folio year shock* rural

tempfile shocks_2005
save `shocks_2005'

* -------------------------------------

* [2009]

* Crime shock is in different dataset:
use "$projdir/dta/src/ENNVIH/ehh09dta_all/ehh09dta_b2/ii_vlh.dta", clear

gen shock_crim_2	  	  = inlist(1, vlh12a_a, vlh12a_b, vlh14a, vlh16a)

keep folio shock_crim_2 

tempfile shockcrim2_2009
save `shockcrim2_2009'

use "$projdir/dta/src/ENNVIH/ehh09dta_all/ehh09dta_bc/c_portad.dta", clear

gen rural = estrato == 4

keep folio rural 

tempfile portada_2009
save `portada_2009'

use "$projdir/dta/src/ENNVIH/ehh09dta_all/ehh09dta_bc/c_conpor.dta", clear

drop if visita != 1
keep folio anio

replace anio = 2009 if anio == 9
replace anio = 2010 if anio == 10
replace anio = 2011 if anio == 11
replace anio = 2012 if anio == 12
replace anio = 2013 if anio == 13

merge 1:1 folio using `portada_2009'
drop _merge

merge 1:1 folio using 													   ///
	 "$projdir/dta/src/ENNVIH/ehh09dta_all/ehh09dta_b2/ii_se.dta"
drop if _merge == 1
drop _merge 

* Time distance between interview and shock occurrence:
gen tdist_accident_illnss = min(anio-se02ba_2, anio-se02bb_2, anio-se02bc_2)
gen tdist_lostjob = min(anio-se02ca_2, anio-se02cb_2, anio-se02cc_2)
gen tdist_natdisast = min(anio-se02da_2, anio-se02db_2, anio-se02dc_2,     ///
						  anio-se02ea_2, anio-se02eb_2, anio-se02ec_2)
gen tdist_crim_1 = min(anio-se02fa_2, anio-se02fb_2, anio-se02fc_2)

* Keep only shocks that occurred within the survey year and the year before
gen shock_accident_illnss = se01b == 1 & tdist_accident_illnss <= 1
gen shock_lostjob   	  = se01c == 1 & tdist_lostjob <= 1
gen shock_natdisast 	  = inlist(1, se01d, se01e) & tdist_natdisast <= 1
gen shock_crim_1	  	  = se01f == 1 // cannot subset for crime shock

keep folio rural shock_* 

gen year = 2009

merge 1:1 folio using `shockcrim2_2009'

gen shock_criminality = shock_crim_1 == 1 | shock_crim_2 == 1

drop shock_crim_*

keep folio year shock* rural

append using `shocks_2005'
append using `shocks_2002'

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_shock_prevalence_hhlvl_02_09.dta", replace

* -------------------------------------




* -------------------------------------------------------------------