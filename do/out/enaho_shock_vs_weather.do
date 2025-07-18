* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Correlate weather shocks with self-reported nat disast shocks 

* -----------------

* Add weather shock measures to enaho housheholds:

cd "$projdir/dta/src/ERA5/20250618-pp-mex-per-Tempshocks/"
use "shocks_t2m_PER_1979-2023y.dta", clear

gen ubigeo = string(codmpio,"%06.0f")

gen year = y

cd "$projdir/dta/cln/ENAHO"
merge 1:m year ubigeo using "enaho_shock_prevalence_hhlvl_13_23.dta"

tab year _merge 
keep if year >= 2013 & year <= 2019
drop if _merge == 1 // year-muni combinations not in enaho

egen hhid = group(conglome vivienda hogar)
xtset hhid year

xtset hhid year

bys hhid: keep if _N >= 2

eststo m1: reghdfe shock_natdisast tp80, absorb(hhid year) cluster(ubigeo)

eststo m2: reghdfe shock_natdisast tp80_1,   absorb(hhid year) 		   ///	
										   cluster(ubigeo)
eststo m3: reghdfe shock_natdisast tp80_2,   absorb(hhid year) 		   ///	
										   cluster(ubigeo)
eststo m4: reghdfe shock_natdisast tp80_3,   absorb(hhid year) 		   ///	
										   cluster(ubigeo)

coefplot 															       ///
	(m1, mcolor(navy%70) ciopts(lcolor(navy%70))) 					  	   /// 
	(m2, mcolor(navy%70) ciopts(lcolor(navy%70))) 						   ///
	(m3, mcolor(navy%70) ciopts(lcolor(navy%70))) 						   ///
	(m4, mcolor(navy%70) ciopts(lcolor(navy%70))), 						   ///
	keep(tp80* 1.rural_baseline#c.tp80*)  			   					   ///
	rename(tp80 = "Heat Shock (t)" tp80_1 = "Heat Shock (t-1)" 			   ///
		   tp80_2 = "Heat Shock (t-2)" tp80_3 = "Heat Shock (t-3)")		   ///
	vert ytit("Prob. self-reported shock  (nat. disaster)") 		  	   ///
	yline(0, lcolor(black%50)) legend(off) 										   


cd "$projdir/out/enaho/"
graph export "enaho_shock_vs_weather_tp80.png", replace

eststo m5: reghdfe shock_natdisast c.tp80##i.rural, 			   ///
		   absorb(hhid year) cluster(ubigeo)

eststo m6: reghdfe shock_natdisast c.tp80_1##i.rural, 			   ///
		   absorb(hhid year) cluster(ubigeo)

eststo m7: reghdfe shock_natdisast c.tp80_2##i.rural, 			   ///
		   absorb(hhid year) cluster(ubigeo)

eststo m8: reghdfe shock_natdisast c.tp80_3##i.rural, 			   ///
		   absorb(hhid year) cluster(ubigeo)

 coefplot 																   ///
 	(m5 m6 m7 m8, mcolor(navy%70) ciopts(lcolor(navy%70)) keep(tp80*)) 	   ///
	(m5 m6 m7 m8, mcolor(cranberry%70) ciopts(lcolor(cranberry%70))        ///
				  keep(1.rural#c.tp80*)), 						   ///
	  	rename(tp80 = "Heat Shock (t)" 									   ///
		   tp80_1 = "Heat Shock (t-1)" 									   ///
		   tp80_2 = "Heat Shock (t-2)" 									   ///
		   tp80_3 = "Heat Shock (t-3)" 									   ///
		   1.rural#c.tp80 = "Heat Shock (t) x Rural" 	  		   ///
		   1.rural#c.tp80_1 = "Heat Shock (t-1) x Rural" 		   ///
		   1.rural#c.tp80_2 = "Heat Shock (t-2) x Rural" 		   ///
		   1.rural#c.tp80_3 = "Heat Shock (t-3) x Rural") 		   ///
		   order("Heat Shock (t)" "Heat Shock (t) x Rural" 				   ///
		   		 "Heat Shock (t-1)" "Heat Shock (t-1) x Rural" 			   ///
				 "Heat Shock (t-2)" "Heat Shock (t-2) x Rural" 			   ///
				 "Heat Shock (t-3)" "Heat Shock (t-3) x Rural") 		   ///
	xtitle("Prob. self-reported shock (nat. disaster)") 				   ///
	xline(0, lcolor(black%50)) legend(off)

cd "$projdir/out/enaho/"
graph export "enaho_shock_vs_weather_tp80_rururb.png", replace


* -------------------------------------------------------------------
