* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Import FAO-DIEM data and aggregate at region level

* ---------------------------
* 2023: 

cd "$projdir/dta/src"

/*

local lngname DIEM_household_surveys_microdata_-8076258325030754197_all2023
import delimited using "FAODIEM/`lngname'", clear // bulk download 2023
												  // all countries
												  // all variables
												
save "$projdir/dta/src/FAODIEM/allpublic2023.dta", replace


*/

use "$projdir/dta/src/FAODIEM/allpublic2023.dta", clear

gen region = "SSA"
replace region = "SAR" if inlist(adm0_name, "Afghanistan", "Bangladesh")
replace region = "LAC" if inlist(adm0_name, "Colombia", "Guatemala", "Haiti", "Honduras")
replace region = "MENA" if inlist(adm0_name, "Iraq", "Lebanon", "Pakistan", "Palestine", "Yemen")
replace region = "EAP" if inlist(adm0_name, "Myanmar")

replace region = "SAR-EAP" if inlist(region, "SAR", "EAP")

// survey date
gen double datetime = clock(survey_date, "MDYhms")
gen round_date = dofc(datetime)
format round_date %td
gen round_month = month(round_date)
gen round_year  = year(round_date)
//


keep round round_* objectid survey_id shock_* weight_final region adm0_name

gen allshockmiss = 1 
gen check = 0

// rename shock_noshock ashock_noshock

unab shockv: shock_*
local noshock shock_noshock 
local shockvars: list shockv - noshock



foreach var of local shockvars {
	display "`var'"
	replace allshockmiss = 0 if `var' != .
	replace check = check + `var'
}

drop if allshockmiss == 1 // 0 obs
gen     noshock = check == 0
drop if  noshock != shock_noshock 

* Aggregate shocks into 4 main categories

gen shock_accident_illnss = shock_sicknessordeathofhh

gen shock_lostjob 	      = shock_lostemplorwork > 0

gen shock_natdisast 	  = (shock_coldtemporhail + shock_flood +  		   ///
				      		 shock_hurricane + shock_drought +   		   ///
					  		 shock_earthquake + shock_landslides  + 	   ///
					  		 shock_firenatural + shock_othernathazard) > 0

gen shock_criminality     = (shock_violenceinsecconf + 					   ///
							 shock_theftofprodassets + shock_firemanmade) > 0	

gen shock_any = inlist(1, shock_accident_illnss, shock_lostjob, 		   ///
						  shock_natdisast, shock_criminality)

keep adm0_name region round round_date shock_accident_illnss shock_lostjob ///
	 shock_natdisast shock_criminality shock_any weight_final

gen yq = yq(year(round_date), quarter(round_date))
format yq %tq

foreach v in shock_accident_illnss shock_lostjob 						   ///
			 shock_natdisast shock_criminality shock_any {

	bys adm0_name region round: 										   ///
		egen mean_`v' = wtmean(`v'), weight(weight_final)
}

foreach v in shock_accident_illnss shock_lostjob 						   ///
			 shock_natdisast shock_criminality shock_any {

	bys region yq: egen regmean_`v' = wtmean(`v'), weight(weight_final)

	drop `v'
}

bys adm0_name region round: egen med_date = median(round_date)

bys adm0_name region round: keep if _n == 1

format med_date %td

bys region adm0_name: gen group_order = _n

tempfile all23
save `all23'

/*

cd "$projdir/dta/src"

local lngname2 Household_Surveys_Microdata_6215924197953569388_all2122
import delimited using "FAODIEM/`lngname2'", clear // bulk download 2022-2021
												   // all countries
												   // all variables

												
save "$projdir/dta/src/FAODIEM/allpublic2122.dta", replace

*/

use "$projdir/dta/src/FAODIEM/allpublic2122.dta", clear

rename admin0name adm0_name 

gen region = "SSA"
replace region = "SAR" if inlist(adm0_name, "Afghanistan", "Bangladesh")
replace region = "LAC" if inlist(adm0_name, "Colombia", "Guatemala", "Haiti", "Honduras")
replace region = "MENA" if inlist(adm0_name, "Iraq", "Lebanon", "Pakistan", "Palestine", "Yemen")
replace region = "EAP" if inlist(adm0_name, "Myanmar")

replace region = "SAR-EAP" if inlist(region, "SAR", "EAP")

// survey date:
gen double datetime = clock(survey_date, "MDYhms")
gen round_date = dofc(datetime)
format round_date %td
gen round_month = month(round_date)
gen round_year  = year(round_date)
//

keep round round_* objectid survey_id hhnotimpacted* hhshock*   	 	   ///
	 otherintrahhshock othereconomichhshock otherhhshockcroplivestock 	   ///
	 weight_final adm0_name region

gen allshockmiss = 1 
gen check = 0

foreach var of varlist hhshock* otherintrahhshock othereconomichhshock 	   ///
					   otherhhshockcroplivestock {

	replace allshockmiss = 0 if `var' != .
	replace check = check + `var'
}

drop if allshockmiss == 1 // 14 obs
gen noshock = check == 0
drop if noshock != hhnotimpactedbyshocks 

rename noshock shock_noshock

rename hhshock* shock_*

rename otherintrahhshock    shock_otherintra
rename othereconomichhshock shock_otherecon
rename otherhhshockcroplivestock shock_othercropls

rename shock_bccoldtemp    			   shock_coldtemporhail
rename shock_bchigherfoodp 			   shock_higherfoodprices
rename shock_bchigherfuelp   		   shock_higherfuelprices
rename shock_fireman   	   			   shock_firemanmade
rename shock_lostjoborworkopportunity  shock_lostemplorwork
rename shock_refusal 				   shock_ref
rename shock_sicknessoraccidentordeath shock_sicknessordeathofhh 
rename shock_othermanhazard 		   shock_othermanmadehazard
rename shock_otherintra 			   shock_otherintrahhshock
rename shock_othercropls			   shock_othercropandlivests
rename shock_otherecon				   shock_othereconomicshock
rename shock_noaccesspasture		   shock_napasture
rename shock_notaware				   shock_dk 
rename shock_cantworkordobusiness      shock_mvtrestrict 

drop check allshockmiss hhnotimpactedbyshocks hhnotimpactedbycovid 

drop if inlist(1, shock_dk, shock_ref) // dont know / refuse to answer (54 obs)


* Aggregate shocks into 4 main categories

gen shock_accident_illnss = shock_sicknessordeathofhh

gen shock_lostjob 	      = shock_lostemplorwork > 0

gen shock_natdisast 	  = (shock_coldtemporhail + shock_flood +  		   ///
				      		 shock_hurricane + shock_drought +   		   ///
					  		 shock_earthquake + shock_landslides  + 	   ///
					  		 shock_firenatural + shock_othernathazard) > 0

gen shock_criminality     = (shock_violenceinsecconf + 					   ///
							 shock_theftofprodassets + shock_firemanmade) > 0	

gen shock_any = inlist(1, shock_accident_illnss, shock_lostjob, 		   ///
						  shock_natdisast, shock_criminality)

keep adm0_name region round round_date shock_accident_illnss shock_lostjob ///
	 shock_natdisast shock_criminality shock_any weight_final

gen yq = yq(year(round_date), quarter(round_date))
format yq %tq

foreach v in shock_accident_illnss shock_lostjob 						   ///
			 shock_natdisast shock_criminality shock_any {

	bys adm0_name region round: 										   ///
		egen mean_`v' = wtmean(`v'), weight(weight_final)
}

bys adm0_name region round: egen med_date = median(round_date)

foreach v in shock_accident_illnss shock_lostjob 						   ///
			 shock_natdisast shock_criminality shock_any {

	bys region yq: egen regmean_`v' = wtmean(`v'), weight(weight_final)

	drop `v'
}

bys adm0_name region round: keep if _n == 1

format med_date %td

gen dta = "2122"

drop if yq == 252 // 2023q1 
drop if yq == 253 // 2023q2 
drop if yq == 254 // 2023q3 

append using `all23'

drop if yq == 251 & dta != "2122" // 2022q4

egen region_id = group(region)
egen cty_id = group()
save "$projdir/dta/cln/FAODIEM_COL/allcty_incidence_yq.dta", replace

* -----------------

use "$projdir/dta/cln/FAODIEM_COL/allcty_incidence_yq.dta", clear

gen yqd = dofq(yq) 

format yqd %td

local s msize(1.5)

sort region yqd

twoway ///
scatter mean_shock_any med_date if region == "LAC", color(stc1%15) ||  ///
scatter mean_shock_any med_date if region == "SAR-EAP", color(stc2%15) ||  ///
scatter mean_shock_any med_date if region == "MENA",color(stc3%15) ||  ///
scatter mean_shock_any med_date if region == "SSA", color(stc4%15) ||   ///
/*scatter mean_shock_any med_date if region == "EAP", color(stc5%15) ||*/  ///
///
connected regmean_shock_any yqd if region == "LAC", color(stc1%70) `s'  || ///
connected regmean_shock_any yqd if region == "SAR-EAP", color(stc2%70) `s'  || ///
connected regmean_shock_any yqd if region == "MENA", color(stc3%70) `s' || ///
connected regmean_shock_any yqd if region == "SSA", color(stc4%70) `s'   ///
/*connected regmean_shock_any yqd if region == "EAP", color(stc5%70) `s'*/     ///
legend(order(5 "LAC" 6 "SAR-EAP" 7 "MENA" 8 "SSA")) xtitle("") ///
subtitle("Any Shock") ytitle("Quarterly incidence")
 
cd "$projdir/out/faodiem"
graph export "faodiem_incidence_allcty_anyshock_yq.png", replace

sort region yqd
local s msize(1.5)

twoway ///
scatter mean_shock_natdisas med_date if region == "LAC", color(stc1%15) || ///
scatter mean_shock_natdisas med_date if region == "SAR-EAP", color(stc2%15) || ///
scatter mean_shock_natdisas med_date if region == "MENA",color(stc3%15) || ///
scatter mean_shock_natdisas med_date if region == "SSA", color(stc4%15) || ///
///
connected regmean_shock_natd yqd if region == "LAC", color(stc1%70) `s' || ///
connected regmean_shock_natd yqd if region == "SAR-EAP", color(stc2%70) `s'|| ///
connected regmean_shock_natd yqd if region == "MENA", color(stc3%70) `s' || ///
connected regmean_shock_natd yqd if region == "SSA", color(stc4%70) `s'  ///
legend(order(5 "LAC" 6 "SAR-EAP" 7 "MENA" 8 "SSA")) ///
text(0.8 23410 "HTI") xtitle("") ///
subtitle("Natural Disaster") ytitle("Quarterly incidence")

cd "$projdir/out/faodiem"
graph export "faodiem_incidence_allcty_natdisast_yq.png", replace

sort region yqd
local s msize(1.5)

twoway ///
scatter mean_shock_lostjob med_date if region == "LAC", color(stc1%15) ||  ///
scatter mean_shock_lostjob med_date if region == "SAR-EAP", color(stc2%15) ||  ///
scatter mean_shock_lostjob med_date if region == "MENA",color(stc3%15) ||  ///
scatter mean_shock_lostjob med_date if region == "SSA", color(stc4%15) ||  ///
///
connected regmean_shock_lostj yqd if region == "LAC", color(stc1%70) `s' || ///
connected regmean_shock_lostj yqd if region == "SAR-EAP", color(stc2%70) `s'|| ///
connected regmean_shock_lostj yqd if region == "MENA", color(stc3%70) `s' || ///
connected regmean_shock_lostj yqd if region == "SSA", color(stc4%70) `s'  ///
legend(order(5 "LAC" 6 "SAR-EAP" 7 "MENA" 8 "SSA"))  xtitle("") ///
subtitle("Employment") ytitle("Quarterly incidence")

cd "$projdir/out/faodiem"
graph export "faodiem_incidence_allcty_lostjob_yq.png", replace

sort region yqd
local s msize(1.5)

twoway ///
scatter mean_shock_accid med_date if region == "LAC", color(stc1%20) ||    ///
scatter mean_shock_accid med_date if region == "SAR-EAP",color(stc2%20) || ///
scatter mean_shock_accid med_date if region == "MENA",color(stc3%20) ||    ///
scatter mean_shock_accid med_date if region == "SSA", color(stc4%20) ||    ///
///
connected regmean_shock_acci yqd if region == "LAC", color(stc1%70) `s' || ///
connected regmean_shock_acci yqd if region == "SAR-EAP",color(stc2%70) `s'|| ///
connected regmean_shock_acci  yqd if region == "MENA", color(stc3%70) `s' || ///
connected regmean_shock_acci  yqd if region == "SSA", color(stc4%70) `s'  ///
legend(order(5 "LAC" 6 "SAR-EAP" 7 "MENA" 8 "SSA"))  xtitle("") ///
subtitle("Health") ytitle("Quarterly incidence")

cd "$projdir/out/faodiem"
graph export "faodiem_incidence_allcty_accident-illness_yq.png", replace

sort region yqd
local s msize(1.5)

sort yqd

keep if yq >= 247 
keep if mean_shock_crim < 0.6 

twoway ///
scatter mean_shock_crim med_date if region == "LAC", color(stc1%20) ||     ///
scatter mean_shock_crim med_date if region == "SAR-EAP", color(stc2%20) || ///
scatter mean_shock_crim med_date if region == "MENA",color(stc3%20) ||     ///
scatter mean_shock_crim med_date if region == "SSA", color(stc4%20) ||     ///
///
connected regmean_shock_crim yqd if region == "LAC", color(stc1%70) `s'  || ///
connected regmean_shock_cr yqd if region == "SAR-EAP", color(stc2%70) `s'|| ///
connected regmean_shock_crim yqd if region == "MENA", color(stc3%70) `s' || ///
connected regmean_shock_crim yqd if region == "SSA", color(stc4%70) `s'     ///
legend(order(5 "LAC" 6 "SAR-EAP" 7 "MENA" 8 "SSA"))  xtitle("") 		    ///
text(0.48 23410 "HTI") ///
subtitle("Criminality") ytitle("Quarterly incidence")

cd "$projdir/out/faodiem"
graph export "faodiem_incidence_allcty_criminality_yq.png", replace

* -------------------------------------------------------------------