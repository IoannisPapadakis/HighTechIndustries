/*
Author: Nathan Goldschlag
Date: 10/28/2016
Description: Preliminary analysis of HT QWI data.
*/

global data "~/Documents/projects/HighTechIndustries/data"
global plt "~/Documents/projects/HighTechIndustries/plots/"
set more off

********************************************************************************
**********************************LOAD DATA*************************************
********************************************************************************

** set of 15 HT 4-digit 2007 NAICS industries 
insheet using $data/stemunion07.csv, clear
rename naics07_4 industry
tempfile su07
save `su07'

** load qwi tabulation
*insheet using $data/qwiht_us.csv, clear
*insheet using $data/sum_qwi_us_y1998q1.csv, clear
insheet using $data/sum_qwi_us_y1995q1.csv, clear
*drop _merge ht
merge m:1 industry using `su07'
gen hitech=_merge==3
drop if _merge==2
drop _merge
sort year quarter
gen ts=year +quarter/4 -.25
** drop totals records
drop if agegrp=="A00" | sex==0
keep if ts>=1995 & ts<=2015.5
gen female=sex==2
tempfile qwiht
save `qwiht'

********************************************************************************
*****************************BASIC DATA CHECKS**********************************
********************************************************************************

** explore and check data
use `qwiht', clear
count
tab ownercode, missing
tab race, missing
tab ethnicity, missing
tab education, missing
tab firmage, missing
tab firmsize, missing
tab year, missing
tab female sex, missing

use `qwiht', clear
collapse (sum) b e jc jd, by(ts)
gen jc_e_ratio=jc/e
gen jd_e_ratio=jd/e
tw (scatter e ts, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (scatter b ts, lcolor(maroon) mcolor(maroon) lwidth(.5) m(circle_hollow) connect(1) msize(1)), ylabel(,angle(horizontal)) ytitle("Employmnet Counts") xtitle("Year") title("Beginning and EoQ Emplyoment Counts""Full Sample") legend(order(1 "BoQ Employment" 2 "EoQ Employment")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_datachecks_eb_emp.png, replace

tw (scatter jc ts, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (scatter jd ts, lcolor(maroon) mcolor(maroon) lwidth(.5) m(circle_hollow) connect(1) msize(1)), ylabel(,angle(horizontal)) ytitle("Employmnet Counts") xtitle("Year") title("Job Creation and Job Destruction Counts""Full Sample") legend(order(1 "Job Creation" 2 "Job Destruction")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_datachecks_jcjd.png, replace

tw (scatter jc_e_ratio ts, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (scatter jd_e_ratio ts, lcolor(maroon) mcolor(maroon) lwidth(.5) m(circle_hollow) connect(1) msize(1)), ylabel(,angle(horizontal)) ytitle("Employmnet Counts") xtitle("Year") title("Ratio of Job Creation and Job Destruction To EoQ Emp""Full Sample") legend(order(1 "JC EoQ Ratio" 2 "JD EoQ Ratio")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_datachecks_jcjd_eratio.png, replace


********************************************************************************
**********************************EW FIGURES************************************
********************************************************************************

use `qwiht', clear
collapse (sum) e b jc jd, by(hitech ts)
gen denom = (e+b)/2
sort hitech ts
gen ts_n=_n
tsset ts_n
sort ts hitech
by ts: egen e_tot=sum(e)
gen e_share=100*(e/e_tot)
by ts: egen jc_tot=sum(jc)
gen jc_share=100*(jc/jc_tot)
by ts: egen jd_tot=sum(jd)
gen jd_share=100*(jd/jd_tot)
gen jcr=100*(jc/denom)
gen jdr=100*(jd/denom)
tsfilter hp e_hp = e_share if hitech==1, smooth(1600) trend(e_share_tr)
tsfilter hp jc_hp = jc_share if hitech==1, smooth(1600) trend(jc_share_tr)
tsfilter hp jd_hp = jd_share if hitech==1, smooth(1600) trend(jd_share_tr)
tsfilter hp jcr_hp = jcr if hitech==1, smooth(1600) trend(jcr_tr)
tsfilter hp jcr_hp_nonht = jcr if hitech==0, smooth(1600) trend(jcr_tr_nonht)
tsfilter hp jdr_hp = jdr if hitech==1, smooth(1600) trend(jdr_tr)
tsfilter hp jdr_hp_nonht = jdr if hitech==0, smooth(1600) trend(jdr_tr_nonht)

tw (scatter e_share ts if hitech==1, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (line e_share_tr ts if hitech==1, lcolor(navy) lpattern(dash) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("High Tech Share EoQ Employment") xtitle("Year") title("High Tech Share EoQ Employment") legend(off)  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_ew_eshare.png, replace

tw (scatter jc_share ts if hitech==1, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (line jc_share_tr ts if hitech==1, lcolor(navy) lpattern(dash) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("High Tech JC Share") xtitle("Year") title("High Tech Share Job Creation") legend(off)  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_ew_jcshare.png, replace

tw (scatter jd_share ts if hitech==1, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (line jd_share_tr ts if hitech==1, lcolor(navy) lpattern(dash) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("High Tech JD Share") xtitle("Year") title("High Tech Share Job Destruction") legend(off)  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_ew_jdshare.png, replace

tw (line jcr_tr ts if hitech==1, lcolor(navy) lwidth(.5)) (line jcr_tr_nonht ts if hitech==0, lcolor(maroon) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("Job Creation Rate") xtitle("Year") title("High Tech and non-High Tech Job Creation Trends") legend(order(1 "HT Job Creation Rate" 2 "non-HT Job Creation Rate"))  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_ew_jcr_htvnonht.png, replace

tw (line jdr_tr ts if hitech==1, lcolor(navy) lwidth(.5)) (line jdr_tr_nonht ts if hitech==0, lcolor(maroon) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("Job Destruction Rate") xtitle("Year") title("High Tech and non-High Tech Job Destruction Trends") legend(order(1 "HT Job Destruction Rate" 2 "non-HT Job Destruction Rate"))  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_ew_jdr_htvnonht.png, replace

tw (line jcr_tr ts if hitech==1, lcolor(navy) lwidth(.5)) (line jdr_tr ts if hitech==1, lcolor(maroon) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("Job Creation/Destruction Rate") xtitle("Year") title("High Tech Job Creation and Destruction Trends") legend(order(1 "Job Creation Rate" 2 "Job Destruction Rate"))  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_ew_jcrjdr.png, replace

********************************************************************************
**********************************SEX FIGURES***********************************
********************************************************************************

use `qwiht', clear
collapse (sum) e b jc jd, by(hitech ts female)
gen denom = (e+b)/2
gen jcr=100*(jc/denom)
gen jdr=100*(jd/denom)
sort hitech female ts
gen ts_n=_n
tsset ts_n
sort ts hitech
by ts: egen e_tot=sum(e)
gen e_share=100*(e/e_tot)
by ts: egen jc_tot=sum(jc)
gen jc_share=100*(jc/jc_tot)
by ts: egen jd_tot=sum(jd)
gen jd_share=100*(jd/jd_tot)

sort ts hitech female
by ts hitech: gen e_share_sexdiff=e_share[_n]-e_share[_n+1]
by ts hitech: gen jc_share_sexdiff=jc_share[_n]-jc_share[_n+1]
by ts hitech: gen jd_share_sexdiff=jd_share[_n]-jd_share[_n+1]

tsfilter hp e_m_hp = e_share if hitech==1 & female==0, smooth(1600) trend(e_share_m_tr)
tsfilter hp e_f_hp = e_share if hitech==1 & female==1, smooth(1600) trend(e_share_f_tr)
tsfilter hp jc_m_hp = jc_share if hitech==1 & female==0, smooth(1600) trend(jc_share_m_tr)
tsfilter hp jc_f_hp = jc_share if hitech==1 & female==1, smooth(1600) trend(jc_share_f_tr)
tsfilter hp jd_m_hp = jd_share if hitech==1 & female==0, smooth(1600) trend(jd_share_m_tr)
tsfilter hp jd_f_hp = jd_share if hitech==1 & female==1, smooth(1600) trend(jd_share_f_tr)
tsfilter hp e_diff_hp = e_share_sexdiff if hitech==1 & female==0, smooth(1600) trend(e_share_sexdiff_tr)
tsfilter hp jc_diff_hp = jc_share_sexdiff if hitech==1 & female==0, smooth(1600) trend(jc_share_sexdiff_tr)
tsfilter hp jd_diff_hp = jd_share_sexdiff if hitech==1 & female==0, smooth(1600) trend(jd_share_sexdiff_tr)

sort hitech female ts
by hitech female: gen e_share_indx=100*(e_share[_n]-e_share[1])/e_share[1]
by hitech female: gen jc_share_indx=100*(jc_share[_n]-jc_share[1])/jc_share[1]
by hitech female: gen jd_share_indx=100*(jd_share[_n]-jd_share[1])/jd_share[1]

tw (scatter e_share ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1) yaxis(1)) (scatter e_share ts if hitech==1 & female==1, lcolor(maroon) mcolor(maroon) lwidth(.5) m(triangle_hollow) connect(1) msize(1) yaxis(2)), ytitle("High Tech Share EoQ Employment (Male)",axis(1)) ytitle("High Tech Share EoQ Employment (Female)",axis(2)) xtitle("Year") title("High Tech Share EoQ Employment""Male and Female") legend(order(1 "Male" 2 "Female")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylab(4.4(0.2)5.2,axis(1)) ylab(2.2(0.2)3.0,axis(2))
graph export $plt/qwiht_sex_eshare.png, replace

tw (scatter jc_share ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (scatter jc_share ts if hitech==1 & female==1, lcolor(maroon) mcolor(maroon) lwidth(.5) m(triangle_hollow) connect(1) msize(1)), ytitle("High Tech Share Job Creation") xtitle("Year") title("High Tech Share Job Creation""Male and Female") legend(order(1 "Male" 2 "Female")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_sex_jcshare.png, replace

tw (scatter jd_share ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (scatter jd_share ts if hitech==1 & female==1, lcolor(maroon) mcolor(maroon) lwidth(.5) m(triangle_hollow) connect(1) msize(1)), ytitle("High Tech Share Job Destruction") xtitle("Year") title("High Tech Share Job Destruction""Male and Female") legend(order(1 "Male" 2 "Female")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_sex_jdshare.png, replace

tw (scatter e_share_sexdiff ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (line e_share_sexdiff_tr ts if hitech==1 & female==0, lwidth(.5) lcolor(navy) lpattern(dash)), ytitle("EoQ Emp Share Difference (Male-Female)") xtitle("Year") title("Difference in High Tech EoQ Employment Share") note("Hodrick-Prescott filter shown with multiplier 1600.""Difference calculated as male share minus female share.") graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) legend(off)
graph export $plt/qwiht_sex_esharediff.png, replace

tw (scatter jc_share_sexdiff ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (line jc_share_sexdiff_tr ts if hitech==1 & female==0, lwidth(.5) lcolor(navy) lpattern(dash)), ytitle("JC Share Difference (Male-Female)") xtitle("Year") title("Difference in High Tech Job Creation Share") note("Hodrick-Prescott filter shown with multiplier 1600.""Difference calculated as male share minus female share.") graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) legend(off)
graph export $plt/qwiht_sex_jcsharediff.png, replace

tw (scatter jd_share_sexdiff ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (line jd_share_sexdiff_tr ts if hitech==1 & female==0, lwidth(.5) lcolor(navy) lpattern(dash)), ytitle("JD Share Difference (Male-Female)") xtitle("Year") title("Difference in High Tech Job Destruction Share") note("Hodrick-Prescott filter shown with multiplier 1600.""Difference calculated as male share minus female share.") graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) legend(off)
graph export $plt/qwiht_sex_jdsharediff.png, replace

tw (scatter jcr ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (scatter jcr ts if hitech==1 & female==1, lcolor(maroon) mcolor(maroon) lwidth(.5) m(triangle_hollow) connect(1) msize(1)), ytitle("High Tech Job Creation Rate") xtitle("Year") title("High Tech Job Creation Rate""Male and Female") legend(order(1 "Male" 2 "Female")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_sex_jcr.png, replace

tw (scatter jdr ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (scatter jdr ts if hitech==1 & female==1, lcolor(maroon) mcolor(maroon) lwidth(.5) m(triangle_hollow) connect(1) msize(1)), ytitle("High Tech Job Destruction Rate") xtitle("Year") title("High Tech Job Destruction Rate""Male and Female") legend(order(1 "Male" 2 "Female")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_sex_jdr.png, replace

tw (scatter e_share_indx ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (scatter e_share_indx ts if hitech==1 & female==1, lcolor(maroon) mcolor(maroon) lwidth(.5) m(triangle_hollow) connect(1) msize(1)), ylabel(,angle(horizontal)) ytitle("Change in High Tech Share EoQ Employment") xtitle("Year") title("High Tech Share EoQ Employment Change by Sex") legend(order(1 "Male" 2 "Female"))  yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_sex_eshare_chg.png, replace

tw (scatter jc_share_indx ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (scatter jc_share_indx ts if hitech==1 & female==1, lcolor(maroon) mcolor(maroon) lwidth(.5) m(triangle_hollow) connect(1) msize(1)), ylabel(,angle(horizontal)) ytitle("Change in High Tech Job Creation Share") xtitle("Year") title("High Tech Job Creation Share Change by Sex") legend(order(1 "Male" 2 "Female")) yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_sex_jcshare_chg.png, replace

tw (scatter jd_share_indx ts if hitech==1 & female==0, lcolor(navy) mcolor(navy) lwidth(.5) m(circle_hollow) connect(1) msize(1)) (scatter jd_share_indx ts if hitech==1 & female==1, lcolor(maroon) mcolor(maroon) lwidth(.5) m(triangle_hollow) connect(1) msize(1)), ylabel(,angle(horizontal)) ytitle("Change in High Tech Share EoQ Employment") xtitle("Year") title("High Tech Job Destruction Share Change by Sex") legend(order(1 "Male" 2 "Female")) yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_sex_jdshare_chg.png, replace



********************************************************************************
**********************************AGE FIGURES***********************************
********************************************************************************

use `qwiht', clear
*replace agegrp="a) 14-18" if agegrp=="A01"
drop if agegrp=="A01"
replace agegrp="a) 19-21" if agegrp=="A02"
replace agegrp="b) 22-24" if agegrp=="A03"
replace agegrp="c) 25-34" if agegrp=="A04"
replace agegrp="d) 35-44" if agegrp=="A05"
replace agegrp="e) 45-54" if agegrp=="A06"
replace agegrp="f) 55-64" if agegrp=="A07"
replace agegrp="g) 65-99" if agegrp=="A08"
collapse (sum) e jc jd, by(hitech ts agegrp)
collapse (mean) e jc jd, by(hitech agegrp)
sort hitech agegrp
by hitech: egen e_tot=sum(e)
by hitech: egen jc_tot=sum(jc)
by hitech: egen jd_tot=sum(jd)
gen e_pct=100*(e/e_tot)
gen jc_pct=100*(jc/jc_tot)
gen jd_pct=100*(jd/jd_tot)
sort agegrp hitech
by agegrp: gen e_pct_ht=e_pct[_n+1]
by agegrp: gen jc_pct_ht=jc_pct[_n+1]
by agegrp: gen jd_pct_ht=jd_pct[_n+1]
keep if hitech==0
drop hitech
graph bar e_pct e_pct_ht, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("EoQ Employment by Age Group""Average Percent 1995-2015") ytitle("Percent of EoQ Employment")
graph export $plt/qwiht_age_edist.png, replace
graph bar jc_pct jc_pct_ht, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Job Creation by Age Group""Average Percent 1995-2015") ytitle("Percent of Job Creation")
graph export $plt/qwiht_age_jcdist.png, replace
graph bar jd_pct jd_pct_ht, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Job Destruction by Age Group""Average Percent 1995-2015") ytitle("Percent of Job Destruction")
graph export $plt/qwiht_age_jddist.png, replace

use `qwiht', clear
* recode ages
drop if agegrp=="A01"
replace agegrp="a) 19-24" if agegrp=="A02" | agegrp=="A03"
replace agegrp="b) 25-34" if agegrp=="A04" 
replace agegrp="c) 35-54" if agegrp=="A05" | agegrp=="A06"
replace agegrp="d) 55-64" if agegrp=="A07" 
replace agegrp="e) 65-99" if agegrp=="A08" 
collapse (sum) e b jc jd, by(hitech ts agegrp)
gen denom = (e+b)/2
gen jcr=100*(jc/denom)
gen jdr=100*(jd/denom)
sort hitech agegrp ts
gen ts_n=_n
tsset ts_n
sort ts hitech
by ts: egen e_tot=sum(e)
gen e_share=100*(e/e_tot)
by ts: egen jc_tot=sum(jc)
gen jc_share=100*(jc/jc_tot)
by ts: egen jd_tot=sum(jd)
gen jd_share=100*(jd/jd_tot)

sort hitech agegrp ts

by hitech agegrp: gen e_share_ma = (e_share[_n-1] + e_share[_n] + e_share[_n-1])/3
by hitech agegrp: gen jc_share_ma = (jc_share[_n-1] + jc_share[_n] + jc_share[_n-1])/3
by hitech agegrp: gen jd_share_ma = (jd_share[_n-1] + jd_share[_n] + jd_share[_n-1])/3

keep if ts>1995

by hitech agegrp: gen e_share_indx=100*(e_share_ma[_n]-e_share_ma[1])/e_share_ma[1]
by hitech agegrp: gen jc_share_indx=100*(jc_share_ma[_n]-jc_share_ma[1])/jc_share_ma[1]
by hitech agegrp: gen jd_share_indx=100*(jd_share_ma[_n]-jd_share_ma[1])/jd_share_ma[1]

* tsfilter cannot take string values for conditional filter
egen agegrp_int=group(agegrp)

foreach v of num 1/4 {
	tsfilter hp e_hp_`v' = e_share if hitech==1 & agegrp_int==`v', smooth(1600) trend(e_share_tr_`v')
	tsfilter hp jc_hp_`v' = jc_share if hitech==1 & agegrp_int==`v', smooth(1600) trend(jc_share_tr_`v')
	tsfilter hp jd_hp_`v' = jd_share if hitech==1 & agegrp_int==`v', smooth(1600) trend(jd_share_tr_`v')
	tsfilter hp jcr_`v' = jcr if hitech==1 & agegrp_int==`v', smooth(1600) trend(jcr_tr_`v')
	tsfilter hp jdr_`v' = jdr if hitech==1 & agegrp_int==`v', smooth(1600) trend(jdr_tr_`v')
}

tw (line e_share ts if hitech==1 & agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line e_share ts if hitech==1 & agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line e_share ts if hitech==1 & agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line e_share ts if hitech==1 & agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line e_share ts if hitech==1 & agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("High Tech Share EoQ Employment") xtitle("Year") title("High Tech Share EoQ Employment by Age") legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99"))  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_age_eshare.png, replace

tw (line jc_share ts if hitech==1 & agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line jc_share ts if hitech==1 & agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line jc_share ts if hitech==1 & agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line jc_share ts if hitech==1 & agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line jc_share ts if hitech==1 & agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("High Tech Share JC") xtitle("Year") title("High Tech Share Job Creation by Age") legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99"))  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_age_jcshare.png, replace

tw (line jd_share ts if hitech==1 & agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line jd_share ts if hitech==1 & agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line jd_share ts if hitech==1 & agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line jd_share ts if hitech==1 & agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line jd_share ts if hitech==1 & agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("High Tech Share JD") xtitle("Year") title("High Tech Share Job Destruction by Age") legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99"))  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_age_jdshare.png, replace

tw 	(line e_share_indx ts if hitech==1 & agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line e_share_indx ts if hitech==1 & agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line e_share_indx ts if hitech==1 & agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line e_share_indx ts if hitech==1 & agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line e_share_indx ts if hitech==1 & agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("High Tech Share EoQ Employment Change") xtitle("Year") title("High Tech Share EoQ Employment Change by Age") legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99"))  yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_age_eshare_chg.png, replace

tw 	(line jc_share_indx ts if hitech==1 & agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line jc_share_indx ts if hitech==1 & agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line jc_share_indx ts if hitech==1 & agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line jc_share_indx ts if hitech==1 & agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line jc_share_indx ts if hitech==1 & agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("High Tech Share JC Change") xtitle("Year") title("High Tech Share Job Creation Change by Age") legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99"))  yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_age_jcshare_chg.png, replace

tw 	(line jc_share_indx ts if hitech==1 & agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line jc_share_indx ts if hitech==1 & agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line jc_share_indx ts if hitech==1 & agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line jc_share_indx ts if hitech==1 & agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line jc_share_indx ts if hitech==1 & agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("High Tech Share JD Change") xtitle("Year") title("High Tech Share Job Destruction Change by Age") legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99"))  yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_age_jdshare_chg.png, replace

tw (line jcr ts if hitech==1 & agegrp=="b) 25-34", lcolor(maroon) lwidth(.5) connect(1) msize(1)) (line jcr ts if hitech==1 & agegrp=="c) 35-54", lcolor(forest_green)  lwidth(.5)) (line jcr ts if hitech==1 & agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line jcr ts if hitech==1 & agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("Job Creation Rate") xtitle("Year") title("High Tech Job Creation Rate by Age") legend(order( 1 "b) 25-34" 2 "c) 35-54" 3 "d) 55-64" 4 "e) 65-99"))  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_age_jcr.png, replace

tw (line jdr ts if hitech==1 & agegrp=="b) 25-34", lcolor(maroon) lwidth(.5) connect(1) msize(1)) (line jdr ts if hitech==1 & agegrp=="c) 35-54", lcolor(forest_green)  lwidth(.5)) (line jdr ts if hitech==1 & agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line jdr ts if hitech==1 & agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), ylabel(,angle(horizontal)) ytitle("Job Destruction Rate") xtitle("Year") title("High Tech Job Destruction Rate by Age") legend(order( 1 "b) 25-34" 2 "c) 35-54" 3 "d) 55-64" 4 "e) 65-99"))  graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_age_jdr.png, replace


use `qwiht', clear
*replace agegrp="a) 14-18" if agegrp=="A01"
drop if agegrp=="A01"
replace agegrp="a) 19-21" if agegrp=="A02"
replace agegrp="b) 22-24" if agegrp=="A03"
replace agegrp="c) 25-34" if agegrp=="A04"
replace agegrp="d) 35-44" if agegrp=="A05"
replace agegrp="e) 45-54" if agegrp=="A06"
replace agegrp="f) 55-64" if agegrp=="A07"
replace agegrp="g) 65-99" if agegrp=="A08"
collapse (sum) e jc jd, by(hitech ts agegrp)
sort hitech agegrp ts
gen ts_n=_n
tsset ts_n
sort ts hitech
by ts: egen e_tot=sum(e)
gen e_share=100*(e/e_tot)
by ts: egen jc_tot=sum(jc)
gen jc_share=100*(jc/jc_tot)
by ts: egen jd_tot=sum(jd)
gen jd_share=100*(jd/jd_tot)

sort hitech agegrp ts
by hitech agegrp: gen e_share_ma = (e_share[_n-1] + e_share[_n] + e_share[_n-1])/3
by hitech agegrp: gen jc_share_ma = (jc_share[_n-1] + jc_share[_n] + jc_share[_n-1])/3
by hitech agegrp: gen jd_share_ma = (jd_share[_n-1] + jd_share[_n] + jd_share[_n-1])/3

keep if ts>1995
by hitech agegrp: gen e_share_indx=100*(e_share_ma[_n]-e_share_ma[1])/e_share_ma[1]
by hitech agegrp: gen jc_share_indx=100*(jc_share_ma[_n]-jc_share_ma[1])/jc_share_ma[1]
by hitech agegrp: gen jd_share_indx=100*(jd_share_ma[_n]-jd_share_ma[1])/jd_share_ma[1]
egen agegrp_int=group(agegrp)

tw (line e_share_indx ts if hitech==1 & agegrp_int==2, lwidth(.5)) (line e_share_indx ts if hitech==1 & agegrp_int==3, lwidth(.5)) (line e_share_indx ts if hitech==1 & agegrp_int==4, lwidth(.5)) (line e_share_indx ts if hitech==1 & agegrp_int==5, lwidth(.5)) (line e_share_indx ts if hitech==1 & agegrp_int==6, lwidth(.5)) (line e_share_indx ts if hitech==1 & agegrp_int==7, lwidth(.5)) (line e_share_indx ts if hitech==1 & agegrp_int==8, lwidth(.5)), ylabel(,angle(horizontal)) ytitle("High Tech Share EoQ Employment Change") xtitle("Year") title("High Tech Share EoQ Employment Change by Age") legend(order(1 "b) 19-21" 2 "c) 22-24" 3 "d) 25-34" 4 "e) 35-44" 5 "f) 45-54" 6 "g) 55-64" 7 "h) 65-99")) yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_age_eshare_chg_allgroups.png, replace



********************************************************************************
*******************************SEX AGE FIGURES**********************************
********************************************************************************

use `qwiht', clear
*replace agegrp="a) 14-18" if agegrp=="A01"
drop if agegrp=="A01"
replace agegrp="b) 19-21" if agegrp=="A02"
replace agegrp="c) 22-24" if agegrp=="A03"
replace agegrp="d) 25-34" if agegrp=="A04"
replace agegrp="e) 35-44" if agegrp=="A05"
replace agegrp="f) 45-54" if agegrp=="A06"
replace agegrp="g) 55-64" if agegrp=="A07"
replace agegrp="h) 65-99" if agegrp=="A08"
collapse (sum) e jc jd, by(hitech ts agegrp sex)
collapse (mean) e jc jd, by(hitech agegrp sex)
tempfile hold
save `hold'
sort hitec sex agegrp
by hitech sex: egen e_tot=sum(e)
by hitech sex: egen jc_tot=sum(jc)
by hitech sex: egen jd_tot=sum(jd)
gen e_pct=100*(e/e_tot)
gen jc_pct=100*(jc/jc_tot)
gen jd_pct=100*(jd/jd_tot)
sort sex agegrp hitech
by sex agegrp: gen e_pct_ht=e_pct[_n+1]
by sex agegrp: gen jc_pct_ht=jc_pct[_n+1]
by sex agegrp: gen jd_pct_ht=jd_pct[_n+1]
keep if hitech==0
drop hitech

graph bar e_pct e_pct_ht if sex==1, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Male EoQ Employment by Age Group""Average Percent 1995-2015") ytitle("Percent of EoQ Employment")
graph export $plt/qwiht_agesex_male_edist.png, replace
graph bar e_pct e_pct_ht if sex==2, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Female EoQ Employment by Age Group""Average Percent 1995-2015") ytitle("Percent of EoQ Employment")
graph export $plt/qwiht_agesex_female_edist.png, replace
graph bar jc_pct jc_pct_ht if sex==1, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Male Job Creation by Age Group""Average Percent 1995-2015") ytitle("Percent of Job Creation")
graph export $plt/qwiht_agesex_male_jcdist.png, replace
graph bar jc_pct jc_pct_ht if sex==2, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Male Job Creation by Age Group""Average Percent 1995-2015") ytitle("Percent of Job Creation")
graph export $plt/qwiht_agesex_female_jcdist.png, replace
graph bar jd_pct jd_pct_ht if sex==1, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Male Job Destruction by Age Group""Average Percent 1995-2015") ytitle("Percent of Job Destruction")
graph export $plt/qwiht_agesex_male_jddist.png, replace
graph bar jd_pct jd_pct_ht if sex==2, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Female Job Destruction by Age Group""Average Percent 1995-2015") ytitle("Percent of Job Destruction")
graph export $plt/qwiht_agesex_female_jddist.png, replace

sort agegrp sex
by agegrp: gen e_pct_ht_f=e_pct_ht[_n+1]
by agegrp: gen e_pct_f=e_pct[_n+1]
by agegrp: gen jc_pct_ht_f=jc_pct_ht[_n+1]
by agegrp: gen jc_pct_f=jc_pct[_n+1]
by agegrp: gen jd_pct_ht_f=jd_pct_ht[_n+1]
by agegrp: gen jd_pct_f=jd_pct[_n+1]
keep if sex==1
gen e_pct_ht_diff=e_pct_ht-e_pct_ht_f
gen e_pct_diff=e_pct-e_pct_f
gen jc_pct_ht_diff=jc_pct_ht-jc_pct_ht_f
gen jc_pct_diff=jc_pct-jc_pct_f
gen jd_pct_ht_diff=jd_pct_ht-jd_pct_ht_f
gen jd_pct_diff=jd_pct-jd_pct_f
gen e_pct_htnonht_diff = e_pct_ht_diff-e_pct_diff

graph bar e_pct_ht_diff, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(-2(1)2,angle(horizontal)) b1title("Age Group") title("High Tech EoQ Emp Sex Difference by Age Group""Average 1995-2015") ytitle("Difference in Percent") note("Difference calculated as male share minus female share. Positive values indicate that the High Tech""employment share among males is higher.") yline(0, lwidth(.5) lcolor(black))
graph export $plt/qwiht_agesex_male_edist_diff.png, replace
graph bar e_pct_diff, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(-2(1)2,angle(horizontal)) b1title("Age Group") title("non-High Tech EoQ Emp Sex Difference by Age Group""Average 1995-2015") ytitle("Difference in Percent of EoQ Employment") note("Difference calculated as male share minus female share. Positive values indicate that the High Tech""employment share among males is higher.") yline(0, lwidth(.5) lcolor(black))
graph export $plt/qwiht_agesex_male_edist_diff_nonht.png, replace

graph bar e_pct_htnonht_diff, over(agegrp, label(angle(45))) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(-2(1)2,angle(horizontal)) b1title("Age Group") title("Difference: Male-Female, High Tech-non-High Tech by Age""Average Percent 1995-2015") ytitle("Difference in Percent of EoQ Employment") note("Difference calculated as male share minus female share and High Tech minus non-High Tech. Positive values indicate ") yline(0, lwidth(.5) lcolor(black))
graph export $plt/qwiht_agesex_male_edist_diff_htnonhtdiff.png, replace



graph bar jc_pct_ht_diff, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(-2(1)2,angle(horizontal)) b1title("Age Group") title("High Tech Job Creation Difference by Age Group""Average Percent 1995-2015") ytitle("Difference in Percent of JC") note("Difference calculated as male share minus female share.") yline(0, lwidth(.5) lcolor(black))
graph export $plt/qwiht_agesex_male_jcdist_diff.png, replace
graph bar jc_pct_diff, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(-2(1)2,angle(horizontal)) b1title("Age Group") title("non-High Tech Job Creation Difference by Age Group""Average Percent 1995-2015") ytitle("Difference in Percent of JC") note("Difference calculated as male share minus female share.") yline(0, lwidth(.5) lcolor(black))
graph export $plt/qwiht_agesex_male_jcdist_diff_nonht.png, replace

graph bar jd_pct_ht_diff, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(-2(1)2,angle(horizontal)) b1title("Age Group") title("High Tech Job Destruction Difference by Age Group""Average Percent 1995-2015") ytitle("Difference in Percent of JD") note("Difference calculated as male share minus female share.") yline(0, lwidth(.5) lcolor(black))
graph export $plt/qwiht_agesex_male_jddist_diff.png, replace
graph bar jd_pct_diff, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(-2(1)2,angle(horizontal)) b1title("Age Group") title("non-High Tech Job Destruction Difference by Age Group""Average Percent 1995-2015") ytitle("Difference in Percent of JD") note("Difference calculated as male share minus female share.") yline(0, lwidth(.5) lcolor(black))
graph export $plt/qwiht_agesex_male_jddist_diff_nonht.png, replace



use `hold', clear
drop if agegrp=="a) 14-18" | agegrp=="b) 19-21" | agegrp=="h) 65-99"
sort hitec sex agegrp
by hitech sex: egen e_tot=sum(e)
by hitech sex: egen jc_tot=sum(jc)
by hitech sex: egen jd_tot=sum(jd)
gen e_pct=100*(e/e_tot)
gen jc_pct=100*(jc/jc_tot)
gen jd_pct=100*(jd/jd_tot)
sort sex agegrp hitech
by sex agegrp: gen e_pct_ht=e_pct[_n+1]
by sex agegrp: gen jc_pct_ht=jc_pct[_n+1]
by sex agegrp: gen jd_pct_ht=jd_pct[_n+1]
keep if hitech==0
drop hitech

graph bar e_pct e_pct_ht if sex==1, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Male EoQ Employment by Age Group""Average Percent 1995-2015") ytitle("Percent of EoQ Employment")
graph export $plt/qwiht_agesex_male_edist_midage.png, replace
graph bar e_pct e_pct_ht if sex==2, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Female EoQ Employment by Age Group""Average Percent 1995-2015") ytitle("Percent of EoQ Employment")
graph export $plt/qwiht_agesex_female_edist_midage.png, replace
graph bar jc_pct jc_pct_ht if sex==1, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Male Job Creation by Age Group""Average Percent 1995-2015") ytitle("Percent of Job Creation")
graph export $plt/qwiht_agesex_male_jcdist_midage.png, replace
graph bar jc_pct jc_pct_ht if sex==2, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Male Job Creation by Age Group""Average Percent 1995-2015") ytitle("Percent of Job Creation")
graph export $plt/qwiht_agesex_female_jcdist_midage.png, replace
graph bar jd_pct jd_pct_ht if sex==1, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Male Job Destruction by Age Group""Average Percent 1995-2015") ytitle("Percent of Job Destruction")
graph export $plt/qwiht_agesex_male_jddist_midage.png, replace
graph bar jd_pct jd_pct_ht if sex==2, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Female Job Destruction by Age Group""Average Percent 1995-2015") ytitle("Percent of Job Destruction")
graph export $plt/qwiht_agesex_female_jddist_midage.png, replace

sort agegrp sex
by agegrp: gen e_pct_ht_f=e_pct_ht[_n+1]
by agegrp: gen jc_pct_ht_f=jc_pct_ht[_n+1]
by agegrp: gen jd_pct_ht_f=jd_pct_ht[_n+1]
keep if sex==1
gen e_pct_ht_diff=e_pct_ht-e_pct_ht_f
gen jc_pct_ht_diff=jc_pct_ht-jc_pct_ht_f
gen jd_pct_ht_diff=jd_pct_ht-jd_pct_ht_f

graph bar e_pct_ht_diff, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("EoQ Employment Difference by Age Group""Average Percent 1995-2015") ytitle("Difference in Percent of EoQ Employment") note("Difference calculated as male share minus female share.") yline(0, lwidth(.5) lcolor(black))
graph export $plt/qwiht_agesex_male_edist_diff_midage.png, replace
graph bar jc_pct_ht_diff, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Job Creation Difference by Age Group""Average Percent 1995-2015") ytitle("Difference in Percent of JC") note("Difference calculated as male share minus female share.") yline(0, lwidth(.5) lcolor(black))
graph export $plt/qwiht_agesex_male_jcdist_diff_midage.png, replace
graph bar jd_pct_ht_diff, over(agegrp, label(angle(45))) legend(order(1 "non-High Tech" 2 "High Tech")) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) ylabel(,angle(horizontal)) b1title("Age Group") title("Job Destruction Difference by Age Group""Average Percent 1995-2015") ytitle("Difference in Percent of JD") note("Difference calculated as male share minus female share.") yline(0, lwidth(.5) lcolor(black))
graph export $plt/qwiht_agesex_male_jddist_diff_midage.png, replace


use `qwiht', clear
drop if agegrp=="A01"
*replace agegrp="a) 14-18" if agegrp=="A01"
replace agegrp="a) 19-21" if agegrp=="A02"
replace agegrp="b) 22-24" if agegrp=="A03"
replace agegrp="c) 25-34" if agegrp=="A04"
replace agegrp="d) 35-44" if agegrp=="A05"
replace agegrp="e) 45-54" if agegrp=="A06"
replace agegrp="f) 55-64" if agegrp=="A07"
replace agegrp="g) 65-99" if agegrp=="A08"
collapse (sum) e jc jd, by(hitech ts agegrp sex)
sort ts hitec sex agegrp
by ts hitech sex: egen e_tot=sum(e)
by ts hitech sex: egen jc_tot=sum(jc)
by ts hitech sex: egen jd_tot=sum(jd)
gen e_pct=100*(e/e_tot)
gen jc_pct=100*(jc/jc_tot)
gen jd_pct=100*(jd/jd_tot)
sort ts sex agegrp hitech
by ts sex agegrp: gen e_pct_ht=e_pct[_n+1]
by ts sex agegrp: gen jc_pct_ht=jc_pct[_n+1]
by ts sex agegrp: gen jd_pct_ht=jd_pct[_n+1]
keep if hitech==0
drop hitech
sort ts agegrp sex
by ts agegrp: gen e_pct_ht_f=e_pct_ht[_n+1]
by ts agegrp: gen jc_pct_ht_f=jc_pct_ht[_n+1]
by ts agegrp: gen jd_pct_ht_f=jd_pct_ht[_n+1]
keep if sex==1
drop sex
gen e_pct_ht_diff=e_pct_ht-e_pct_ht_f
gen jc_pct_ht_diff=jc_pct_ht-jc_pct_ht_f
gen jd_pct_ht_diff=jd_pct_ht-jd_pct_ht_f
egen agegrp_int=group(agegrp)


tw (line e_pct_ht_diff ts if agegrp_int==1, lwidth(.5)) (line e_pct_ht_diff ts if agegrp_int==2, lwidth(.5)) (line e_pct_ht_diff ts if agegrp_int==3, lwidth(.5)) (line e_pct_ht_diff ts if agegrp_int==4, lwidth(.5)) (line e_pct_ht_diff ts if agegrp_int==5, lwidth(.5)) (line e_pct_ht_diff ts if agegrp_int==6, lwidth(.5)) (line e_pct_ht_diff ts if agegrp_int==7, lwidth(.5)) , legend(order(1 "a) 19-21" 2 "b) 22-24" 3 "c) 25-34" 4 "d) 35-44" 5 "e) 45-54" 6 "f) 55-64" 7 "g) 65-99")) ylabel(,angle(horizontal)) ytitle("Differnce in HT Share (Male-Female)") xtitle("Year") title("Difference in High Tech Share Male-Female by Age") note("Difference in share calculated as male share minus female share.") yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_agesex_htshare_sexdiff_e_allgroups.png, replace

tw (line jc_pct_ht_diff ts if agegrp_int==1, lwidth(.5)) (line jc_pct_ht_diff ts if agegrp_int==2, lwidth(.5)) (line jc_pct_ht_diff ts if agegrp_int==3, lwidth(.5)) (line jc_pct_ht_diff ts if agegrp_int==4, lwidth(.5)) (line jc_pct_ht_diff ts if agegrp_int==5, lwidth(.5)) (line jc_pct_ht_diff ts if agegrp_int==6, lwidth(.5)) (line jc_pct_ht_diff ts if agegrp_int==7, lwidth(.5)) , legend(order(1 "a) 19-21" 2 "b) 22-24" 3 "c) 25-34" 4 "d) 35-44" 5 "e) 45-54" 6 "f) 55-64" 7 "g) 65-99")) ylabel(,angle(horizontal)) ytitle("Differnce in HT Share (Male-Female)") xtitle("Year") title("Difference in High Tech Job Creation Share Male-Female by Age") note("Difference in share calculated as male share minus female share.") yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_agesex_htshare_sexdiff_jc_allgroups.png, replace

tw (line jd_pct_ht_diff ts if agegrp_int==1, lwidth(.5)) (line jd_pct_ht_diff ts if agegrp_int==2, lwidth(.5)) (line jd_pct_ht_diff ts if agegrp_int==3, lwidth(.5)) (line jd_pct_ht_diff ts if agegrp_int==4, lwidth(.5)) (line jd_pct_ht_diff ts if agegrp_int==5, lwidth(.5)) (line jd_pct_ht_diff ts if agegrp_int==6, lwidth(.5)) (line jd_pct_ht_diff ts if agegrp_int==7, lwidth(.5)) , legend(order(1 "a) 19-21" 2 "b) 22-24" 3 "c) 25-34" 4 "d) 35-44" 5 "e) 45-54" 6 "f) 55-64" 7 "g) 65-99")) ylabel(,angle(horizontal)) ytitle("Differnce in HT Share (Male-Female)") xtitle("Year") title("Difference in High Tech Job Destruction Share Male-Female by Age") note("Difference in share calculated as male share minus female share.") yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_agesex_htshare_sexdiff_jd_allgroups.png, replace

tw 	(line e_pct_ht_f ts if agegrp=="d) 25-34") (line e_pct_ht ts if agegrp=="d) 25-34")
tw 	(line e_pct_ht_f ts if agegrp=="e) 35-44") (line e_pct_ht ts if agegrp=="e) 35-44")
tw 	(line e_pct_ht_f ts if agegrp=="f) 45-54") (line e_pct_ht ts if agegrp=="f) 45-54")

use `qwiht', clear
drop if agegrp=="A01"
replace agegrp="a) 19-24" if agegrp=="A02" | agegrp=="A03"
replace agegrp="b) 25-34" if agegrp=="A04" 
replace agegrp="c) 35-54" if agegrp=="A05" | agegrp=="A06"
replace agegrp="d) 55-64" if agegrp=="A07" 
replace agegrp="e) 65-99" if agegrp=="A08" 
collapse (sum) e jc jd, by(hitech ts agegrp sex)
sort ts hitec sex agegrp
by ts hitech sex: egen e_tot=sum(e)
by ts hitech sex: egen jc_tot=sum(jc)
by ts hitech sex: egen jd_tot=sum(jd)
gen e_pct=100*(e/e_tot)
gen jc_pct=100*(jc/jc_tot)
gen jd_pct=100*(jd/jd_tot)
sort ts sex agegrp hitech
by ts sex agegrp: gen e_pct_ht=e_pct[_n+1]
by ts sex agegrp: gen jc_pct_ht=jc_pct[_n+1]
by ts sex agegrp: gen jd_pct_ht=jd_pct[_n+1]
keep if hitech==0
drop hitech
sort ts agegrp sex
by ts agegrp: gen e_pct_ht_f=e_pct_ht[_n+1]
by ts agegrp: gen jc_pct_ht_f=jc_pct_ht[_n+1]
by ts agegrp: gen jd_pct_ht_f=jd_pct_ht[_n+1]
keep if sex==1
drop sex
gen e_pct_ht_diff=e_pct_ht-e_pct_ht_f
gen jc_pct_ht_diff=jc_pct_ht-jc_pct_ht_f
gen jd_pct_ht_diff=jd_pct_ht-jd_pct_ht_f

/*
sort agegrp ts
by agegrp: gen ediff_ma = (e_pct_ht_diff[_n-1] + e_pct_ht_diff[_n] + e_pct_ht_diff[_n-1])/3
by agegrp: gen jcdiff_ma = (jc_pct_ht_diff[_n-1] + jc_pct_ht_diff[_n] + jc_pct_ht_diff[_n-1])/3
by agegrp: gen jddiff_ma = (jd_pct_ht_diff[_n-1] + jd_pct_ht_diff[_n] + jd_pct_ht_diff[_n-1])/3

keep if ts>1995

by agegrp: gen ediff_indx=100*(ediff_ma[_n]-ediff_ma[1])/ediff_ma[1]
by agegrp: gen jcdiff_indx=100*(jcdiff_ma[_n]-jcdiff_ma[1])/jcdiff_ma[1]
by agegrp: gen jddiff_indx=100*(jddiff_ma[_n]-jddiff_ma[1])/jddiff_ma[1]

by agegrp: gen e_pct_ht_indx=100*(e_pct_ht[_n]-e_pct_ht[1])/e_pct_ht[1]
by agegrp: gen e_pct_ht_f_indx=100*(e_pct_ht_f[_n]-e_pct_ht_f[1])/e_pct_ht_f[1]
*/

keep if ts>1995
sort agegrp ts
by agegrp: gen ediff_indx=100*(e_pct_ht_diff[_n]-e_pct_ht_diff[1])/abs(e_pct_ht_diff[1])
by agegrp: gen jcdiff_indx=100*(jc_pct_ht_diff[_n]-jc_pct_ht_diff[1])/abs(jc_pct_ht_diff[1])
by agegrp: gen jddiff_indx=100*(jd_pct_ht_diff[_n]-jd_pct_ht_diff[1])/abs(jd_pct_ht_diff[1])

by agegrp: gen e_pct_ht_indx=100*(e_pct_ht[_n]-e_pct_ht[1])/abs(e_pct_ht[1])
by agegrp: gen e_pct_ht_f_indx=100*(e_pct_ht_f[_n]-e_pct_ht_f[1])/abs(e_pct_ht_f[1])


tw (line e_pct_ht_indx ts if agegrp=="b) 25-34") (line e_pct_ht_f_indx ts if agegrp=="b) 25-34") 

tw 	(line e_pct_ht_diff ts if agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line e_pct_ht_diff ts if agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line e_pct_ht_diff ts if agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line e_pct_ht_diff ts if agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line e_pct_ht_diff ts if agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99")) ylabel(,angle(horizontal)) ytitle("Differnce in HT Share (Male-Female)") xtitle("Year") title("Difference in High Tech Share Male-Female by Age") note("Difference in share calculated as male share minus female share.") yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_agesex_htshare_sexdiff_e.png, replace

tw 	(line jc_pct_ht_diff ts if agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line jc_pct_ht_diff ts if agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line jc_pct_ht_diff ts if agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line jc_pct_ht_diff ts if agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line jc_pct_ht_diff ts if agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99")) ylabel(,angle(horizontal)) ytitle("Differnce in HT Share (Male-Female)") xtitle("Year") title("Difference in High Tech Job Creation Share Male-Female by Age") note("Difference in share calculated as male share minus female share.") yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_agesex_htshare_sexdiff_jc.png, replace

tw 	(line jd_pct_ht_diff ts if agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line jd_pct_ht_diff ts if agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line jd_pct_ht_diff ts if agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line jd_pct_ht_diff ts if agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line jd_pct_ht_diff ts if agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99")) ylabel(,angle(horizontal)) ytitle("Differnce in HT Share (Male-Female)") xtitle("Year") title("Difference in High Tech Job Destruction Share Male-Female by Age") note("Difference in share calculated as male share minus female share.") yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white))  
graph export $plt/qwiht_agesex_htshare_sexdiff_jd.png, replace

tw 	(line ediff_indx ts if agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line ediff_indx ts if agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line ediff_indx ts if agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line ediff_indx ts if agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line ediff_indx ts if agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99")) ylabel(,angle(horizontal)) ytitle("Differnce in HT Share (Male-Female)") xtitle("Year") title("Difference in High Tech Share""Male-Female by Age") note("Difference in share calculated as male share minus female share. Indexed to the 1995 value.") yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_agesex_htshare_sexdiff_eindx.png, replace

tw 	(line jcdiff_indx ts if agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line jcdiff_indx ts if agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line jcdiff_indx ts if agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line jcdiff_indx ts if agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line jcdiff_indx ts if agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99")) ylabel(,angle(horizontal)) ytitle("Differnce in HT Share (Male-Female)") xtitle("Year") title("Difference in High Tech Job Creation Share""Male-Female by Age") note("Difference in share calculated as male share minus female share. Indexed to the 1995 value.") yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white)) 
graph export $plt/qwiht_agesex_htshare_sexdiff_jcindx.png, replace

tw 	(line jddiff_indx ts if agegrp=="a) 19-24", lcolor(navy) lwidth(.5)) (line jddiff_indx ts if agegrp=="b) 25-34", lcolor(maroon) lwidth(.5)) (line jddiff_indx ts if agegrp=="c) 35-54", lcolor(forest_green) lwidth(.5)) (line jddiff_indx ts if agegrp=="d) 55-64", lcolor(dkorange) lwidth(.5)) (line jddiff_indx ts if agegrp=="e) 65-99", lcolor(teal) lwidth(.5)), legend(order(1 "a) 19-24" 2 "b) 25-34" 3 "c) 35-54" 4 "d) 55-64" 5 "e) 65-99")) ylabel(,angle(horizontal)) ytitle("Differnce in HT Share (Male-Female)") xtitle("Year") title("Difference in High Tech Job Destruction Share""Male-Female by Age") note("Difference in share calculated as male share minus female share. Indexed to the 1995 value.") yline(0,lcolor(black) lwidth(.5)) graphregion(fcolor(white)) plotregion(style(none) fcolor(white) lcolor(white))  
graph export $plt/qwiht_agesex_htshare_sexdiff_jdindx.png, replace






