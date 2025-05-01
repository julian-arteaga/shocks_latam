* ----------------------------------------------------------------------------*

* Shocks LatAm
* Julian Arteaga
* 2025

* ----------------------------------------------------------------------------*

* Project settings (Stata)

* -----------------

clear all
global projdir "/Users/julian/Documents/Github/shocks_latam"

if "`c(username)'" == "julianart" {
	
	local long1 C:/Users/JULIANART/
	local long2 OneDrive - Inter-American Development Bank Group/
	global projdir "`long1'`long2'Documents/shocks_latam"
}

