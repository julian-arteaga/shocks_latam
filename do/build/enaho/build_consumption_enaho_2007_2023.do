* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Import ENAHO consumption measures -- 2007-2023

forvalues y = 2007(1)2023 {

	use "$projdir/dta/src/ENAHO/`y'/sumaria-`y'.dta", clear
	numlabel, add

	gen percinc_month = inghog2d / (mieperho*12)
	label var percinc "Net household percapita monthly income"

	gen percexp_month = gashog2d / (mieperho*12)
	label var percexp "Total household percapita monthly expenditure"

	* consumption categories:
	* Following the definitions in ~/dta/src/ENAHO/2013/Sumaria_2013.pdf
	
	egen check = rowtotal( /// 	
	/// food:
	g05hd g05hd1 g05hd2 g05hd3 g05hd4 g05hd5 g05hd6  					   ///
	ig06hd  /// // ig06hd1 ig06hd2 ig06hd3 ig06hd4 ig06hd5 ig06hd6 (notsure)
	sg23 sig24 sg25 sig26 												   ///
	gru11hd gru12hd1 gru12hd2 gru13hd1 gru13hd2 gru13hd3 				   ///
	gru14hd gru14hd1 gru14hd2 gru14hd3 gru14hd4 gru14hd5  				   /// 
	///
	/// personal
	gru21hd gru22hd1 gru22hd2 gru23hd1 gru23hd2 gru23hd3 gru24hd   /// vestido
	gru61hd gru62hd1 gru62hd2 gru63hd1 gru63hd2 gru63hd3 gru64hd /// transport
	///
	/// rent (personal?)
	gru31hd gru32hd1 gru32hd2 gru33hd1 gru33hd2 gru33hd3 gru34hd 	 /// renta
	///
	/// durable
	gru41hd gru42hd1 gru42hd2 gru43hd1 gru43hd2 gru43hd3 gru44hd   /// muebles
	sg42 sg421 sg422 sg423 sg42d sg42d1 sg42d2 sg42d3   /// equipamiento hogar
	///
	/// health
	gru51hd gru52hd1 gru53hd1 gru53hd2 gru53hd3 gru53hd4 gru54hd  ///
	///
	/// leisure (includes educ as well...)
	gru71hd gru72hd1 gru72hd2 gru73hd1 gru73hd2 gru73hd3 gru74hd  /// esparcim
	///
	/// other
	g07hd ig08hd 														   ///
	gru81hd gru82hd1 gru82hd2 gru83hd1 gru83hd2 gru83hd3 gru83hd4 gru84hd)

	drop if abs(check - gashog2d) > 1 // 1 obs, surely an error. ok

	egen consumo_health = rowtotal(gru51hd gru52hd1 gru53hd1 	   		   ///
								   gru53hd2 gru53hd3 gru53hd4 gru54hd)

	egen consumo_alimento = rowtotal(g05hd g05hd1 g05hd2 g05hd3 g05hd4 	   ///
				 					 g05hd5 g05hd6  					   ///
				 					 ig06hd					   			   /// 
				 					 sg23 sig24 sg25 sig26 				   ///								   ///
				 					 gru11hd gru12hd1 gru12hd2 			   ///
									 gru13hd1 gru13hd2 gru13hd3 	   	   ///
				 					 gru14hd gru14hd1 gru14hd2 			   ///
									 gru14hd3 gru14hd4 gru14hd5)	 
	
	egen consumo_personal = rowtotal(									   ///
			gru21hd gru22hd1 gru22hd2 gru23hd1 gru23hd2 gru23hd3 gru24hd   /// 
			gru61hd gru62hd1 gru62hd2 gru63hd1 gru63hd2 gru63hd3 gru64hd   /// 
			gru31hd gru32hd1 gru32hd2 gru33hd1 gru33hd2 gru33hd3 gru34hd   ///
			/// include 'other' category
			g07hd ig08hd gru81hd gru82hd1 gru82hd2 gru83hd1 gru83hd2 	   ///
			gru83hd3 gru83hd4 gru84hd)

	egen consumo_leisure = rowtotal(									   ///
		    gru71hd gru72hd1 gru72hd2 gru73hd1 gru73hd2 gru73hd3 gru74hd)

	egen consumo_durables = rowtotal(									   ///
			gru41hd gru42hd1 gru42hd2 gru43hd1 gru43hd2 gru43hd3 gru44hd   /// 
			sg42 sg421 sg422 sg423 sg42d sg42d1 sg42d2 sg42d3)

	assert (gashog2d - (consumo_health + consumo_alimento + 			   ///  
						consumo_personal + consumo_leisure + 			   ///
						consumo_durables)) < 1  // ok

	egen consumo_transfers = rowtotal(									   ///
			gru13hd1 gru13hd2 gru14hd3 gru14hd4 gru23hd1 gru23hd2		   ///
			gru63hd1 gru63hd2 gru33hd1 gru33hd2 gru43hd1 gru43hd2		   ///
			gru53hd1 gru53hd2 gru73hd1 gru73hd2 gru83hd1 gru83hd2)

	gen consumo_purchased = gashog2d - consumo_transfers

	gen hh_totexp = gashog2d
	gen hh_totinc = inghog2d

	label var percexp "Yearly household consumption (nominal soles)"

	gen year = `y'

	keep conglome vivienda hogar year consumo_* hh_totexp hh_totinc 

	tempfile incexp_`y'
	save `incexp_`y''
}

use `incexp_2007', clear 

forvalues y = 2008(1)2023 {

	append using `incexp_`y''
}

if year < 2014  {

	destring conglome, gen(congaux)
	gen cong_aux = string(congaux, "%06.0f") 
	drop conglome 
	rename cong_aux conglome
	order conglome
}

drop congaux 

compress 

cd "$projdir/dta/cln/ENAHO"
save "enaho_consump_hhlvl_07_23.dta", replace

* -------------------------------------------------------------------