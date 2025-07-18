* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENNVIH main household roster list

* -----------------

use "$projdir/dta/src/ENNVIH/ehh02dta_all/ehh02dta_bc/c_portad.dta", clear

gen rural = estrato == 4 // | estrato == 3

drop if folio == . // 3 obs
duplicates tag folio, gen(dup)
drop if dup > 0 & ls != 1 // 1 duplicate hh
drop dup
keep folio rural edo mpio

merge 1:m folio using 													   ///
	"$projdir/dta/src/ENNVIH/ehh02dta_all/ehh02dta_bc/c_ls.dta"
drop if _merge == 2 // individuals with no folio in control book
drop _merge 
egen hh_id = group(folio)

label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   	   ///
	3 "Post-secondary non-university"  4 "College"

gen educ=.
replace educ=0 if inlist(ls14, 1, 2)
replace educ=1 if inlist(ls14, 3)
replace educ=2 if inlist(ls14, 4, 5, 6, 7)
replace educ=3 if inlist(ls14, 8)
replace educ=4 if inlist(ls14, 9, 10)
label values educ niveduc
label variable educ "Highest Education Level Attained"

gen female = ls04 == 3
gen age = ls02_2

gen in_school = ls16 == 1
replace in_school = . if ls16 == . 

keep folio ls rural edo mpio female age educ in_school

rename folio folio02

gen folio_02 = string(folio02, "%08.0f")

drop folio02

gen year = 2002

rename edo ent

gen ls_ = string(ls, "%02.0f")
drop ls
rename ls_ ls

gen cve_ent = string(ent, "%02.0f")
gen cve_mun = string(mpio, "%03.0f")
gen cvegeo = cve_ent + cve_mun 
drop cve_ent cve_mun 

tempfile roster02 
save `roster02'

* -------------------------------------

* [2005]

use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_bc/c_portad.dta", clear

gen rural = estrato == 4 // | estrato == 3

keep folio rural ent mpio

gen folio_02 = substr(folio, 1, 6) + "00"

merge 1:m folio using 													   ///
	"$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_bc/c_ls.dta"
drop _merge 
egen hh_id = group(folio)

drop if inlist(ls01a, 0, 3)    // drop previous household members 
							   // no longer living in hh

label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   	   ///
	3 "Post-secondary non-university"  4 "College"

gen educ=.
replace educ=0 if inlist(ls14, 1, 2)
replace educ=1 if inlist(ls14, 3)
replace educ=2 if inlist(ls14, 4, 5, 6, 7)
replace educ=3 if inlist(ls14, 8)
replace educ=4 if inlist(ls14, 9, 10)
label values educ niveduc
label variable educ "Highest Education Level Attained"

gen female = ls04 == 3
gen age = ls02_2

gen in_school = ls16 == 1
replace in_school = . if ls16 == . 

keep folio ls rural ent mpio female age educ in_school

rename folio folio_05

gen year = 2005

gen cve_ent = string(ent, "%02.0f")
gen cve_mun = string(mpio, "%03.0f")
gen cvegeo = cve_ent + cve_mun 
drop cve_ent cve_mun 

tempfile roster05 
save `roster05'

* -------------------------------------

* [2009]

use "$projdir/dta/src/ENNVIH/ehh09dta_all/ehh09dta_bc/c_portad.dta", clear

gen rural = estrato == 4 // | estrato == 3

keep folio rural ent mpio

gen check1 = substr(folio, 1, 6) 
gen check2 = substr(folio, 7, 2) 
gen check3 = substr(folio, 9, 2) 

gen folio_02 = check1 + "00"

gen folio_05 = check1 + check3

merge 1:m folio using 													   ///
			"$projdir/dta/src/ENNVIH/ehh09dta_all/ehh09dta_bc/c_ls.dta"
drop if _merge == 1 // 687 folios with no individuals in ls
drop if _merge == 2 // 5 individuals with no folio in control book
drop _merge 
egen hh_id = group(folio)

drop if inlist(ls01a, 0, 3, 5) // drop previous household members 
							   // no longer living in hh

label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   	   ///
	3 "Post-secondary non-university"  4 "College"

gen educ=.
replace educ=0 if inlist(ls14, 1, 2)
replace educ=1 if inlist(ls14, 3)
replace educ=2 if inlist(ls14, 4, 5, 6, 7)
replace educ=3 if inlist(ls14, 8)
replace educ=4 if inlist(ls14, 9, 10)
label values educ niveduc
label variable educ "Highest Education Level Attained"

gen female = ls04 == 3
gen age = ls02_2

gen in_school = ls16 == 1
replace in_school = . if ls16 == . 

keep folio ls rural ent mpio female age educ in_school

gen year = 2009

rename folio folio_09

gen cve_ent = string(ent, "%02.0f")
gen cve_mun = string(mpio, "%03.0f")
gen cvegeo = cve_ent + cve_mun 
drop cve_ent cve_mun 

rename cvegeo cvegeo_2009

* ---

append using `roster05'
append using `roster02'

* ---

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_educ_schooling_indlvl_02_05_09.dta", replace

* -------------------------------------------------------------------

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_educ_schooling_indlvl_02_05_09.dta", clear

gen minor = inrange(age, 5, 17)
gen minor_noschool = minor == 1 & in_school == 0

keep if year == 2002 

bys folio_02: egen has_minors = max(minor)
bys folio_02: egen minor_no_school = max(minor_noschool)

replace minor_no_school = . if has_minors == 0

bys folio_02: keep if _n == 1

keep folio_02 year minor_no_school

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_noschool_minors_hhlvl_02.dta", replace

* -----

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_educ_schooling_indlvl_02_05_09.dta", clear

gen minor = inrange(age, 5, 17)
gen minor_noschool = minor == 1 & in_school == 0

keep if year == 2005

bys folio_05: egen has_minors = max(minor)
bys folio_05: egen minor_no_school = max(minor_noschool)

replace minor_no_school = . if has_minors == 0

bys folio_05: keep if _n == 1

keep folio_05 year minor_no_school

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_noschool_minors_hhlvl_05.dta", replace

* -----

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_educ_schooling_indlvl_02_05_09.dta", clear

gen minor = inrange(age, 5, 17)
gen minor_noschool = minor == 1 & in_school == 0

keep if year == 2009

bys folio_09: egen has_minors = max(minor)
bys folio_09: egen minor_no_school = max(minor_noschool)

replace minor_no_school = . if has_minors == 0

bys folio_09: keep if _n == 1

keep folio_09 year minor_no_school

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_noschool_minors_hhlvl_09.dta", replace

* -------------------------------------------------------------------
