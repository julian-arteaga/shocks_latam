* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Compute shock prevalence summary statistics ELCA 2013-2016:

cd "$projdir/dta/cln/ELCA"
use "elca_shock_prevalence_hhlvl_13_16.dta", clear

* RESHAPE wide *_2010, *_2013, *_2016; isid llave_n16

cd "$projdir/dta/cln/ELCA"
use "vars_elca_private.dta", clear

* merge with vars_elca_private - Also check if they match consumption dta

* -----------------