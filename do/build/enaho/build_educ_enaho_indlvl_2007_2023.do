* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENAHO school attendance / educ values

* Person level:

* -----------------

cd "$projdir/dta/src/ENAHO/"

forvalues y = 2007(1)2023 {

	local a a 
	if inlist(`y', 2017, 2018, 2019) local a 

	cd "$projdir/dta/src/ENAHO/"
	use "`y'/Enaho01-`y'-100.dta", clear

	drop if inlist(result, 3, 4, 5, 7) // rechazo, ausente, desocupada, otro

	gen rural = inlist(estrato, 6, 7 ,8)
	label var rural "Rural household"

	keep conglome vivienda hogar rural 

	merge 1:m conglome vivienda hogar using "`y'/Enaho01-`y'-200.dta"
	drop _merge
	egen hh_id = group(conglome vivienda hogar)

	merge 1:1 conglome vivienda hogar codperso 							   ///
			  using "`y'/Enaho01`a'-`y'-300.dta"
	drop _merge 

	gen hhmember = p204 == 1 											   ///
				   & !inlist(p206, 8, 9) // 'Sumaria PANEL_2007-2011.pdf' 
										 // definition

	label define niveduc 0 "None" 1 "Primary" 2 "Secondary"				   ///
		3 "Post-secondary non-university"  4 "College"

	gen educ=.
	replace educ=0 if p301a==1 | p301a==2 | p301a==3
	replace educ=1 if p301a==4 | p301a==5
	replace educ=2 if p301a==6 | p301a==7 | p301a==9 
	replace educ=3 if p301a==8
	replace educ=4 if p301a==10 | p301a==11
	label values educ niveduc
	label variable educ "Highest Education Level Attained"

	gen female = p207 == 2

	gen age = p208a 
	replace age = . if p208a == 98

	gen in_school = p306 == 1 

	keep conglome vivienda hogar codperso rural ubigeo dominio estrato 		///
		 female age educ in_school

	sort conglome vivienda hogar codperso
	order conglome vivienda hogar codperso

	gen year = `y'

	tempfile educ`y'
	save `educ`y''
}
	
use `educ2007'
forvalues y = 2008(1)2023 {

	append using `educ`y''
}

compress 

if year < 2014  {

	destring conglome, gen(congaux)
	gen cong_aux = string(congaux, "%06.0f") 
	drop conglome 
	rename cong_aux conglome
	order conglome
}

cd "$projdir/dta/cln/ENAHO"
merge m:1 conglome vivienda hogar year using "enaho_hhrosterlist_0723.dta"
drop if _merge == 1
drop _merge 

keep conglome vivienda hogar codperso rural ubigeo dominio estrato educ    ///
	 age in_school year female

compress 

cd "$projdir/dta/cln/ENAHO"
save "enaho_educ_schooling_indlvl_0723.dta", replace

* -----------------------------------------------
	
cd "$projdir/dta/cln/ENAHO"
use "enaho_educ_schooling_indlvl_0723.dta", clear

gen minor = inrange(age, 5, 17)

gen minor_noschool = minor == 1 & in_school == 0

bys conglome vivienda hogar year: egen has_minors = max(minor)

bys conglome vivienda hogar year: egen minor_no_school = max(minor_noschool)

replace minor_no_school = . if has_minors == 0

bys conglome vivienda hogar year: keep if _n == 1

keep conglome vivienda hogar year minor_no_school

compress 

cd "$projdir/dta/cln/ENAHO"
save "enaho_noschool_minors_hhlvl_0723.dta", replace

* -------------------------------------------------------------------