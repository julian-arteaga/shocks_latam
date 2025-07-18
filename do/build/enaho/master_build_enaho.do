* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Build ENAHO dataset
* Master do file 

* -----------------

* 1. Household roster:
cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2007_2011.do"

cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2011_2015.do"

cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2012_2016.do"

cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2013_2017.do"

cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2014_2018.do"

cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2015_2019.do"

cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2016_2020.do"

cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2017_2021.do"

cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2018_2022.do"

cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2019_2023.do"

* ---
cd "$projdir/do/build/enaho"
include "build_hhrosterlist_enaho_2007_2023.do"
* ---

* 2. Shocks:
`XXXXFINISHXXXXX'

* 3. Consumption (includes income):

* 4. Debts:

* 5. Govt Programs:

* X. Build panel:

* X. Build incidence figures by pre-shock expenditure level:


* -------------------------------------------------------------------