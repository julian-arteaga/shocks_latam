* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute mean incidence figures for FAODIEM surveys:

* -------------------------------------


cd "$projdir/dta/cln/ENAHO"
use "faodiem_allcty_yr_incidence.dta", clear 

twoway (connected m_shock_natdisast m_shock_accident_illnss  			   ///
		m_shock_lostjob m_shock_criminality med_date if cty == "GTM"), 	   ///
		legend(order(1 "Nat. disaster" 2 "Illness" 3 "Job loss" 4 "Crime") ///
			   pos(6) row(1)) xlab(,labsize(vsmall)) xtit("") ///
		ytitle("Cumulative Incidence") subtitle("Guatemala") 

cd "$projdir/out/faodiem"

graph save g1.gph, replace

twoway (connected m_shock_natdisast m_shock_accident_illnss  			   ///
		m_shock_lostjob m_shock_criminality med_date if cty == "HND"), 	   ///
		legend(order(1 "Nat. disaster" 2 "Illness" 3 "Job loss" 4 "Crime") ///
		pos(6) row(1))													   ///
		ytitle("Cumulative Incidence") subtitle("Honduras") ///
		xlab(,labsize(vsmall)) xtit("")


graph save g2.gph, replace 

twoway (connected m_shock_natdisast m_shock_accident_illnss  			   ///
		m_shock_lostjob m_shock_criminality med_date if cty == "HTI"), 	   ///
		legend(order(1 "Nat. disaster" 2 "Illness" 3 "Job loss" 4 "Crime") ///
		pos(6) row(1))													   ///
		ytitle("Cumulative Incidence") subtitle("Haiti") ///
		xlab(,labsize(vsmall)) xtit("")

graph save g3.gph, replace 

twoway (connected m_shock_natdisast m_shock_accident_illnss  			   ///
		m_shock_lostjob m_shock_criminality med_date if cty == "COL"), 	   ///
		legend(order(1 "Nat. disaster" 2 "Illness" 3 "Job loss" 4 "Crime") ///
		pos(6) row(1))													   ///
		ytitle("Cumulative Incidence") subtitle("Colombia") ///
		xlab(,labsize(vsmall)) xtit("")

graph save g4.gph, replace 

cd "$projdir/out/faodiem"
grc1leg g1.gph g2.gph g3.gph g4.gph, row(2) title("Annual Shock Risk") 

graph export "shock_risk_faodiem_allcty.png", replace

* -------------------------------------

cd "$projdir"
use "dta/cln/FAODIEM_GTM/faodiem_gtm_shocks_hhlvl_r1r4.dta", clear

gen cty = "GTM"

append using "dta/cln/FAODIEM_HND/faodiem_hnd_shocks_hhlvl_r1r4.dta"

replace cty = "HND" if cty == ""

append using "$projdir/dta/cln/FAODIEM_HTI/faodiem_hti_shocks_hhlvl_r3r6.dta"

replace cty = "HTI" if cty == ""

append using "$projdir/dta/cln/FAODIEM_COL/faodiem_col_shocks_hhlvl_r3r6.dta"

replace cty = "COL" if cty == ""

drop shock_noshock 

foreach var of varlist shock_* {

	bys cty round: egen m_`var'   = wtmean(`var'), weight(weight_final)
	bys cty round: egen sd_`var'  = sd(`var')

	replace m_`var' = 1 - (1 - m_`var')^4 // go from quarterly to yearly risk
}

bys cty round: egen med_date = median(round_date)

bys cty round: keep if _n == 1 

keep m_* round cty med_date

format med_date %td

rename m_shock_* *

* Nat disast:

twoway (connected coldtemporhail flood hurricane  						   ///
		drought earthquake landslides 			  						   ///
		firenatural othernathazard med_date if cty == "GTM"),			   ///
		legend(pos(6) row(2))											   ///
		ytitle("Cumulative Incidence") xtitle("")						   ///
		subtitle("Guatemala") xlab(, labsize(vsmall))

cd "$projdir/out/faodiem"

graph save g1.gph, replace

twoway (connected coldtemporhail flood hurricane  						   ///
		drought earthquake landslides 			  						   ///
		firenatural othernathazard med_date if cty == "HND"),			   ///
		legend(pos(6) row(2))											   ///
		ytitle("Cumulative Incidence") xtitle("")						   ///
		subtitle("Honduras") xlab(, labsize(vsmall))

graph save g2.gph, replace

twoway (connected coldtemporhail flood hurricane  						   ///
		drought earthquake landslides 			  						   ///
		firenatural othernathazard med_date if cty == "HTI"),			   ///
		legend(pos(6) row(2))											   ///
		ytitle("Cumulative Incidence") xtitle("")						   ///
		subtitle("Haiti") xlab(, labsize(vsmall))

graph save g3.gph, replace

twoway (connected coldtemporhail flood hurricane  						   ///
		drought earthquake landslides 			  						   ///
		firenatural othernathazard med_date if cty == "COL"),			   ///
		legend(pos(6) row(2))											   ///
		ytitle("Cumulative Incidence") xtitle("")						   ///
		subtitle("Colombia") xlab(, labsize(vsmall))

graph save g4.gph, replace

cd "$projdir/out/faodiem"
grc1leg g1.gph g2.gph g3.gph g4.gph, row(2) 							   ///
		title("Annual Shock Risk", size(small))

graph export "shock_risk_natdist_faodiem_allcty.png", replace

erase g1.gph 
erase g2.gph 
erase g3.gph 
erase g4.gph 

* -------------------------------------------------------------------
