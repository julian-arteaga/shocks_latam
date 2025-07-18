* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Correlate weather shocks with self-reported nat disast shocks 

* -----------------

* Import weather shocks (From Paola P):

cd "$projdir/dta/src/ERA5"

use "20250618-pp-mex-per-Tempshocks/shocks_t2m_MEX_1979-2010y.dta", clear

gen cvegeo = string(codmpio, "%05.0f")

xtset codmpio y

gen tp90_1 = L.tp90
gen tp90_2 = L2.tp90 
gen tp90_3 = L3.tp90

gen tp10_1 = L.tp10 

gen tp95_1 = L.tp95 
gen tp5_1  = L.tp5

keep if inlist(y, 2002, 2005, 2009)

keep cvegeo y stpag_l12 tp20 tp20_1 tp20_2 tp20_3 ///
						tp80 tp80_1 tp80_2 tp80_3 ///
						tp90* tp95* tp5* tp10* 
	 
foreach var of varlist tp* {

	replace `var' = `var' / 100
}	 

rename y year

cd "$projdir/dta/cln/ENNVIH/"
merge 1:m cvegeo year using "ennvih_hhpanel_02_05_09.dta"
drop if _merge != 3 
drop _merge 

xtset hhid year


eststo m1: reghdfe shock_natdisast tp80,   absorb(allwaveid year) 		   ///	
										   cluster(cvegeo)
eststo m2: reghdfe shock_natdisast tp80_1, absorb(allwaveid year) 		   ///
										   cluster(cvegeo)
eststo m3: reghdfe shock_natdisast tp80_2, absorb(allwaveid year) 		   ///
										   cluster(cvegeo)
eststo m4: reghdfe shock_natdisast tp80_3, absorb(allwaveid year) 		   ///
										   cluster(cvegeo)

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

cd "$projdir/out/ennvih/"
graph export "ennvih_shock_vs_weather_tp80.png", replace

eststo m5: reghdfe shock_natdisast c.tp80##i.rural_baseline, 			   ///
		   absorb(allwaveid year) cluster(cvegeo)		
eststo m6: reghdfe shock_natdisast c.tp80_1##i.rural_baseline, 			   ///
		   absorb(allwaveid year) cluster(cvegeo)		
eststo m7: reghdfe shock_natdisast c.tp80_2##i.rural_baseline, 			   ///
		   absorb(allwaveid year) cluster(cvegeo)
eststo m8: reghdfe shock_natdisast c.tp80_3##i.rural_baseline, 			   ///
		   absorb(allwaveid year) cluster(cvegeo)
 
 coefplot 																   ///
 	(m5 m6 m7 m8, mcolor(navy%70) ciopts(lcolor(navy%70)) keep(tp80*)) 	   ///
	(m5 m6 m7 m8, mcolor(cranberry%70) ciopts(lcolor(cranberry%70))        ///
				  keep(1.rural_baseline#c.tp80*)), 						   ///
	  	rename(tp80 = "Heat Shock (t)" 									   ///
		   tp80_1 = "Heat Shock (t-1)" 									   ///
		   tp80_2 = "Heat Shock (t-2)" 									   ///
		   tp80_3 = "Heat Shock (t-3)" 									   ///
		   1.rural_baseline#c.tp80 = "Heat Shock (t) x Rural" 	  		   ///
		   1.rural_baseline#c.tp80_1 = "Heat Shock (t-1) x Rural" 		   ///
		   1.rural_baseline#c.tp80_2 = "Heat Shock (t-2) x Rural" 		   ///
		   1.rural_baseline#c.tp80_3 = "Heat Shock (t-3) x Rural") 		   ///
		   order("Heat Shock (t)" "Heat Shock (t) x Rural" 				   ///
		   		 "Heat Shock (t-1)" "Heat Shock (t-1) x Rural" 			   ///
				 "Heat Shock (t-2)" "Heat Shock (t-2) x Rural" 			   ///
				 "Heat Shock (t-3)" "Heat Shock (t-3) x Rural") 		   ///
	xtitle("Prob. self-reported shock (nat. disaster)") 				   ///
	xline(0, lcolor(black%50)) legend(off)

cd "$projdir/out/ennvih/"
graph export "ennvih_shock_vs_weather_tp80_rururb.png", replace

* -------------------------------------------------------------------