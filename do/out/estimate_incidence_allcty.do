* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Estimate correlation between shock incidence and 
* baseline household characteristics

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

replace cty = "COL" if cty == ""

cd "$projdir/dta/cln/ENNVIH"
append using "ennvih_hhpanel_02_05_09.dta" 

replace cty = "MEX" if cty == ""

cd "$projdir/dta/cln/LTSLV"
append using "ltslv_hhpanel_11_13.dta" 

replace cty = "SLV" if cty == ""

cd "$projdir/dta/cln/FAODIEM_HTI"
append using "faodiem_HTI_hhpanel_r3r6.dta" 

replace cty = "HTI" if cty == ""

gen date = dofy(year)

bys round: egen med_date = median(round_date)

replace date = med_date if year == .

gen yq = qofd(date)
format yq %tq
sort yq cty

tab yq cty

rename shock_accident_illnss shock_health 

gen percses_baseline = percexp_baseline 

replace percses_baseline = percinc_baseline if percexp_baseline == . 

drop if  percses_baseline == .

* Express all in 2016 dollars:

foreach var of varlist percses_baseline {
    
    replace `var' = `var' * 1000 if cty == "SLV" // Really need to check this
    replace `var' = (`var' / 57.210) * 4 if cty == "HTI" // make yearly
    replace `var' = (`var' / 3.307)  if cty == "PER" 
	replace `var' = `var' / 17.35290 if cty == "MEX"
	replace `var' = `var' / 3149.47  if cty == "COL"
}

keep cty yq                                                                ///
     shock_any shock_lostjob shock_health shock_natdisast shock_crim       ///
     percses* rural* hhead_female* singleheaded*                           ///
     share_hh_female* share_hh_old* share_hh_young* hhead_educ*            ///
     distance_to_sea_km* poverty_rate_tot* rate_nohealthaccess*			   ///
	 admincode hhid

egen hid = group(cty hhid)

replace rural_baseline = 1 if cty == "HTI"
replace rural_baseline = 0 if cty == "SLV"

gen logpercses_baseline = log(percses_baseline)

gen hhead_somecolmore_baseline = inlist(hhead_educ_baseline, 3, 4)  
replace hhead_somecolmore_baseline = . if hhead_educ_baseline == .

gen logdist_tosea_baseline = log(distance_to_sea_km_baseline)

replace poverty_rate_tot_baseline = poverty_rate_tot_baseline / 100

egen cty_id =group(cty)

* Balance table between shock no shock:

label var rural_baseline "Rural"
label var percses_baseline "Consumption per capita"
label var hhead_female_baseline "Female household head"
label var singleheaded_baseline "Single-headed household"
label var share_hh_female_baseline "Share of household female (%)"
label var share_hh_old_baseline "Share of household over 65 (%)"
label var share_hh_young_baseline "Share of household under 15 (%)"
label var hhead_educ_baseline "Household head has college"
label var distance_to_sea_km_baseline "Distance to sea (km)"
label var poverty_rate_tot_baseline "Municipal poverty rate (%)"
label var rate_nohealthaccess_baseline "Munic. pop. without health access (%)"

cd "$projdir/out/allcty/"
iebaltab rural_baseline percses_baseline hhead_female_baseline 			   ///
		 singleheaded_baseline 	   										   ///
		 share_hh_female_baseline share_hh_old_baseline 				   ///	
		 share_hh_young_baseline hhead_educ_baseline 					   ///
		  poverty_rate_tot_baseline 			   						   ///
		 rate_nohealthaccess_baseline distance_to_sea_km_baseline, 		   ///
		 grpvar(shock_any) order(1 0) 		 							   ///
		 savetex("balance_table_shock_any_allcty.tex") tblnonote		   ///
		 rowvarlabels replace grplabels(1 "Shock" 0 "No Shock")
		 
* -------------------------------------

* Est sample: 

reg shock_any logpercses_baseline i.cty_id i.yq rural_baseline,r

/* 
  Obs:
        cty |      Freq.     Percent        Cum.
------------+-----------------------------------
        COL |     18,003       31.88       31.88
        HTI |      1,373        2.43       34.31
        MEX |     15,001       26.56       60.87
        PER |     20,336       36.01       96.89
        SLV |      1,759        3.11      100.00
------------+-----------------------------------
      Total |     56,472      100.00

  HHs:
        cty |      Freq.     
------------+-----------------------------------
        COL |      9,608       
        HTI |      1,162        
        MEX |      8,175       
        PER |     20,336      
        SLV |      1,759       
------------+-----------------------------------
      Total |      41,040   
*/

* -------------------------------------

local i = 1
foreach var in logpercses hhead_female singleheaded                        ///
               share_hh_female share_hh_old share_hh_young                 ///
               hhead_somecolmore poverty_rate_tot                		   ///
                rate_nohealthaccess logdist_tosea {

    * Run regressions and store estimates
    eststo m`i': reg shock_any `var'_baseline,r
    estadd local cty_FE "No"
    estadd local year_FE "No"
    estadd local zone_FE "No"
    local i = `i' + 1

    eststo m`i': reg shock_any `var'_baseline i.cty_id i.yq,r
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "No"
    local i = `i' + 1

    eststo m`i': reg shock_any `var'_baseline i.cty_id i.yq rural_baseline,r
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "Yes"
    local i = `i' + 1

    eststo m`i': reg shock_any `var'_baseline i.cty_id i.yq                ///
                                if rural_baseline == 0, r
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "No"
    local i = `i' + 1

    eststo m`i': reg shock_any `var'_baseline i.cty_id i.yq                ///
                                if rural_baseline == 1,r
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "No"
    local i = `i' + 1
}
display "`i'"
* -----------------------------------------------

* Suppress coefficients m2 and m3 so they show up as (-)

local pa Panel A: Household Characteristics
local pb Panel B: Municipality Characteristics

cd "$projdir/out/allcty"
esttab m1 m2 m3 m4 m5 using "prob_anyshock_hhchars.tex", 		           ///
    b(3) se(3) keep(logpercses_baseline)  star(* 0.1 ** 0.05 *** 0.01) 	   ///
	prehead("\begin{tabular}{l*{5}{c}} \hline\hline") 					   ///
	posthead("\hline \\ \multicolumn{5}{l}{\emph{`pa'}} \\") 	   		   ///
    coeflabels(logpercses_baseline "Log Consumption")       		   	   ///
    mgroups("Any shock" "\shortstack{Any shock \\ Urban}" 				   ///
			"\shortstack{Any shock \\ Rural}",           				   ///
            pattern(1 0 0 1 1) prefix(\multicolumn{@span}{c}{) suffix(})   ///
	        span erepeat(\cmidrule(lr){@span}))                            /// 
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")               	   ///
	label nonotes fragment nomtitle replace sfmt(%4.0fc %3.2fc)

cd "$projdir/out/allcty"
esttab m6 m7 m8 m9 m10 using "prob_anyshock_hhchars.tex", 		           ///
    b(3) se(3) keep(hhead_female_baseline)  star(* 0.1 ** 0.05 *** 0.01)   ///
    coeflabels(hhead_female_baseline "Female Household Head")              ///
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")           		   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab m11 m12 m13 m14 m15 using "prob_anyshock_hhchars.tex", 		       ///
    b(3) se(3) keep(singleheaded_baseline)  star(* 0.1 ** 0.05 *** 0.01)   ///
    coeflabels(singleheaded_baseline "Single-headed Household")            ///
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")             	   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab m16 m17 m18 m19 m20 using "prob_anyshock_hhchars.tex", 		       ///
    b(3) se(3) keep(share_hh_female_baseline) star(* 0.1 ** 0.05 *** 0.01) ///
    coeflabels(share_hh_female_baseline "\% household Female")       	   ///
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")               	   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab m21 m22 m23 m24 m25 using "prob_anyshock_hhchars.tex", 		       ///
    b(3) se(3) keep(share_hh_old_baseline)  star(* 0.1 ** 0.05 *** 0.01)   ///
    coeflabels(share_hh_old_baseline "\% household over 65")       	   	   ///
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")               	   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab m26 m27 m28 m29 m30 using "prob_anyshock_hhchars.tex", 		       ///
    b(3) se(3) keep(share_hh_young_baseline)  star(* 0.1 ** 0.05 *** 0.01) ///
    coeflabels(share_hh_young_baseline "\% household under 15")       	   ///
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")               	   ///
    label nonotes fragment nomtitle append nonumber 					   ///  
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab m31 m32 m33 m34 m35 using "prob_anyshock_hhchars.tex", 		       ///
    b(3) se(3) keep(hhead_somecolmore_baseline) 						   ///
	star(* 0.1 ** 0.05 *** 0.01) 										   ///
    coeflabels(hhead_somecolmore_baseline "Household head has college")    ///
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")               	   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline") postfoot("\hline")					   

cd "$projdir/out/allcty"
esttab m36 m37 m38 m39 m40 using "prob_anyshock_hhchars.tex", 		       ///
    b(3) se(3) keep(poverty_rate_tot_baseline) 							   ///
	star(* 0.1 ** 0.05 *** 0.01) 										   ///
	posthead("\hline \multicolumn{5}{l}{\emph{`pb'}} \\\\[-2ex]") 	   	   ///
    coeflabels(poverty_rate_tot_baseline "Poverty rate (\%)")       	   ///
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")               	   ///
    label nonotes fragment nomtitle append nonumber

cd "$projdir/out/allcty"
esttab m41 m42 m43 m44 m45 using "prob_anyshock_hhchars.tex", 		       ///
    b(3) se(3) keep(rate_nohealthaccess_baseline)  						   ///
	star(* 0.1 ** 0.05 *** 0.01) 										   ///
    coeflabels(rate_nohealthaccess_baseline 						   	   ///
			   "\% pop. with low health access")       	   				   ///
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")               	   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab m46 m47 m48 m49 m50 using "prob_anyshock_hhchars.tex", 		       ///
    b(3) se(3) keep(logdist_tosea_baseline)  						   	   ///
	star(* 0.1 ** 0.05 *** 0.01) 	   									   ///
	fragment append nomtitles nonum										   ///
    coeflabels(logdist_tosea_baseline 							   	  	   ///
			   "Distance to sea") 				   		   			   	   ///
	scalars("N Obs." "r2 \$R^2\$"                             	   		   ///
			"cty_FE County FE" "year_FE Year FE" 						   ///
			"zone_FE Rural/Urban Dummy")  								   ///
		substitute("\_" "_")       										   /// 
	prefoot("\hline") postfoot("\hline \hline \end{tabular}") 			   ///
	posthead("\hline \hline")

* ---------------------------------------------------------

foreach var in rural											   		   ///
			   logpercses hhead_female singleheaded                        ///
               share_hh_female share_hh_old share_hh_young                 ///
               hhead_somecolmore poverty_rate_tot                		   ///
               rate_nohealthaccess logdist_tosea {

	if "`var'" == "rural" local i = 101
	if "`var'" == "logpercses" local i = 1

	local r r 

	if inlist("`var'", "poverty_rate_tot", "rate_nohealthaccess", 		   ///
					   "logdist_tosea") {

		local r vce(cluster admincode)
	}

    * Run regressions and store estimates
    eststo n`i': reg shock_any `var'_baseline i.cty_id i.yq, `r'
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "Yes"
	estadd scalar N = e(N), replace
	estadd scalar r2 = e(r2), replace

    local i = `i' + 1

    eststo n`i': reg shock_natdisast `var'_baseline i.cty_id i.yq, `r'
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "Yes"
	estadd scalar N = e(N), replace
	estadd scalar r2 = e(r2), replace

    local i = `i' + 1

    eststo n`i': reg shock_health `var'_baseline i.cty_id i.yq, `r'
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "Yes"
	estadd scalar N = e(N), replace
	estadd scalar r2 = e(r2), replace

    local i = `i' + 1

    eststo n`i': reg shock_lostjob `var'_baseline i.cty_id i.yq, `r'
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "Yes"
	estadd scalar N = e(N), replace
	estadd scalar r2 = e(r2), replace

    local i = `i' + 1

    eststo n`i': reg shock_criminality `var'_baseline i.cty_id i.yq, `r'
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "Yes"
	estadd scalar N = e(N), replace
	estadd scalar r2 = e(r2), replace

    local i = `i' + 1

    eststo n`i': reg shock_any `var'_baseline i.cty_id i.yq                ///
                                if rural_baseline == 0, `r'
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "No"
	
	if "`var'" != "rural" {

		estadd scalar N = e(N), replace
		estadd scalar r2 = e(r2), replace
	}

	if "`var'" == "rural" {

		estadd local N "-", replace
		estadd local r2 "", replace
	}
	
    local i = `i' + 1

    eststo n`i': reg shock_any `var'_baseline i.cty_id i.yq                ///
                                if rural_baseline == 1, `r'
    estadd local cty_FE "Yes"
    estadd local year_FE "Yes"
    estadd local zone_FE "No"

	if "`var'" != "rural" {

		estadd scalar N = e(N), replace
		estadd scalar r2 = e(r2), replace
	}

	if "`var'" == "rural" {

		estadd local N "-", replace
		estadd local r2 "", replace
	}

	estadd local line 

    local i = `i' + 1
}

display "`i'"
* -----------------------------------------------


local pa Panel A: Household Characteristics
local pb Panel B: Municipality Characteristics

cd "$projdir/out/allcty"
esttab n101 n102 n103 n104 n105 n106 n107 								   ///
	using "prob_allshocks_hhchars.tex", 								   ///
    b(3) se(3) keep(rural_baseline)  star(* 0.1 ** 0.05 *** 0.01) 	  	   ///
	prehead("\begin{tabular}{l*{7}{c}} \hline\hline") 					   ///
	posthead("\multicolumn{7}{l}{\emph{`pa'}} \\") 	   		   			   ///
    coeflabels(rural_baseline "Rural household")       		   	   		   ///
    mgroups("Any shock" 												   ///
			"Climate" 													   ///
			"\hspace{1em}Health\hspace{1em} " 						   	   ///
			"Employment" 						   						   ///
			"\hspace{1em}Crime\hspace{1em} "   							   ///
			"\shortstack{Any shock \\ Urban}" 				  			   ///
			"\shortstack{Any shock \\ Rural}", 							   ///
            pattern(1 1 1 1 1 1 1) 										   ///
			prefix(\multicolumn{@span}{c}{) suffix(})   				   ///
	        span erepeat(\cmidrule(lr){@span}))                            /// 
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %3.2f)) 				   ///
	nonotes fragment nomtitle replace 			   						   ///
	substitute("0.000" "-" "(.)" " ") 

cd "$projdir/out/allcty"
esttab n1 n2 n3 n4 n5 n6 n7 using "prob_allshocks_hhchars.tex", 		   ///
    b(3) se(3) keep(logpercses_baseline)  star(* 0.1 ** 0.05 *** 0.01)     ///
    coeflabels(logpercses_baseline "Log consumption per capita")           ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %3.2f)) 				   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab n8 n9 n10 n11 n12 n13 n14 using "prob_allshocks_hhchars.tex", 	   ///
    b(3) se(3) keep(hhead_female_baseline)  star(* 0.1 ** 0.05 *** 0.01)   ///
    coeflabels(hhead_female_baseline "Female household head")              ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %3.2f)) 				   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab n15 n16 n17 n18 n19 n20 n21 using "prob_allshocks_hhchars.tex", 	   ///
    b(3) se(3) keep(singleheaded_baseline)  star(* 0.1 ** 0.05 *** 0.01)   ///
    coeflabels(singleheaded_baseline "Single-headed household")            ///
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")             	   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab n22 n23 n24 n25 n26 n27 n28 using "prob_allshocks_hhchars.tex", 	   ///
    b(3) se(3) keep(share_hh_female_baseline) star(* 0.1 ** 0.05 *** 0.01) ///
    coeflabels(share_hh_female_baseline "\% household female")       	   ///
	scalars("N Obs." "r2 \$R^2\$") substitute("\_" "_")               	   ///
    label nonotes fragment nomtitle append nonumber 				       ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab n29 n30 n31 n32 n33 n34 n35  using "prob_allshocks_hhchars.tex",    ///
    b(3) se(3) keep(share_hh_old_baseline)  star(* 0.1 ** 0.05 *** 0.01)   ///
    coeflabels(share_hh_old_baseline "\% household over 65")       	   	   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %3.2f)) 				   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab n36 n37 n38 n39 n40 n41 n42  using "prob_allshocks_hhchars.tex",    ///
    b(3) se(3) keep(share_hh_young_baseline)  star(* 0.1 ** 0.05 *** 0.01) ///
    coeflabels(share_hh_young_baseline "\% household under 15")       	   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %3.2f)) 				   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline")

cd "$projdir/out/allcty"
esttab n43 n44 n45 n46 n47 n48 n49  using "prob_allshocks_hhchars.tex",    ///
    b(3) se(3) keep(hhead_somecolmore_baseline)  						   ///
	star(* 0.1 ** 0.05 *** 0.01) 										   ///
    coeflabels(hhead_somecolmore_baseline "Household head has college")    ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %3.2f)) 				   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline") postfoot("\hline \hline")					   

* -----------
* Muni chars:

cd "$projdir/out/allcty"
esttab n50 n51 n52 n53 n54 n55 n56 using "prob_allshocks_hhchars.tex", 	   ///
    b(3) se(3) keep(poverty_rate_tot_baseline) 							   ///
	star(* 0.1 ** 0.05 *** 0.01) 										   ///
	posthead(" \multicolumn{7}{l}{\emph{`pb'}} \\ ") 	   			   	   ///
    coeflabels(poverty_rate_tot_baseline "Poverty rate")       	   		   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %3.2f)) 				   ///
    label nonotes fragment nomtitle append nonumber

cd "$projdir/out/allcty"
esttab n57 n58 n59 n60 n61 n62 n63 using "prob_allshocks_hhchars.tex", 	   ///
    b(3) se(3) keep(rate_nohealthaccess_baseline) 						   ///
	star(* 0.1 ** 0.05 *** 0.01) 										   ///
    coeflabels(rate_nohealthaccess_baseline 							   ///
			   "\% pop. without health access")       	   				   ///
	stats(N r2, label("Obs." "\$R^2\$") fmt(%9.0fc %3.2f)) 				   ///
    label nonotes fragment nomtitle append nonumber 					   ///
	posthead("\hline \hline") postfoot("\hline ")					   

cd "$projdir/out/allcty"
esttab n64 n65 n66 n67 n68 n69 n70 using "prob_allshocks_hhchars.tex", 	   ///
    b(3) se(3) keep(logdist_tosea_baseline)  						   	   ///
	star(* 0.1 ** 0.05 *** 0.01) 	   									   ///
	fragment append nomtitles nonum										   ///
    coeflabels(logdist_tosea_baseline 							   	  	   ///
			   "Log distance to sea") 				   		   			   ///
	stats(N r2  year_FE cty_FE zone_FE, 							   	   ///
	label("Obs." "\$R^2\$"								   	   			   ///
		  "\hline Country FE" "Year FE" "Rural/Urban Dummy")     		   ///
	fmt(%9.0fc %3.2f)) substitute("\_" "_")       					   	   /// 
	prefoot("\hline") postfoot("\bottomrule \end{tabular}") 

* -----------------------------------------------

coefplot n101 n1 n8 n15 n22 n29 n36 n43 n50 n57 n64,  					   ///
	keep(rural_baseline logpercses_baseline hhead_female_baseline 		   ///
		 singleheaded_baseline share_hh_female_baseline 				   ///
		 share_hh_old_baseline share_hh_young_baseline                 	   ///
         hhead_somecolmore_baseline poverty_rate_tot_baseline              ///
         rate_nohealthaccess_baseline logdist_tosea_baseline)			   ///
		legend(off) color(black%75 black%75 black%75 black%75 black%75 	   ///
						  black%75 black%75 black%75 black%75 black%75 	   ///
						  black%75) 									   ///
		ciopts(lcolor(black%75 black%75 black%75 black%75 black%75 	   	   ///
						  black%75 black%75 black%75 black%75 black%75 	   ///
						  black%75)) xline(0, lcolor(red%50))			   ///  
		coeflabels( 													   ///
			rural_baseline               =  "Rural household" 			   ///
			logpercses_baseline          =  "Log consumption per capita"   ///
			hhead_female_baseline        =  "Female household head" 	   ///
			singleheaded_baseline        =  "Single-headed household" 	   ///
			share_hh_female_baseline     =  "% household female" 		   ///
			share_hh_old_baseline        =  "% household over 65" 		   ///
			share_hh_young_baseline      =  "% household under 15" 		   ///
			hhead_somecolmore_baseline   =  "Household head has college"   ///
			poverty_rate_tot_baseline    =  "Poverty rate (%)" 			   ///
			rate_nohealthaccess_baseline = "% pop. without health access"  ///
			logdist_tosea_baseline       = "Log distance to sea")		   ///
		headings(														   ///
			rural_baseline = "{bf: Household Characteristics}"        	   ///
			poverty_rate_tot_baseline = "{bf: Municipal Characteristics}") ///
		xtitle("Prob. of Household Reporting Any Shock")

cd "$projdir/out/allcty/"
graph export "coefplot_prob_anyshock_hhchars.png", replace

* -------------------------------------------------------------------
