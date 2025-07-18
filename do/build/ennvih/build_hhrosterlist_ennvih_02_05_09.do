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
gen hhead = ls05_1 == 1
gen spouse = ls05_1 == 2
gen hhmember = 1 

gen female_hhmember = female == 1 & hhmember == 1 

gen old_hhmember = age > 65 & age != . & hhmember == 1
gen young_hhmember = age < 15 & age != . & hhmember == 1

bys hh_id: egen  mieperho = total(hhmember)

bys hh_id: egen  mieperho_old = total(old_hhmember)
bys hh_id: egen  mieperho_young = total(young_hhmember)

bys hh_id: egen hhead_female = max(cond(female == 1 & hhead == 1), 1, 0)
bys hh_id: egen hasspouse = max(cond(spouse == 1), 1, 0)
bys hh_id: egen numfemale = total(female_hhmember)

bys hh_id: egen hhead_educ = max(cond(hhead==1, educ, .))
label variable hhead_educ "HH Head Education Attainment"

gen singleheaded = hasspouse == 0
gen share_hh_female = numfemale / mieperho 
gen share_hh_old = mieperho_old / mieperho 
gen share_hh_young = mieperho_young / mieperho 

bys hh_id: keep if _n == 1

keep folio rural edo mpio hhead_female singleheaded      				   ///
	 share_hh_female share_hh_old share_hh_young mieperho hhead_educ 

rename folio folio02

gen folio_02 = string(folio02, "%08.0f")

drop folio02

gen year = 2002

foreach var in rural edo mpio hhead_female singleheaded      			   ///
	 		   share_hh_female share_hh_old share_hh_young 				   ///
			   mieperho hhead_educ  {

	rename `var' `var'_2002
} 

rename edo ent

gen cve_ent = string(ent, "%02.0f")
gen cve_mun = string(mpio, "%03.0f")
gen cvegeo = cve_ent + cve_mun 
drop cve_ent cve_mun 

rename cvegeo cvegeo_2002

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
gen hhead = ls05_1 == 1
gen spouse = ls05_1 == 2
gen hhmember = 1 

gen female_hhmember = female == 1 & hhmember == 1 

gen old_hhmember = age > 65 & age != . & hhmember == 1
gen young_hhmember = age < 15 & age != . & hhmember == 1

bys hh_id: egen  mieperho = total(hhmember)

bys hh_id: egen  mieperho_old = total(old_hhmember)
bys hh_id: egen  mieperho_young = total(young_hhmember)

bys hh_id: egen hhead_female = max(cond(female == 1 & hhead == 1), 1, 0)
bys hh_id: egen hasspouse = max(cond(spouse == 1), 1, 0)
bys hh_id: egen numfemale = total(female_hhmember)

bys hh_id: egen hhead_educ = max(cond(hhead==1, educ, .))
label variable hhead_educ "HH Head Education Attainment"

gen singleheaded = hasspouse == 0
gen share_hh_female = numfemale / mieperho 
gen share_hh_old = mieperho_old / mieperho 
gen share_hh_young = mieperho_young / mieperho 

bys hh_id: keep if _n == 1

gen year = 2005

rename folio folio_05

keep year folio_05 folio_02 rural ent mpio hhead_female singleheaded       ///
	 share_hh_female share_hh_old share_hh_young mieperho hhead_educ 

foreach var in rural ent mpio hhead_female singleheaded      			   ///
	 		   share_hh_female share_hh_old share_hh_young 				   ///
			   mieperho hhead_educ  {

	rename `var' `var'_2005
} 

gen cve_ent = string(ent, "%02.0f")
gen cve_mun = string(mpio, "%03.0f")
gen cvegeo = cve_ent + cve_mun 
drop cve_ent cve_mun 

rename cvegeo cvegeo_2005

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
gen hhead = ls05_1 == 1
gen spouse = ls05_1 == 2
gen hhmember = 1 

gen female_hhmember = female == 1 & hhmember == 1 

gen old_hhmember = age > 65 & age != . & hhmember == 1
gen young_hhmember = age < 15 & age != . & hhmember == 1

bys hh_id: egen  mieperho = total(hhmember)

bys hh_id: egen  mieperho_old = total(old_hhmember)
bys hh_id: egen  mieperho_young = total(young_hhmember)

bys hh_id: egen hhead_female = max(cond(female == 1 & hhead == 1), 1, 0)
bys hh_id: egen hasspouse = max(cond(spouse == 1), 1, 0)
bys hh_id: egen numfemale = total(female_hhmember)

bys hh_id: egen hhead_educ = max(cond(hhead==1, educ, .))
label variable hhead_educ "HH Head Education Attainment"

gen singleheaded = hasspouse == 0
gen share_hh_female = numfemale / mieperho 
gen share_hh_old = mieperho_old / mieperho 
gen share_hh_young = mieperho_young / mieperho 

bys hh_id: keep if _n == 1

gen year = 2009

rename folio folio_09

keep year folio_09 folio_05 folio_02 rural ent mpio hhead_female 		   ///
	 singleheaded share_hh_female share_hh_old share_hh_young mieperho     ///
	 hhead_educ 

foreach var in rural ent mpio hhead_female singleheaded      			   ///
	 		   share_hh_female share_hh_old share_hh_young 				   ///
			   mieperho hhead_educ  {

	rename `var' `var'_2009
} 

gen cve_ent = string(ent, "%02.0f")
gen cve_mun = string(mpio, "%03.0f")
gen cvegeo = cve_ent + cve_mun 
drop cve_ent cve_mun 

rename cvegeo cvegeo_2009

merge m:1  folio_05 using `roster05'
rename _merge merge0905

merge m:1 folio_02 using `roster02'
rename _merge merge0502

drop if mieperho_2005 == . // 2002 households not found in 2005
					   	  // (also excludes 2002 households not found 
					   	  //  in 05 but refound in 09)

replace folio_09 = "9999999999" if folio_09 == ""

gen allwaveid = folio_02 + folio_05 + folio_09

keep folio* allwaveid rural_* mieperho_* cvegeo*						   ///
	 hhead_female_* singleheaded_* share_hh_female_* 					   ///
	 share_hh_old* share_hh_young* hhead_educ*

reshape long rural_ mieperho_ cvegeo_									   ///
			 hhead_female_ singleheaded_ share_hh_female_				   ///
			 share_hh_old_ share_hh_young_ hhead_educ_, 				   ///
			 i(allwaveid) j(year)

rename *_ *

gen flag1 = rural == . 
gen flag2 = year == 2009 & folio_09 == "9999999999"

assert flag1 == flag2 //ok, only households not found in 2016 have no var val 

drop if year == 2009 & folio_09 == "9999999999"

/*
. tab year
  # RENGLON |      Freq.     Percent        Cum.
------------+-----------------------------------
       2002 |      8,377       34.57       34.57
       2005 |      8,377       34.57       69.14
       2009 |      7,478       30.86      100.00
------------+-----------------------------------
      Total |     24,232      100.00			*/

drop flag* 

order allwaveid folio_09 folio_05 folio_02 year

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_hhrosterlist_02_05_09.dta", replace

* -------------------------------------------------------------------
