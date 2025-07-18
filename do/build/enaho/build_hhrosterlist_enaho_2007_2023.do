* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENAHO main household roster list
* [2007 - 2023] 

* Maximum number of years a household is interviewed is supposed to be 5 years.
* Some (~5%) households (group(conglome vivienda hogar)) show up 6, 7, or 8 
* times. Not clear why, and not clear if they are the same household throughout

* In this case keep 5 obs per household keeping the latest 5-year period.

cd "$projdir/dta/cln/ENAHO/"

use "enaho_hhrosterlist_1923.dta", clear

rename inghog* inghog*_f1923
rename hpan* hpan*_f1923
rename numpanh waveid_f1923

tempfile 1923
save `1923'

use "enaho_hhrosterlist_1822.dta", clear

rename inghog* inghog*_f1822
rename hpan* hpan*_f1822
rename numpanh waveid_f1822

tempfile 1822
save `1822'

use "enaho_hhrosterlist_1721.dta", clear

rename inghog* inghog*_f1721
rename hpan* hpan*_f1721
rename numpanh waveid_f1721

tempfile 1721
save `1721'

use "enaho_hhrosterlist_1620.dta", clear

rename inghog* inghog*_f1620
rename hpan* hpan*_f1620
rename numpanh waveid_f1620

tempfile 1620
save `1620'

use "enaho_hhrosterlist_1519.dta", clear

rename inghog* inghog*_f1519
rename hpan* hpan*_f1519
rename numpanh waveid_f1519

tempfile 1519
save `1519'

use "enaho_hhrosterlist_1418.dta", clear

rename inghog* inghog*_f1418
rename hpan* hpan*_f1418
rename numpanh waveid_f1418

tempfile 1418
save `1418'

use "enaho_hhrosterlist_1317.dta", clear

rename inghog* inghog*_f1317
rename hpan* hpan*_f1317
rename cenl waveid_f1317

tempfile 1317
save `1317'

use "enaho_hhrosterlist_1216.dta", clear

rename inghog* inghog*_f1216
rename hpan* hpan*_f1216
rename cenl waveid_f1216

tempfile 1216
save `1216'

use "enaho_hhrosterlist_1115.dta", clear

rename inghog* inghog*_f1115
rename hpan* hpan*_f1115
rename num_hog waveid_f1115

tempfile 1115
save `1115'

use "enaho_hhrosterlist_0711.dta", clear

rename inghog* inghog*_f0711
rename hpan* hpan*_f0711
rename num_hog waveid_f0711

tempfile 0711
save `0711'

use `1923', clear

merge 1:1 conglome vivienda hogar year using `1822'
rename _merge merge1822

merge 1:1 conglome vivienda hogar year using `1721'
rename _merge merge1721

merge 1:1 conglome vivienda hogar year using `1620'
rename _merge merge1620

merge 1:1 conglome vivienda hogar year using `1519'
rename _merge merge1519

merge 1:1 conglome vivienda hogar year using `1418'
rename _merge merge1418

merge 1:1 conglome vivienda hogar year using `1317'
rename _merge merge1317

merge 1:1 conglome vivienda hogar year using `1216'
rename _merge merge1216

merge 1:1 conglome vivienda hogar year using `1115'
rename _merge merge1115

merge 1:1 conglome vivienda hogar year using `0711'
rename _merge merge0711


sort conglome vivienda hogar year 

egen hhid = group(conglome vivienda hogar)

bys hhid: egen maxyr = max(year)
bys hhid: egen minyr = min(year)

keep if year >= maxyr - 4 // 5 year max; keep most recent year

* Assumption: same id in different waves represents the same household:

// eg:
assert inghog2d_2018_f1519 == inghog2d_2018_f1822						   ///
	if !inlist(., inghog2d_2018_f1519, inghog2d_2018_f1822)

* This does not happen 100% of the time but close. Probably small errors.

bys hhid: gen numobs = _N
drop if numobs < 2
// numobs == 1 are probably households that split but stay in same house. drop.

drop waveid*

* Build allwaveid:
tostring(year), gen(yrst)
gen waveid = yrst + conglome + vivienda + hogar

bys hhid (year): gen allwaveid = waveid[_N]

* Keep hhpanel indicator from relevant survey year 
bys hhid: egen hpan0708 = max(cond(year == 2008, hpan0708_f0711, .))
bys hhid: egen hpan0809 = max(cond(year == 2009, hpan0809_f0711, .))
bys hhid: egen hpan0910 = max(cond(year == 2010, hpan0910_f0711, .))
bys hhid: egen hpan1011 = max(cond(year == 2011, hpan1011_f0711, .))

* same for rest...

foreach t in 1112 1213 1314 1415 1516 1617 1718 1819 1920 2021 2122 2223 {

	if `t' == 1112 local y 2012
	if `t' == 1213 local y 2013
	if `t' == 1314 local y 2014
	if `t' == 1415 local y 2015
	if `t' == 1516 local y 2016
	if `t' == 1617 local y 2017
	if `t' == 1718 local y 2018
	if `t' == 1819 local y 2019
	if `t' == 1920 local y 2020
	if `t' == 2021 local y 2021
	if `t' == 2122 local y 2022
	if `t' == 2223 local y 2023

	if `t' == 1112 local yt 1115
	if `t' == 1213 local yt 1115
	if `t' == 1314 local yt 1115
	if `t' == 1415 local yt 1115
	if `t' == 1516 local yt 1216
	if `t' == 1617 local yt 1317
	if `t' == 1718 local yt 1418
	if `t' == 1819 local yt 1519
	if `t' == 1920 local yt 1620
	if `t' == 2021 local yt 1721
	if `t' == 2122 local yt 1822
	if `t' == 2223 local yt 1923

	bys hhid: egen hpan`t' = max(cond(year == `y', hpan`t'_f`yt', .))
}

drop hpan*_f* inghog2d* merge* congaux result waveid yrst hhid


foreach var of varlist hpan* {
	replace `var' = 0 if `var' == .
}

order allwaveid year conglome vivienda hogar year rural ubigeo dominio 	   ///
	  estrato mieperho hhead_female singleheaded share_hh_female 		   ///
	  share_hh_old share_hh_young

compress 

cd "$projdir/dta/cln/ENAHO"
save "enaho_hhrosterlist_0723.dta", replace

* -------------------------------------------------------------------
