* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Project settings (Stata)

* -----------------

clear all
global projdir "/Users/julian/Documents/Github/shocks_latam"

if "`c(username)'" == "JULIANART" {
	
	local long1 C:/Users/JULIANART/
	local long2 OneDrive - Inter-American Development Bank Group/
	global projdir "`long1'`long2'/shocks_latam"
}

