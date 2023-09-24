********************************************
*e4_construct_amenity_proxy
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global temp_dir ="../temp"
global output_dir="../output"
global e2c_met2013_rent_dta="$output_dir/e2c_met2013_rent.dta"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	*e4a_elsi_data
	*e4b_cbp_data
	e4c_compile_and_export
	
end

prog e4a_load_data
	import delimited using ../data/ELSI_csv_export_6377840140006523453470.csv, clear varnames(1)
	gen met2013=real(cbsaiddistrict201617) 
	gen exp_per_pupi=real(totalexpenditurestotalexpperpupi)
	gen pui_tea_ratio=real(pupilteacherratiopublicschool201)
	gen pui_pop=real(totalstudentsallgradesexcludesae)
	keep met2013 exp_per_pupi pui_tea_ratio pui_pop
	collapse (mean) pui_tea_ratio exp_per_pupi [aweight=pui_pop], by(met2013)
	save $temp_dir/temp1.dta, replace
end

prog e4b_cbp_data
	import delimited using ../data/cbp19msa.txt, clear
	ren msa met2013
	gen industry=real(substr(naics,1,2))
	ren est b_count
	keep met2013 industry b_count
	keep if inlist(industry,61,71,72)
	collapse (sum)b_count, by(met2013 industry)
	reshape wide b_count, i(met2013) j(industry)
	save $temp_dir/temp2.dta, replace
end
	
prog e4c_compile_and_export
	u $e1a_acs_dta, clear
	gen popcount=1
	collapse (sum) popcount [pweight=perwt], by(met2013)
	save $temp_dir/temp3.dta, replace
	
	u $e2c_met2013_rent_dta, clear
	drop met2013_rent
	merge 1:1 met2013 using $temp_dir/temp1.dta, nogen keep(match)
	merge 1:1 met2013 using $temp_dir/temp2.dta, nogen keep(match)
	merge 1:1 met2013 using $temp_dir/temp3.dta, nogen keep(match)
	save $output_dir/e4c_amenity_proxy.dta, replace

end


* Execute
main

