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

label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   	   ///
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

gen in_school = estudia == 1
replace in_school = . if estudia == .

keep llave_n16 llave consecutivo zona_2016   			   				   ///
	 mpio consecutivo_c des_comunidad llave female age educ in_school

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

gen in_school = estudia == 1 
replace in_school = . if estudia == .

keep llave_n16 llave consecutivo zona_2016   			   				   ///
	 mpio consecutivo_c des_comunidad llave female age educ in_school

append using `rhogar16'

rename zona_2016 zona

gen year = 2016

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

gen in_school = estudia == 1
replace in_school = . if estudia == .

keep llave consecutivo zona  			   				   				   ///
	 mpio consecutivo_c des_comunidad llave female age educ in_school

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

gen in_school = estudia == 1
replace in_school = . if estudia == .

keep llave consecutivo zona  			   				   				   ///
	 mpio consecutivo_c des_comunidad llave female age educ in_school

append using `rhogar13'

gen year = 2013

tempfile hh2013
save `hh2013'

* ---

use "2010/Rural/RPersonas.dta", clear
use "2013/Rural/RPersonas.dta", clear

cd "$projdir/dta/src/ELCA/ELCA_10_13_16"
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

gen in_school = estudia == 1 
replace in_school = . if estudia == .

keep consecutivo zona  			   				   				   ///
	 mpio consecutivo_c female age educ in_school

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

gen in_school = estudia == 1 
replace in_school = . if estudia == .

keep consecutivo zona  			   				   				   ///
	 mpio consecutivo_c female age educ in_school

append using `rhogar10'

gen year = 2010
gen des_comunidad = "" // not used 2010

tempfile hh2010
save `hh2010'

* ---

use `hh2016', clear 
append using `hh2013'
append using `hh2010'

* ---

cd "$projdir/dta/cln/ELCA"
save "elca_educ_schooling_indlvl_10_13_16.dta", replace

* -----------------------------------------------

cd "$projdir/dta/cln/ELCA"
use "elca_educ_schooling_indlvl_10_13_16.dta", clear

gen minor = inrange(age, 5, 17)

gen minor_noschool = minor == 1 & in_school == 0

keep if year == 2010 

bys consecutivo: egen has_minors = max(minor)
bys consecutivo: egen minor_no_school = max(minor_noschool)

replace minor_no_school = . if has_minors == 0

bys consecutivo: keep if _n == 1

keep consecutivo year minor_no_school

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_noschool_minors_hhlvl_10.dta", replace

* -----

cd "$projdir/dta/cln/ELCA"
use "elca_educ_schooling_indlvl_10_13_16.dta", clear

gen minor = inrange(age, 5, 17)

gen minor_noschool = minor == 1 & in_school == 0

keep if year == 2013

bys llave: egen has_minors = max(minor)
bys llave: egen minor_no_school = max(minor_noschool)

replace minor_no_school = . if has_minors == 0

bys llave: keep if _n == 1

keep llave consecutivo year minor_no_school

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_noschool_minors_hhlvl_13.dta", replace

* -----

cd "$projdir/dta/cln/ELCA"
use "elca_educ_schooling_indlvl_10_13_16.dta", clear

gen minor = inrange(age, 5, 17)

gen minor_noschool = minor == 1 & in_school == 0

keep if year == 2016

bys llave_n16: egen has_minors = max(minor)
bys llave_n16: egen minor_no_school = max(minor_noschool)

replace minor_no_school = . if has_minors == 0

bys llave_n16: keep if _n == 1

keep llave_n16 llave consecutivo year minor_no_school

compress 

cd "$projdir/dta/cln/ELCA"
save "elca_noschool_minors_hhlvl_16.dta", replace

* -------------------------------------------------------------------

