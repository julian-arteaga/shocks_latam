* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENNVIH migration indicator 2005 - 2009 

* -----------------
* [2005]

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_hhrosterlist_02_05_09.dta", clear

drop if year == 2009

egen hh_id = group(allwaveid)

br hh_id year rural cvegeo

sort hh_id year 

gen migrazona = rural != rural[_n-1] & hh_id == hh_id[_n-1]

gen migramun = cvegeo != cvegeo[_n-1] & hh_id == hh_id[_n-1]

gen migrante = migrazona == 1 | migramun == 1 

keep allwaveid year migra*

keep if year == 2005 

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_migration_hhlvl_05", replace

* -------------------------------------

* [2009]

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_hhrosterlist_02_05_09.dta", clear

drop if year == 2002

egen hh_id = group(allwaveid)

br hh_id year rural cvegeo

sort hh_id year 

gen migrazona = rural != rural[_n-1] & hh_id == hh_id[_n-1]

gen migramun = cvegeo != cvegeo[_n-1] & hh_id == hh_id[_n-1]

gen migrante = migrazona == 1 | migramun == 1 

keep allwaveid year migra*

keep if year == 2009

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_migration_hhlvl_09", replace

* -------------------------------------------------------------------