* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Estimate shock impact on household outcomes independently for each country:

* ---------------------------

cd "$projdir/dta/cln/ENAHO"
use "enaho_hhpanel_07_23_3yearly.dta", clear

foreach var of varlist shock_lostjob shock_accident_illnss                 ///
                       shock_criminality shock_natdisast shock_any {

    drop `var'
    rename `var'_3y `var'
}

gen cty = "PER"

cd "$projdir/dta/cln/ELCA"
append using "elca_hhpanel_10_13_16.dta"

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_hhpanel_02_05_09.dta"

drop numobs 
drop if percexp == . // 214 obs

bys cty allwaveid: gen numobs = _N 
drop if numobs == 1 // 42 obs

gen check = consumo_alimento_pc + consumo_personal_pc + consumo_health_pc  ///
			+ consumo_durables_pc + consumo_leisure_pc

assert abs(check - percexp) < 20 // ok

gen check2 = consumo_transfers_pc + consumo_purchased_pc 

assert abs(check2 - percexp) < 20 // ok

* Express all in 2016 dollars:
foreach var of varlist percexp consumo_alimento_pc consumo_personal_pc	   ///
					   consumo_health_pc consumo_durables_pc 			   ///
					   consumo_leisure_pc 			   					   ///
					   consumo_purchased_pc consumo_transfers_pc		   ///
					   hh_totinc_pc {
	
	replace `var' = `var' / 17.35290 if cty == "MEX"
	replace `var' = `var' / 3149.47 if cty == "COL"
	replace `var' = `var' / 3.4176  if cty == "PER"
}

* Define this var more intuitively:

gen all_minors_in_school = 1 - minor_no_school

drop hhid 
egen hhid = group(allwaveid cty)
egen muni_id = group(cty admincode)
sort hhid year 

bys hhid: gen t = 1 if _n == 1
bys hhid: replace t = 2 if _n == 2 
bys hhid: replace t = 3 if _n == 3

xtset hhid t

gen diffcons     = (percexp - L.percexp) 
gen diffcons_ali = (consumo_alimento_pc - L.consumo_alimento_pc) 
gen diffcons_per = (consumo_personal_pc - L.consumo_personal_pc)
gen diffcons_hlt = (consumo_health_pc - L.consumo_health_pc) 
gen diffcons_dur = (consumo_durables_pc - L.consumo_durables_pc) 
gen diffcons_lei = (consumo_leisure_pc - L.consumo_leisure_pc) 

gen diffcons_purch = (consumo_purchased_pc - L.consumo_purchased_pc) 
gen diffcons_trans = (consumo_transfers_pc - L.consumo_transfers_pc) 

gen diffincome  = (hh_totinc_pc - L.hh_totinc_pc)

gen diffhasdebt = (debts_dummy - L.debts_dummy)
gen diffmigrante = (migrante - L.migrante)

gen diffgovtprog = (govt_prog - L.govt_prog)

gen diffminorschool = (all_minors_in_school - L.all_minors_in_school)

rename shock_accident_illnss shock_illnss

estimates clear

foreach i in 1 2 3 4 {

	if `i' == 1 local cond 
	if `i' == 2 local cond if cty == "COL"
	if `i' == 3 local cond if cty == "MEX"
	if `i' == 4 local cond if cty == "PER"

	local ctrl hhead_female_baseline singleheaded_baseline 				   ///
			   share_hh_female_baseline share_hh_old_baseline 			   ///
			   share_hh_young_baseline hhead_educ_baseline 				   ///
			   distance_to_sea_km_baseline poverty_rate_tot_baseline 	   ///
			   rate_nohealthaccess_baseline

	foreach shk in any natdisast lostjob illnss criminality {

		local outcome diffcons diffcons_ali diffcons_per diffcons_hlt	   ///
					 diffcons_dur diffcons_lei 							   ///
					 diffcons_purch diffcons_trans						   ///
					 diffincome diffgovtprog 	   			   			   ///
					 diffminorschool

		if `i' != 4 local outcome `outcome' diffmigrante diffhasdebt

		foreach y of local outcome {

			if "`y'" == "diffcons"     	 local m a 
			if "`y'" == "diffcons_ali"   local m b 
			if "`y'" == "diffcons_per" 	 local m c
			if "`y'" == "diffcons_hlt"   local m d 
			if "`y'" == "diffcons_dur"   local m e 
			if "`y'" == "diffcons_lei"   local m f 
			if "`y'" == "diffcons_purch" local m g 
			if "`y'" == "diffcons_trans" local m h 
			if "`y'" == "diffhasdebt"    local m i 
			if "`y'" == "diffmigrante"   local m j 
			if "`y'" == "diffincome"     local m k 
			if "`y'" == "diffgovtprog"   local m l 
			if "`y'" == "diffminorschool"   local m m

			/*
			eststo m`i'_`m'_`shk': reghdfe `y' shock_`shk' `cond', 		   ///
					absorb(cty year rural_baseline) cluster(muni_id)

			estadd local ctrls "No"
			estadd local mun_FE "No"
			estadd local cty_FE "Yes"
			estadd local year_FE "Yes"
			estadd local zone_FE "Yes"
			estadd scalar N = e(N), replace
			estadd scalar r2 = e(r2), replace */

			eststo j`i'_`m'_`shk': reghdfe `y' shock_`shk' `ctrl' `cond',  ///
					absorb(cty year rural_baseline) cluster(muni_id) 
			
			estadd local ctrls "Yes"
			estadd local mun_FE "No"
			estadd local cty_FE "Yes"
			estadd local year_FE "Yes"
			estadd local zone_FE "Yes"
			estadd scalar N = e(N), replace
			estadd scalar r2 = e(r2), replace

		    /* 
		 	eststo k`i'_`m'_`shk': reghdfe `y' shock_`shk' `ctrl' `cond',  ///
					absorb(muni_id year rural_baseline) cluster(muni_id)

			estadd local ctrls "Yes"
			estadd local mun_FE "Yes"
			estadd local cty_FE "No"
			estadd local year_FE "Yes"
			estadd local zone_FE "Yes"
			estadd scalar N = e(N), replace
			estadd scalar r2 = e(r2), replace */

		}
	}
}
	
* -----------------------------------------------

/* 
a diffcons 
b diffcons_ali 
c diffcons_per 
d diffcons_hlt	   						   
e diffcons_dur 
f diffcons_lei 							  
g diffcons_purch 
h diffcons_trans						   
i diffhasdebt 
j diffmigrante 
k diffincome 
l diffgovtprog 	  
m diffminornoschool 
*/

* By country:

local t j

foreach s in any natdisast illnss lostjob criminality {

	coefplot ///
    /// Income
    /* (`t'1_k_`s', keep(shock_`s') rename(shock_`s' = "Income") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_k_`s', keep(shock_`s') rename(shock_`s' = "Income") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_k_`s', keep(shock_`s') rename(shock_`s' = "Income") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_k_`s', keep(shock_`s') rename(shock_`s' = "Income") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))) */ /// 
    ///
    /// Total Spending
    (`t'1_a_`s', keep(shock_`s') rename(shock_`s' = "Total Spending") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_a_`s', keep(shock_`s') rename(shock_`s' = "Total Spending") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_a_`s', keep(shock_`s') rename(shock_`s' = "Total Spending") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_a_`s', keep(shock_`s') rename(shock_`s' = "Total Spending") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))) ///
    ///
    /// Spending - Food
    (`t'1_b_`s', keep(shock_`s') rename(shock_`s' = "Spending - Food") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_b_`s', keep(shock_`s') rename(shock_`s' = "Spending - Food") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_b_`s', keep(shock_`s') rename(shock_`s' = "Spending - Food") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_b_`s', keep(shock_`s') rename(shock_`s' = "Spending - Food") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))) ///
    ///
    /// Spending - Personal
    (`t'1_c_`s', keep(shock_`s') rename(shock_`s' = "Spending - Personal") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_c_`s', keep(shock_`s') rename(shock_`s' = "Spending - Personal") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_c_`s', keep(shock_`s') rename(shock_`s' = "Spending - Personal") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_c_`s', keep(shock_`s') rename(shock_`s' = "Spending - Personal") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))) ///
    ///
    /// Spending - Health
    (`t'1_d_`s', keep(shock_`s') rename(shock_`s' = "Spending - Health") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_d_`s', keep(shock_`s') rename(shock_`s' = "Spending - Health") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_d_`s', keep(shock_`s') rename(shock_`s' = "Spending - Health") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_d_`s', keep(shock_`s') rename(shock_`s' = "Spending - Health") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))) ///
    ///
    /// Spending - Durables
    (`t'1_e_`s', keep(shock_`s') rename(shock_`s' = "Spending - Durables") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_e_`s', keep(shock_`s') rename(shock_`s' = "Spending - Durables") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_e_`s', keep(shock_`s') rename(shock_`s' = "Spending - Durables") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_e_`s', keep(shock_`s') rename(shock_`s' = "Spending - Durables") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))) ///
    ///
    /// Spending - Leisure
    (`t'1_f_`s', keep(shock_`s') rename(shock_`s' = "Spending - Leisure") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_f_`s', keep(shock_`s') rename(shock_`s' = "Spending - Leisure") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_f_`s', keep(shock_`s') rename(shock_`s' = "Spending - Leisure") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_f_`s', keep(shock_`s') rename(shock_`s' = "Spending - Leisure") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))), ///
    ///
    drop(_cons)  yline(0, lcolor(red%50) lpattern(dash)) ///
    legend(order(2 "All Countries" 4 "COL" 6 "MEX" 8 "PER") row(4) 		   ///
		       position(3) /*ring(0) bmargin(5 5 5 5)*/ ///
	       region(lstyle(solid))) ///) ///
    vert ytitle("USD (2016)") xlab(, angle(45))

	cd "$projdir/out/allcty"
	graph export "impact_consumptype_shock_`s'_by_cty.png", replace
}

* -------------------------------------

local t j

foreach s in any natdisast illnss lostjob criminality {

	coefplot ///
    /// Total Spending
    (`t'1_a_`s', keep(shock_`s') rename(shock_`s' = "Total Spending") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_a_`s', keep(shock_`s') rename(shock_`s' = "Total Spending") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_a_`s', keep(shock_`s') rename(shock_`s' = "Total Spending") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_a_`s', keep(shock_`s') rename(shock_`s' = "Total Spending") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))) ///
    ///
    /// Spending - Purchases
    (`t'1_g_`s', keep(shock_`s') rename(shock_`s' = "Spending - Purchases") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_g_`s', keep(shock_`s') rename(shock_`s' = "Spending - Purchases") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_g_`s', keep(shock_`s') rename(shock_`s' = "Spending - Purchases") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_g_`s', keep(shock_`s') rename(shock_`s' = "Spending - Purchases") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))) ///
    ///
    /// Spending - Gifts/Transfers
    (`t'1_h_`s', keep(shock_`s') rename(shock_`s' = "Spending - Gifts/Transfers") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_h_`s', keep(shock_`s') rename(shock_`s' = "Spending - Gifts/Transfers") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_h_`s', keep(shock_`s') rename(shock_`s' = "Spending - Gifts/Transfers") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_h_`s', keep(shock_`s') rename(shock_`s' = "Spending - Gifts/Transfers") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))), ///
    ///
    drop(_cons)  yline(0, lcolor(red%50) lpattern(dash)) ///
    legend(order(2 "All Countries" 4 "COL" 6 "MEX" 8 "PER") row(4) 		   ///
		       position(3) /*ring(0) bmargin(5 5 5 5)*/ ///
	       region(lstyle(solid))) ///) ///
    vert ytitle("USD (2016)") xlab(, angle(45))

	cd "$projdir/out/allcty"
	graph export "impact_consumpsource_shock_`s'_by_cty.png", replace
}

* -------------------------------------

local t j

foreach s in any natdisast illnss lostjob criminality {

	coefplot ///
    ///
    /// Govt. Programs
    (`t'1_l_`s', keep(shock_`s') rename(shock_`s' = "Receives Govt. Benefits") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_l_`s', keep(shock_`s') rename(shock_`s' = "Receives Govt. Benefits") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_l_`s', keep(shock_`s') rename(shock_`s' = "Receives Govt. Benefits") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_l_`s', keep(shock_`s') rename(shock_`s' = "Receives Govt. Benefits") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))) ///
    ///
    /// School Attendance
    (`t'1_m_`s', keep(shock_`s') rename(shock_`s' = "School Enrollment") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_m_`s', keep(shock_`s') rename(shock_`s' = "School Enrollment") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_m_`s', keep(shock_`s') rename(shock_`s' = "School Enrollment") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    (`t'4_m_`s', keep(shock_`s') rename(shock_`s' = "School Enrollment") ///
        label("any_shock") offset(0.15) mcolor(stred%75) ciopts(lcolor(stred%75))) ///
    ///
    /// Debts
    (`t'1_i_`s', keep(shock_`s') rename(shock_`s' = "Household has Debt") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_i_`s', keep(shock_`s') rename(shock_`s' = "Household has Debt") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_i_`s', keep(shock_`s') rename(shock_`s' = "Household has Debt") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))) ///
    /// Migration
    (`t'1_j_`s', keep(shock_`s') rename(shock_`s' = "Household Migration") ///
        offset(-0.15) mcolor(black%75) ciopts(lcolor(black%75))) ///
    (`t'2_j_`s', keep(shock_`s') rename(shock_`s' = "Household Migration") ///
        label("any_shock") offset(-0.05) mcolor(stblue%75) ciopts(lcolor(stblue%75))) ///
    (`t'3_j_`s', keep(shock_`s') rename(shock_`s' = "Household Migration") ///
        label("any_shock") offset(0.05) mcolor(stgreen%75) ciopts(lcolor(stgreen%75))), ///
    ///
    drop(_cons)  yline(0, lcolor(red%50) lpattern(dash)) ///
    legend(order(2 "All Countries" 4 "COL" 6 "MEX" 8 "PER") row(4) 		   ///
		       position(3) /* ring(0) bmargin(5 5 5 5) */ ///
	       region(lstyle(solid))) ///) ///
    vert ytitle("Change in Probability") xlab(, angle(45))

	cd "$projdir/out/allcty"
	graph export "impact_copingstrat_shock_`s'_by_cty.png", replace
}

* -------------------------------------------------------------------