* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ELCA dataset
* Master do file 

* -----------------

* 1. Household roster:
cd "$projdir/do/build/elca"
include "build_hhrosterlist_elca_10_13_16.do"

* 2. Shocks:
cd "$projdir/do/build/elca"
include "build_shocks_elca_10_13_16.do"

cd "$projdir/do/build/elca"
include "build_shocks_elco_19.do"

* 3. Consumption:
cd "$projdir/do/build/elca"
include "build_consumption_elca_10.do"

cd "$projdir/do/build/elca"
include "build_consumption_elca_13.do"

cd "$projdir/do/build/elca"
include "build_consumption_elca_16.do"

* 4. Debts:
cd "$projdir/do/build/elca"
include "build_debts_elca_10_13_16.do"

* 5. Income:
cd "$projdir/do/build/elca"
include "build_income_elca_10_13_16.do"




* X. Build panel:
cd "$projdir/do/build/elca" 
include "build_hhpanel_elca_10_13_16.do"

* X. Build incidence figures by pre-shock expenditure level:
cd "$projdir/do/build/elca"
include "build_elca_incidence_preexp.do"

* -------------------------------------------------------------------