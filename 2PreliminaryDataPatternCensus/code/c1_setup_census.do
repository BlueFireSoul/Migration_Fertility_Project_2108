********************************************
*c1_setup_census
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global puma_centroid_txt ="C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/2000puma_centroid.txt"
global state_population_centroid_txt ="C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/2000state_population_centroid.txt"
global census2000_dta = "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/usa_00008.dta"
global temp_dir ="../temp"
global output_dir="../output"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	c1a_load_data
	
end


prog c1a_load_data
	import delimited using "$puma_centroid_txt", clear
	ren latitude latitude_puma
	ren longitude longitude_puma
	keep puma statefip latitude_puma longitude_puma
	save $temp_dir/c1a_puma.dta, replace
	
	import delimited using "$state_population_centroid_txt", clear
	ren fips bpl
	ren latitude latitude_bpl
	ren longitude longitude_bpl
	keep bpl latitude_bpl longitude_bpl
	save $temp_dir/c1a_state.dta, replace
	
	u "$census2000_dta", clear
	keep if sex==2
	keep if age>=26 & age<=40
	merge n:1 bpl using $temp_dir/c1a_state.dta, nogen keep(match)
	merge n:1 statefip puma using $temp_dir/c1a_puma.dta, nogen keep(match)
	geodist latitude_bpl longitude_bpl latitude_puma longitude_puma, generate(geodistance) miles
	save $output_dir/c1a_census.dta, replace
end


* Execute
main

