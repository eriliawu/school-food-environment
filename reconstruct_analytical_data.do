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




