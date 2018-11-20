clear all
set more off
set showbaselevels on

cd "S:\Personal\hw1220\FF free zone"
use "food_environment_2009-2013_FF_free_zone.dta", clear

cd "C:\Users\wue04\Box Sync\school-food-env\school-food-environment"
********************************************************************************
* define sample
global sample halfmile_home==0 & !missing(grade) & !missing(nat) & halfmile_sch==0 & level==3
global dist nearestAnyall_sch<=2640 & nearestOutlet_sch!=5

* covariates
global demo b5.ethnic2 female poorever native sped lep age i.graden i.year
global demo2 b5.ethnic2 female poorever native sped engathome age i.graden i.year
global house publichousing fam1 coop fam2to4 fam5ormore condo mixeduse otherres nonres
global tenblocks n2640BOD_sch n2640C6P_sch n2640FFOR_sch n2640WS_sch
********************************************************************************
* create new variables
gen nearestAnyall1000_sch = nearestAnyall_sch/1000

* 0-5 & 5-10 blocks, london model
gen nearestGroup_sch = 1 if $sample & nearestOutlet_sch==1 & nearestAnyall_sch<1320
replace nearestGroup_sch = 2 if $sample & nearestOutlet_sch==2 & nearestAnyall_sch<1320
replace nearestGroup_sch = 3 if $sample & nearestOutlet_sch==3 & nearestAnyall_sch<1320
replace nearestGroup_sch = 4 if $sample & nearestOutlet_sch==4 & nearestAnyall_sch<1320
replace nearestGroup_sch = 5 if $sample & nearestOutlet_sch==1 & nearestAnyall_sch<2640 & nearestAnyall_sch>=1320
replace nearestGroup_sch = 6 if $sample & nearestOutlet_sch==2 & nearestAnyall_sch<2640 & nearestAnyall_sch>=1320
replace nearestGroup_sch = 7 if $sample & nearestOutlet_sch==3 & nearestAnyall_sch<2640 & nearestAnyall_sch>=1320
replace nearestGroup_sch = 8 if $sample & nearestOutlet_sch==4 & nearestAnyall_sch<2640 & nearestAnyall_sch>=1320

label var nearestGroup_sch "nearest food outlet in group"
label define group 1 "FFOR 0-5" 2 "BOD 0-5" 3 "WS 0-5" 4 "C6P 0-5" ///
	5 "FFOR 5-10" 6 "BOD 5-10" 7 "WS 5-10" 8 "C6P 5-10", replace
label values nearestGroup_sch group
tab nearestGroup

destring boro_sch, replace

* make figures for supp analyses
label define outlet 1 "Fast food" 2 "Corner store" 3 "Wait service" 4 "Supermarket" ///
	5 "More than 1", replace
label values nearestOutlet_sch outlet

********************************************************************************
* summary stats
* table 1
* female, race, poverty, lep, sped, native, obesity
* age, zbmi
foreach var in female ethnic poor engathome sped native obese {
	tab nearestOutlet_sch `var' if $sample & $dist & year==2013, row
}
.
sum age zbmi if $sample & $dist & year==2013
bys nearestOutlet_sch: sum age zbmi if $sample & $dist & year==2013

* table 2
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

* regression, table 3
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

* figure 1
quietly: areg obese c.nearestAnyall_sch##b1.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640))
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

* table 4
eststo clear
quietly eststo: areg obese b2.nearestGroup $demo2 $house if $sample & $dist, robust absorb(boroct2010)
eststo: margins i.nearestGroup, post
esttab using main_tables.rtf, append nogaps title("table4 london") b(3) se(3)
esttab using main_tables.csv, append nogaps title("table4 london") ci(3)

*** suuplemental tables
* stratification by gender
eststo clear
forvalues i=0/1 {
	quietly eststo: areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch ///
		$demo2 $house if $sample & $dist & female==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, post
}
.
esttab using supp_table.rtf, replace b(3) se(3) nogaps title("stratify by gender")

* stratification by race
eststo clear
forvalues i=2/5 {
	quietly eststo: areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch ///
		female poorever native sped engathome age i.graden i.year $house ///
		if $sample & $dist & ethnic==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, post
}
.
esttab using supp_table.rtf, append b(3) se(3) nogaps title("stratify by race")

* stratify by boro
eststo clear
forvalues i=1/5 {
	quietly eststo: areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch $demo2 ///
		$house if $sample & $dist & boro_sch==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, post
}
.
esttab using supp_table.rtf, append b(3) se(3) nogaps title("stratify by boro")

*** export margins and CI estimates to make figures
*** export .csv files
eststo clear
forvalues i=0/1 {
	quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch ///
		$demo2 $house if $sample & $dist & female==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) post
}
.
esttab using data\supp_table_gender.csv, replace b(3) ci(3) nogaps title("stratify by gender")

eststo clear
forvalues i=2/5 {
	quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch ///
		female poorever native sped engathome age i.graden i.year $house ///
		if $sample & $dist & ethnic==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) post
}
.
esttab using data\supp_table_race.csv, replace b(3) ci(3) nogaps title("stratify by race")

eststo clear
forvalues i=1/5 {
	quietly eststo: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch $demo2 ///
		$house if $sample & $dist & boro_sch==`i', robust absorb(boroct2010)
	quietly eststo: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) post
}
.
esttab using data\supp_table_boro.csv, replace b(3) ci(3) nogaps title("stratify by boro")

/*******************************************************************************
* by gender
* male students 
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch ///
		$demo2 $house if $sample & $dist & female==0, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) level(95)
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("Sample: male students") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(`=0.12' "0.12" `=0.13' "0.13" `=0.14' "0.14" `=0.15' "0.15" ///
	`=0.16' "0.16" `=0.17' "0.17" `=0.18' "0.18" `=0.19' "0.19" `=0.2' "0.2", ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ci4opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_male.gph, replace

* female students 
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch ///
		$demo2 $house if $sample & $dist & female==1, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) level(10)
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("Sample: female students") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(`=0.09' "0.09" `=0.1' "0.1" `=0.11' "0.11" `=0.12' "0.12" ///
	`0.13' "0.13" `=0.14' "0.14" `=0.15' "0.15" `=0.16' "0.16" `=0.17' "0.17", ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ci4opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_female.gph, replace

* stratify by race
* asian
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch ///
	female poorever native sped engathome age i.graden i.year $house ///
	if $sample & $dist & ethnic==2, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) level(10)
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(`=0' "0" `=0.03' "0.03" `=0.06' "0.06" `=0.09' "0.09" `=0.12' "0.12" `=0.15' "0.15" `=0.18' "0.18" `=0.21' "0.21" , ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ci4opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_asian.gph, replace

* hisp
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch ///
	female poorever native sped engathome age i.graden i.year $house ///
	if $sample & $dist & ethnic==3, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) level(10)
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(`=0.14' "0.14" `=0.15' "0.15" `=0.16' "0.16" `=0.17' "0.17" ///
	`=0.18' "0.18" `=0.19' "0.19" `=0.2' "0.2" `=0.21' "0.21", ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ci4opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_hisp.gph, replace

* black
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch ///
	female poorever native sped engathome age i.graden i.year $house ///
	if $sample & $dist & ethnic==4, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) level(10)
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(`=0.14' "0.14" `=0.15' "0.15" `=0.16' "0.16" `=0.17' "0.17" ///
	`=0.18' "0.18" `=0.19' "0.19" `=0.2' "0.2" `=0.21' "0.21", ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ci4opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_black.gph, replace

* white
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch ///
	female poorever native sped engathome age i.graden i.year $house ///
	if $sample & $dist & ethnic==5, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640)) level(10)
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(`=0.14' "0.14" `=0.15' "0.15" `=0.16' "0.16" `=0.17' "0.17" ///
	`=0.18' "0.18" `=0.19' "0.19" `=0.2' "0.2" `=0.21' "0.21", ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ci4opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_white.gph, replace

* by boro figures, manhattan
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist & boro_sch==1, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640))
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("Manhattan") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(, ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ci4opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_manhattan.gph, replace

* by boro figures, bronx
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist & boro_sch==2, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640))
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("Bronx") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(, ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ci4opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_bronx.gph, replace

* by boro figures, brooklyn
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist & boro_sch==3, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640))
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("Brooklyn") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(, ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ci4opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_brooklyn.gph, replace

* by boro figures, queens
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist & boro_sch==4, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640))
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("Queens") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(, ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ci4opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_queens.gph, replace

* by boro figures, SI
quietly: areg obese c.nearestAnyall_sch##b2.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist & boro_sch==5, robust absorb(boroct2010)
quietly: margins i.nearestOutlet_sch, at(nearestAnyall_sch=(0(264)2640))
marginsplot, legend(label(1 "Fast food") label(2 "Corner store") ///
	label(3 "Wait service") label(4 "Supermarket") position(7) size(vsmall)) ///
	title("Staten Island") ///
	xtitle("Distance to nearest food outlet (ft.)", size(vsmall)) ///
	ytitle("Likelihood of obesity", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	ylabel(, ///
	labsize(vsmall) glwidth(vthin) glcolor(black%20)) ///
	graphregion(color(white)) bgcolor(white) ///
	plot1opts(msize(tiny)) plot2opts(msize(tiny)) ///
	plot3opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	plot4opts(lpattern(shortdash) msize(tiny) lcolor(%60)) ///
	ci1opts(lcolor(%0)) ci2opts(lcolor(%0)) ci3opts(lcolor(%0)) ///
	level(10)
graph save figures\likelihood_si.gph, replace
*******************************************************************************/


/*
eststo clear
* interaction by gender
quietly eststo: areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch##female $demo2 ///
	$house if $sample & $dist, robust absorb(boroct2010)
eststo: margins i.nearestOutlet_sch, post by(female)
* interaction by race
quietly eststo: areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch##b5.ethnic $demo2 ///
	$house if $sample & $dist, robust absorb(boroct2010)
eststo: margins i.nearestOutlet_sch, post by(i.ethnic)
esttab using supp_table.rtf, replace b(3) se(3) nogaps title("interaction by gender/race")

*test
areg obese c.nearestAnyall1000_sch##b2.nearestOutlet_sch $demo2 ///
	$house if $sample & $dist & boro_sch==5, robust absorb(boroct2010)
margins i.nearestOutlet_sch, post
*/





















