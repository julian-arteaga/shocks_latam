* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENNVIH dataset
* Master do file 

* -----------------

* 1. Household roster:
cd "$projdir/do/build/ennvih"
include "build_hhrosterlist_ennvih_02_05_09.do"

* 2. Shocks:
cd "$projdir/do/build/ennvih"
include "build_shocks_ennvih_02_05_09.do"

* 3. Health expenditures:
cd "$projdir/do/build/ennvih"
include "build_healthexp_ennvih_02.do"

cd "$projdir/do/build/ennvih" 
include "build_healthexp_ennvih_05.do"

cd "$projdir/do/build/ennvih" 
include "build_healthexp_ennvih_09.do"

* 4. Consumption (adds in health expenditures):
cd "$projdir/do/build/ennvih"
include "build_consumption_ennvih_02.do"

cd "$projdir/do/build/ennvih" 
include "build_consumption_ennvih_05.do"

cd "$projdir/do/build/ennvih" 
include "build_consumption_ennvih_09.do"

* 5. Debts:
cd "$projdir/do/build/ennvih"
include "build_debts_ennvih_02_05_09.do"

* X. Build panel:
cd "$projdir/do/build/ennvih" 
include "build_hhpanel_ennvih_02_05_09.do"

* X. Build incidence figures by pre-shock expenditure level:
cd "$projdir/do/build/ennvih"
include "build_ennvih_incidence_preexp.do"

* -------------------------------------------------------------------