* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Estimate shock impact on household outcomes:

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

foreach i in 1 /*2 3 4*/ {

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

		foreach y in diffcons diffcons_ali diffcons_per diffcons_hlt	   ///
					 diffcons_dur diffcons_lei 							   ///
					 diffcons_purch diffcons_trans						   ///
					 diffhasdebt diffmigrante diffincome diffgovtprog 	   ///
					 diffminorschool {

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

			eststo m`i'_`m'_`shk': reghdfe `y' shock_`shk' `cond', 		   ///
					absorb(cty year rural_baseline) cluster(muni_id)

			estadd local ctrls "No"
			estadd local mun_FE "No"
			estadd local cty_FE "Yes"
			estadd local year_FE "Yes"
			estadd local zone_FE "Yes"
			estadd scalar N = e(N), replace
			estadd scalar r2 = e(r2), replace

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

/* local s any
esttab m1_a_`s' m1_b_`s'  m1_c_`s' m1_d_`s' m1_e_`s' m1_f_`s' m1_g_`s'     ///
	   m1_h_`s' m1_i_`s'  m1_j_`s' m1_k_`s' m1_l_`s' m1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

esttab j1_a_`s' j1_b_`s'  j1_c_`s' j1_d_`s' j1_e_`s' j1_f_`s' j1_g_`s'     ///
	   j1_h_`s' j1_i_`s'  j1_j_`s' j1_k_`s' j1_l_`s' j1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

esttab k1_a_`s' k1_b_`s'  k1_c_`s' k1_d_`s' k1_e_`s' k1_f_`s' k1_g_`s'     ///
	   k1_h_`s' k1_i_`s'  k1_j_`s' k1_k_`s' k1_l_`s' k1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

local s natdisast 
esttab m1_a_`s' m1_b_`s'  m1_c_`s' m1_d_`s' m1_e_`s' m1_f_`s' m1_g_`s'     ///
	   m1_h_`s' m1_i_`s'  m1_j_`s' m1_k_`s' m1_l_`s' m1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 					

esttab j1_a_`s' j1_b_`s'  j1_c_`s' j1_d_`s' j1_e_`s' j1_f_`s' j1_g_`s'     ///
	   j1_h_`s' j1_i_`s'  j1_j_`s' j1_k_`s' j1_l_`s' j1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

esttab k1_a_`s' k1_b_`s'  k1_c_`s' k1_d_`s' k1_e_`s' k1_f_`s' k1_g_`s'     ///
	   k1_h_`s' k1_i_`s'  k1_j_`s' k1_k_`s' k1_l_`s' k1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

local s lostjob 
esttab m1_a_`s' m1_b_`s'  m1_c_`s' m1_d_`s' m1_e_`s' m1_f_`s' m1_g_`s'     ///
	   m1_h_`s' m1_i_`s'  m1_j_`s' m1_k_`s' m1_l_`s' m1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

esttab j1_a_`s' j1_b_`s'  j1_c_`s' j1_d_`s' j1_e_`s' j1_f_`s' j1_g_`s'     ///
	   j1_h_`s' j1_i_`s'  j1_j_`s' j1_k_`s' j1_l_`s' j1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

esttab k1_a_`s' k1_b_`s'  k1_c_`s' k1_d_`s' k1_e_`s' k1_f_`s' k1_g_`s'     ///
	   k1_h_`s' k1_i_`s'  k1_j_`s' k1_k_`s' k1_l_`s' k1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

local s illnss 
esttab m1_a_`s' m1_b_`s'  m1_c_`s' m1_d_`s' m1_e_`s' m1_f_`s' m1_g_`s'     ///
	   m1_h_`s' m1_i_`s'  m1_j_`s' m1_k_`s' m1_l_`s' m1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 		

esttab j1_a_`s' j1_b_`s'  j1_c_`s' j1_d_`s' j1_e_`s' j1_f_`s' j1_g_`s'     ///
	   j1_h_`s' j1_i_`s'  j1_j_`s' j1_k_`s' j1_l_`s' j1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

esttab k1_a_`s' k1_b_`s'  k1_c_`s' k1_d_`s' k1_e_`s' k1_f_`s' k1_g_`s'     ///
	   k1_h_`s' k1_i_`s'  k1_j_`s' k1_k_`s' k1_l_`s' k1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

local s criminality 
esttab m1_a_`s' m1_b_`s'  m1_c_`s' m1_d_`s' m1_e_`s' m1_f_`s' m1_g_`s'     ///
	   m1_h_`s' m1_i_`s'  m1_j_`s' m1_k_`s' m1_l_`s' m1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 			

esttab j1_a_`s' j1_b_`s'  j1_c_`s' j1_d_`s' j1_e_`s' j1_f_`s' j1_g_`s'     ///
	   j1_h_`s' j1_i_`s'  j1_j_`s' j1_k_`s' j1_l_`s' j1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				

esttab k1_a_`s' k1_b_`s'  k1_c_`s' k1_d_`s' k1_e_`s' k1_f_`s' k1_g_`s'     ///
	   k1_h_`s' k1_i_`s'  k1_j_`s' k1_k_`s' k1_l_`s' k1_m_`s', 			   ///
	   keep(shock_`s') se star(* 0.1 ** 0.05 *** 0.01) 				 */

* ------

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

cd "$projdir/out/allcty"

local s any
esttab m1_k_`s' m1_a_`s'  m1_b_`s' m1_c_`s' m1_d_`s' m1_e_`s' m1_f_`s' 	   ///
	   m1_g_`s' m1_h_`s'												   ///
	using "impact_allshocks_allcty.tex", 		           			   	   ///
	b(3) se(3) keep(shock_any)  star(* 0.1 ** 0.05 *** 0.01) 	  	   	   ///
	prehead("\begin{tabular}{l*{9}{c}} \hline\hline") 					   ///
    coeflabels(shock_any "Any Shock")       		   	   		   		   ///
    mgroups(" " " "												   	       ///
			"Spending Type"											   ///
			"Spending Source", 							   			   ///
            pattern(1 1 1 0 0 0 0 1 0) 									   ///
			prefix(\multicolumn{@span}{c}{) suffix(})   				   ///
	        span erepeat(\cmidrule(lr){@span}))                            /// 
	mtitles("Income" 						   /// 
			"Spending" 		   			   ///
			"\hspace{1em} Food \hspace{1em} " "Personal" 				   ///
			"\hspace{1em} Health \hspace{1em} " 		   				   ///
			"Durables" " Leisure"							   ///
			"Purchases" "Gifts/Transfers")         ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
	nonotes fragment replace postfoot("\hline \hline ") 				   ///
	posthead("\cmidrule(lr){2-10}")										   ///

local s natdisast 
esttab m1_k_`s' m1_a_`s'  m1_b_`s' m1_c_`s' m1_d_`s' m1_e_`s' m1_f_`s' 	   ///
	   m1_g_`s' m1_h_`s'												   ///
	using "impact_allshocks_allcty.tex", 		           				   ///
    b(3) se(3) keep(shock_natdisast)  star(* 0.1 ** 0.05 *** 0.01)         ///
    coeflabels(shock_natdisast "Weather Shock")           				   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
    label nonotes fragment append nonumber 					   			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} ")			   ///
	posthead(" ") postfoot("\hline \hline")

local s lostjob 
esttab m1_k_`s' m1_a_`s'  m1_b_`s' m1_c_`s' m1_d_`s' m1_e_`s' m1_f_`s' 	   ///
	   m1_g_`s' m1_h_`s'												   ///
	using "impact_allshocks_allcty.tex", 		           				   ///
    b(3) se(3) keep(shock_lostjob)  star(* 0.1 ** 0.05 *** 0.01)           ///
    coeflabels(shock_lostjob "Employment Shock")           				   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
    label nonotes fragment append nonumber 					   			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} ")			   ///
	posthead(" ") postfoot("\hline \hline")

local s illnss 
esttab m1_k_`s' m1_a_`s'  m1_b_`s' m1_c_`s' m1_d_`s' m1_e_`s' m1_f_`s' 	   ///
	   m1_g_`s' m1_h_`s'												   ///
	using "impact_allshocks_allcty.tex", 		           				   ///
    b(3) se(3) keep(shock_illnss)  star(* 0.1 ** 0.05 *** 0.01)            ///
    coeflabels(shock_illnss "Health Shock")           				       ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %3.2f)) 				   ///
    label nonotes fragment append nonumber 					   			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} ")			   ///
	posthead(" ") postfoot("\hline \hline")

local s criminality 
esttab m1_k_`s' m1_a_`s'  m1_b_`s' m1_c_`s' m1_d_`s' m1_e_`s' m1_f_`s' 	   ///
	   m1_g_`s' m1_h_`s'												   ///
	using "impact_allshocks_allcty.tex", 		           				   ///
    b(3) se(3) keep(shock_criminality) star(* 0.1 ** 0.05 *** 0.01) 	   ///
	fragment append nonum										   		   ///
    coeflabels(shock_criminality "Crime Shock") 				   		   ///
	stats(N r2 year_FE cty_FE zone_FE, 							   	       ///
	label("Obs." "\$R^2\$"								   	   			   ///
		  "\hline Country FE" "Year FE" "Rural/Urban Dummy")     		   ///
	fmt(%9.0fc %4.3f)) substitute("\_" "_")       					   	   /// 
	prefoot("\hline") postfoot("\bottomrule \end{tabular}") 			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} ")			   ///
	posthead(" ")
			
* ---------------------------

cd "$projdir/out/allcty"

local t j

if "`t'" == "j" local end ctrls
if "`t'" == "k" local end ctrls_munife

local s any
esttab `t'1_k_`s' `t'1_a_`s' `t'1_b_`s' `t'1_c_`s' `t'1_d_`s' `t'1_e_`s'   ///
	   `t'1_f_`s' `t'1_g_`s' `t'1_h_`s'									   ///
	using "impact_allshocks_allcty_`end'.tex", 		           			   ///
	b(3) se(3) keep(shock_any)  star(* 0.1 ** 0.05 *** 0.01) 	  	   	   ///
	prehead("\begin{tabular}{l*{9}{c}} \hline\hline") 					   ///
    coeflabels(shock_any "Any Shock")       		   	   		   		   ///
    mgroups(" " " "												   	       ///
			"Spending Type"											       ///
			"Spending Source", 							   			   	   ///
            pattern(1 1 1 0 0 0 0 1 0) 									   ///
			prefix(\multicolumn{@span}{c}{) suffix(})   				   ///
	        span erepeat(\cmidrule(lr){@span}))                            ///
	mtitles("Income" 						   							   /// 
			"Spending" 		   			   							       ///
			"\hspace{1em} Food \hspace{1em} " "Personal" 				   ///
			"\hspace{1em} Health \hspace{1em} " 		   				   ///
			"Durables" " Leisure"							   			   ///
			"Purchases" "Gifts/Transfers")         						   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
	nonotes fragment replace postfoot("\hline \hline ") 				   ///
	posthead("\cmidrule(lr){2-10}")										   ///

local s natdisast 
esttab `t'1_k_`s' `t'1_a_`s' `t'1_b_`s' `t'1_c_`s' `t'1_d_`s' `t'1_e_`s'   ///
	   `t'1_f_`s' `t'1_g_`s' `t'1_h_`s'									   ///
	using "impact_allshocks_allcty_`end'.tex", 		           			   ///
    b(3) se(3) keep(shock_natdisast)  star(* 0.1 ** 0.05 *** 0.01)         ///
    coeflabels(shock_natdisast "Weather Shock")           				   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
    label nonotes fragment append nonumber 					   			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} ")			   ///
	posthead(" ") postfoot("\hline \hline")

local s lostjob 
esttab `t'1_k_`s' `t'1_a_`s' `t'1_b_`s' `t'1_c_`s' `t'1_d_`s' `t'1_e_`s'   ///
	   `t'1_f_`s' `t'1_g_`s' `t'1_h_`s'									   ///
	using "impact_allshocks_allcty_`end'.tex", 		           			   ///
    b(3) se(3) keep(shock_lostjob)  star(* 0.1 ** 0.05 *** 0.01)           ///
    coeflabels(shock_lostjob "Employment Shock")           				   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
    label nonotes fragment append nonumber 					   			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} ")			   ///
	posthead(" ") postfoot("\hline \hline")

local s illnss 
esttab `t'1_k_`s' `t'1_a_`s' `t'1_b_`s' `t'1_c_`s' `t'1_d_`s' `t'1_e_`s'   ///
	   `t'1_f_`s' `t'1_g_`s' `t'1_h_`s'									   ///
	using "impact_allshocks_allcty_`end'.tex", 		           			   ///
    b(3) se(3) keep(shock_illnss)  star(* 0.1 ** 0.05 *** 0.01)            ///
    coeflabels(shock_illnss "Health Shock")           				       ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
    label nonotes fragment append nonumber 					   			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} ")			   ///
	posthead(" ") postfoot("\hline \hline")

local s criminality 
esttab `t'1_k_`s' `t'1_a_`s' `t'1_b_`s' `t'1_c_`s' `t'1_d_`s' `t'1_e_`s'   ///
	   `t'1_f_`s' `t'1_g_`s' `t'1_h_`s'									   ///
	using "impact_allshocks_allcty_`end'.tex", 		           			   ///
    b(3) se(3) keep(shock_criminality) star(* 0.1 ** 0.05 *** 0.01) 	   ///
	fragment append nonum										   		   ///
    coeflabels(shock_criminality "Crime Shock") 				   		   ///
	stats(N r2 ctrls year_FE cty_FE zone_FE, 					   	       ///
	label("Obs." "\$R^2\$"								   	   			   ///
		  "\hline Baseline Controls" "Country FE" 						   ///
		  "Year FE" "Rural/Urban Dummy")     		   					   ///
	fmt(%9.0fc %4.3f)) substitute("\_" "_")       					   	   ///
	prefoot("\hline") postfoot("\bottomrule \end{tabular}") 			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} " 			   ///
			"\hspace{4em} " "\hspace{4em} " "\hspace{4em} ")			   ///
	posthead(" ")

* ---------------------------

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


cd "$projdir/out/allcty"

local t j

if "`t'" == "j" local end ctrls
if "`t'" == "k" local end ctrls_munife

local s any
esttab `t'1_i_`s' `t'1_l_`s' `t'1_j_`s' `t'1_m_`s'						   ///
	using "impact_allshocks_allcty_coping_`end'.tex", 		           	   ///
	b(3) se(3) keep(shock_any)  star(* 0.1 ** 0.05 *** 0.01) 	  	   	   ///
	prehead("\begin{tabular}{l*{4}{c}} \hline\hline") 					   ///
    coeflabels(shock_any "Any Shock")       		   	   		   		   ///
	mtitles("\shortstack{Household \\ Has Debts}" 						   /// 
			"\shortstack{Receives Govt. \\ Benefits}" 		   			   ///
			"\shortstack{Household \\ Migrates}"						   ///
			"\shortstack{All Underage hh \\ Members in School}")           ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
	nonotes fragment replace postfoot("\hline \hline ") 				   ///
	posthead("\cmidrule(lr){2-5}")										   

local s natdisast 
esttab `t'1_i_`s' `t'1_l_`s' `t'1_j_`s' `t'1_m_`s'						   ///
	using "impact_allshocks_allcty_coping_`end'.tex", 		           	   ///
    b(3) se(3) keep(shock_natdisast)  star(* 0.1 ** 0.05 *** 0.01)         ///
    coeflabels(shock_natdisast "Weather Shock")           				   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
    label nonotes fragment append nonumber 					   			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " 							   ///
			"\hspace{4em} " "\hspace{4em} ")			   				   ///
	posthead(" ") postfoot("\hline \hline")

local s lostjob 
esttab `t'1_i_`s' `t'1_l_`s' `t'1_j_`s' `t'1_m_`s'						   ///
	using "impact_allshocks_allcty_coping_`end'.tex", 		           	   ///
    b(3) se(3) keep(shock_lostjob)  star(* 0.1 ** 0.05 *** 0.01)           ///
    coeflabels(shock_lostjob "Employment Shock")           				   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
    label nonotes fragment append nonumber 					   			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " 							   ///
			"\hspace{4em} " "\hspace{4em} ")			   				   ///
	posthead(" ") postfoot("\hline \hline")

local s illnss 
esttab `t'1_i_`s' `t'1_l_`s' `t'1_j_`s' `t'1_m_`s'						   ///
	using "impact_allshocks_allcty_coping_`end'.tex", 		           	   ///
    b(3) se(3) keep(shock_illnss)  star(* 0.1 ** 0.05 *** 0.01)            ///
    coeflabels(shock_illnss "Health Shock")           				       ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %4.3f)) 				   ///
    label nonotes fragment append nonumber 					   			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " 							   ///
			"\hspace{4em} " "\hspace{4em} ")			   				   ///
	posthead(" ") postfoot("\hline \hline")

local s criminality 
esttab `t'1_i_`s' `t'1_l_`s' `t'1_j_`s' `t'1_m_`s'						   ///
	using "impact_allshocks_allcty_coping_`end'.tex", 		           	   ///
    b(3) se(3) keep(shock_criminality) star(* 0.1 ** 0.05 *** 0.01) 	   ///
	fragment append nonum										   		   ///
    coeflabels(shock_criminality "Crime Shock") 				   		   ///
	stats(N r2 ctrls year_FE cty_FE zone_FE, 					   	       ///
	label("Obs." "\$R^2\$"								   	   			   ///
		  "\hline Baseline Controls" "Country FE" 						   ///
		  "Year FE" "Rural/Urban Dummy")     		   					   ///
	fmt(%9.0fc %4.3f)) substitute("\_" "_")       					   	   ///
	prefoot("\hline") postfoot("\bottomrule \end{tabular}") 			   ///
	mtitles("\hspace{4em} " "\hspace{4em} " 							   ///
			"\hspace{4em} " "\hspace{4em} ")			   				   ///
	posthead(" ")

/*
* Check:
reghdfe diffcons shock_any, 			   ///
					absorb(cty year rural_baseline) cluster(admincode)

	local ctrl hhead_female_baseline singleheaded_baseline 				   ///
			   share_hh_female_baseline share_hh_old_baseline 			   ///
			   share_hh_young_baseline hhead_educ_baseline 				   ///
			   distance_to_sea_km_baseline poverty_rate_tot_baseline 	   ///
			   rate_nohealthaccess_baseline

reghdfe diffcons shock_any `ctrl', 			   ///
					absorb(cty year rural_baseline) cluster(admincode)

reghdfe diffcons shock_natdisast, 			   ///
					absorb(cty year rural_baseline) cluster(admincode)
			
reghdfe diffcons shock_lostjob, 			   ///
					absorb(cty year rural_baseline) cluster(admincode)

reghdfe diffcons shock_illnss, 			   ///
					absorb(cty year rural_baseline) cluster(admincode)

reghdfe diffcons shock_criminality, 			   ///
					absorb(cty year rural_baseline) cluster(admincode)

* -----------------------------------------------


reghdfe diffmigrante shock_any##exp_pc_q_baseline, 			   ///
					absorb(cty year rural_baseline) cluster(admincode) 

reghdfe diffmigrante shock_natdisast##exp_pc_q_baseline, 			   ///
					absorb(cty year rural_baseline) cluster(admincode)

lincom 1.shock_natdisast 
lincom 1.shock_natdisast + 1.shock_natdisast#2.exp_pc_q_baseline
lincom 1.shock_natdisast + 1.shock_natdisast#3.exp_pc_q_baseline
lincom 1.shock_natdisast + 1.shock_natdisast#4.exp_pc_q_baseline
lincom 1.shock_natdisast + 1.shock_natdisast#5.exp_pc_q_baseline


reghdfe diffmigrante shock_lostjob##exp_pc_q_baseline, 			   ///
					absorb(cty year rural_baseline) cluster(admincode)

reghdfe diffmigrante shock_illnss##exp_pc_q_baseline, 			   ///
					absorb(cty year rural_baseline) cluster(admincode)

reghdfe diffmigrante shock_criminality##exp_pc_q_baseline, 			   ///
					absorb(cty year rural_baseline) cluster(admincode)

* -------------------------------------------------------------------

