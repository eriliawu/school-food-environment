clear all
set more off
set showbaselevels on
*ssc install mimrgns
*ssc install dataex
*net install parallel,  from(https://raw.github.com/gvegayon/parallel/stable/) replace
*mata mata mlib index

cd "C:\Users\wue04\OneDrive - NYU Langone Health\school-food-env\school-food-environment"
use data/food-environment-reconstructed-mi2.dta, clear

************* R&R **************************************************************
************* relax sample restrictions ****************************************
************** drop housing/not continous schools/food env vars ****************
{
*** sample
* school address, demographics data, bmi data
* school within half a mile from city border
* multiple outlets as nearest
* no outlets within half a mile of school
unique(newid) if level==3 & !missing(x_sch) & !missing(obese) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 & nearestOutlet_sch<=4 ///
	& !missing(boroct2010) //840,158
count if level==3 & !missing(x_sch) & !missing(x) & !missing(obese) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 & nearestOutlet_sch<=4 ///
	& !missing(boroct2010) //
global sample level==3 & !missing(x_sch) & !missing(x) & !missing(obese) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 & nearestOutlet_sch<=4 ///
	& !missing(boroct2010)
*count if $sample

*** derive sample, overall and only AY 2013
{
* start, grade 9-12, districts 1-32
count if level==3 & district>=1 & district<=32 //1,435,103
unique(newid) if level==3 & district>=1 & district<=32
* has home address
count if level==3 & district>=1 & district<=32 & (missing(x)|missing(boroct2010)) //78,511
* has school address
count if level==3 & district>=1 & district<=32 & missing(x_sch) //64,582
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

* AY 2013
count if level==3 & district>=1 & district<=32 & year==2013
* has home address
count if level==3 & district>=1 & district<=32 & (missing(x)|missing(boroct2010))  & year==2013
* has school address
count if level==3 & district>=1 & district<=32 & missing(x_sch)  & year==2013
* has demographics data
count if level==3 & district>=1 & district<=32 & (missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor))  & year==2013
* has bmi data
count if level==3 & district>=1 & district<=32 & missing(obese)  & year==2013
* school not within half a mile from border
count if level==3 & district>=1 & district<=32 & dist_sch<2640  & year==2013
* multiple outlets as nearest 
count if level==3 & district>=1 & district<=32 & nearestOutlet_sch==5  & year==2013
* no outlets within half a mile from school 
count if level==3 & district>=1 & district<=32 & nearestDist_sch>2640  & year==2013
* sample
count if level==3 & !missing(x_sch) & !missing(obese) & !missing(x) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 & nearestOutlet_sch<=4 ///
	& !missing(boroct2010) & year==2013
}
.

* overlap in sample missing data
{
* home address + school address
unique(newid) if level==3 & district<=32 & district>=1 & missing(x) & missing(x_sch)
* home address + demographic
unique(newid) if level==3 & district<=32 & district>=1 & missing(x) & ///
	(missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor))
* home address + bmi
*unique(newid) if level==3 & district<=32 & district>=1 & missing(x) & missing(obese)
* home address + school <0.5 miles from border 
unique(newid) if level==3 & district<=32 & district>=1 & missing(x) & dist_sch<2640
* home address + multiple outlets
unique(newid) if level==3 & district<=32 & district>=1 & missing(x) & nearestOutlet_sch==5
* home address + no outlets within 0.5 miles from school 
unique(newid) if level==3 & district<=32 & district>=1 & missing(x)  & nearestDist_sch>2640
* school address + demographic
unique(newid) if level==3 & district<=32 & district>=1 & missing(x_sch) & ///
	(missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor))
* school address + bmi
*unique(newid) if level==3 & district<=32 & district>=1 & missing(x_sch) & missing(obese)
* school address + school <0.5 miles from border 
unique(newid) if level==3 & district<=32 & district>=1 & missing(x_sch) & dist_sch<2640
* school address + multiple outlets
unique(newid) if level==3 & district<=32 & district>=1 & missing(x_sch) & nearestOutlet_sch==5
* school address + no outlets within 0.5 miles from school 
unique(newid) if level==3 & district<=32 & district>=1 & missing(x_sch)  & nearestDist_sch>2640

* demo + bmi
*count if level==3 & district<=32 & district>=1 & (missing(grade)|missing(ethnic) ///
*	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
*	|missing(age)|missing(poor)) & missing(obese)
* demo + school <0.5 miles from border 
unique(newid) if level==3 & district<=32 & district>=1 & (missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor)) & dist_sch<2640
* demo + multiple outlets
unique(newid) if level==3 & district<=32 & district>=1 & (missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor)) & nearestOutlet_sch==5
* demo + no outlets within 0.5 miles from school
unique(newid) if level==3 & district<=32 & district>=1 & (missing(grade)|missing(ethnic) ///
	|missing(sped)|missing(native)|missing(female)|missing(eng_home) ///
	|missing(age)|missing(poor)) & nearestDist_sch>2640
* bmi + school <0.5 miles from border 
*unique(newid) if level==3 & district<=32 & district>=1 & missing(obese) & dist_sch<2640
* bmi+ multiple outlets 
*unique(newid) if level==3 & district<=32 & district>=1 & missing(obese) & nearestOutlet_sch==5
* bmi + no outlets within 0.5 miles from school
*unique(newid) if level==3 & district<=32 & district>=1 & missing(obese) & nearestDist_sch>2640
* school <0.5 miles from border + multiple outlets
unique(newid) if level==3 & district<=32 & district>=1 & dist_sch<2640 & nearestOutlet_sch==5
* school <0.5 miles from border + no outlets within 0.5 miles from school
unique(newid) if level==3 & district<=32 & district>=1 & dist_sch<2640 & nearestDist_sch>2640
* multiple outlets + no outlets within 0.5 miles from school 
unique(newid) if level==3 & district<=32 & district>=1 & nearestOutlet_sch==5 & nearestDist_sch>2640

* check demographic makeup in students with missing bmi
tab ethnic if level==3 & district<=32 & district>=1 & missing(obese)
tab ethnic if level==3 & district<=32 & district>=1
}
.

*** missing data at school level
{
* total num of schools in final sample
unique(bds)if level==3 & district<=32 & district>=1 & !missing(x_sch) & ///
	dist_sch>=2640 & nearestOutlet_sch!=5 & nearestDist_sch<=2640 
* schools with grade 9-12
unique(bds) if level==3
* charter school
unique(bds) if district==84 & level==3
* special ed only school 
unique(bds) if district==75 & level==3
* missing school address
unique(bds) if missing(x_sch) & level==3
* less than 0.5 miles from border
unique(bds) if dist_sch<2640 & level==3
* have multiple outlets
unique(bds) if nearestOutlet_sch==5 & level==3
* no outlets within 0.5 miles
unique(bds) if nearestDist_sch>2640 & level==3
}
.

*** examine overlap in missing data in school
{
* charter school + address
unique(bds) if level==3 & district==84 & missing(x_sch)
* charter school + <0.5 from border
unique(bds) if level==3 & district==84 & dist_sch<2640
* charter school + multiple outlets
unique(bds) if level==3 & district==84 & nearestOutlet_sch==5
* charter school + no outlets in 0.5 miles
unique(bds) if level==3 & district==84 & nearestDist_sch>2640

* special ed school + address
unique(bds) if level==3 & district==75 & missing(x_sch)
* special ed school + <0.5 from border
unique(bds) if level==3 & district==75 & dist_sch<2640
* special ed school + multiple outlets
unique(bds) if level==3 & district==75 & nearestOutlet_sch==5
* special ed school + no outlets in 0.5 miles
unique(bds) if level==3 & district==75 & nearestDist_sch>2640

* missing school address  + 0.5 miles from border
unique(bds) if level==3 & missing(x_sch) & dist_sch<2640
* missing school address + multiple outlets
unique(bds) if level==3 & missing(x_sch) & nearestOutlet_sch==5
* missing school address + no outlets within 0.5 miles
unique(bds) if level==3 & missing(x_sch) & nearestDist_sch>2640

* less than 0.5 miles from border + multiple outlets
unique(bds) if level==3 & dist_sch<2640 & nearestOutlet_sch==5
* less than 0.5 miles from border + no outlets in 0.5 miles
unique(bds) if level==3 & dist_sch<2640 & nearestDist_sch>2640

* multiple outlets + no outlets in 0.5 miles
unique(bds) if level==3 & nearestOutlet_sch==5 & nearestDist_sch>2640
}
.

*** number of student-year obs with missing bmi
count if level==3 & district>=1 & district<=32 & missing(obese)

* sample size per year, pre-/post-sample restrictions, unique newid and N
forvalues i=2009/2013 {
	*unique(newid) if level==3 & district>=1 & district<=32 & year==`i'
	*unique(newid) if $sample & year==`i'
	count if level==3 & district>=1 & district<=32 & year==`i'
	count if $sample & year==`i'
	*count if level==3 & district>=1 & district<=32 & missing(obese) & year==`i'
}
.

* check different combos for having multiple outlets as nearest, 2013
{
tab nearestOutlet_sch
tab nearestOutlet_sch if level==3 & district>=1 & district<=32 & year==2013

count if level==3 & district>=1 & district<=32 & FFOR_sch==BOD_sch & FFOR_sch<WS_sch & FFOR_sch<C6P_sch & year==2013 & !missing(FFOR_sch) //FFOR=BOD
count if level==3 & district>=1 & district<=32 & FFOR_sch==WS_sch & FFOR_sch<BOD_sch & FFOR_sch<C6P_sch & year==2013 & !missing(FFOR_sch) //FFOR=WS 
count if level==3 & district>=1 & district<=32 & FFOR_sch==C6P_sch & FFOR_sch<BOD_sch & FFOR_sch<WS_sch & year==2013 & !missing(FFOR_sch) //FFOR=C6P
count if level==3 & district>=1 & district<=32 & BOD_sch==WS_sch & BOD_sch<FFOR_sch & BOD_sch<C6P_sch & year==2013 & !missing(FFOR_sch) //BOD=WS
count if level==3 & district>=1 & district<=32 & BOD_sch==C6P_sch & BOD_sch<FFOR_sch & BOD_sch<WS_sch & year==2013 & !missing(FFOR_sch) //BOD<C6P
count if level==3 & district>=1 & district<=32 & WS_sch==C6P_sch & WS_sch<FFOR_sch & WS_sch<BOD_sch & year==2013 & !missing(FFOR_sch) //WS=C6P
count if level==3 & district>=1 & district<=32 & FFOR_sch==BOD_sch & FFOR_sch==WS_sch & FFOR_sch<C6P_sch & year==2013 & !missing(FFOR_sch) //FFOR=BOD=WS
count if level==3 & district>=1 & district<=32 & FFOR_sch==BOD_sch & FFOR_sch==C6P_sch & FFOR_sch<WS_sch & year==2013 & !missing(FFOR_sch) //FFOR=BOD=C6P
count if level==3 & district>=1 & district<=32 & FFOR_sch==WS_sch & FFOR_sch==C6P_sch & FFOR_sch<BOD_sch & year==2013 & !missing(FFOR_sch) //FFOR=WS=C6P
count if level==3 & district>=1 & district<=32 & C6P_sch==BOD_sch & C6P_sch==WS_sch & C6P_sch<FFOR_sch & year==2013 & !missing(FFOR_sch) //BOD=WS=C6P
count if level==3 & district>=1 & district<=32 & FFOR_sch==BOD_sch & FFOR_sch==WS_sch & FFOR_sch==C6P_sch & year==2013 & !missing(FFOR_sch) //FFOR=BOD=WS=C6P

* examine the students/schools with both FFOR and WS as nearest 
duplicates drop bds year FFOR_sch WS_sch if level==3 & district>=1 & district<=32 & FFOR_sch==WS_sch & FFOR_sch<BOD_sch & FFOR_sch<C6P_sch & year==2013 & !missing(FFOR_sch), force
tab bds if level==3 & district>=1 & district<=32 & FFOR_sch==WS_sch & FFOR_sch<BOD_sch & FFOR_sch<C6P_sch & year==2013 & !missing(FFOR_sch), sort
br bds FFORname_sch WSname_sch WS_sch if level==3 & district>=1 & district<=32 & FFOR_sch==WS_sch & FFOR_sch<BOD_sch & FFOR_sch<C6P_sch & year==2013 & !missing(FFOR_sch)

* examine the students/schools with both FFOR and BOD as nearest 
tab bds if level==3 & district>=1 & district<=32 & FFOR_sch==BOD_sch & FFOR_sch<WS_sch & FFOR_sch<C6P_sch & year==2013 & !missing(FFOR_sch)
duplicates drop bds year FFOR_sch WS_sch if level==3 & district>=1 & district<=32 & FFOR_sch==BOD_sch & FFOR_sch<WS_sch & FFOR_sch<C6P_sch & year==2013 & !missing(FFOR_sch), force
br bds FFORname_sch BODname_sch FFOR_sch if level==3 & district>=1 & district<=32 & FFOR_sch==BOD_sch & FFOR_sch<WS_sch & FFOR_sch<C6P_sch & year==2013 & !missing(FFOR_sch)
}
.

*** regressions
global demo b5.ethnic female poor native sped eng_home age i.grade i.year

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
mdesc obese ethnic sped poor nycha
mi misstable patterns poor sped
mi misstable summarize poor sped

* check ranges for some variables
sum age FFOR_sch BOD_sch WS_sch C6P_sch

* check num of students who never had bmi taken, or nycha status
{
sum obese
bys newid: egen min_obese = min(obese)
gen no_obese = (min_obese==.)
drop min_obese
codebook no_obese if no_obese==1 & level==3 & district<=32 & district>=1 //122,786
unique(newid) if no_obese==1 & level==3 & district<=32 & district>=1 //75,418

sum nycha
bys newid: egen min_nycha = min(nycha)
gen no_nycha = (min_nycha==.)
drop min_nycha
codebook no_nycha if no_nycha==1 & level==3 & district<=32 & district>=1 //93,303
unique(newid) if no_nycha==1 & level==3 & district<=32 & district>=1 //49,596

unique(newid) if no_obese==1 & no_nycha==1 & level==3 & district<=32 & district>=1 //12,322, 16,038
}
.

* patterns of missing data
mi set mlong

* add sped_ever
*bys newid: egen sped_ever = max(sped)
*br newid year sped sped_ever

*** reshape data from long to wide
drop x y lon lat continuous lat_sch lon_sch bbl* weight_kg height_cm ///
	bmi sevobese underweight
mi reshape wide grade age lep sped dist boro bds district level x_sch y_sch dist_sch boro_sch ///
	zbmi obese overweight FFOR_sch FFORname_sch BOD_sch BODname_sch WS_sch ///
	WSname_sch C6P_sch C6Pname_sch eng_home nearestDist_sch nearestOutlet_sch ///
	nearestDistk_sch boroct2010 bldg_type nycha nearestGroup_sch, i(newid) j(year)
* for testing only, select 10% of the sample
*sample 10

* check collinearity
_rmcoll obese* ethnic female native age* poor sped* FFOR_sch* BOD_sch* WS_sch* ///
	C6P_sch* eng_home* grade* //eng_home and grade ommited, collinearity
display r(varlist)

*** imputation prepare
mi register imputed obese* native age* 
mi register imputed poor sped*
mi register imputed nycha*
mi register imputed FFOR_sch* BOD_sch* WS_sch* C6P_sch*
mi register imputed female ethnic
compress

*** imputation
* predictor: other years of BMI, covariates
mi xtset, clear
timer clear
timer on 1
mi impute chained (logit, augment) obese* poor sped* native female nycha* ///
	(mlogit, augment) ethnic ///
	(reg) FFOR_sch* BOD_sch* WS_sch* C6P_sch* age*, ///
	add(5) rseed(5) force replace noisily showcommand 
timer off 1

* reshape back to long data
mi reshape long grade age lep sped dist x_sch y_sch boro bds district level dist_sch boro_sch ///
	zbmi obese overweight FFOR_sch FFORname_sch BOD_sch BODname_sch WS_sch ///
	WSname_sch C6P_sch C6Pname_sch eng_home nearestDist_sch nearestOutlet_sch ///
	nearestDistk_sch boroct2010 bldg_type nycha nearestGroup_sch, i(newid) j(year)

* sanity check for imputed values
bys _mi_m: sum FFOR_sch BOD_sch WS_sch C6P_sch age
mi register passive nearestDist_sch nearestDistk_sch
mi register passive nearestOutlet_sch 

* fill in new nearestOutlet_sch and nearestDistk_sch
drop nearestDist_sch nearestDistk_sch
mi passive: egen nearestDist_sch = rowmin(FFOR_sch BOD_sch WS_sch C6P_sch) if !missing(FFOR_sch)
mi passive: gen nearestDistk_sch = nearestDist_sch/1000 if !missing(FFOR_sch)

mi passive: replace nearestOutlet_sch = 1 if FFOR_sch<BOD_sch & FFOR_sch<WS_sch & FFOR_sch<C6P_sch & _mi_m!=0
mi passive: replace nearestOutlet_sch = 2 if BOD_sch<FFOR_sch & BOD_sch<WS_sch & BOD_sch<C6P_sch & _mi_m!=0
mi passive: replace nearestOutlet_sch = 3 if WS_sch<BOD_sch & WS_sch<FFOR_sch & WS_sch<C6P_sch & _mi_m!=0
mi passive: replace nearestOutlet_sch = 4 if C6P_sch<BOD_sch & C6P_sch<WS_sch & C6P_sch<FFOR_sch & _mi_m!=0
mi passive: replace nearestOutlet_sch = 5 if missing(nearestOutlet_sch) & _mi_m!=0

bys _mi_m: sum nearestDist_sch nearestOutlet_sch

* create time lag, t-1
*sort newid year
sort newid _mi_m year
bys newid _mi_m: gen nearestDistk_sch1 = nearestDistk_sch[_n-1]
bys newid _mi_m: gen nearestOutlet_sch1 = nearestOutlet_sch[_n-1]
mi register passive nearestDistk_sch1 nearestOutlet_sch1

* create nearest group as london model
mi register passive nearestGroup_sch
mi passive: replace nearestGroup_sch = 1 if nearestOutlet_sch==1 & nearestDist_sch<=1320 & _mi_m!=0
mi passive: replace nearestGroup_sch = 2 if nearestOutlet_sch==2 & nearestDist_sch<=1320 & _mi_m!=0
mi passive: replace nearestGroup_sch = 3 if nearestOutlet_sch==3 & nearestDist_sch<=1320 & _mi_m!=0
mi passive: replace nearestGroup_sch = 4 if nearestOutlet_sch==4 & nearestDist_sch<=1320 & _mi_m!=0
mi passive: replace nearestGroup_sch = 5 if nearestOutlet_sch==1 & nearestDist_sch<=2640 & nearestDist_sch>1320 & _mi_m!=0
mi passive: replace nearestGroup_sch = 6 if nearestOutlet_sch==2 & nearestDist_sch<=2640 & nearestDist_sch>1320 & _mi_m!=0
mi passive: replace nearestGroup_sch = 7 if nearestOutlet_sch==3 & nearestDist_sch<=2640 & nearestDist_sch>1320 & _mi_m!=0
mi passive: replace nearestGroup_sch = 8 if nearestOutlet_sch==4 & nearestDist_sch<=2640 & nearestDist_sch>1320 & _mi_m!=0

compress
save data\food-environment-reconstructed-mi2.dta, replace

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
mi xtset, clear
{
eststo clear
eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch##female ///
	$demo if $sample, robust absorb(boroct2010) cluster(newid) //main model, cluster newid
quietly eststo: mimrgns i.nearestOutlet_sch, predict(xb) post //table 3, col 3 predicted likelihood
esttab using raw-tables\tables_rr.rtf, replace nogaps title("table3 main model") b(3) se(3) 

* test joint significance 
mi estimate: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if $sample, robust absorb(boroct2010) cluster(newid)
mi test c.nearestDistk_sch#1.nearestOutlet_sch ///
	c.nearestDistk_sch#3.nearestOutlet_sch c.nearestDistk_sch#4.nearestOutlet_sch
} //joint significance: F=0.9491
.

* table 4, london model
{
eststo clear
quietly eststo: mi estimate, post: areg obese b2.nearestGroup $demo ///
	if $sample, robust absorb(boroct2010) cluster(newid)
quietly eststo: mimrgns i.nearestGroup_sch, predict(xb) post
esttab using raw-tables\tables_rr.rtf, append nogaps title("table4-london") b(3) se(3)
esttab using raw-tables\tables_rr_CI.csv, replace nogaps title("table4-london-CI") ci(10) b(10)
}
.

*** supp analysis
* stratify by gender
{
eststo clear
eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch##female ///
	$demo if $sample, robust absorb(boroct2010) cluster(newid)
eststo: mimrgns i.nearestOutlet_sch, over(female) predict(xb) post
esttab using raw-tables\tables_rr.rtf, append b(3) se(3) nogaps title("stratify by gender")
esttab using raw-tables\tables_rr_CI.csv, append b(3) ci(3) nogaps title("stratify by gender, CI")
}
.
* stratify by race/ethnicity
{
eststo clear
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch##b5.ethnic ///
	$demo if $sample, robust absorb(boroct2010) cluster(newid)
eststo: mimrgns i.nearestOutlet_sch, over(i.ethnic) predict(xb) post
esttab using raw-tables\tables_rr.rtf, append b(3) se(3) nogaps title("stratify by race")
esttab using raw-tables\tables_rr_CI.csv, append b(3) ci(3) nogaps title("stratify by race, CI")
}
.

* stratify by boro
{
eststo clear
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch##b1.boro_sch $demo ///
		if $sample, robust absorb(boroct2010) cluster(newid)
quietly eststo: mimrgns i.nearestOutlet_sch, over(i.boro) predict(xb) post
esttab using raw-tables\tables_rr.rtf, append b(3) se(3) nogaps title("stratify by boro")
esttab using raw-tables\tables_rr_CI.csv, append b(3) ci(3) nogaps title("stratify by boro, CI")
}
.

* following table 3
* compare point estimates on diff points along the lines
* compare diff points on the same line, and same dist on diff lines
{
*set matsize 1000
quietly: mi estimate: areg obese c.nearestDist_sch##b2.nearestOutlet_sch $demo ///
	if $sample, robust absorb(boroct2010) cluster(newid)
eststo: mimrgns emargins i.nearestOutlet_sch, at(nearestDist_sch=(0(264)2640)) pwcompare post //copy the table
esttab using raw-tables\tables_rr.rtf, append b(3) se(3) nogaps title("table3-95CI-estimates")
esttab using raw-tables\tables_rr_CI.csv, append b(3) ci(3) nogaps title("table3-95CI-estimates")
}
. 

{ // sensitivity checks, per reviewer requests
eststo clear
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if $sample, robust absorb(boroct2010) cluster(bds) //cluster at bds level
quietly eststo: mimrgns i.nearestOutlet_sch, predict(xb) post
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if $sample & poor==1, robust absorb(boroct2010) cluster(newid) //limit sample to poor students
quietly eststo: mimrgns i.nearestOutlet_sch, predict(xb) post
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch##b2.nearestOutlet_sch ///
	$demo if level==3 & !missing(x_sch) & !missing(obese) ///
	& dist_sch>=2640 & district>=1 & district<=32 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & nearestDist_sch<=2640 ///
	& !missing(boroct2010), robust absorb(boroct2010) cluster(newid) // allow multiple nearest outlets
quietly eststo: mimrgns i.nearestOutlet_sch, predict(xb) post
quietly eststo: mi estimate, post: areg obese c.nearestDistk_sch1##b2.nearestOutlet_sch1 ///
	$demo if $sample & nearestOutlet_sch1<=4, robust absorb(boroct2010) cluster(newid) //main model, t-1
quietly eststo: mimrgns i.nearestOutlet_sch, predict(xb) post
esttab using raw-tables\tables_rr.rtf, append nogaps ///
	title("sensitivity-check-per-reviewers-requests") b(3) se(3) 
}
.

}
.
