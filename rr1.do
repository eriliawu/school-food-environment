clear all
set more off
set showbaselevels on

cd "C:\Users\wue04\OneDrive - NYU Langone Health\school-food-env\school-food-environment"
use data/food-environment-reconstructed.dta, clear

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
global sample level==3 & !missing(x_sch) & !missing(obese) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 & nearestOutlet_sch<=4 ///
	& !missing(boroct2010)

*** derive sample
{
* start, grade 9-12, districts 1-32
count if level==3 & district>=1 & district<=32 //1,435,103
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

*** reshape data from long to wide
keep newid year bds zbmi obese ethnic boroct2010 nycha
reshape wide bds zbmi obese boroct2010 nycha, i(newid) j(year)
	
* create indicator for every on nycha, lep and sped
foreach var in nycha lep sped eng_home {
	egen `var' = rowmax(`var'*) if `var'2009!=.|`var'2010!=.|`var'2011!=.|`var'2012!=.|`var'2013!=.
}
.

* patterns of missing data
mi set mlong
mi misstable patterns zbmi ethnic native ///
	female age if level==3 & district<=32 & district>=1

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
mi register imputed obese* zbmi* nycha poor
compress

* imputation
* predictor: other years of BMI, ever in nycha, on sped/lep, poor, eng_home
* predict by ethnicity, cluster by bds
mi xtset, clear
mi impute chained (logit) obese* nycha = poor, by(ethnic) add(5) replace rseed(5) force noisily


*mi impute chained (logit) obese* nycha (regress) zbmi*, by(ethnic) add(5) replace rseed(5) force noisily

mi estimate: areg zbmi c.nearestDistk_sch##b2.nearestOutlet_sch $demo ///
	if $sample, robust absorb(boroct2010) //main model

help mi impute



}
.