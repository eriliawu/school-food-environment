* assemble students vars from analytics file

set more off 
clear all

cd "S:\Personal\hw1220\food environment paper 1\archive"

* found in archive folder
* student analytical data: demographic var, school code
use demo09-13.dta, clear
merge 1:1 newid year using address09-13.dta //merge address

count if length(newid)!=9
drop if length(newid)!=9
drop _mer
drop dup
unique(newid year) //sanity check

label var poor "ever being poor between 01-13"
label var boro "home boro"
label var x "home x"
label var y "home y"
label var lat "home lat"
label var lon "home lon"

compress
save demo+home-address_09-13.dta, replace

*** add school addresses
use "S:\AnalyticFiles\Mapping\bds year AP address data, AY 2006-2014.dta", clear
rename WA2_XCoordinate x_sch
rename WA2_YCoordinate y_sch
rename boro boro_sch
rename WA2_Latitude lat_sch
rename WA2_Longitude lon_sch
keep if !missing(x_sch) & !missing(y_sch)
keep if year>=2009 & year<=2013
tab boro

sort year x_sch y_sch
quietly by year x_sch y_sch: gen dup=cond(_N==1, 0, _n) 
unique(year bds) //some schools share the same address

label var year ""
label var bds ""
label var lat_sch "school latitude"
label var lon_sch "school longitude"
label var x_sch "school x"
label var y_sch "school y"
rename WA2_BBL bbl_sch
label var bbl_sch "school BBL"
keep year x y_sch bds year boro_sch lat lon bbl_sch
destring boro, replace

merge 1:m bds year using demo+home-address_09-13.dta //merge with student analytical data
drop _merge

destring x y x_sch y_sch, replace
merge m:1 x_sch y_sch using "S:\Personal\hw1220\food environment paper 1\city border\sch_border.dta"
drop _merge
merge m:1 x y using "S:\Personal\hw1220\food environment paper 1\city border\student_border.dta"
drop _merge
label var dist "dist from home to border"
label var dist_sch "dist from school to border"

compress
save student_analytical+address_09-13.dta, replace

* count number of schools
unique(bds year) //9427 school+year, 5709080 students
unique(bds) //2191 schools overall

*** attach distance measurements
* link raw output from ArcGIS to school addresses
cd "H:\Personal\food environment paper 1"
*use "school address\unique_sch_all.dta", clear
*2009
{
foreach var in FFOR BOD WS C6P {
	import delimited 2009\closest\closest`var'_sch.csv, clear
	keep total incidentid name
	rename total `var'_sch
	rename name `var'name_sch
	rename incident id
	gen year=2009
	replace id = id-284653
	compress
	save archive\closest`var'sch_2009.dta, replace
}
.

foreach var in FFOR BOD WS {
	merge 1:1 id using archive\closest`var'sch_2009.dta
	drop _merge
	erase archive\closest`var'sch_2009.dta
}
.
compress
save archive\closest_sch_2009.dta, replace
erase archive\closestC6Psch_2009.dta
}
.

*2010
{
foreach var in FFOR BOD WS C6P {
	import delimited 2010\closest\closest`var'_sch.csv, clear
	keep total incidentid name
	rename total `var'_sch
	rename name `var'name_sch
	rename incident id
	gen year=2010
	replace id = id-285724
	compress
	save archive\closest`var'sch_2010.dta, replace
}
.

foreach var in FFOR BOD WS {
	merge 1:1 id using archive\closest`var'sch_2010.dta
	drop _merge
	erase archive\closest`var'sch_2010.dta
}
.
compress
save archive\closest_sch_2010.dta, replace
erase archive\closestC6Psch_2010.dta
}
.

*2011-13
{
foreach i in 11 12 13 {
	foreach var in FFOR BOD WS C6P {
		import delimited 20`i'\closest\closest`var'_sch.csv, clear
		keep total incidentid name
		rename total `var'_sch
		rename name `var'name_sch
		rename incident id
		gen year=20`i'
		compress
		save archive\closest`var'sch_20`i'.dta, replace
	}
	.

	foreach var in FFOR BOD WS {
		merge 1:1 id using archive\closest`var'sch_20`i'.dta
		drop _merge
		erase archive\closest`var'sch_20`i'.dta
	}
	.
	compress
	save archive\closest_sch_20`i'.dta, replace
	erase archive\closestC6Psch_20`i'.dta
}
}
.

* combine all years
foreach i in 09 10 11 12 {
	append using archive\closest_sch_20`i'.dta
	erase archive\closest_sch_20`i'.dta
}
.
compress
save archive\closest_sch_allyears.dta, replace
erase archive\closest_sch_2013.dta

* link resutls to school coordinates
*use archive\closest_sch_allyears.dta, clear
merge 1:1 id year using "school address\unique_sch_all.dta"
drop _merge
rename x x_sch
rename y y_sch
merge 1:m x_sch y_sch year using "S:\Personal\hw1220\food environment paper 1\archive\student_analytical+address_09-13.dta"
drop _merge id

foreach var in FFOR BOD WS C6P {
	label var `var'_sch "distance to nearest `var' from school"
	label var `var'name_sch "name of nearest `var'"
}
.

*** create analytical variables
* distance to nearest outlet
* type of nearest food outlet
egen nearestDist = rowmin(FFOR_sch BOD_sch WS_sch C6P_sch)
gen nearestOutlet_sch = 1 if FFOR_sch<BOD_sch & FFOR_sch<WS_sch & FFOR_sch<C6P_sch
replace nearestOutlet_sch = 2 if BOD_sch<FFOR_sch & BOD_sch<WS_sch & BOD_sch<C6P_sch
replace nearestOutlet_sch = 3 if WS_sch<BOD_sch & WS_sch<FFOR_sch & WS_sch<C6P_sch
replace nearestOutlet_sch = 4 if C6P_sch<FFOR_sch & C6P_sch<WS_sch & C6P_sch<BOD_sch

label var nearestDist "dist to nearest food outlet from school"
label var nearestOutlet "type of nearest food outlet from school"

compress
cd "S:\Personal\hw1220\food environment paper 1\analytical-data"
save food-environment-reconstructed.dta, replace













