* assemble students vars from analytics file

set more off 
clear all

cd "S:\Personal\hw1220\food environment paper 1"

* students analytical 2009
{
use "S:\AnalyticFiles\Student Level Files Stata\y200809f.dta", clear 

keep newid grade lep sex native sped homelang age_yrs_31dec ethnic2 //NO in homelang is english

gen eng_home = 1 if homelang=="NO"
replace eng=0 if homelang!="NO" & !missing(homelang)
tab eng
drop homel

gen female=1 if sex=="F"
replace female=0 if sex=="M"
drop sex

tab grade
replace grade=0 if grade==98
replace grade=. if grade>12

tab lep
tab sped
replace sped=0 if sped==.

tab native
replace native=. if native==9

sum age
rename age age

gen year=2009
compress
save "demo09.dta", replace
}
.

* students analytical 2010
{
use "S:\AnalyticFiles\Student Level Files Stata\y200910fnew.dta", clear
keep ethnic2 female sex native sped grade homelang lep age_yrs_31dec newid

tab ethnic
tab female sex
drop sex

tab native
replace native=. if native==9
tab sped
tab grade
replace grade=0 if grade==98
replace grade=. if grade>12

tab home
gen eng_home = 1 if home=="NO"
replace eng=0 if homelang!="NO" & !missing(homelang)
drop home

tab lep
sum age
rename age age

gen year=2010
compress
save "demo10.dta", replace
}
.

* students analytical 2011
{
use "S:\AnalyticFiles\Student Level Files Stata\y201011fnew.dta", clear
keep ethnic2 sex native sped grade homelang lep age newid

tab sex
gen female=1 if sex=="F"
replace female=0 if sex=="M"
drop sex

tab native
replace native=. if native==9

tab sped
tab grade
replace grade=0 if grade==98
replace grade=. if grade>12

tab home
gen eng_home=1 if home=="NO"
replace eng=0 if homelang!="NO" & !missing(homelang)
drop home

tab lep
sum age

gen year=2011
compress
save "demo11.dta", replace
}
.

* students analytical 2012
{
use "S:\AnalyticFiles\Student Level Files Stata\y201112fnew.dta", clear
keep ethnic2 sex native sped graden lang_name lep newid yob mob

tab lang
gen eng_home=1 if lang=="English only"
replace eng=0 if lang=="English only" & !missing(lang)

gen female=1 if sex=="F"
replace female=0 if sex=="M"

tab native
replace nati=. if nat==9

tab sped
tab gra
replace graden=0 if gra==98
replace gra=. if gra>12
rename grade grade

tab lep

sum yob mob //2011-1-1: 18992
tostring yob mob, replace
replace mob="0"+mob if length(mob)==1
gen dob=mob+"01"+yob
gen dob2 = date(dob,"MDY")
gen dob3=18992-dob2
gen age=dob3/365

gen year=2012
compress
drop sex lang_name yob mob dob*
save demo12.dta, replace
}
.

* students analytical 2013
{
use "S:\AnalyticFiles\Student Level Files Stata\y201213f.dta", clear
keep ethnic2 sex native swd grade homelang ell newid birth_mm_yyyy

tab sex
gen female=1 if sex=="F"
replace female=0 if sex=="M"

tab native
replace nat=. if nat==9

tab swd
tab grade
replace gra=0 if gra==98
replace gra=. if gra>12

tab home 
gen eng_home=1 if home=="NO"
replace eng_home=0 if home!="NO" & !missing(home)

tab ell

gen mob=substr(birth, 1, 2) //2012-12-31: 19358
gen yob=substr(birth, -4, 4)
gen dob=mob+"01"+yob
gen dob2 = date(dob,"MDY")
gen dob3=19358-dob2
gen age=dob3/365

rename ell lep
rename swd sped

drop sex homelang birth mob yob dob*
gen year=2013
compress
save demo13.dta, replace
}
.

* merge data from 09-12
{
foreach year in 09 10 11 12 {
	append using demo`year'.dta
	erase demo`year'.dta
}
.
destring newid, replace
gen id=string(newid, "%09.0f")
drop newid 
rename id newid
compress
save demo09-13.dta, replace
erase demo13.dta
}
.

*** attach bds codes to students 
* because madellein forgot to do it yesterday... aiyaya
use "S:\AnalyticFiles\Student Level Files Stata\y200809f.dta", clear 
keep newid bdsoct
rename bds bds
gen year=2009
compress
save bds09.dta, replace

use "S:\AnalyticFiles\Student Level Files Stata\y200910fnew.dta", clear
keep newid bdsnew
rename bds bds
gen year=2010
compress
save bds10.dta, replace

use "S:\AnalyticFiles\Student Level Files Stata\y201011fnew.dta", clear
keep newid dbnoct
gen boro=substr(dbn, 3, 1)
tab boro
replace boro="1" if boro=="M"
replace boro="2" if boro=="X"
replace boro="3" if boro=="K"
replace boro="4" if boro=="Q"
replace boro="5" if boro=="R"

gen bds=boro+substr(dbn, 1, 2)+substr(dbn, 4, 3)
drop dbn boro
gen year=2011
compress
save bds11.dta, replace

use "S:\AnalyticFiles\Student Level Files Stata\y201112fnew.dta", clear
keep newid bdsnew
rename bds bds
gen year=2012
compress
save bds12.dta, replace

use "S:\AnalyticFiles\Student Level Files Stata\y201213f.dta", clear
keep newid bdsnew
rename bds bds
gen year=2013
compress
save bds13.dta, replace

foreach year in 09 10 11 12 {
	append using bds`year'.dta
	erase bds`year'.dta
}
.
merge 1:1 newid year using "demo09-13.dta"
drop _mer
compress
save demo09-13.dta, replace
erase bds13.dta

* add poverty status; b/c madellein forgot about this too; aiyayaaaa
use demo09-13.dta, replace
merge m:1 newid using "S:\AnalyticFiles\Poor Ever\poorever01_13.dta"
drop if _mer==2
replace poorever=0 if poorever==.
drop _mer
tab poorever
rename poore poor

compress
save demo09-13.dta, replace

*** student addresses
cd "S:\Restricted Data\Geocoding\AP"
use "newid ap coordinates 2010.dta", clear
keep newid boro xcoord ycoord boro year WA2_Latitude WA2_Longitude
rename xcoord x
rename ycoord y
rename WA2_Latitude lat
rename WA2_Longitude lon
tab boro //all abnormal boronum are missing xy
replace boro="." if boro!="1"&boro!="2"&boro!="3"&boro!="4"&boro!="5"
destring boro, replace
compress
save "S:\Personal\hw1220\food environment paper 1\address10.dta", replace
*export delimited using "S:\Personal\hw1220\food environment paper 1\students' addresses\students10", replace

use "newid ap coordinates 2011.dta", clear //RES_BORO
drop RES_ZIP WA2_BBL
rename xcoord x
rename ycoord y
rename RES_BORO boro
rename WA2_Latitude lat
rename WA2_Longitude lon
tab boro
count if (boro=="Y"|boro=="Z") & !missing(x) //none
replace boro="." if boro!="1"&boro!="2"&boro!="3"&boro!="4"&boro!="5"
destring boro, replace
compress
save "S:\Personal\hw1220\food environment paper 1\address11.dta", replace
*export delimited using "S:\Personal\hw1220\food environment paper 1\students' addresses\students11", replace

use "newid ap coordinates 2012.dta", clear //res_boro
drop zip WA2_BBL
rename xcoord x
rename ycoord y
rename res_boro boro
rename WA2_Latitude lat
rename WA2_Longitude lon
tab boro
compress
save "S:\Personal\hw1220\food environment paper 1\address12.dta", replace
*export delimited using "S:\Personal\hw1220\food environment paper 1\students' addresses\students12", replace

use "newid ap coordinates 2009.dta", clear
keep newid resboro xcoord ycoord WA2_Lat WA2_Lon year
rename xcoord x
rename ycoord y
rename resboro boro
rename WA2_Latitude lat
rename WA2_Longitude lon
tab boro
replace boro="." if boro=="Y"|boro=="Z"
destring boro, replace
compress
save "S:\Personal\hw1220\food environment paper 1\address09.dta", replace
*export delimited using "S:\Personal\hw1220\food environment paper 1\students' addresses\students`year'", replace

use "newid ap coordinates 2013.dta", clear
keep newid resboro xcoord ycoord WA2_Lat WA2_Lon year
rename xcoord x
rename ycoord y
rename resboro boro
rename WA2_Latitude lat
rename WA2_Longitude lon
tab boro
destring boro, replace
compress
save "S:\Personal\hw1220\food environment paper 1\address13.dta", replace
*export delimited using "S:\Personal\hw1220\food environment paper 1\students' addresses\students`year'", replace

foreach year in 09 10 11 12 {
	append using "S:\Personal\hw1220\food environment paper 1\address`year'.dta"
	erase "S:\Personal\hw1220\food environment paper 1\address`year'.dta"
}
.
destring newid, replace
gen id=string(newid, "%09.0f")
drop newid 
rename id newid
duplicates tag newid year, gen(dup)
drop if dup==1 & missing(boro)
unique(newid year) //all unique
compress
save "S:\Personal\hw1220\food environment paper 1\address09-13.dta", replace
erase "S:\Personal\hw1220\food environment paper 1\address13.dta"

*use address09-13.dta, clear
*use "S:\Personal\hw1220\food environment paper 1\address09-13.dta", clear
merge 1:1 newid year using demo09-13.dta
count if length(newid)!=9
drop if length(newid)!=9
drop _mer
compress
save students09-13.dta, replace

*** separate coordinates from 09-13 to csv
foreach year in 09 10 11 12 13 {
	use address09-13.dta, clear
	keep x y year
	keep if year==20`year'
	duplicates drop x y, force
	gen id=_n
	compress
	export delimited using unique_xy`year'.csv, replace
}
.

*** school address
cd "S:\Personal\hw1220\food environment paper 1\school address"
foreach year in 09 10 11 12 13 {
	use "S:\AnalyticFiles\Mapping\bds year AP address data, AY 2006-2014.dta", clear
	keep if year==20`year'
	rename WA2_XCoordinate x
	rename WA2_YCoordinate y
	keep year x y
	duplicates drop x y, force
	gen id=_n
	compress
	export delimited using "unique_sch`year'.csv", replace
}
.


