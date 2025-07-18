* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ENNVIH govt program access measures -- 2002-2005-2009

* -----------------

* [2002]

use "$projdir/dta/src/ENNVIH/ehh02dta_all/ehh02dta_b2/ii_in.dta", clear

keep folio in01a*_1 

drop in01a1_1 in01a4_1 in01a8_1

// PROGRESA data excluded from the public datasets in waves 05 and 09
// eg https://www.econstor.eu/bitstream/10419/103004/1/796392285.pdf

foreach var of varlist in01a*_1 {

	gen `var'_yes = inlist(`var', 1, 2)
}

egen govtprogs = rowtotal(in01a2_1_yes in01a3_1_yes 		   			   ///
						  in01a5_1_yes in01a6_1_yes 					   ///
						  in01a7_1_yes in01a9_1_yes 					   ///
						  in01a10_1_yes)

gen govt_prog = govtprogs > 0

label var govt_prog "Participa en algun programa del gobierno"

keep folio govt_prog 

gen year = 2002 

gen folio_02 = string(folio, "%08.0f")

keep folio_02 year govt_prog 

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_govtprog_hhlvl_02.dta", replace

* ---------------------------

* [2005]

use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b2/ii_in.dta", clear

keep folio in01a*_1 

drop in01a4_1 in01a8_1 // not in 2009 wave (very few participate in any case)

foreach var of varlist in01a*_1 {

	gen `var'_yes = inlist(`var', 1, 2)
}

egen govtprogs = rowtotal(in01a2_1_yes in01a3_1_yes 		   			   ///
						  in01a5_1_yes in01a6_1_yes 					   ///
						  in01a7_1_yes in01a9_1_yes 					   ///
						  in01a10_1_yes)

gen govt_prog = govtprogs > 0

keep folio govt_prog

label var govt_prog "Participa en algun programa del gobierno"

gen year = 2005

gen folio_05 = folio

keep folio_05 year govt_prog 

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_govtprog_hhlvl_05.dta", replace


* ---------------------------

* [2009]

use "$projdir/dta/src/ENNVIH/ehh09dta_all/ehh09dta_b2/ii_in.dta", clear

keep folio in01a*_1 
 
foreach var of varlist in01a*_1 {

	gen `var'_yes = inlist(`var', 1, 2)
}

egen govtprogs = rowtotal(in01a2_1_yes in01a3_1_yes 		   			   ///
						  in01a5_1_yes in01a6_1_yes 					   ///
						  in01a7_1_yes in01a9_1_yes 		   			   ///
						  in01a10_1_yes)

gen govt_prog = govtprogs > 0

label var govt_prog "Participa en algun programa del gobierno"

keep folio govt_prog 

gen year = 2009 

gen folio_09 = folio

keep folio_09 year govt_prog

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_govtprog_hhlvl_09.dta", replace

* -------------------------------------------------------------------