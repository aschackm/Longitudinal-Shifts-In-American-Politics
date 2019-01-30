/*
Final .do file
Alex Schackmuth
SOC 412
Spring Quarter 2017
*/

**Creation of dataset from the last 6 GSS cross sections (2006-2016)

clear all

set linesize 80

set more off

//2006
use "D:\soc412\dtas\GSS2006.DTA"

gen timeid= string(year) + " " + string(id)
keep age conrinc degree educ ethnic marital newsfrom partyid race realrinc scifrom sex year polviews wrkstat wtss timeid

save "D:\soc412\dtas\GSS2006a.DTA", replace

//2008
clear
use "D:\soc412\dtas\GSS2008.dta"

gen timeid= string(year) + " " + string(id)
keep age conrinc degree educ ethnic marital newsfrom partyid race realrinc scifrom sex year polviews wrkstat wtss timeid

save "D:\soc412\dtas\GSS2008a.dta", replace

//2010
clear
use "D:\soc412\dtas\GSS2010.dta"

gen timeid= string(year) + " " + string(id)
keep age conrinc degree educ ethnic marital newsfrom partyid race realrinc scifrom sex year polviews wrkstat wtss timeid

save "D:\soc412\dtas\GSS2010a.dta", replace

//2012
clear
use "D:\soc412\dtas\GSS2012.dta"

gen timeid= string(year) + " " + string(id)
keep age conrinc degree educ ethnic marital newsfrom partyid race realrinc scifrom sex year polviews wrkstat wtss timeid

save "D:\soc412\dtas\GSS2012a.dta", replace

//2014
clear
use "D:\soc412\dtas\GSS2014.dta"

gen timeid= string(year) + " " + string(id)
keep age conrinc degree educ ethnic marital newsfrom partyid race realrinc scifrom sex year polviews wrkstat wtss timeid

save "D:\soc412\dtas\GSS2014a.dta", replace

//2016
clear
use "D:\soc412\dtas\GSS2016.dta"

gen timeid= string(year) + " " + string(id)
keep age conrinc degree educ ethnic marital newsfrom partyid race realrinc scifrom sex year polviews wrkstat wtss timeid

save "D:\soc412\dtas\GSS2016a.dta", replace

//append all sections to 2006 ex(2006, 2008, 2010, 2012, 2014, 2016)
use "D:\soc412\dtas\GSS2006a.DTA"
append using "D:\soc412\dtas\GSS2008a.dta"
append using "D:\soc412\dtas\GSS2010a.dta"
append using "D:\soc412\dtas\GSS2012a.dta"
append using "D:\soc412\dtas\GSS2014a.DTA"
append using "D:\soc412\dtas\GSS2016a.DTA"
save "D:\soc412\GSS0616v2.dta"

**Recodes

//recode polviews 1=center 2=near center 3=full 4=extreme
recode polviews 4 = 1 5 3 = 2 2 6 = 3 1 7 = 4, gen (polext)
label define polextl 1 "Center" 2 "Near Center" 3 "Full Lib or Con" 4 "Extreme Lib or Con"
label values polext polextl
tab polviews polext

//polext dummy
gen extreme = polext==4
gen fullprty = polext==3
gen nearcntr = polext==2
gen center = polext==1

//recode newsfrom 1=print 2=tv 3=internet 4=radio (mass media formats only)
recode newsfrom 1 2 4 = 1 5 = 2 3 = 3 6 = 4 7/10 = ., gen (newsmedia)
label define newsl 1 "Print" 2 "TV" 3 "Internet" 4 "Radio"
label values newsmedia newsl
tab newsfrom newsmedia

//recode newsfrom 1=print 2=tv 3=internet 4=radio 5= friends and relatives 6= other(Including other formats)
recode newsfrom 1 2 4 = 1 5 = 2 3 = 3 6 = 4 8/9 = 5 7 10 = 6, gen (newsinfo)
label define newsl1 1 "Print" 2 "TV" 3 "Internet" 4 "Radio" 5 "Friends and Family" 6 "Other Sources"
label values newsinfo newsl1

gen printmedia = newsmedia==1
gen tv = newsmedia==2
gen internet = newsmedia==3
gen radio = newsmedia==4

//recode age into groups
recode age 18/29 = 1 30/39 = 2 40/49 = 3 50/59 = 4 60/69 = 5 70/79 = 6 80/89 = 7, gen (agecateg)
tab agecateg

//recode conrinc to normalize income distribution
gen loginc = ln(conrinc)

//labels
label variable educ "Highest Year of Education"
label variable age "Age of Respondent"
label variable year "GSS Year"

** First Presentation Analysis
tab year
tab newsfrom newsmedia
tab polviews polext
tab year newsmedia, col chi
tab year polext, col chi

//Tables in Presentation
ttest age, by (internet)
ttest age, by (tv)
ttest age, by (radio)
ttest age, by (printmedia)
ttest age, by (extreme)
ttest age, by (fullprty)
ttest age, by (nearcntr)
ttest age, by (center)
tab year
tab polext newsmedia, col
tab polext newsmedia, row
tab polext newsmedia if (agecateg) == 1, row

//Controling for 'digital divide'
tab polext newsmedia if (agecateg) == 1, row
by year, sort: tab polext newsmedia if (agecateg) == 1, row

**Analysis Used in Poster Presentation and Final Paper

** Uses packages st0097 st0208 spost9 estout**

use "/Volumes/Untitled/soc412/GSS0616v2.dta"


//Univariate Tests

tab year

//Variables Treated as Nominal
tab newsmedia
tab race
tab polviews

//Variables Treated as Ordinal
tab polext
tabstat polext, stats(n q min max iqr)

//Variables Treated as Continuous
summarize age, detail
summarize conrinc, detail
summarize loginc, detail
summarize educ, detail

//Bivariate Tests

tab polviews newsmedia, col chi
tab polext newsmedia, col chi
tab polext race, col chi
ttest age, by (extreme)
ttest loginc, by (extreme)
ttest educ, by (extreme)
/*
**Ordered Generalized Linear Model 
Using this type of model in order to retain the ordinal nature of the variable but without violating the parralel odds assumption of the ordinal logit model.
*/
//1=center 4=ext
xi: oglm polext i.newsmedia, or store (polext1)
xi: oglm polext i.newsmedia age i.race, or store (polext2)
xi: oglm polext i.newsmedia age i.race educ loginc, or store (PoliticalExtremeness)
esttab polext1 polext2 PoliticalExtremeness using oglm.rtf, t stats(N ll pr2) rtf mtitle label

/*
**Binary Logit Models and Marginal Changes
Using these to quickly highlight the way that age affects the relationship between extremeness and internet use for news.  Age has been a huge factor in why the data does not allign with some theories and personal observation.  Ultimatly I would suggest all theories and observations I had in the beginning would hold if the analysis could be performed only on people 18-35. However sample size does not permit this.
*/
quietly xi: logit extreme i.newsmedia age i.race educ loginc
quietly margins, at(age=(20(5)80))
marginsplot

quietly xi: logit internet i.polext age i.race educ loginc
quietly margins, at(age=(20(5)80))
marginsplot

/*
**Multinomial Logit Model
Using this model to examime the relationship between political views and news media sources in more detail.  This model allows the reader to see the relationship all the way across the politcal spectrum and assumes no ordinal relationship between values.
*/
//1=ext lib 7=ext con
eststo clear
xi: mlogit polviews i.newsmedia, rrr 
eststo
xi: mlogit polviews i.newsmedia age i.race, rrr 
eststo
xi: mlogit polviews i.newsmedia age i.race educ loginc, rrr 
eststo

esttab est1 est2 est3 using mlog.rtf, t stats(N ll pr2) rtf mtitle label


















