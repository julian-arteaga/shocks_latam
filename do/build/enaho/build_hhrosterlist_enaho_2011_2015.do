* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENAHO main household roster list

* -----------------

* Sumarias to get household codes (allwaveid)
* [2011 - 2015] 

cd "$projdir/dta/src/ENAHO/"

use "panel/2011_2015/sumaria-2011-2015.dta", clear
	
isid num_hog 

keep conglome_* vivienda_* hogar_* num_hog hpan* inghog2d_*

rename conglome_*  conglome_20*
rename vivienda_*  vivienda_20*
rename hogar_*     hogar_20*
rename inghog2d_*  inghog2d_20*

reshape long conglome_ vivienda_ hogar_, i(num_hog) j(year)

rename *_ *

drop if conglome == ""

tempfile sumpanel_20112015
save `sumpanel_20112015'

* -----------------

* Household characteristics: 

forvalues y = 2011(1)2015 {

	loc t = `y' - 2000

	cd "$projdir/dta/src/ENAHO/"
	use "`y'/Enaho01-`y'-100.dta", clear
	
	gen rural = inlist(estrato, 6, 7 ,8)
	label var rural "Rural household"

	isid conglome vivienda hogar

	drop if inlist(result, 3, 4, 5, 7) // rechazo, ausente, desocupada, otro

	keep conglome vivienda hogar rural result

	merge 1:m conglome vivienda hogar using "`y'/Enaho01-`y'-200.dta"
	drop _merge
	egen hh_id = group(conglome vivienda hogar)

	merge 1:1 conglome vivienda hogar codperso using "`y'/Enaho01a-`y'-300.dta"
	// _merge == 1: mostly age <= 3
	drop _merge 

	if inlist(`y', 2011, 2012, 2013, 2014)  {

		destring conglome, gen(congaux)
		gen cong_aux = string(congaux, "%06.0f") 
		drop conglome 
		rename cong_aux conglome
		order conglome
	}

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

	gen hhead = p203 == 1
	gen spouse = p203 == 2

	gen hhmember = p204 == 1 											   ///
				   & !inlist(p206, 8, 9) // 'Sumaria PANEL_2007-2011.pdf' 
										 // definition

	gen female_hhmember = female == 1 & hhmember == 1 

	gen age = p208a 
	replace age = . if p208a == 98

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

	keep conglome vivienda hogar rural ubigeo dominio estrato 			   ///
		hhead_female singleheaded share_hh_female share_hh_old 			   ///
		share_hh_young mieperho hhead_educ

	gen year = `y'

	tempfile roster`y'
	save `roster`y''
}

* merge rosters 2007-2011

use `roster2011', clear 

forvalues y = 2012(1)2015 {

	append using `roster`y''
}

merge 1:1 conglome vivienda hogar year using `sumpanel_20112015'
drop _merge 

gen ispanel = inlist(1, hpan1112, hpan1213, hpan1314, hpan1415)
drop if ispanel != 1
drop ispanel 

isid conglome vivienda hogar year
isid num_hog year

compress

cd "$projdir/dta/cln/ENAHO"
save "enaho_hhrosterlist_1115.dta", replace

bys num_hog: gen numobs = _N

* -------------------------------------------------------------------
