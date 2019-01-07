clear all
set more off
set showbaselevels on

cd "S:\Personal\hw1220\food environment paper 2"
use food_environment_2009-2013.dta, clear
keep newid-bbl boroct2010 boro cb2010-bbl_sch boroct2010_sch boro_sch sch ///
	district-level bmi zbmi sevobese-underweight zread-res_unitmsg ///
	nearestBODsn-nearestFFORsn
unique(newid year) //sanity check before merging
compress
cd "S:\Personal\hw1220\FF free zone"
save temp.dta, replace

use food_environment_2009-2013_FF_free_zone.dta, clear
keep newid year name nearestC6Psn_sch-nearestOutlet_sch distToSt nearestAnyall_sch ///
	n2640BOD_sch n2640C6P_sch n2640WS_sch n2640FFOR_sch n1320BOD_sch ///
	n1320C6P_sch n1320WS_sch n1320FFOR_sch
unique(newid year) //sanity check before merging
merge 1:1 newid year using temp.dta
drop if _mer!=3
drop _merge
compress

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

********************************************************************************
*** check variations within cells
{
* select top 10 census tracts that are heavily black/hispanic/asian
* see how much variance is there for nearest outlet distance and type of outlet to school
* use 2013 as example
sort boroct2010 ethnic
gen marker=1 if $sample & $dist & year==2013
replace marker=0 if missing(marker)

bys boroct2010: egen pop_total = sum(marker) if $sample & $dist & year==2013
bys boroct2010 ethnic: egen pop_subgroup = sum(marker) if $sample & $dist & year==2013
hist pop_total //looks like a reasonable distribution
gen percent_subgroup = pop_sub/pop_total if $sample & $dist & year==2013
drop marker
compress
preserve

keep if $sample & $dist & year==2013
duplicates drop boroct2010 ethnic, force
keep boroct2010 ethnic percent pop*
gsort -ethnic -percent //find out top 10 CTs heavily leaning towards a specific race

foreach race in asian black hisp white {
	gen `race'=0
}
.

* have enough total num of students until the sum reaches ~1,000 obs
replace asian=(boroct2010=="40456.00"|boroct2010=="10008.00"|boroct2010=="10029.00"| ///
	boroct2010=="10041.00"|boroct2010=="10027.00"|boroct2010=="10016.00"| ///
	boroct2010=="30104.00"|boroct2010=="30106.00"|boroct2010=="40797.01"| ///
	boroct2010=="40861.00")
replace hisp=(boroct2010=="30533.00"|boroct2010=="10267.00"|boroct2010=="20001.00"| ///
	boroct2010=="30531.00"|boroct2010=="10102.00"|boroct2010=="30515.00"| ///
	boroct2010=="30529.00"|boroct2010=="10109.00"|boroct2010=="30453.00"| ///
	boroct2010=="10285.00"|boroct2010=="10277.00"|boroct2010=="10269.00"| ///
	boroct2010=="30002.00"|boroct2010=="30523.00"|boroct2010=="30527.00"| ///
	boroct2010=="10293.00")
replace black=(boroct2010=="10103.00"|boroct2010=="10113.00"|boroct2010=="40594.00"| ///
	boroct2010=="40598.00"|boroct2010=="30936.00"|boroct2010=="40518.00"| ///
	boroct2010=="41010.02"|boroct2010=="30862.00"|boroct2010=="30856.00"| ///
	boroct2010=="30866.00"|boroct2010=="40616.01"|boroct2010=="31004.00"| ///
	boroct2010=="40682.00"|boroct2010=="31006.00"|boroct2010=="30848.00"| ///
	boroct2010=="30780.00"|boroct2010=="40590.00"|boroct2010=="40530.00"| ///
	boroct2010=="30984.00"|boroct2010=="30992.00")
replace white=(boroct2010=="30616.00"|boroct2010=="40607.01"|boroct2010=="10142.00"| ///
	boroct2010=="30458.00"|boroct2010=="30056.02"|boroct2010=="40299.00"| ///
	boroct2010=="10149.00"|boroct2010=="40916.01"|boroct2010=="10060.00"| ///
	boroct2010=="10013.00"|boroct2010=="10096.00"|boroct2010=="10094.00"| ///
	boroct2010=="30610.02"|boroct2010=="50244.02"|boroct2010=="30356.02"| ///
	boroct2010=="10037.00"|boroct2010=="30702.01"|boroct2010=="40922.00"| ///
	boroct2010=="50279.00"|boroct2010=="30612.00"|boroct2010=="50198.00"| ///
	boroct2010=="50244.01"|boroct2010=="30354.00"|boroct2010=="30350.00"| ///
	boroct2010=="30414.02")
drop pop* percent ethnic
duplicates drop boroct2010, force
compress
save data\race_leaning_ct.dta, replace
********************************************************************************
merge m:1 boroct2010 using data\race_leaning_ct.dta
drop _mer

*** summary stats:
* mean, median, min, max, sd
eststo clear
estpost tabstat nearestAnyall_sch if $sample & $dist & year==2013 & (asian==1| ///
	hisp==1|black==1|white==1), stat(mean sd count min max)
esttab . using top10race_distance_variance.rtf, replace ///
	cells("mean(fmt(%12.0f)) sd(fmt(%12.0f)) count(fmt(%12.0f)) min(fmt(%12.0f)) max(fmt(%12.0f))") ///
	title("summary total")
unique(boroct2010) if $sample & $dist & year==2013 & (asian==1|	hisp==1|black==1|white==1)

eststo clear
foreach race in asian hisp black white {
	estpost tabstat nearestAnyall_sch if $sample & $dist & year==2013 & `race'==1, ///
		stat(mean sd count min max)
	esttab . using top10race_distance_variance.rtf, append ///
		cells("mean(fmt(%12.0f)) sd(fmt(%12.0f)) count(fmt(%12.0f)) min(fmt(%12.0f)) max(fmt(%12.0f))") ///
		title("summary `race'")
	unique(boroct2010) if $sample & $dist & year==2013 & `race'==1
}
.

* type of nearest food outlet
* do they vary
tab nearestGroup if $sample & $dist & year==2013 & (asian==1|hisp==1|black==1|white==1)
foreach race in asian hisp black white {
	tab nearestGroup if $sample & $dist & year==2013 & `race'==1
}
.
}
.

* make histograms
{
hist nearestAnyall_sch if $sample & $dist & year==2013 & asian==1, ///
	bin(150) freq ///
	xtitle("Distance to nearest food outlet", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	title("Asian students") ///
	ytitle("Number of obs", size(vsmall)) ///
	ylabel(0(50)200, labsize(vsmall)) ///
	graphregion(color(white)) bgcolor(white)
graph save figures\asian_variance.gph, replace

hist nearestAnyall_sch if $sample & $dist & year==2013 & hisp==1, ///
	bin(150) freq ///
	xtitle("Distance to nearest food outlet", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	title("Hispanic students") ///
	ytitle("Number of obs", size(vsmall)) ///
	ylabel(0(50)250, labsize(vsmall)) ///
	graphregion(color(white)) bgcolor(white)
graph save figures\hisp_variance.gph, replace

hist nearestAnyall_sch if $sample & $dist & year==2013 & black==1, ///
	bin(150) freq ///
	xtitle("Distance to nearest food outlet", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	title("Black students") ///
	ytitle("Number of obs", size(vsmall)) ///
	ylabel(0(20)100, labsize(vsmall)) ///
	graphregion(color(white)) bgcolor(white)
graph save figures\black_variance.gph, replace

hist nearestAnyall_sch if $sample & $dist & year==2013 & white==1, ///
	bin(150) freq ///
	xtitle("Distance to nearest food outlet", size(vsmall)) ///
	xlabel(0(264)2640, labsize(vsmall)) ///
	title("White students") ///
	ytitle("Number of obs", size(vsmall)) ///
	ylabel(0(50)500, labsize(vsmall)) ///
	graphregion(color(white)) bgcolor(white)
graph save figures\white_variance.gph, replace
}
.

*** how the sample was derived

