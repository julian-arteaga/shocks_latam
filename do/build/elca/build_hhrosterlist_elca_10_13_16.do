* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ELCA main household roster list

* -----------------

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"

use "2016/Rural/Rhogar.dta", clear

keep llave_n16 llave consecutivo zona_2016   			   				   ///
	 mpio consecutivo_c des_comunidad llave

merge 1:m llave_n16 using "2016/Rural/RPersonas.dta"
drop _merge 
egen hh_id = group(llave_n16)

label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   ///
	3 "Post-secondary non-university"  4 "College"

replace nivel_educ = 2  if nivel_educ_cursa == 1 & estudia == 1 
replace nivel_educ = 2  if nivel_educ_cursa == 2 & estudia == 1
replace nivel_educ = 3  if nivel_educ_cursa == 3 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 4 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 5 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 6 & estudia == 1
replace nivel_educ = 10 if nivel_educ_cursa == 7 & estudia == 1

gen educ=.
replace educ=0 if nivel_educ == 1 | nivel_educ == 2 
replace educ=1 if nivel_educ == 3 
replace educ=2 if inlist(nivel_educ, 4, 5, 7, 9)
replace educ=3 if inlist(nivel_educ, 6, 8)
replace educ=4 if inlist(nivel_educ, 10, 12)
label values educ niveduc
label variable educ "Highest Education Level Attained"

gen female = sexo == 2
gen age = edad
gen hhead = parentesco == 1
gen spouse = parentesco == 2
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
label variable hhead_educ "HH Head Education Attainment" // 2016 doesnt record 
														 // this... 
														 // questionnaire skips
														 // people who haven't 
														 // studied in the last
														 // 3 years (?)

gen singleheaded = hasspouse == 0
gen share_hh_female = numfemale / mieperho 
gen share_hh_old = mieperho_old / mieperho 
gen share_hh_young = mieperho_young / mieperho 

bys hh_id: keep if _n == 1

keep llave_n16 llave consecutivo zona_2016   			   				   ///
	 mpio consecutivo_c des_comunidad llave hhead_female singleheaded      ///
	 share_hh_female share_hh_old share_hh_young mieperho hhead_educ 

tempfile rhogar16
save `rhogar16'

use "2016/Urbano/Uhogar.dta", clear

keep llave_n16 llave consecutivo zona_2016   			   				   ///
	 mpio consecutivo_c des_comunidad llave

merge 1:m llave_n16 using "2016/Urbano/UPersonas.dta"
drop _merge 
egen hh_id = group(llave_n16)

label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   ///
	3 "Post-secondary non-university"  4 "College"

replace nivel_educ = 2  if nivel_educ_cursa == 1 & estudia == 1 
replace nivel_educ = 2  if nivel_educ_cursa == 2 & estudia == 1
replace nivel_educ = 3  if nivel_educ_cursa == 3 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 4 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 5 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 6 & estudia == 1
replace nivel_educ = 10 if nivel_educ_cursa == 7 & estudia == 1

gen educ=.
replace educ=0 if nivel_educ == 1 | nivel_educ == 2 
replace educ=1 if nivel_educ == 3 
replace educ=2 if inlist(nivel_educ, 4, 5, 7, 9)
replace educ=3 if inlist(nivel_educ, 6, 8)
replace educ=4 if inlist(nivel_educ, 10, 12)
label values educ niveduc
label variable educ "Highest Education Level Attained"

gen female = sexo == 2
gen age = edad
gen hhead = parentesco == 1
gen spouse = parentesco == 2
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
label variable hhead_educ "HH Head Education Attainment" // 2016 doesnt record 
														 // this... 
														 // questionnaire skips
														 // people who haven't 
														 // studied in the last
														 // 3 years (?)

gen singleheaded = hasspouse == 0
gen share_hh_female = numfemale / mieperho 
gen share_hh_old = mieperho_old / mieperho 
gen share_hh_young = mieperho_young / mieperho 

bys hh_id: keep if _n == 1

keep llave_n16 llave consecutivo zona_2016   			   				   ///
	 mpio consecutivo_c des_comunidad llave hhead_female singleheaded      ///
	 share_hh_female share_hh_old share_hh_young mieperho hhead_educ 

append using `rhogar16'

foreach var of varlist mpio consecutivo_c des_comunidad mieperho 		   ///
					   hhead_female singleheaded hhead_educ    			   ///
	 				   share_hh_female share_hh_old share_hh_young  {

	rename `var' `var'_2016
}

tempfile hh2016 
save `hh2016'

* ---

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
use "2013/Rural/Rhogar.dta", clear

keep llave consecutivo zona   			   				   ///
	 mpio consecutivo_c des_comunidad 

merge 1:m llave using "2013/Rural/RPersonas.dta"
drop _merge 
egen hh_id = group(llave)

label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   ///
	3 "Post-secondary non-university"  4 "College"

replace nivel_educ = 2  if nivel_educ_cursa == 1 & estudia == 1 
replace nivel_educ = 2  if nivel_educ_cursa == 2 & estudia == 1
replace nivel_educ = 3  if nivel_educ_cursa == 3 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 4 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 5 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 6 & estudia == 1
replace nivel_educ = 10 if nivel_educ_cursa == 7 & estudia == 1

gen educ=.
replace educ=0 if nivel_educ == 1 | nivel_educ == 2 
replace educ=1 if nivel_educ == 3 
replace educ=2 if inlist(nivel_educ, 4, 5, 7, 9)
replace educ=3 if inlist(nivel_educ, 6, 8)
replace educ=4 if inlist(nivel_educ, 10, 12)
label values educ niveduc
label variable educ "Highest Education Level Attained"

gen female = sexo == 2
gen age = edad
gen hhead = parentesco == 1
gen spouse = parentesco == 2
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

bys llave: keep if _n == 1

keep llave consecutivo zona mpio consecutivo_c des_comunidad			   ///
	 hhead_female singleheaded share_hh_female share_hh_old share_hh_young ///
	 mieperho hhead_educ 

tempfile rhogar13
save `rhogar13'

use "2013/Urbano/Uhogar.dta", clear

keep llave consecutivo zona   			   				   ///
	 mpio consecutivo_c des_comunidad 

merge 1:m llave using "2013/Urbano/UPersonas.dta"
drop _merge 

egen hh_id = group(llave)

label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   ///
	3 "Post-secondary non-university"  4 "College"

replace nivel_educ = 2  if nivel_educ_cursa == 1 & estudia == 1 
replace nivel_educ = 2  if nivel_educ_cursa == 2 & estudia == 1
replace nivel_educ = 3  if nivel_educ_cursa == 3 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 4 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 5 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 6 & estudia == 1
replace nivel_educ = 10 if nivel_educ_cursa == 7 & estudia == 1

gen educ=.
replace educ=0 if nivel_educ == 1 | nivel_educ == 2 
replace educ=1 if nivel_educ == 3 
replace educ=2 if inlist(nivel_educ, 4, 5, 7, 9)
replace educ=3 if inlist(nivel_educ, 6, 8)
replace educ=4 if inlist(nivel_educ, 10, 12)
label values educ niveduc
label variable educ "Highest Education Level Attained"

gen female = sexo == 2
gen age = edad
gen hhead = parentesco == 1
gen spouse = parentesco == 2
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

bys llave: keep if _n == 1

keep llave consecutivo zona mpio consecutivo_c des_comunidad			   ///
	 hhead_female singleheaded share_hh_female share_hh_old  			   ///
	 share_hh_young mieperho hhead_educ 

append using `rhogar13'

foreach var of varlist zona mpio consecutivo_c des_comunidad mieperho	   ///
					   hhead_female singleheaded share_hh_female 		   ///
					   share_hh_old share_hh_young hhead_educ {

		rename `var' `var'_2013
}

tempfile hh2013
save `hh2013'

* ---

use "2010/Rural/Rhogar.dta", clear

keep consecutivo zona   			   				   ///
	 mpio consecutivo_c 

merge 1:m consecutivo using "2010/Rural/RPersonas.dta"
drop _merge 
egen hh_id = group(consecutivo)


label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   ///
	3 "Post-secondary non-university"  4 "College"

replace nivel_educ = 2  if nivel_educ_cursa == 1 & estudia == 1 
replace nivel_educ = 2  if nivel_educ_cursa == 2 & estudia == 1
replace nivel_educ = 3  if nivel_educ_cursa == 3 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 4 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 5 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 6 & estudia == 1
replace nivel_educ = 10 if nivel_educ_cursa == 7 & estudia == 1

gen educ=.
replace educ=0 if nivel_educ == 1 | nivel_educ == 2 
replace educ=1 if nivel_educ == 3 
replace educ=2 if inlist(nivel_educ, 4, 5, 7, 9)
replace educ=3 if inlist(nivel_educ, 6, 8)
replace educ=4 if inlist(nivel_educ, 10, 12)
label values educ niveduc
label variable educ "Highest Education Level Attained"

gen female = sexo == 2
gen age = edad
gen hhead = parentesco == 1
gen spouse = parentesco == 2
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

bys consecutivo: keep if _n == 1

keep consecutivo zona mpio consecutivo_c 				   				   ///
	 hhead_female singleheaded share_hh_female share_hh_old  			   ///
	 share_hh_young mieperho hhead_educ 

tempfile rhogar10
save `rhogar10'

use "2010/Urbano/Uhogar.dta", clear

keep consecutivo zona   			   				   ///
	 mpio consecutivo_c 

merge 1:m consecutivo using "2010/Urbano/UPersonas.dta"
drop _merge 
egen hh_id = group(consecutivo)

label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   ///
	3 "Post-secondary non-university"  4 "College"

replace nivel_educ = 2  if nivel_educ_cursa == 1 & estudia == 1 
replace nivel_educ = 2  if nivel_educ_cursa == 2 & estudia == 1
replace nivel_educ = 3  if nivel_educ_cursa == 3 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 4 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 5 & estudia == 1
replace nivel_educ = 4  if nivel_educ_cursa == 6 & estudia == 1
replace nivel_educ = 10 if nivel_educ_cursa == 7 & estudia == 1

gen educ=.
replace educ=0 if nivel_educ == 1 | nivel_educ == 2 
replace educ=1 if nivel_educ == 3 
replace educ=2 if inlist(nivel_educ, 4, 5, 7, 9)
replace educ=3 if inlist(nivel_educ, 6, 8)
replace educ=4 if inlist(nivel_educ, 10, 12)
label values educ niveduc
label variable educ "Highest Education Level Attained"

gen female = sexo == 2
gen age = edad
gen hhead = parentesco == 1
gen spouse = parentesco == 2
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

bys consecutivo: keep if _n == 1

keep consecutivo zona mpio consecutivo_c 								   ///
	 hhead_female singleheaded share_hh_female share_hh_old  			   ///
	 share_hh_young mieperho hhead_educ 

append using `rhogar10'


foreach var of varlist zona mpio consecutivo_c mieperho	   ///
					   hhead_female singleheaded share_hh_female 		   ///
					   share_hh_old share_hh_young hhead_educ {

		rename `var' `var'_2010
}

gen des_comunidad_2010 = "" // not used 2010

tempfile hh2010
save `hh2010'

* ---

use `hh2016', clear 

merge m:1 llave using `hh2013'
rename _merge merge1316

merge m:1 consecutivo using `hh2010'
rename _merge merge1013

* ---

* Sample should be:
drop if zona_2013 == . // 2010 households not found in 13
					   // (also excludes 2010 households not found 
					   //  in 13 but refound in 16)

replace llave_n16 = 9999999999 if llave_n16 == .

tostring consecutivo, gen(consecutivo_s)
tostring llave, gen(llave_s)
tostring llave_n16, gen(llave_n16_s)

gen allwaveid = consecutivo_s + llave_s + llave_n16_s

keep consecutivo llave llave_n16 allwaveid								   ///
	 zona_* mpio_* des_comunidad_* consecutivo_c_* mieperho_* 			   ///
	 hhead_female* singleheaded* share_hh_female* share_hh_old*  		   ///
	 share_hh_young* hhead_educ* 

reshape long zona_ mpio_ des_comunidad_ consecutivo_c_ mieperho_   		   ///
			 hhead_female_ singleheaded_ share_hh_female_ share_hh_old_    ///
	 		share_hh_young_ hhead_educ_, i(allwaveid) j(year)

rename *_ * 

gen flag1 = zona == . 
gen flag2 = year == 2016 & llave_n16 == 9999999999
assert flag1 == flag2 //ok, only households not found in 2016 have no var val 

drop if year == 2016 & llave_n16 == 9999999999

bys allwaveid: gen numys = _N			  

sort allwaveid year 

keep allwaveid year consecutivo llave llave_n16 						   ///
	 zona mpio consecutivo_c des_comunidad mieperho 					   ///
	 hhead_female hhead_educ singleheaded 								   ///
	 share_hh_female share_hh_old share_hh_young

gen rural = zona == 2
drop zona

cd "$projdir/dta/cln/ELCA"
save "elca_hhrosterlist_10_13_16.dta", replace

* -------------------------------------------------------------------
