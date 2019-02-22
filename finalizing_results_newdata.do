clear all
set more off
set showbaselevels on

use "S:\Personal\hw1220\FF free zone\food-environment-reconstructed.dta", clear
cd "C:\Users\wue04\Box Sync\school-food-env\school-food-environment"

************* house cleaning ***************************************************
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
	& district<=32 & continuous==1 & !missing(FFOR_sch) & nearestDist_sch<=2640 ///
	& !missing(nearestOutlet) //1501

unique(bds) if level==3 & !missing(x_sch) & dist_sch>2640 & district>=1 ///
	& district<=32 & continuous==1 & !missing(FFOR_sch) & nearestDist_sch<=2640 ///
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
unique(newid) if $start_sample & nearestDist_sch>2640 //49731
* not being in continuously operated schools
unique(newid) if $start_sample & continuous!=1 //98263
* sample
unique(newid) if level==3 & !missing(x) & !missing(x_sch) & !missing(obese) ///
	& dist>=2640 & dist_sch>=2640 & district>=1 & district<=32 & continuous==1 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & !missing(FFOR_sch) & nearestDist_sch<=2640 & nearestOutlet<=4 //361942
* sample, student-year observation
count if level==3 & !missing(x) & !missing(x_sch) & !missing(bbl) & !missing(obese) ///
	& dist>=2640 & dist_sch>=2640 & district>=1 & district<=32 & continuous==1 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & !missing(FFOR_sch) & nearestDist_sch<=2640 & nearestOutlet<=4 //734,861

global sample level==3 & !missing(x) & !missing(x_sch) & !missing(obese) ///
	& dist>=2640 & dist_sch>=2640 & district>=1 & district<=32 & continuous==1 ///
	& !missing(grade) & !missing(ethnic) & !missing(sped) ///
	& !missing(native) & !missing(female) & !missing(eng_home) & !missing(age) ///
	& !missing(poor) & !missing(FFOR_sch) & nearestDist_sch<=2640 & nearestOutlet<=4
sum age if $sample
tab nearestOutlet if $sample

********************************************************************************
*** analytical section
*** summary stats and regression
global demo b5.ethnic female poor native sped eng_home age i.grade i.year



********************************************************************************
* summary stats
* table 1
{
* female, race, poverty, lep, sped, native, obesity
* age, zbmi
foreach var in female ethnic poor engathome sped native obese {
	tab nearestOutlet_sch `var' if $sample & $dist & year==2013, row
}
.
sum age zbmi if $sample & $dist & year==2013
bys nearestOutlet_sch: sum age zbmi if $sample & $dist & year==2013
}
.

* table 2
{
* distance, overall and by nearest outlet type
sum nearestAnyall_sch if $sample & $dist & year==2013
tabstat nearestAnyall_sch if $sample & $dist & year==2013, ///
	by(nearestOutlet) stats(mean sd count)
tabstat nearestAnyall_sch if $sample & nearestAnyall<1320 & year==2013, ///
	by(nearestOutlet) stats(mean sd count)
tabstat nearestAnyall_sch if $sample & nearestAnyall>=1320 & nearestAnyall<=2640 & year==2013, ///
	by(nearestOutlet) stats(mean sd count)
tab nearestGroup if $sample & $dist & year==2013
tab nearestOutlet if $sample & $dist & year==2013 & nearestAnyall<1320 
*tab nearestOutlet if $sample & $dist & year==2013 & nearestAnyall>=1320 & nearestAnyall<=2640
}
.

* regression, table 3
{
eststo clear
*quietly eststo: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch $demo2 ///
*	$house if $sample & $dist, robust absorb(boroct2010)
quietly eststo: areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist, robust absorb(boroct2010)
*quietly eststo: areg obese b2.nearestOutlet_sch c.nearestAnyall_sch#b2.nearestOutlet_sch ///
*	$demo2 $house if $sample & $dist, robust absorb(boroct2010)
quietly eststo: margins i.nearestOutlet_sch, post //table 3, col 3 predicted likelihood
*quietly eststo: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch $demo2 ///
*	$house if $sample & $dist, robust absorb(boroct2010)
esttab using main_tables.rtf, replace nogaps title("table3 main model") b(3) se(3) 
esttab using main_tables.csv, replace nogaps title("table3 main model") ci(3)

*test joint significance in model 2
areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist, robust absorb(boroct2010)
testparm nearestAnyall1000_sch c.nearestAnyall1000_sch#b2.nearestOutlet_sch

*test joint significance in model 2
*but test the joint significance pair wise: FF+dist*FF, BOD+dist*BOD, etc.
tab nearestOutlet_sch, gen(outlet)
areg obese c.nearestAnyall1000_sch##outlet1 ///
	c.nearestAnyall1000_sch##outlet3 c.nearestAnyall1000_sch##outlet4 $demo2 ///
	$house if $sample & $dist, robust absorb(boroct2010)
testparm nearestAnyall1000_sch c.nearestAnyall1000_sch#outlet1 //p=0.0001
testparm nearestAnyall1000_sch c.nearestAnyall1000_sch#outlet2 //p=0.0003
testparm nearestAnyall1000_sch c.nearestAnyall1000_sch#outlet3 //p=0.0009
testparm nearestAnyall1000_sch c.nearestAnyall1000_sch#outlet4 //p=0.0014
}
.

* figure 1
{
quietly: areg obese c.nearestAnyall_sch##b1.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist, robust absorb(boroct2010) 
quietly: margins nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640))
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(`=0.06' "0.06" `=0.08' "0.08" `=0.1' "0.1" `=0.12' "0.12" 
	`=0.14' "0.14" `=0.16' "0.16"  `=0.18' "0.18" `=0.2' "0.2", ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60))
graph save likelihood_10block_without_more_than_1.gph, replace

* figure 1, export data to .csv
eststo clear
quietly: areg obese c.nearestAnyall_sch##b1.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist, robust absorb(boroct2010)
quietly eststo: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) post
esttab using data\fig1.csv, replace b(10) ci(10) nogaps title("fig1")
}
.

* following table 3
* compare point estimates on diff points along the lines
* compare diff points on the same line, and same dist on diff lines
{
set matsize 1000
quietly: areg obese c.nearestAnyall_sch##b1.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist, robust absorb(boroct2010) 
eststo: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) pwcompare post //copy the tablee
quietly: areg obese c.nearestAnyall_sch##b1.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist, robust absorb(boroct2010) 
margins r.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) //copy the table
}
.

* table 4
{
eststo clear
quietly eststo: areg obese b2.nearestGroup $demo2 $house $tenblocks ///
	if $sample & $dist, robust absorb(boroct2010)
eststo: margins i.nearestGroup, post
esttab using main_tables.rtf, append nogaps title("table4 london") b(3) se(3)
esttab using main_tables_margins_estimates.csv, append nogaps title("table4 london") ci(10) b(10)
}
.

*** suuplemental tables
* stratification by gender
{
eststo clear
forvalues i=0/1 {
	quietly eststo: areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch ///
		$demo2 $house if $sample & $dist & female==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, post
}
.
esttab using supp_table.rtf, replace b(3) se(3) nogaps title("stratify by gender")
esttab using raw-tables\supp_table.rtf, append b(3) ci(3) nogaps title("stratify by gender, CI")
}
.

* stratification by race
{
eststo clear
forvalues i=2/5 {
	quietly eststo: areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch ///
		female poorever native sped engathome age i.graden i.year $house ///
		if $sample & $dist & ethnic==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, post
}
.
esttab using supp_table.rtf, append b(3) se(3) nogaps title("stratify by race")
esttab using raw-tables\supp_table.rtf, append b(3) ci(3) nogaps title("stratify by race, CI")
}
.

* stratify by boro
{
eststo clear
forvalues i=1/5 {
	quietly eststo: areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch $demo2 ///
		$house if $sample & $dist & boro_sch==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, post
}
.
esttab using supp_table.rtf, append b(3) se(3) nogaps title("stratify by boro")
esttab using supp_table.rtf, append b(3) ci(3) nogaps title("stratify by boro, CI")
}
.

*** export margins and CI estimates to make figures
*** export .csv files
{
eststo clear
forvalues i=0/1 {
	quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch ///
		$demo2 $house if $sample & $dist & female==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) post
}
.
esttab using data\supp_table_gender.csv, replace b(10) ci(10) nogaps title("stratify by gender")

eststo clear
forvalues i=2/5 {
	quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch ///
		female poorever native sped engathome age i.graden i.year $house ///
		if $sample & $dist & ethnic==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) post
}
.
esttab using data\supp_table_race.csv, replace b(10) ci(10) nogaps title("stratify by race")

eststo clear
forvalues i=1/5 {
	quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch $demo2 ///
		$house if $sample & $dist & boro_sch==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) post
}
.
esttab using data\supp_table_boro.csv, replace b(10) ci(10) nogaps title("stratify by boro")
}
.

*** new sample
* include not continuously operated schools
* exclude housing variables
