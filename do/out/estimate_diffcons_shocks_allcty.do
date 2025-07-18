* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Correlate shock onset with change in consumption levels, migration, assets

* -----------------

cd "$projdir/dta/cln/ELCA"
use "elca_shock_prevalence_hhlvl_13_16.dta", clear

gen zona = zona_2016 
replace zona = zona_2013 if zona == . 

gen rural = zona == 2 

keep llave_n16 llave ola rural											   ///
	 shock_natdisast shock_accident_illnss shock_lostjob 			   	   ///
	 shock_criminality shock_deathmember shock_bankrupcy 

gen shock_any = shock_natdisast + shock_accident_illnss  		   		   ///
	    	   + shock_lostjob + shock_criminality 				   		   ///
			   + shock_deathmember + shock_bankrupcy > 0

foreach i of varlist shock_* rural {
			 
		gen `i'_2=`i' if ola==2	
		bys llave: egen `i'_2013=max(`i'_2)
		drop `i'_2
		 
		rename `i' `i'_2016
}

drop if llave_n16 == .

merge 1:1 llave_n16 using "elca_consumption_hhlvl_10_13_16.dta"
drop if _merge != 3
drop _merge 

merge 1:1 llave_n16 using "elca_debts_hhlvl_10_13_16.dta"
drop if _merge != 3
drop _merge 

gen rural_2010 = zona_2010 == 2

egen cons_pc_q_2010 = xtile(consumo_total_pc_2010), n(5) by(rural_2010) 

egen cons_pc_q_2013 = xtile(consumo_total_pc_2013), n(5) by(rural_2013) 

drop if inlist(., cons_pc_q_2010, cons_pc_q_2013) // 9 obs

keep llave_n16  llave rural* shock_natdisast* shock_accident_illnss*       ///
	 shock_lostjob* shock_criminality* shock_deathmember* shock_bankrupcy* ///	
	 shock_any* cons_pc_q_* consumo_total_pc_*						       ///
	  numperh_2016 numperh_2010 numperh_2013  							   ///
	 consumo_alimento_pc_* consumo_personal_pc_* consumo_educatio_pc_*     ///
	 consumo_durables_pc_* consumo_health_pc_* consumo_insuranc_pc_*       ///
	 consumo_leisure_pc_* consumo_purchased_pc_* consumo_transfers_pc_*    ///
	 consumo_selfcons_pc_* debts_dummy_* debts_value_pc_* debts_value*

reshape long rural_ shock_natdisast_ shock_accident_illnss_       		   ///
	 shock_lostjob_ shock_criminality_ shock_deathmember_ shock_bankrupcy_ ///	
	 shock_any_ cons_pc_q_ 	   											   ///
	 consumo_total_pc_ numperh_ tiene_credito_ 							   ///
	 consumo_alimento_pc_ consumo_personal_pc_ consumo_educatio_pc_        ///
	 consumo_durables_pc_ consumo_health_pc_ consumo_insuranc_pc_          ///
	 consumo_leisure_pc_ consumo_purchased_pc_ consumo_transfers_pc_       ///
	 consumo_selfcons_pc_ debts_dummy_ debts_value_pc_ debts_value_, 	   ///
	 i(llave_n16) j(year)

rename *_ * 

*** Harmonize categories with mex:
replace consumo_personal_pc = consumo_personal_pc + consumo_insuranc_pc
drop consumo_insuranc_pc

replace consumo_transfers_pc = consumo_transfers_pc + consumo_selfcons_pc
drop consumo_selfcons_pc
***

sort llave_n16 year 

format llave_n16 %15.0f
tostring llave_n16, gen(allwaveid)

gen country = "Colombia"
gen cty = "COL"

format year %5.0f

gen t = .
replace t = 1 if year == 2010 
replace t = 2 if year == 2013
replace t = 3 if year == 2016

rename consumo_total_pc percexp

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_hhpanel_02_05_09.dta"

replace country = "Mexico" if country == ""
replace cty = "MEX" if cty == ""

replace t = 1 if year == 2002 & cty == "MEX"
replace t = 2 if year == 2005 & cty == "MEX"
replace t = 3 if year == 2009 & cty == "MEX"

egen hhid = group(allwaveid cty)

xtset hhid t
sort cty hhid t

gen rural_baseline = rural[_n-1] if hhid == hhid[_n-1]

* Exchange rates: Express all in dollars

/* replace percexp = percexp / 9.10370 if year == 2002 & cty == "MEX"
replace percexp = percexp / 11.20070 if year == 2005 & cty == "MEX"
replace percexp = percexp / 13.76780 if year == 2009 & cty == "MEX"

replace percexp = percexp / 2044.23 if year == 2010 & cty == "COL"
replace percexp = percexp / 1768.23 if year == 2013 & cty == "COL"
replace percexp = percexp / 3149.47 if year == 2016 & cty == "COL" */

* Actually express all in 2016 dollars:

foreach var of varlist percexp consumo_alimento_pc consumo_personal_pc	   ///
					   consumo_educatio_pc consumo_health_pc 			   ///
					   consumo_durables_pc consumo_leisure_pc 			   ///
					   debts_value_pc consumo_purchased_pc 				   ///
					   consumo_transfers_pc {
	
	replace `var' = `var' / 17.35290 if cty == "MEX"
	replace `var' = `var' / 3149.47 if cty == "COL"
}

sort hhid t

gen lcons = log(percexp)

gen ldiffcons   = log(percexp/L.percexp)
gen ldiffcons_ali = log(consumo_alimento_pc/L.consumo_alimento_pc)
gen ldiffcons_per = log(consumo_personal_pc/L.consumo_personal_pc)
gen ldiffcons_edu = log(consumo_educatio_pc/L.consumo_educatio_pc)
gen ldiffcons_hlt = log(consumo_health_pc/L.consumo_health_pc)
gen ldiffcons_dur = log(consumo_durables_pc/L.consumo_durables_pc)
gen ldiffcons_lei = log(consumo_leisure_pc/L.consumo_leisure_pc)

gen diffcons     = (percexp - L.percexp) 
gen diffcons_ali = (consumo_alimento_pc - L.consumo_alimento_pc) 
gen diffcons_per = (consumo_personal_pc - L.consumo_personal_pc)
gen diffcons_edu = (consumo_educatio_pc - L.consumo_educatio_pc) 
gen diffcons_hlt = (consumo_health_pc - L.consumo_health_pc) 
gen diffcons_dur = (consumo_durables_pc - L.consumo_durables_pc) 
gen diffcons_lei = (consumo_leisure_pc - L.consumo_leisure_pc) 

gen diffcons_purch = (consumo_purchased_pc - L.consumo_purchased_pc) 
gen diffcons_trans = (consumo_transfers_pc - L.consumo_transfers_pc) 

gen diffdebtsval = (debts_value_pc - L.debts_value_pc)
gen diffdebtsvallvl = (debts_value - L.debts_value)
gen diffhasdebt = debts_dummy - L.debts_dummy

* -------------------------------------

estimates clear

rename shock_accident_illnss shock_illnss

foreach i in 1 2 3 {

	preserve 

	if `i' == 2 keep if cty == "COL"
	if `i' == 3 keep if cty == "MEX"

	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_a0_`shk': reg diffcons shock_`shk'
		//eststo m`i'_a1_`shk': reghdfe diffcons shock_`shk', absorb(cty year)
		eststo m`i'_a2_`shk': reghdfe diffcons shock_`shk', absorb(cty year rural_baseline)
	
		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}


	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_b0_`shk': reg diffcons_ali shock_`shk'
		//eststo m`i'_b1_`shk': reghdfe diffcons_ali shock_`shk', absorb(cty year)
		eststo m`i'_b2_`shk': reghdfe diffcons_ali shock_`shk', absorb(cty year rural_baseline)
		
		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}

	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_c0_`shk': reg diffcons_per shock_`shk'
		//eststo m`i'_c1_`shk': reghdfe diffcons_per shock_`shk', absorb(cty year)
		eststo m`i'_c2_`shk': reghdfe diffcons_per shock_`shk', absorb(cty year rural_baseline)
	
		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}

	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_d0_`shk': reg diffcons_edu shock_`shk'
		//eststo m`i'_d1_`shk': reghdfe diffcons_edu shock_`shk', absorb(cty year)
		eststo m`i'_d2_`shk': reghdfe diffcons_edu shock_`shk', absorb(cty year rural_baseline)
	
		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}

	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_e0_`shk': reg diffcons_hlt shock_`shk'
		//eststo m`i'_e1_`shk': reghdfe diffcons_hlt shock_`shk', absorb(cty year)
		eststo m`i'_e2_`shk': reghdfe diffcons_hlt shock_`shk', absorb(cty year rural_baseline)
	
		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}

	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_f0_`shk': reg diffcons_dur shock_`shk'
		//eststo m`i'_f1_`shk': reghdfe diffcons_dur shock_`shk', absorb(cty year)
		eststo m`i'_f2_`shk': reghdfe diffcons_dur shock_`shk', absorb(cty year rural_baseline)
	
		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}

	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_g0_`shk': reg diffcons_lei shock_`shk'
		//eststo m`i'_g1_`shk': reghdfe diffcons_lei shock_`shk', absorb(cty year)
		eststo m`i'_g2_`shk': reghdfe diffcons_lei shock_`shk', absorb(cty year rural_baseline)
	
		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}

	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_h0_`shk': reg diffcons_purch shock_`shk'
		//eststo m`i'_h1_`shk': reghdfe diffcons_purch shock_`shk', absorb(cty year)
		eststo m`i'_h2_`shk': reghdfe diffcons_purch shock_`shk', absorb(cty year rural_baseline)
		
		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}

	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_i0_`shk': reg diffcons_trans shock_`shk'
		//eststo m`i'_i1_`shk': reghdfe diffcons_trans shock_`shk', absorb(cty year)
		eststo m`i'_i2_`shk': reghdfe diffcons_trans shock_`shk', absorb(cty year rural_baseline)
	
		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}

	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_j0_`shk': reg diffhasdebt shock_`shk'
		//eststo m`i'_j1_`shk': reghdfe diffhasdebt shock_`shk', absorb(cty year)
		eststo m`i'_j2_`shk': reghdfe diffhasdebt shock_`shk', absorb(cty year rural_baseline)
	
		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}

	foreach shk in any natdisast lostjob illnss criminality {

		//eststo m`i'_k0_`shk': reg diffdebtsval shock_`shk'
		//eststo m`i'_k1_`shk': reghdfe diffdebtsval shock_`shk', absorb(cty year)
		eststo m`i'_k2_`shk': reghdfe diffdebtsval shock_`shk', absorb(cty year rural_baseline)

		estadd local cty_FE "Yes"
		estadd local year_FE "Yes"
		estadd local zone_FE "Yes"
	}

	restore
}


/* local s any natdisast lostjob illnss criminality */
local s any

/* esttab m1_a0_`s' m1_a1_`s' m1_a2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				
esttab m1_b0_`s' m1_b1_`s' m1_b2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				
esttab m1_c0_`s' m1_c1_`s' m1_c2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				
esttab m1_d0_`s' m1_d1_`s' m1_d2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				
esttab m1_e0_`s' m1_e1_`s' m1_e2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				
esttab m1_f0_`s' m1_f1_`s' m1_f2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				
esttab m1_g0_`s' m1_g1_`s' m1_g2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				
esttab m1_h0_`s' m1_h1_`s' m1_h2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				
esttab m1_i0_`s' m1_i1_`s' m1_i2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				
esttab m1_j0_`s' m1_j1_`s' m1_j2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				
esttab m1_k0_`s' m1_k1_`s' m1_k2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				 */ */

local s any

esttab m1_a2_`s'  m1_b2_`s'  m1_c2_`s' m1_d2_`s' m1_e2_`s' m1_f2_`s' m1_g2_`s', keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

esttab m1_a2_any  m1_a2_natdisast  m1_a2_lostjob 						   ///
	   m1_a2_illnss m1_a2_criminality, keep(shock_*) se star(* 0.1 ** 0.05 *** 0.01) 				

foreach x in a b c d e f g h i j k {

	if "`x'" == "a" local title "Total expenditure"
	if "`x'" == "b" local title "Food expenditure"
	if "`x'" == "c" local title "Personal items expenditure"
	if "`x'" == "d" local title "Education expenditure"
	if "`x'" == "e" local title "Health expenditure"
	if "`x'" == "f" local title "Durable goods expenditure"
	if "`x'" == "g" local title "Leisure expenditure"
	if "`x'" == "h" local title "Expenditure from purchases"
	if "`x'" == "i" local title "Expenditure from transfers"
	if "`x'" == "j" local title "Household has any debt"
	if "`x'" == "k" local title "Value of total debts"

	if inlist("`x'", "a", "b", "c", "d", "e", "f", "g", "h", "i") {

		local ytitle Change in per capita expenditure (USD)
	}

	if "`x'" == "j" local ytitle Change in prob. of having debt
	if "`x'" == "k" local ytitle Change in total debt value (USD)


	coefplot ///
		(m1_`x'2_any, rename(shock_any = "Any Shock") ///
			offset(-0.2) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m2_`x'2_any, rename(shock_any = "Any Shock") ///
			label("any_shock") offset(0) mcolor(stblue) ///
			ciopts(lcolor(stblue))) ///
		(m3_`x'2_any, rename(shock_any = "Any Shock") ///
			label("any_shock") offset(0.2) mcolor(stred) ///
			ciopts(lcolor(stred))) ///
		(m1_`x'2_natdisast, rename(shock_natdisast = "Nat. Disaster") ///
			label("Nat. Disaster") offset(-0.2) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m2_`x'2_natdisast, rename(shock_natdisast = "Nat. Disaster") ///
			label("Nat. Disaster") offset(0) mcolor(stblue) ///
			ciopts(lcolor(stblue))) ///
		(m3_`x'2_natdisast, rename(shock_natdisast = "Nat. Disaster") ///
			label("Nat. Disaster") offset(0.2) mcolor(stred) ///
			ciopts(lcolor(stred))) ///
		(m1_`x'2_illnss, rename(shock_illnss = "Health Shock") ///
			label("Health Shock") offset(-0.2) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m2_`x'2_illnss, rename(shock_illnss = "Health Shock") ///
			label("Health Shock") offset(0) mcolor(stblue) ///
			ciopts(lcolor(stblue))) ///
		(m3_`x'2_illnss, rename(shock_illnss = "Health Shock") ///
			label("Health Shock") offset(0.2) mcolor(stred) ///
			ciopts(lcolor(stred))) ///
		(m1_`x'2_lostjob, rename(shock_lostjob = "Employment") ///
			label("Employment") offset(-0.2) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m2_`x'2_lostjob, rename(shock_lostjob = "Employment") ///
			label("Employment") offset(0) mcolor(stblue) ///
			ciopts(lcolor(stblue))) ///
		(m3_`x'2_lostjob, rename(shock_lostjob = "Employment") ///
			label("Employment") offset(0.2) mcolor(stred) ///
			ciopts(lcolor(stred))) ///
		(m1_`x'2_criminality, rename(shock_criminality = "Criminality") ///
			label("Criminality") offset(-0.2) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m2_`x'2_criminality, rename(shock_criminality = "Criminality") ///
			label("Criminality") offset(0) mcolor(stblue) ///
			ciopts(lcolor(stblue))) ///
		(m3_`x'2_criminality, rename(shock_criminality = "Criminality") ///
			label("Criminality") offset(0.2) mcolor(stred) ///
			ciopts(lcolor(stred))), ///
		drop(_cons)  yline(0, lcolor(red%50) lpattern(dash))    ///
		legend(order(2 "Both Countries" 								///
					4 "COL" 								   ///
					6 "MEX") pos(6) row(1)) vert						 ///
		ytitle("`ytitle'") title("`title'")

		graph export 												       ///
			  "$projdir/out/shock_response_mexcol_allshocks_`x'.png", replace
}



foreach x in a b c d e f g h i j k {

	if "`x'" == "a" local title "Total expenditure"
	if "`x'" == "b" local title "Food expenditure"
	if "`x'" == "c" local title "Personal items expenditure"
	if "`x'" == "d" local title "Education expenditure"
	if "`x'" == "e" local title "Health expenditure"
	if "`x'" == "f" local title "Durable goods expenditure"
	if "`x'" == "g" local title "Leisure expenditure"
	if "`x'" == "h" local title "Expenditure from purchases"
	if "`x'" == "i" local title "Expenditure from transfers"
	if "`x'" == "j" local title "Household has any debt"
	if "`x'" == "k" local title "Value of total debts"

	if inlist("`x'", "a", "b", "c", "d", "e", "f", "g", "h", "i") {

		local ytitle Change in per capita expenditure (USD)
	}

	if "`x'" == "j" local ytitle Change in prob. of having debt
	if "`x'" == "k" local ytitle Change in total debt value (USD)

	local fixy
	if "`x'" == "j" local fixy ysc(range(-0.05(0.05)0.15)) ylab(-0.05(0.05)0.15)

	coefplot ///
		(m1_`x'2_any, rename(shock_any = "Any Shock") ///
			offset(-0) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m1_`x'2_natdisast, rename(shock_natdisast = "Nat. Disaster") ///
			label("Nat. Disaster") offset(-0) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m1_`x'2_illnss, rename(shock_illnss = "Health Shock") ///
			label("Health Shock") offset(-0) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m1_`x'2_lostjob, rename(shock_lostjob = "Employment") ///
			label("Employment") offset(-0) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m1_`x'2_criminality, rename(shock_criminality = "Criminality") ///
			label("Criminality") offset(-0) mcolor(black) ///
			ciopts(lcolor(black))), ///
		drop(_cons)  yline(0, lcolor(red%50) lpattern(dash))    ///
		legend(off) vert						 ///
		ytitle("`ytitle'") title("`title'") `fixy'

		graph export 												       ///
			  "$projdir/out/shock_response_allshocks_`x'.png", replace
}



foreach x in a b c d e f g h i j k {

	if "`x'" == "a" local title "Total expenditure"
	if "`x'" == "b" local title "Food expenditure"
	if "`x'" == "c" local title "Personal items expenditure"
	if "`x'" == "d" local title "Education expenditure"
	if "`x'" == "e" local title "Health expenditure"
	if "`x'" == "f" local title "Durable goods expenditure"
	if "`x'" == "g" local title "Leisure expenditure"
	if "`x'" == "h" local title "Expenditure from purchases"
	if "`x'" == "i" local title "Expenditure from transfers"
	if "`x'" == "j" local title "Household has any debt"
	if "`x'" == "k" local title "Value of total debts"

	if inlist("`x'", "a", "b", "c", "d", "e", "f", "g", "h", "i") {

		local ytitle Change in per capita expenditure (USD)
	}

	if "`x'" == "j" local ytitle Change in prob. of having debt
	if "`x'" == "k" local ytitle Change in total debt value (USD)

	local fixy
	if "`x'" == "j" local fixy ysc(range(-0.05(0.05)0.15)) ylab(-0.05(0.05)0.15)

	coefplot ///
		(m1_`x'2_any, rename(shock_any = "Any Shock") ///
			offset(-0) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m1_`x'2_natdisast, rename(shock_natdisast = "Nat. Disaster") ///
			label("Nat. Disaster") offset(-0) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m1_`x'2_illnss, rename(shock_illnss = "Health Shock") ///
			label("Health Shock") offset(-0) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m1_`x'2_lostjob, rename(shock_lostjob = "Employment") ///
			label("Employment") offset(-0) mcolor(black) ///
			ciopts(lcolor(black))) ///
		(m1_`x'2_criminality, rename(shock_criminality = "Criminality") ///
			label("Criminality") offset(-0) mcolor(black) ///
			ciopts(lcolor(black))), ///
		drop(_cons)  yline(0, lcolor(red%50) lpattern(dash))    ///
		legend(off) vert						 ///
		ytitle("`ytitle'") title("`title'") `fixy'

		graph export 												       ///
			  "$projdir/out/shock_response_allshocks_`x'.png", replace
}

* Loop over each shock instead of each outcome
foreach s in any natdisast illnss lostjob criminality {

	* Set shock label
	if "`s'" == "any"         local shocklabel "Any Shock"
	if "`s'" == "natdisast"   local shocklabel "Nat. Disaster"
	if "`s'" == "illnss"      local shocklabel "Health"
	if "`s'" == "lostjob"     local shocklabel "Employment"
	if "`s'" == "criminality" local shocklabel "Criminality"

	* Now plot the effect of this shock on all outcomes
	coefplot ///
		(m1_a2_`s', rename(shock_`s' = "Total")) ///
		(m1_b2_`s', rename(shock_`s' = "Food")) ///
		(m1_c2_`s', rename(shock_`s' = "Personal items")) ///
		(m1_d2_`s', rename(shock_`s' = "Education")) ///
		(m1_e2_`s', rename(shock_`s' = "Health")) ///
		(m1_f2_`s', rename(shock_`s' = "Durable goods")) ///
		(m1_g2_`s', rename(shock_`s' = "Leisure")), ///
		drop(_cons) yline(0, lcolor(red%50) lpattern(dash)) ///
		legend(off) vert ///
		ytitle("Change in per capita expenditure (USD)") ///
		title("Effect of `shocklabel' on household outcomes")

	// graph export "$projdir/out/shock_response_`s'_alloutcomes.png", replace
}

* Loop over each shock instead of each outcome
foreach s in any natdisast illnss lostjob criminality {

	* Set shock label
	if "`s'" == "any"         local shocklabel "Any Shock"
	if "`s'" == "natdisast"   local shocklabel "Nat. Disaster"
	if "`s'" == "illnss"      local shocklabel "Health"
	if "`s'" == "lostjob"     local shocklabel "Employment"
	if "`s'" == "criminality" local shocklabel "Criminality"

	* Now plot the effect of this shock on all outcomes, all in black
	coefplot ///
		(m1_a2_`s', rename(shock_`s' = "Total") mcolor(black) ciopts(lcolor(black))) ///
		(m1_b2_`s', rename(shock_`s' = "Food") mcolor(black) ciopts(lcolor(black))) ///
		(m1_c2_`s', rename(shock_`s' = "Personal") mcolor(black) ciopts(lcolor(black))) ///
		(m1_d2_`s', rename(shock_`s' = "Education") mcolor(black) ciopts(lcolor(black))) ///
		(m1_e2_`s', rename(shock_`s' = "Health") mcolor(black) ciopts(lcolor(black))) ///
		(m1_f2_`s', rename(shock_`s' = "Durable") mcolor(black) ciopts(lcolor(black))) ///
		(m1_g2_`s', rename(shock_`s' = "Leisure") mcolor(black) ciopts(lcolor(black))), ///
		drop(_cons) yline(0, lcolor(red%50) lpattern(dash)) ///
		legend(off) vert ///
		ytitle("Change in per capita expenditure (USD)") ///
		title("`shocklabel'")

	graph export "$projdir/out/response_percexp_`s'shock.png", replace
}

foreach s in any natdisast illnss lostjob criminality {

	* Set shock label
	if "`s'" == "any"         local shocklabel "Any Shock"
	if "`s'" == "natdisast"   local shocklabel "Nat. Disaster"
	if "`s'" == "illnss"      local shocklabel "Health"
	if "`s'" == "lostjob"     local shocklabel "Employment"
	if "`s'" == "criminality" local shocklabel "Criminality"

	* Now plot the effect of this shock on all outcomes, all in black
	coefplot ///
		(m1_a2_`s', rename(shock_`s' = "Total") mcolor(black) ciopts(lcolor(black))) ///
		(m1_h2_`s', rename(shock_`s' = "Purchased") mcolor(black) ciopts(lcolor(black))) ///
		(m1_i2_`s', rename(shock_`s' = "Transfers") mcolor(black) ciopts(lcolor(black))), ///
		drop(_cons) yline(0, lcolor(red%50) lpattern(dash)) ///
		legend(off) vert ///
		ytitle("Change in per capita expenditure (USD)") ///
		title("`shocklabel'")

	graph export "$projdir/out/response_purchtrasnf_`s'shock.png", replace
}
