* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Project settings (Stata)

* -----------------

clear all

local long1 OneDrive-Inter-AmericanDevelopmentBankGroup
global projdir "/Users/julian/Library/CloudStorage/`long1'/shocks_latam"

if "`c(username)'" == "JULIANART" {
	
	local long2 C:/Users/JULIANART/
	local long3 OneDrive - Inter-American Development Bank Group/
	global projdir "`long2'`long3'/shocks_latam"
}


