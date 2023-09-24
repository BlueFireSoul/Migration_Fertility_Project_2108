********************************************
*e5_obtain_land_elasticity
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global temp_dir ="../temp"
global output_dir="../output"
global e2c_met2013_rent_dta="$output_dir/e2c_met2013_rent.dta"
global diamond_dta="../data/diamond2016_gmm_estimation_data.dta"
global cbsa2013_names_txt="../data/tl_2013_us_cbsa/cbsa2013_names.txt"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	*e5a_load_data
	e5b_organize_manual_data
	
end

prog e5b_organize_manual_data
	import delimited using $output_dir/e5a_land_elast_manual.csv, clear
	collapse (mean)supply_elast, by(met2013)
	merge 1:1 met2013 using $e2c_met2013_rent_dta, nogen keep(using match)
	egen average=mean(supply_elast)
	replace supply_elast=average if supply_elast==.
	sort met2013
	gen epsilon=1/(supply_elast+1)
	keep met2013 epsilon
	export delimited using $output_dir/e5b_land_elast.csv, replace
	

end

prog e5a_load_data
	import delimited using $cbsa2013_names_txt, clear
	ren cbsafp met2013
	ren name met2013_name
	keep met2013 met2013_name
	save $temp_dir/temp1.dta, replace
	
	u $diamond_dta, clear
	label var WRLURI_msa "Wharton Landuse Regulation Index"
	label var unaval_msa "Pct Land Unavailable for Real Estate Development"
	keep msa WRLURI_msa unaval_msa year
	collapse (mean) WRLURI_msa unaval_msa, by(msa)
	gen supply_elast=0.014+0.091*exp(WRLURI_msa)+0.021*exp(unaval_msa)
	keep if supply_elast!=.
	sum supply_elast, detail
	decode msa, generate(met2013_name)
	merge 1:1 met2013_name using $temp_dir/temp1.dta, keep(match master) nogen
	export delimited using $output_dir/e5a_land_elast_pre.csv, replace
end



* Execute
main

