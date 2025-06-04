* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ENNVIH household income level 2002-2005-2009

* -----------------

cd "$projdir/dta/cln/ENNVIH"
use "ennvih_consump_hhlvl_09.dta", clear

rename folio folio09

gen folio_1 = substr(folio09, 1, 6)

gen folio_2 = substr(folio09, 7, 2)

gen folio_3 = substr(folio09, 9, 2)

gen folio = folio_1 + folio_3

keep folio* percexp

rename percexp percexp_2009

* drop households included in 2009 with same folio as older households

duplicates tag folio, gen(dup)
drop if dup > 0 & folio_2 == "CP"
drop dup 

merge 1:1 folio using "ennvih_consump_hhlvl_05.dta"
gen merge_0905 = _merge
drop if _merge == 1 // "CP" households included in 2009
drop _merge // _merge == 2: households in 2005 not in 2009

isid folio

keep folio* percexp* merge

rename percexp percexp_2005

merge 1:1 folio using "ennvih_consump_hhlvl_02.dta"
gen merge_0502 = _merge 
drop if _merge == 2 // households in 2002 not in 2005 or 2009
drop _merge 

isid folio 

keep folio* percexp* merge*

rename percexp percexp_2002 

drop if merge_0502 == 1 & merge_0905 == 2

gen consump09zero = percexp_2009 == 0
gen consump05zero = percexp_2005 == 0
gen consump02zero = percexp_2002 == 0

egen sumexp = rowtotal(percexp_2009 percexp_2005 percexp_2002)
drop if sumexp == 0 // 

drop folio_* folio09 folio05 folio02 consump*zero merge_0* sumexp

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_consump_hhlvl_09_05_02.dta", replace

* -------------------------------------------------------------------
