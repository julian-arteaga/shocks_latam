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

//merge 1:1 llave_n16 using "vars_elca_private.dta"
// drop if _merge != 3
//drop _merge 

//rename consumo_total_pc* consumo_total_pc_og* 
//drop consumo_total_pc* // update with new consumption dta

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
	 shock_any* cons_pc_q_* consumo_total_pc_*							   ///
	 /*familias_accion_2016 familias_accion_2010 familias_accion_2013	   ///
	 riqueza_pca_2010 riqueza_pca_2013 riqueza_pca_2016 				   ///
	 migrante_2016 migrante_2013*/ numperh_2016 numperh_2010 numperh_2013  ///
	 /*tiene_credito_2016 tiene_credito_2010 tiene_credito_2013*/		   ///
	 consumo_alimento_pc_* consumo_personal_pc_* consumo_educatio_pc_*     ///
	 consumo_durables_pc_* consumo_health_pc_* consumo_insuranc_pc_*       ///
	 consumo_leisure_pc_* consumo_purchased_pc_* consumo_transfers_pc_*    ///
	 consumo_selfcons_pc_* debts_dummy_* debts_value_pc_* debts_value*

reshape long rural_ shock_natdisast_ shock_accident_illnss_       		   ///
	 shock_lostjob_ shock_criminality_ shock_deathmember_ shock_bankrupcy_ ///	
	 shock_any_ cons_pc_q_ /*familias_accion_ riqueza_pca_ migrante_*/	   ///
	 consumo_total_pc_ numperh_ tiene_credito_ 							   ///
	 consumo_alimento_pc_ consumo_personal_pc_ consumo_educatio_pc_        ///
	 consumo_durables_pc_ consumo_health_pc_ consumo_insuranc_pc_          ///
	 consumo_leisure_pc_ consumo_purchased_pc_ consumo_transfers_pc_       ///
	 consumo_selfcons_pc_ debts_dummy_ debts_value_pc_ debts_value_, 	   ///
	 i(llave_n16) j(year)

sort llave_n16 year 

gen cons_pc_q_baseline = cons_pc_q[_n-1] if llave_n16 == llave_n16[_n-1]
gen rural_baseline = rural[_n-1] if llave_n16 == llave_n16[_n-1]

rename cons_pc_q_ cons_pc_q_contemp

format year %5.0f

rename *_ * 

xtset llave_n16 year

gen lcons = log(consumo_total_pc)

gen ldiffcons   = log(consumo_total_pc/L3.consumo_total_pc)
gen ldiffcons_ali = log(consumo_alimento_pc/L3.consumo_alimento_pc)
gen ldiffcons_per = log(consumo_personal_pc/L3.consumo_personal_pc)
gen ldiffcons_edu = log(consumo_educatio_pc/L3.consumo_educatio_pc)
gen ldiffcons_hlt = log(consumo_health_pc/L3.consumo_health_pc)
gen ldiffcons_dur = log(consumo_durables_pc/L3.consumo_durables_pc)
gen ldiffcons_ins = log(consumo_insuranc_pc/L3.consumo_insuranc_pc)
gen ldiffcons_lei = log(consumo_leisure_pc/L3.consumo_leisure_pc)

replace consumo_total_pc = consumo_total_pc * 1000000

gen diffcons     = (consumo_total_pc - L3.consumo_total_pc) // / L3.consumo_total_pc
gen diffcons_ali = (consumo_alimento_pc - L3.consumo_alimento_pc) // / L3.consumo_alimento_pc
gen diffcons_per = (consumo_personal_pc - L3.consumo_personal_pc) // / L3.consumo_personal_pc
gen diffcons_edu = (consumo_educatio_pc - L3.consumo_educatio_pc) // / L3.consumo_educatio_pc
gen diffcons_hlt = (consumo_health_pc - L3.consumo_health_pc) // / L3.consumo_health_pc
gen diffcons_dur = (consumo_durables_pc - L3.consumo_durables_pc) // / L3.consumo_durables_pc
gen diffcons_ins = (consumo_insuranc_pc - L3.consumo_insuranc_pc) // / L3.consumo_insuranc_pc
gen diffcons_lei = (consumo_leisure_pc - L3.consumo_leisure_pc) //  / L3.consumo_leisure_pc

gen diffcons_purch = (consumo_purchased_pc - L3.consumo_purchased_pc) //  / L3.consumo_leisure_pc
gen diffcons_trans = (consumo_transfers_pc - L3.consumo_transfers_pc) //  / L3.consumo_leisure_pc
gen diffcons_selfc = (consumo_selfcons_pc - L3.consumo_selfcons_pc) //  / L3.consumo_leisure_pc

gen diffdebtsval = (debts_value_pc - L3.debts_value_pc)
gen diffdebtsvallvl = (debts_value - L3.debts_value)
gen diffhasdebt = debts_dummy - L3.debts_dummy

//gen diffrich    = riqueza - L3.riqueza
//gen ldiffnumperh = log(numperh/L3.numperh)
egen hhid = group(llave_n16)

/* eststo m1: reghdfe ldiffcons shock_any, absorb(year rural_baseline) // cons_pc_q_contemp rural)
eststo m2: reghdfe diffrich shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo m3: reghdfe migrante shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo m4: reghdfe ldiffnumperh shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo m5: reghdfe diffcred shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)

esttab m1 m2 m3 m4 m5, keep(shock_any) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations"))  */

eststo t1: reghdfe diffcons shock_any, absorb(year rural_baseline) // cons_pc_q_contemp rural)
eststo t2: reghdfe diffcons_ali shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo t3: reghdfe diffcons_per shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo t4: reghdfe diffcons_edu shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo t5: reghdfe diffcons_hlt shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo t6: reghdfe diffcons_dur shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo t7: reghdfe diffcons_ins shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo t8: reghdfe diffcons_lei shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)

esttab t1 t2 t3 t4 t5 t6 t7 t8, keep(shock_any) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations")) 

eststo t9:  reghdfe diffcons shock_any, absorb(year rural_baseline) // cons_pc_q_contemp rural)
eststo t10: reghdfe diffcons_purch shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo t11: reghdfe diffcons_trans shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo t12: reghdfe diffcons_selfc shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo t13: reghdfe diffhasdebt shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo t14: reghdfe diffdebtsval shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)

esttab t9 t10 t11 t12 t13 t14, keep(shock_any) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations")) 

eststo d1: reghdfe diffdebtsval shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo d2: reghdfe diffdebtsval shock_accident_illnss, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo d3: reghdfe diffdebtsval shock_lostjob, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo d4: reghdfe diffdebtsval shock_natdisast, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo d5: reghdfe diffdebtsval shock_criminality, absorb(year rural_baseline)  // cons_pc_q_contemp rural)

esttab d1 d2 d3 d4 d5, keep(shock_*) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations")) 

gen ldiffdebtsval = log(debts_value_pc/L3.debts_value_pc)

eststo ld1: reghdfe diffhasdebt shock_any, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo ld2: reghdfe diffhasdebt shock_accident_illnss, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo ld3: reghdfe diffhasdebt shock_lostjob, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo ld4: reghdfe diffhasdebt shock_natdisast, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo ld5: reghdfe diffhasdebt shock_criminality, absorb(year rural_baseline)  // cons_pc_q_contemp rural)

esttab ld1 ld2 ld3 ld4 ld5, keep(shock_*) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations")) 


eststo n1: reghdfe ldiffcons shock_natdisast, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo n2: reghdfe diffrich shock_natdisast, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo n3: reghdfe migrante shock_natdisast, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo n4: reghdfe ldiffnumperh shock_natdisast, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo n5: reghdfe diffcred shock_natdisast, absorb(year rural_baseline)  // cons_pc_q_contemp rural)

esttab n1 n2 n3 n4 n5, keep(shock_natdisast) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations")) 

eststo j1: reghdfe ldiffcons shock_lostjob, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo j2: reghdfe diffrich shock_lostjob, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo j3: reghdfe migrante shock_lostjob, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo j4: reghdfe ldiffnumperh shock_lostjob, absorb(year rural_baseline)  // cons_pc_q_contemp rural)
eststo j5: reghdfe diffcred shock_lostjob, absorb(year rural_baseline)  // cons_pc_q_contemp rural)

esttab j1 j2 j3 j4 j5, keep(shock_lostjob) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations")) 

eststo k1: reghdfe ldiffcons shock_accident_illnss, absorb(year rural_baseline)  //  cons_pc_q_contemp rural)
eststo k2: reghdfe diffrich shock_accident_illnss, absorb(year rural_baseline)  //  cons_pc_q_contemp rural)
eststo k3: reghdfe migrante shock_accident_illnss, absorb(year rural_baseline)  //  cons_pc_q_contemp rural)
eststo k4: reghdfe ldiffnumperh shock_accident_illnss, absorb(year rural_baseline)  //  cons_pc_q_contemp rural)
eststo k5: reghdfe diffcred shock_accident_illnss, absorb(year rural_baseline)  //  cons_pc_q_contemp rural)

esttab k1 k2 k3 k4 k5, keep(shock_accident_illnss) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations")) 

eststo p1: reghdfe ldiffcons shock_criminality, absorb(year rural_baseline)  //  cons_pc_q_contemp rural)
eststo p2: reghdfe diffrich shock_criminality, absorb(year rural_baseline)  //  cons_pc_q_contemp rural)
eststo p3: reghdfe migrante shock_criminality, absorb(year rural_baseline)  //  cons_pc_q_contemp rural)
eststo p4: reghdfe ldiffnumperh shock_criminality, absorb(year rural_baseline)  //  cons_pc_q_contemp rural)
eststo p5: reghdfe diffcred shock_criminality, absorb(year rural_baseline)  //  cons_pc_q_contemp rural)

esttab p1 p2 p3 p4 p5, keep(shock_criminality) se star(* 0.1 ** 0.05 *** 0.01) 				///
	   stats(N, label("Observations")) 

/*
coefplot m1 n1 j1 k1 p1, drop(_cons) 
coefplot m2 n2 j2 k2 p2, drop(_cons) 
coefplot m3 n3 j3 k3 p3, drop(_cons) 
coefplot m4 n4 j4 k4 p4, drop(_cons) 
coefplot m5 n5 j5 k5 p5, drop(_cons) 
*/

* -----------------

* Append both sets in a single Latex table:

cd "$projdir/out"

local pa Natural Disaster
local pb Job Loss
local pc Accident / Illness

//top panel 
esttab n1 n2 n3 n5 using "shock_response_elca_13_16.tex",         	   	   ///
    b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) keep(shock_natdisast)        ///
	prehead("\begin{tabular}{l*{4}{c}} \hline\hline") 					   ///
	posthead("\hline \\") 	   										 	   ///
	fragment replace												       ///
	coeflabels(shock_natdisast  "`pa'")				  	 				   ///
	mtitles("log Consumption" "Wealth Index" 							   ///
			"Prob. Migration" "Prob. Credit") 							   ///
			 scalars("N Obs.") substitute("\_" "_")

//middle panel 
esttab j1 j2 j3 j5 using "shock_response_elca_13_16.tex",         	   	   ///
    b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) keep(shock_lostjob)          ///
   	posthead("\hline \\") 	   											   ///
	fragment append nomtitles nonum											   ///
	coeflabels(shock_lostjob  "`pb'")				  	 	     	       ///
			 scalars("N Obs.") substitute("\_" "_")

//bottom panel 

esttab k1 k2 k3 k5 using "shock_response_elca_13_16.tex", 		      	   ///
    b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) keep(shock_accident_illnss)  ///
   	posthead("\hline \\") 	   		   ///
	fragment append nomtitles nonum										   ///
	coeflabels(shock_accident_illnss  "`pc'")				  	 	       ///
			 scalars("N Obs.") substitute("\_" "_")						   ///											   /// 
	prefoot("\hline") postfoot("\bottomrule \end{tabular}") 


* ---

forvalues i = 1/5 {

	eststo a`i': reghdfe migrante shock_any 						   	   ///
				 if cons_pc_q_baseline == `i' , 			   			   ///
				 absorb(year rural)

	eststo b`i': reghdfe migrante shock_natdisast 						   ///
				if cons_pc_q_baseline == `i' , 			   			   	   ///
				absorb(year rural)

	eststo c`i': reghdfe migrante shock_lostjob 						   ///
				if cons_pc_q_baseline == `i' , 			   			   	   ///
				absorb(year rural)

	eststo d`i': reghdfe migrante shock_accident_illnss 				   ///
				if cons_pc_q_baseline == `i' , 			   			   	   ///
				absorb(year rural)

	eststo e`i': reghdfe migrante shock_criminality 				   	   ///
				if cons_pc_q_baseline == `i' , 			   			   	   ///
				absorb(year rural)
}

coefplot a1 a2 a3 a4 a5, keep(shock_any) vert

coefplot (b1, rename(shock_natdisast = q1)) ///
		 (b2, rename(shock_natdisast = q2)) ///
		 (b3, rename(shock_natdisast = q3)) ///
		 (b4, rename(shock_natdisast = q4)) ///
		 (b5, rename(shock_natdisast = q5)), ///
		 mcolor(black%80 black%80 black%80 black%80 black%80) ///
		 ciopts(lcolor(black%80 black%80 black%80 black%80 black%80)) ///
		 keep(shock_natdisast) vert legend(off) ///
		 ytit("Prob. Migration") xtit("Baseline consumption level quintile") ///
		 yline(0, lcolor(stred)) tit("Shock: Natural disaster")

cd "$projdir/out"
graph export "elca_migrate_natdisast_baselinecons.png", replace


coefplot c1 c2 c3 c4 c5, keep(shock_lostjob) vert
coefplot d1 d2 d3 d4 d5, keep(shock_accident_illnss) vert
coefplot e1 e2 e3 e4 e5, keep(shock_criminality) vert

