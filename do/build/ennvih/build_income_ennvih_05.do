* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute ENNVIH household income level 2002-2005-2009

* -----------------

* [2005]

* Num household members: 
use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b3a/iiia_portad.dta", clear

bys folio: gen mieperho = _N 

bys folio: keep if _n == 1 

keep folio mieperho 

tempfile mieperho 
save `mieperho'

* Agricultural sales value: 
use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b2/ii_su1.dta", clear

egen ag_sale_inc = rowtotal(su161_2 su162_2 su163_2)

bys folio: egen ag_sales_income = total(ag_sale_inc)

bys folio: keep if _n == 1 

keep folio ag_sales_income 

tempfile ag_sales_income 
save `ag_sales_income'


* Rural income (INR):
use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b2/ii_inr.dta", clear

egen rural_inc_yr = rowtotal(inr03a inr03b inr03c inr03d inr03e inr03f 	   ///
							 inr03g inr03h inr03i inr03j inr03k)

keep folio rural_inc_yr

tempfile rural_inc
save `rural_inc'


* Non-ag business (NNA):
use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b2/ii_nna1.dta", clear

gen nonagbiz_earn = nna22_12
replace nonagbiz_earn = -nna22_13 if nonagbiz_earn == . // losses

replace nonagbiz_earn = 0 if nonagbiz_earn == .

replace nonagbiz_earn = . if nonagbiz_earn > 1000000 // 2 obs
replace nonagbiz_earn = . if nonagbiz_earn < -100000 // 3 obs

bys folio: egen nonagbiz_earnings_yr = total(nonagbiz_earn)

bys folio: keep if _n == 1

keep folio nonagbiz_earnings_yr

tempfile nonagbiz_earnings 
save `nonagbiz_earnings'

* Non labor income (IN):
use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b2/ii_in.dta", clear

keep folio in01a*_2 in01a*_21 in01b*_2 in01c*_2 in01d*_2 in01e*_2 in01f*_2 ///
		   in01g*_2 in01h*_2 in01i*_2 in01j*_2 in01k*_21

egen nonlab_inc_yr = rowtotal(											   ///
	 /*in01a1_2*/ in01a2_2 in01a3_2 in01a4_2 in01a5_2 in01a6_2 in01a7_2    ///
	 in01a8_2 in01a9_2 in01a10_21 in01b_2 in01c_2 in01d_2 in01e_2 in01f_2  ///
	 in01g_2 in01h_2 in01i_2 in01j_2 in01k_21							   ///				
) // PROGRESA data excluded from the public datasets
  // eg https://www.econstor.eu/bitstream/10419/103004/1/796392285.pdf

sum nonlab_inc_yr, d

keep folio nonlab_inc_yr

tempfile nonlab_inc
save `nonlab_inc'

* Wage income:
use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b3a/iiia_tb.dta", clear 

// Some clear outliers:
replace tb35a_2 = . if tb35a_2 > 1000000 // 1 obs
replace tb35aa_2 = . if tb35aa_2 >= 400000 // 1 obs
replace tb35ac_2 = . if tb35ac_2 >= 400000 // 1 obs

egen totwageearn = rowtotal(tb35aa_2 tb35ab_2 tb35ac_2 tb35ad_2 tb35ae_2   ///
   							tb35af_2 tb35ag_2 tb35ah_2 tb35ai_21)

egen monthlywearn = rowtotal(tb35a_2 totwageearn tb35b_2) 
											    // (principal job |
												// principal job by component)  
												// + secondary job
gen yearly_wageearn = monthlywearn * 12

// egen yearly_wageearn_b = rowtotal(tb36a_2 tb36b_2) // alt def (yearly)

egen earn_selfemp = rowtotal(tb37p2_2 tb37s2_2) 

gen yearly_selfempearn = earn_selfemp * 12 

// egen yearly_selfemp_b = rowtotal(tb38p2_2 tb38s2_2) // alt def (yearly)

gen yearly_labearn = yearly_wageearn + yearly_selfempearn

bys folio: egen yearly_laborearnings = total(yearly_labearn)

bys folio: keep if _n == 1 

keep folio yearly_laborearnings

tempfile labor_earnings
save `labor_earnings' 

* 
* Transfers: 

* Parents:

use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b3b/iiib_tp.dta", clear

egen trsf_p = rowtotal(tp26a tp26f_21 tp26ma tp26mf_21 tp26pa tp26pf_21)

bys folio: egen transfers_parents = total(trsf_p)

bys folio: keep if _n == 1

replace transfers_parents = . if transfers_parents > 1000000 

keep folio transfers_parents 

tempfile transfers_parents 
save `transfers_parents'

* Siblings:

use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b3b/iiib_th2.dta", clear

egen trsf_s = rowtotal(th20d1 th20d2 th20d3 th20d4 th20d7_21)

bys folio: egen transfers_siblings = total(trsf_s)

bys folio: keep if _n == 1 

replace transfers_siblings = . if transfers_siblings > 1000000 

keep folio transfers_siblings 

tempfile transfers_siblings 
save `transfers_siblings'

* Children:

use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b3b/iiib_thi2.dta", clear

egen trsf_c = rowtotal(thi24d1 thi24d2 thi24d3 thi24d4 thi24d7_21)

bys folio: egen transfers_children = total(trsf_c)

bys folio: keep if _n == 1 

replace transfers_children = . if transfers_children > 1000000 

keep folio transfers_children

tempfile transfers_children 
save `transfers_children'

* Others: 

use "$projdir/dta/src/ENNVIH/ehh05dta_all/ehh05dta_b3b/iiib_to.dta", clear

egen trsf_o = rowtotal(to041 to042 to043 to044 to047_21)

bys folio: egen transfers_others = total(trsf_o)

bys folio: keep if _n == 1

replace transfers_others = . if transfers_others > 1000000 

keep folio transfers_others

tempfile transfers_others 
save `transfers_others'

* -----------------

use `mieperho', clear 

merge 1:1 folio using `ag_sales_income'
drop _merge 

merge 1:1 folio using `rural_inc'
drop _merge 

merge 1:1 folio using `nonagbiz_earnings'
drop _merge 

merge 1:1 folio using `nonlab_inc'
drop _merge 

merge 1:1 folio using `labor_earnings' 
drop _merge 

merge 1:1 folio using `transfers_parents'
drop _merge 

merge 1:1 folio using `transfers_siblings'
drop _merge 

merge 1:1 folio using `transfers_children'
drop _merge 

merge 1:1 folio using `transfers_others'
drop _merge 

foreach var of varlist ag_sales_income rural_inc_yr nonagbiz_earnings_yr   ///
					   nonlab_inc_yr yearly_laborearnings 				   ///
					   transfers_parents transfers_siblings 			   ///
					   transfers_children transfers_others {

	replace `var' = 0 if `var' == .
}

egen hh_totincome = rowtotal(ag_sales_income rural_inc_yr 				   ///
						     nonagbiz_earnings_yr nonlab_inc_yr 		   ///
							 yearly_laborearnings 		   				   ///
					   		 transfers_parents transfers_siblings 		   ///
					   		 transfers_children transfers_others)
							
gen percinc = hh_totincome / mieperho // 173 hh not in b3a conpor (?)

label var hh_totincome "Yearly household income (nominal pesos)"
label var percinc "Yearly household income per capita (nominal pesos)"

gen year = 2005

gen folio05 = folio

compress 

cd "$projdir/dta/cln/ENNVIH"
save "ennvih_income_hhlvl_05.dta", replace

* -------------------------------------------------------------------