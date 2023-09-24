********************************************
*c2_spatial_analysis
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global temp_dir ="../temp"
global output_dir="../output"
global c1a_census_dta ="$output_dir/c1a_census.dta"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	c2a_create_variables
	*c2b_analysis
end

prog c2b_analysis
	reg geodistance i.haschild i.educd i.age i.metro i.ownershpd i.poverty_num i.single i.race i.school i.empstatd i.bpld i.statefip [pw=perwt], vce(cluster cluster)
	reg age_birth i.kbdist_num i.educd i.age i.metro i.ownershpd i.poverty_num i.single i.race i.school i.empstatd i.bpld i.statefip [pw=perwt], vce(cluster cluster)
	reg haschild i.kbdist_num i.educd i.age i.metro i.ownershpd i.poverty_num i.single i.race i.school i.empstatd i.bpld i.statefip [pw=perwt], vce(cluster cluster)
	reg nchild i.kbdist_num i.educd i.age i.metro i.ownershpd i.poverty_num i.single i.race i.school i.empstatd i.bpld i.statefip [pw=perwt], vce(cluster cluster)
	reg nchild geodistance i.educd i.age i.metro i.ownershpd i.poverty_num i.single i.race i.school i.empstatd i.bpld i.statefip [pw=perwt], vce(cluster cluster)
	
	reg geodistance i.haschild i.educd i.migrate5d i.age i.metro i.ownershpd i.poverty_num i.single i.race i.school i.empstatd i.bpld i.statefip [pw=perwt], vce(cluster cluster)

end

prog c2a_create_variables
	u $c1a_census_dta, clear
	
	gen kstage_num=0 if age>=26 & age<=30
	replace kstage_num=1 if age>=31 & age<=35
	replace kstage_num=2 if age>=36 & age<=40
	
	keep if kstage_num==2
	replace nchild=3 if nchild>3 & nchild<=9
	
	gen kbdist_num=0 if bpl==statefip
	replace kbdist_num=1 if bpl!=statefip & geodistance>=50 & geodistance<200
	replace kbdist_num=2 if bpl!=statefip & geodistance>=200 & geodistance<500
	replace kbdist_num=3 if bpl!=statefip & geodistance>=500 & geodistance<1000
	replace kbdist_num=4 if bpl!=statefip & geodistance>=1000 & geodistance<2000
	replace kbdist_num=5 if bpl!=statefip & geodistance>=2000 & geodistance<10e8
	
	replace hhincome=. if hhincome==9999999
	
	gen poverty_num=0 if poverty>=1 & poverty<100
	replace poverty_num=1 if poverty>=100 & poverty<200
	replace poverty_num=2 if poverty>=200 & poverty<300
	replace poverty_num=3 if poverty>=300 & poverty<400
	replace poverty_num=4 if poverty>=400 & poverty<500
	replace poverty_num=5 if poverty==501
	
	gen haschild=0 if nchild==0
	replace haschild=1 if nchild>0 & nchild<=9
	
	replace eldch=. if eldch==99
	gen age_birth=age-eldch
	replace age_birth=. if age_birth<16
	
	gen single=0 if sploc!=0
	replace single=1 if sploc==0
	tab poverty_num
	tab kstage_num
	tab kbdist_num
	
end


* Execute
main

