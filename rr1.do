clear all
set more off
set showbaselevels on
*ssc install mimrgns

cd "C:\Users\wue04\OneDrive - NYU Langone Health\school-food-env\school-food-environment"
use data/food-environment-reconstructed-mi.dta, clear

************* R&R **************************************************************
************* relax sample restrictions ****************************************
************** drop housing/not continous schools/food env vars ****************
{
*** sample
* school address, demographics data, bmi data
* school within half a mile from city border
* multiple outlets as nearest
* no outlets within half a mile of school
count if level==3 & !missing(x_sch) & !missing(obese) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 & nearestOutlet_sch<=4 ///
	& !missing(boroct2010) //840,158
count if level==3 & !missing(x_sch) & !missing(obese) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 ///
	& !missing(boroct2010) //942,757
global sample level==3 & !missing(x_sch) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 & nearestOutlet_sch<=4 ///
	& !missing(boroct2010)

*** derive sample
{
* start, grade 9-12, districts 1-32
count if level==3 & district>=1 & district<=32 //1,435,103
unique(newid) if level==3 & district>=1 & district<=32
* has home and school address
count if level==3 & district>=1 & district<=32 & (missing(x_sch)|missing(x) ///
	|missing(boroct2010)) //136,440
* has demographics data
count if level==3 & district>=1 & district<=32 & (missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor)) //27,254
* has bmi data
count if level==3 & district>=1 & district<=32 & missing(obese) //374,813
* school not within half a mile from border
count if level==3 & district>=1 & district<=32 & dist_sch<2640 //28,682
* multiple outlets as nearest 
count if level==3 & district>=1 & district<=32 & nearestOutlet_sch==5 //143,674
* no outlets within half a mile from school 
count if level==3 & district>=1 & district<=32 & nearestDist_sch>2640 //89,756
}
.

* overlap in sample missing data
{
* address + demographic
count if level==3 & district<=32 & district>=1 & (missing(x)|missing(x_sch)) & ///
	(missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor))
* address + bmi
count if level==3 & district<=32 & district>=1 & (missing(x)|missing(x_sch)) & missing(obese)
* address + school <0.5 miles from border 
count if level==3 & district<=32 & district>=1 & (missing(x)|missing(x_sch)) & dist_sch<2640
* address + multiple outlets
count if level==3 & district<=32 & district>=1 & (missing(x)|missing(x_sch)) & nearestOutlet_sch==5
* address + no outlets within 0.5 miles from school 
count if level==3 & district<=32 & district>=1 & (missing(x)|missing(x_sch))  & nearestDist_sch>2640
* demo + bmi
count if level==3 & district<=32 & district>=1 & (missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor)) & missing(obese)
* demo + school <0.5 miles from border 
count if level==3 & district<=32 & district>=1 & (missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor)) & dist_sch<2640
* demo + multiple outlets
count if level==3 & district<=32 & district>=1 & (missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor)) & nearestOutlet_sch==5
* demo + no outlets within 0.5 miles from school
count if level==3 & district<=32 & district>=1 & (missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor)) & nearestDist_sch>2640
* bmi + school <0.5 miles from border 
count if level==3 & district<=32 & district>=1 & missing(obese) & dist_sch<2640
* bmi+ multiple outlets 
count if level==3 & district<=32 & district>=1 & missing(obese) & nearestOutlet_sch==5
* bmi + no outlets within 0.5 miles from school
count if level==3 & district<=32 & district>=1 & missing(obese) & nearestDist_sch>2640
* school <0.5 miles from border + multiple outlets
count if level==3 & district<=32 & district>=1 & dist_sch<2640 & nearestOutlet_sch==5
* school <0.5 miles from border + no outlets within 0.5 miles from school
count if level==3 & district<=32 & district>=1 & dist_sch<2640 & nearestDist_sch>2640
* multiple outlets + no outlets within 0.5 miles from school 
count if level==3 & district<=32 & district>=1 & nearestOutlet_sch==5 & nearestDist_sch>2640

* check demographic makeup in students with missing bmi
tab ethnic if level==3 & district<=32 & district>=1 & missing(obese)
tab ethnic if level==3 & district<=32 & district>=1
}
.

*** regressions
global demo b5.ethnic female poor native sped eng_home age i.grade i.year

* create time lag, t-1
sort newid year
by newid: gen nearestDistk_sch1 = nearestDistk_sch[_n-1]
by newid: gen nearestOutlet_sch1 = nearestOutlet_sch[_n-1]
{
eststo clear
quietly eststo: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch $demo ///
	if $sample, robust absorb(boroct2010) //main model
quietly eststo: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch $demo ///
	if $sample, robust absorb(boroct2010) cluster(newid) //cluster at newid, auto-corr
quietly eststo: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch $demo ///
	if $sample, robust absorb(boroct2010) cluster(bds) //cluster at bds level
quietly eststo: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch $demo ///
	if $sample & poor==1, robust absorb(boroct2010) //limit sample to poor students
quietly eststo: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch $demo ///
	if level==3 & !missing(x_sch) & !missing(obese) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 ///
	& !missing(boroct2010), robust absorb(boroct2010) // allow multiple nearest outlets
quietly eststo: areg obese c.nearestDistk_sch1##b2.nearestOutlet_sch1 $demo ///
	if $sample & nearestOutlet_sch1<=4, robust absorb(boroct2010) //main model
esttab using raw-tables\tables_rr_sensitivity.rtf, replace nogaps ///
	title("sensitivity-check-new-sample") b(3) se(3) 
}
.

********************************************************************************
******************************** multiple imputation ***************************
********************************************************************************
*** examine missingness in variables
mdesc zbmi bds x_sch dist_sch ethnic sped native ///
	female eng_home age poor nycha bldg_type if level==3 & district<=32 & district>=1

* patterns of missing data
mi set mlong
mi misstable patterns zbmi ethnic native ///
	female age if level==3 & district<=32 & district>=1

*** reshape data from long to wide
*keep newid year bds obese ethnic boroct2010 nycha poor
mi reshape wide grade age lep sped dist boro bbl x y lat lon bds continuous district level dist_sch x_sch y_sch boro_sch lat_sch lon_sch bbl_sch weight_kg height_cm bmi zbmi sevobese obese overweight underweight FFOR_sch FFORname_sch BOD_sch BODname_sch WS_sch WSname_sch C6P_sch C6Pname_sch eng_home nearestDist_sch nearestOutlet_sch nearestDistk_sch boroct2010 bldg_type nycha nearestGroup_sch nearestDistk_sch1 nearestOutlet_sch1, i(newid) j(year)

* check num of students who never had bmi taken
{
sum zbmi 
by newid: egen min_bmi = min(zbmi)
gen no_bmi = (min_bmi==.)
drop min_bmi
codebook no_bmi if no_bmi==1 & level==3 & district<=32 & district>=1 //122,786
unique(newid) if no_bmi==1 & level==3 & district<=32 & district>=1 //75,418
}
.

*** imputation prepare
mi register imputed obese* 
compress

* imputation
* predictor: other years of BMI, nycha, poor
* predict by ethnicity
mi xtset, clear
mi impute chained (logit) obese* = nycha* poor, by(ethnic) add(5) replace rseed(5) force

* reshape back to long data
mi reshape long grade age lep sped dist boro bbl x y lat lon bds continuous district level dist_sch x_sch y_sch boro_sch lat_sch lon_sch weight_kg height_cm bmi zbmi obese overweight sevobese underweight FFOR_sch FFORname_sch BOD_sch BODname_sch WS_sch WSname_sch C6P_sch C6Pname_sch eng_home nearestDist_sch nearestDistk_sch nearestOutlet_sch boroct2010 bldg_type nycha nearestGroup_sch nearestDistk_sch1 nearestOutlet_sch1, i(newid) j(year)

compress
save data\food-environment-reconstructed-mi.dta, replace

{ // sensitivity checks
eststo clear
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if $sample, robust absorb(boroct2010) //main model
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if $sample, robust absorb(boroct2010) cluster(newid) //cluster at newid, auto-corr
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if $sample, robust absorb(boroct2010) cluster(bds) //cluster at bds level
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if $sample & poor==1, robust absorb(boroct2010) //limit sample to poor students
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if level==3 & !missing(x_sch) & !missing(obese) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 ///
	& !missing(boroct2010), robust absorb(boroct2010) // allow multiple nearest outlets
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch1##b2.nearestOutlet_sch1 ///
	$demo if $sample & nearestOutlet_sch1<=4, robust absorb(boroct2010) //main model, t-1
esttab using raw-tables\tables_rr_sensitivity.rtf, append nogaps ///
	title("sensitivity-check-mi") b(3) se(3) 
}
.

*table 3, coefficients and predicted likelihood
*supp tables, by borough, gender, race/ethnicity, more than 1 outlet
*all cluster at student level
{
eststo clear
eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if $sample, robust absorb(boroct2010) cluster(newid) //main model, cluster newid
*eststo: mimrgns i.nearestOutlet_sch, predict(pr) //table 3, col 3 predicted likelihood
esttab using raw-tables\tables_rr.rtf, replace nogaps title("table3 main model") b(3) se(3) 

/* test joint significance 
mi estimate: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if $sample, robust absorb(boroct2010) cluster(newid)
mi test c.nearestDistk_sch#1.nearestOutlet_sch ///
	c.nearestDistk_sch#3.nearestOutlet_sch c.nearestDistk_sch#4.nearestOutlet_sch
} //joint significance: F=0.04 
. */

/* following table 3
* compare point estimates on diff points along the lines
* compare diff points on the same line, and same dist on diff lines
{
set matsize 1000
quietly: mi estimate: areg obese c.nearestDist_sch##b2.nearestOutlet_sch $demo ///
	if $sample, robust absorb(boroct2010) cluster(newid)
eststo: mi estimate, cmdok post: emargins i.nearestOutlet_sch, at(nearestDist_sch=(0(264)2640)) pwcompare post //copy the table

quietly: mi estimate: areg obese c.nearestDist_sch##b2.nearestOutlet_sch $demo ///
	if $sample, robust absorb(boroct2010) cluster(newid)
eststo: mi estimate, post: margins r.nearestOutlet_sch, at(nearestDistk_sch=(0(264)2640)) //copy the table
}
. */

* table 4, london model
{
eststo clear
quietly eststo: mi estimate, post: areg obese b2.nearestGroup $demo ///
	if $sample, robust absorb(boroct2010) cluster(newid)
*eststo: mi estimate, post: emargins i.nearestGroup, post
esttab using raw-tables\tables_rr.rtf, append nogaps title("table4-london") b(3) se(3)
esttab using raw-tables\tables_rr_CI.csv, append nogaps title("table4-london-CI") ci(10) b(10)
}
.

*** supp analysis
* stratify by gender
{
eststo clear
forvalues i=0/1 {
	quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
		$demo if $sample & female==`i', robust absorb(boroct2010) cluster(newid)
	*quietly eststo: mi estimate, cmdok post: margins i.nearestOutlet_sch, post
}
.
esttab using raw-tables\tables_rr.rtf, append b(3) se(3) nogaps title("stratify by gender")
esttab using raw-tables\tables_rr_CI.csv, append b(3) ci(3) nogaps title("stratify by gender, CI")
}
.
* stratify by race/ethnicity
{
eststo clear
forvalues i=2/5 {
	quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
		$demo if $sample & ethnic==`i', robust absorb(boroct2010) cluster(newid)
	*quietly eststo: margins i.nearestOutlet_sch, post
}
.
esttab using raw-tables\tables_newdata.rtf, append b(3) se(3) nogaps title("stratify by race")
esttab using raw-tables\tables_rr_CI.csv, append b(3) ci(3) nogaps title("stratify by race, CI")
}
.

* stratify by boro
{
eststo clear
forvalues i=1/5 {
	quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch $demo ///
		 if $sample & boro_sch==`i', robust absorb(boroct2010) cluster(newid)
	*quietly eststo: margins i.nearestOutlet_sch, post
}
.
esttab using raw-tables\tables_rr.rtf, append b(3) se(3) nogaps title("stratify by boro")
esttab using raw-tables\tables_rr_CI.csv, append b(3) ci(3) nogaps title("stratify by boro, CI")
}
.


















}
.