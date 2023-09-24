********************************************
*e3_construct_prices
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global temp_dir ="../temp"
global output_dir="../output"
global cbsa_x_division_txt="../data/2013cbsa_x_division.txt"
global d2_cr_price_txt="$output_dir/d2_cr_price.txt"
global e2c_met2013_rent_dta="$output_dir/e2c_met2013_rent.dta"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	e3a_load_data
end

prog e3a_load_data
	import delimited using $cbsa_x_division_txt, clear
	save $temp_dir/e3a_cbsa_x_division.dta, replace
	
	import delimited using $d2_cr_price_txt, clear
	merge 1:n division2013 using $temp_dir/e3a_cbsa_x_division.dta, update nogen
	drop if met2013==.
	sort division2013
	collapse (firstnm) food_price educ_care_price, by (met2013)
	
	merge 1:1 met2013 using $e2c_met2013_rent_dta, nogen keep(match)
	gen support_price=food_price^(0.18)*educ_care_price^(0.16)*met2013_rent^(0.29)
	
	egen meanp=mean(support_price)
	replace support_price=support_price/meanp
	kdensity support_price
	keep met2013* support_price
	
	save $output_dir/e3a_support_price.dta, replace
end



* Execute
main

