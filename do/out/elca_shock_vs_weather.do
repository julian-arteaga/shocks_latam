* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Correlate weather shocks with self-reported nat disast shocks 

* -----------------

* Import weather shocks (From Paola P):

* Rainfall:
cd "$projdir/dta/src/ERA5"
use "20220628-p-poveda-precipitation/tpt_mpio_y.dta", clear

bys codmpio: egen tpt_p20 = pctile(tpt), p(20)
bys codmpio: egen tpt_p80 = pctile(tpt), p(80)

gen rain_20 = tpt < tpt_p20
gen rain_80 = tpt > tpt_p80

xtset codmpio y

gen rain_20_1 = L.rain_20
gen rain_20_2 = L2.rain_20 
gen rain_20_3 = L3.rain_20

gen rain_80_1 = L.rain_80
gen rain_80_2 = L2.rain_80
gen rain_80_3 = L3.rain_80

keep y codmpio rain_*

rename y year 
rename codmpio mpio 

keep if inlist(year, 2010, 2013, 2016)

tempfile tpt 
save `tpt'

* Temperature
cd "$projdir/dta/src/ERA5"

use "tempshocks_elca_mpio_year.dta", clear

rename codmpio mpio
rename y year

foreach var of varlist tp* {

	replace `var' = `var' / 100
}	 

merge 1:1 mpio year using `tpt'
drop _merge 

cd "$projdir/dta/cln/ELCA/"
merge 1:m mpio year using "elca_hhpanel_10_13_16.dta"
drop if _merge == 1 // mpios x years without elca hh
drop _merge 

xtset hhid year


eststo m1: reghdfe shock_natdisast tp80,   absorb(allwaveid year) 		   ///	
										   cluster(admincode)
eststo m2: reghdfe shock_natdisast tp80_1, absorb(allwaveid year) 		   ///
										   cluster(admincode)
eststo m3: reghdfe shock_natdisast tp80_2, absorb(allwaveid year) 		   ///
										   cluster(admincode)
eststo m4: reghdfe shock_natdisast tp80_3, absorb(allwaveid year) 		   ///
										   cluster(admincode)

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

cd "$projdir/out/elca/"
graph export "elca_shock_vs_weather_tp80.png", replace

eststo m5: reghdfe shock_natdisast c.tp80##i.rural_baseline, 			   ///
		   absorb(allwaveid year) cluster(admincode)		
eststo m6: reghdfe shock_natdisast c.tp80_1##i.rural_baseline, 			   ///
		   absorb(allwaveid year) cluster(admincode)		
eststo m7: reghdfe shock_natdisast c.tp80_2##i.rural_baseline, 			   ///
		   absorb(allwaveid year) cluster(admincode)
eststo m8: reghdfe shock_natdisast c.tp80_3##i.rural_baseline, 			   ///
		   absorb(allwaveid year) cluster(admincode)
 
 coefplot 																   ///
 	(m5 m6, mcolor(navy%70) ciopts(lcolor(navy%70)) keep(tp80*)) 	   ///
	(m5 m6, mcolor(cranberry%70) ciopts(lcolor(cranberry%70))        ///
				  keep(1.rural_baseline#c.tp80*)), 						   ///
	  	rename(tp80 = "Heat Shock (t)" 									   ///
		   tp80_1 = "Heat Shock (t-1)"									   ///
		   1.rural_baseline#c.tp80 = "Heat Shock (t) x Rural" 	  		   ///
		   1.rural_baseline#c.tp80_1 = "Heat Shock (t-1) x Rural")		   ///
		   order("Heat Shock (t)" "Heat Shock (t) x Rural" 				   ///
		   		 "Heat Shock (t-1)" "Heat Shock (t-1) x Rural") 		   ///
	xtitle("Prob. self-reported shock (nat. disaster)") 				   ///
	xline(0, lcolor(black%50)) legend(off)

cd "$projdir/out/elca/"
graph export "elca_shock_vs_weather_tp80_rururb.png", replace

* ----------

eststo m1: reghdfe shock_natdisast rain_80,  absorb(allwaveid year) 	   ///	
										     cluster(admincode)
eststo m2: reghdfe shock_natdisast rain_80_1, absorb(allwaveid year) 	   ///
										     cluster(admincode)
eststo m3: reghdfe shock_natdisast rain_80_2, absorb(allwaveid year) 	   ///
										     cluster(admincode)
eststo m4: reghdfe shock_natdisast rain_80_3, absorb(allwaveid year) 	   ///
										     cluster(admincode)

coefplot 															       ///
	(m1, mcolor(navy%70) ciopts(lcolor(navy%70))) 					  	   /// 
	(m2, mcolor(navy%70) ciopts(lcolor(navy%70))) 						   ///
	(m3, mcolor(navy%70) ciopts(lcolor(navy%70))) 						   ///
	(m4, mcolor(navy%70) ciopts(lcolor(navy%70))), 						   ///
	keep(rain_80*)  			   				   						   ///
	rename(rain80 = "Rainfall Shock (t)" 								   ///
		   rain80_1 = "Rainfall Shock (t-1)" 			   				   ///
		   rain80_2 = "Rainfall Shock (t-2)" 							   ///
		   rain80_3 = "Rainfall Shock (t-3)")		   					   ///
	vert ytit("Prob. self-reported shock  (nat. disaster)") 		  	   ///
	yline(0, lcolor(black%50)) legend(off) 

eststo m5: reghdfe shock_natdisast c.rain_80##i.rural_baseline, 		   ///
		   absorb(allwaveid year) cluster(admincode)		
eststo m6: reghdfe shock_natdisast c.rain_80_1##i.rural_baseline, 		   ///
		   absorb(allwaveid year) cluster(admincode)		
eststo m7: reghdfe shock_natdisast c.rain_80_2##i.rural_baseline, 		   ///
		   absorb(allwaveid year) cluster(admincode)
eststo m8: reghdfe shock_natdisast c.rain_80_3##i.rural_baseline, 		   ///
		   absorb(allwaveid year) cluster(admincode)
 
 coefplot 																   ///
 	(m5 m6 m7 m8, mcolor(navy%70) ciopts(lcolor(navy%70)) keep(rain_80*))  ///
	(m5 m6 m7 m8, mcolor(cranberry%70) ciopts(lcolor(cranberry%70))        ///
				  keep(1.rural_baseline#c.rain_80*)), 					   ///
	rename(rain_80 = "Rainfall Shock (t)" 								   ///
		   rain_80_1 = "Rainfall Shock (t-1)" 			   				   ///
		   rain_80_2 = "Rainfall Shock (t-2)" 							   ///
		   rain_80_3 = "Rainfall Shock (t-3)"		   					   ///
		   1.rural_baseline#c.rain_80 = "Rainfall (t) x Rural" 	  		   ///
		   1.rural_baseline#c.rain_80_1 = "Rainfall (t-1) x Rural" 		   ///
		   1.rural_baseline#c.rain_80_2 = "Rainfall (t-2) x Rural" 		   ///
		   1.rural_baseline#c.rain_80_3 = "Rainfall (t-3) x Rural") 	   ///
		   order("Rainfall Shock (t)" "Rainfall (t) x Rural" 			   ///
		   		 "Rainfall Shock (t-1)" "Rainfall (t-1) x Rural" 		   ///
				 "Rainfall Shock (t-2)" "Rainfall (t-2) x Rural" 		   ///
				 "Rainfall Shock (t-3)" "Rainfall (t-3) x Rural") 		   ///
	xtitle("Prob. self-reported shock (nat. disaster)") 				   ///
	xline(0, lcolor(black%50)) legend(off)

* -------------------------------------------------------------------


eststo m1: reghdfe shock_natdisast rain_20,  absorb(allwaveid year) 	   ///	
										     cluster(admincode)
eststo m2: reghdfe shock_natdisast rain_20_1, absorb(allwaveid year) 	   ///
										     cluster(admincode)
eststo m3: reghdfe shock_natdisast rain_20_2, absorb(allwaveid year) 	   ///
										     cluster(admincode)
eststo m4: reghdfe shock_natdisast rain_20_3, absorb(allwaveid year) 	   ///
										     cluster(admincode)

coefplot 															       ///
	(m1, mcolor(navy%70) ciopts(lcolor(navy%70))) 					  	   /// 
	(m2, mcolor(navy%70) ciopts(lcolor(navy%70))) 						   ///
	(m3, mcolor(navy%70) ciopts(lcolor(navy%70))) 						   ///
	(m4, mcolor(navy%70) ciopts(lcolor(navy%70))), 						   ///
	keep(rain_20*)  			   				   						   ///
	rename(rain_20 = "Drought Shock (t)" 								   ///
		   rain_20_1 = "Drought Shock (t-1)" 			   				   ///
		   rain_20_2 = "Drought Shock (t-2)" 							   ///
		   rain_20_3 = "Drought Shock (t-3)")		   					   ///
	vert ytit("Prob. self-reported shock  (nat. disaster)") 		  	   ///
	yline(0, lcolor(black%50)) legend(off) 

eststo m5: reghdfe shock_natdisast c.rain_20##i.rural_baseline, 		   ///
		   absorb(allwaveid year) cluster(admincode)		
eststo m6: reghdfe shock_natdisast c.rain_20_1##i.rural_baseline, 		   ///
		   absorb(allwaveid year) cluster(admincode)		
eststo m7: reghdfe shock_natdisast c.rain_20_2##i.rural_baseline, 		   ///
		   absorb(allwaveid year) cluster(admincode)
eststo m8: reghdfe shock_natdisast c.rain_20_3##i.rural_baseline, 		   ///
		   absorb(allwaveid year) cluster(admincode)
 
 coefplot 																   ///
 	(m5 m6 m7 m8, mcolor(navy%70) ciopts(lcolor(navy%70)) keep(rain_20*))   ///
	(m5 m6 m7 m8, mcolor(cranberry%70) ciopts(lcolor(cranberry%70))        ///
				  keep(1.rural_baseline#c.rain_20*)), 					   ///
	rename(rain_20 = "Drought Shock (t)" 								   ///
		   rain_20_1 = "Drought Shock (t-1)" 			   				   ///
		   rain_20_2 = "Drought Shock (t-2)" 							   ///
		   rain_20_3 = "Drought Shock (t-3)"		   					   ///
		   1.rural_baseline#c.rain_20 = "Drought (t) x Rural" 	  		   ///
		   1.rural_baseline#c.rain_20_1 = "Drought (t-1) x Rural" 		   ///
		   1.rural_baseline#c.rain_20_2 = "Drought (t-2) x Rural" 		   ///
		   1.rural_baseline#c.rain_20_3 = "Drought (t-3) x Rural") 		   ///
		   order("Drought Shock (t)" "Drought (t) x Rural" 			   ///
		   		 "Drought Shock (t-1)" "Drought (t-1) x Rural" 		   ///
				 "Drought Shock (t-2)" "Drought (t-2) x Rural" 		   ///
				 "Drought Shock (t-3)" "Drought (t-3) x Rural") 		   ///
	xtitle("Prob. self-reported shock (nat. disaster)") 				   ///
	xline(0, lcolor(black%50)) legend(off)

* -------------------------------------------------------------------