********************************************
*e1_setup_acs
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global temp_dir ="../temp"
global output_dir="../output"
global e1a_acs_dta="$output_dir/e1a_acs.dta"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	e2a_regional_rent_without_child
	*e2b_check_rent_with_child
	*e2c_obtain_regional_rent
	*e2d_obtain_regional_wage
end

prog e2d_obtain_regional_wage
	u $output_dir/e1a_acs.dta, clear
	drop if met2013==0
	
	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	
	keep if incwage>10
	keep if empstat==1
	collapse (mean)incwage [pweight=perwt], by(met2013 coll_educ)
	ren incwage met2013_inc
	sum met2013_inc, detail
	reshape wide met2013_inc, i(met2013) j(coll_educ)
	ren met2013_inc0 met2013_incL
	ren met2013_inc1 met2013_incH
	save $output_dir/e2d_met2013_inc.dta, replace
end


prog e2c_obtain_regional_rent
	u $output_dir/e1a_acs.dta, clear
	drop if met2013==0
	keep if sftype==0
	drop if rentgrs<=10
	collapse (mean)rentgrs (firstnm) met2013 hhwt, by(serial)
	collapse (mean)rentgrs [pweight=hhwt], by(met2013)
	sum rentgrs, detail
	ren rentgrs met2013_rent
	save $output_dir/e2c_met2013_rent.dta, replace
end


prog e2b_check_rent_with_child
	u $output_dir/e1a_acs.dta, clear
	keep if sftype==0
	keep if nchild>0
	drop if rentgrs<=10
	drop if hhincome<=10
	
	sum rentgrs, detail
	sum hhincome, detail
	
	gen rent_ratio=(12*rentgrs)/hhincome
	drop if rent_ratio>1
	sum rent_ratio, detail
end

prog e2a_regional_rent_without_child
	u $output_dir/e1a_acs.dta, clear
	keep if sftype==0
	keep if famsize==2
	keep if nchild==0
	drop if rentgrs<=10
	drop if hhincome<=10
	
	sum rentgrs, detail
	sum hhincome, detail
	
	gen rent_ratio=(12*rentgrs)/hhincome
	drop if rent_ratio>1
	sum rent_ratio [aweight=perwt], detail 
	* keep marital status later
	
	* hhincome
end

* Execute
main

