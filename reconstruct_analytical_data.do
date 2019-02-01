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
egen nearestDist_sch = rowmin(FFOR_sch BOD_sch WS_sch C6P_sch) if !missing(FFOR_sch)
gen nearestOutlet_sch = 1 if FFOR_sch<BOD_sch & FFOR_sch<WS_sch & FFOR_sch<C6P_sch & !missing(FFOR_sch)
replace nearestOutlet_sch = 2 if BOD_sch<FFOR_sch & BOD_sch<WS_sch & BOD_sch<C6P_sch & !missing(FFOR_sch)
replace nearestOutlet_sch = 3 if WS_sch<BOD_sch & WS_sch<FFOR_sch & WS_sch<C6P_sch & !missing(FFOR_sch)
replace nearestOutlet_sch = 4 if C6P_sch<FFOR_sch & C6P_sch<WS_sch & C6P_sch<BOD_sch & !missing(FFOR_sch)
replace nearestOutlet_sch = 5 if FFOR_sch==nearestDist & BOD_sch==nearestDist & !missing(FFOR_sch)
replace nearestOutlet_sch = 5 if FFOR_sch==nearestDist & WS_sch==nearestDist & !missing(FFOR_sch)
replace nearestOutlet_sch = 5 if FFOR_sch==nearestDist & C6P_sch==nearestDist & !missing(FFOR_sch)
replace nearestOutlet_sch = 5 if BOD_sch==nearestDist & WS_sch==nearestDist & !missing(FFOR_sch)
replace nearestOutlet_sch = 5 if BOD_sch==nearestDist & C6P_sch==nearestDist & !missing(FFOR_sch)
replace nearestOutlet_sch = 5 if WS_sch==nearestDist & C6P_sch==nearestDist & !missing(FFOR_sch)
tab nearestOutlet_sch

label var nearestDist "dist to nearest food outlet from school"
label var nearestOutlet "type of nearest food outlet from school"
label define outlet 1 "FFOR" 2 "BOD" 3 "WS" 4 "SUP" 5 "More than 1", replace
label values nearestOutlet outlet

*tab grade
gen level=1 if grade>=0 & grade <=5
replace level=2 if grade>=6 & grade<=8
replace level=3 if grade>=9 & grade<=12
label var level "school level"
label define level 1 "k-5" 2 "6-8" 3 "9-12"
label values level level

unique(newid year)
duplicates tag newid year, gen(dup)
br if dup!=0
unique(newid year) if !missing(newid)
drop dup
drop if missing(newid)

cd "S:\Personal\hw1220\FF free zone\data"

*** weight and BMI data
merge 1:1 newid year using bmi_temp.dta
drop if year>=2014 & year<=2017
drop _merge

*** merge to identify continuously operated schools
rename bds bdsnew
merge m:1 bdsnew year using "S:\Personal\hw1220\FF free zone\data\bdsnew year continuously operating schools ay 2009-2013.dta"
drop _merge
rename bdsnew bds
drop y_school
rename contop continuous
label var conti "school continuously operated between 09-13"
drop age_mo

* add school district
gen district = substr(bds, 2, 2)
destring district, replace
label var district "school district"

* house cleaning on demographic vars
rename ethnic2 ethnic
label var x_sch "school x coordinate"
label var y_sch "school y coordinate"
label var bds "boro+district+school code"
label var grade "grade"
label var lep "limited English proficiency"
label var ethnic "2 Asian, 3 Hisp, 4 Black, 5 White"
label var sped "special ed"
label var native "native born"
label var eng_home "speak English at home"
label var newid "unique student ID"
label var boro_sch "schoool boro"

order newid year grade age lep-eng_home poor dist boro-lon bds continuous ///
	district level dist_sch x_sch y_sch boro_sch lat_sch-bbl_sch ///
	weight_kg-underweight nearestDist nearestOutlet_sch FFOR_sch FFORname_sch ///
	BOD_sch BODname_sch WS_sch WSname_sch C6P_sch C6Pname_sch

count //5,729,304
tab grade //all good
tab age //table this
tab lep //have missing data
tab ethnic //have missing data
tab sped //have missing data
tab native //have missing data
tab female //have missing data
tab eng_home //have missing data
tab poor //have missing data

replace ethnic=2 if ethnic==1|ethnic>5

*** filling in missing values if the same student has data on other years
sort newid year
foreach var in ethnic female native poor eng_home {
	bys newid: egen `var'2=mode(`var')
	tab `var'
	tab `var'2
	drop `var'
	rename `var'2 `var'
}
.

*** mrege housing data

compress
save "S:\Personal\hw1220\FF free zone\food-environment-reconstructed.dta", replace
erase "S:\Personal\hw1220\FF free zone\data\bmi_temp.dta"

********************************************************************************
*** derive sample
* with address data, home and school
* student level demo data
* housing data
* weight data
* further from border, 0.5 mile, home and school
* districts 1-32 schools only
* only schools continuously operated from 09-12

*** data we started off with
** high schools only
unique(bds year) if level==3 //2674
unique(bds) if level==3 //706
count if level==3 //1,483,223

** add restrictions on schools
unique(bds year) if level==3 & !missing(x_sch) & dist_sch>2640 & district>=1 ///
	& district<=32 & continuous==1 & !missing(FFOR_sch) & nearestDist<=2640 ///
	& !missing(nearestOutlet) //1501

unique(bds) if level==3 & !missing(x_sch) & dist_sch>2640 & district>=1 ///
	& district<=32 & continuous==1 & !missing(FFOR_sch) & nearestDist<=2640 ///
	& !missing(nearestOutlet) //337

** add restrictions on students
* in district 1-32 schools
unique(newid) if level==3 & district>=1 & district<=32 //607,345
global start_sample level==3 & district>=1 & district<=32
* no home/school address data
unique(newid) if $start_sample & (missing(x)|missing(x_sch)) //82203
* no demo data
unique(newid) if $start_sample & (missing(grade)|missing(ethnic)| ///
	missing(sped)|missing(native)|missing(female)|missing(eng_home)| ///
	missing(age)|missing(poor)) //17760
* no weight/height data
unique(newid) if $start_sample & missing(obese) //255175
* home/school within 0.5 mile from city border
unique(newid) if $start_sample & (dist<2640|dist_sch<2640) //25934
* multiple food outlets as the nearest
unique(newid) if $start_sample & nearestOutlet==5 //82467
* not having a food outlet within 0.5 mile from school
unique(newid) if $start_sample & nearestDist>2640 //49731
* not being in continuously operated schools
unique(newid) if $start_sample & continuous!=1 //98263
* sample
unique(newid) if level==3 & !missing(x) & !missing(x_sch) & !missing(obese) ///
	& dist>=2640 & dist_sch>=2640 & district>=1 & district<=32 & continuous==1 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & !missing(FFOR_sch) & nearestDist<=2640 & nearestOutlet<=4 //361942
* sample, student-year observation
count if level==3 & !missing(x) & !missing(x_sch) & !missing(obese) ///
	& dist>=2640 & dist_sch>=2640 & district>=1 & district<=32 & continuous==1 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & !missing(FFOR_sch) & nearestDist<=2640 & nearestOutlet<=4 //734,861

global sample level==3 & !missing(x) & !missing(x_sch) & !missing(obese) ///
	& dist>=2640 & dist_sch>=2640 & district>=1 & district<=32 & continuous==1 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & !missing(FFOR_sch) & nearestDist<=2640 & nearestOutlet<=4
sum age if $sample
tab nearestOutlet if $sample


