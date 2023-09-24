********************************************
*e1_setup_acs
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global puma_centroid_txt ="C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/ipums_puma_2010/2010puma_centroid.txt"
global state_population_centroid_txt ="C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/2000state_population_centroid.txt"
global acs2015_dta = "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/acs_00017.dta"
global pumax2013cbsa_txt ="C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/2013puma_x_2013cbsa.txt"
global pumax2007cbsa_txt ="C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/2013puma_x_2007cbsa.txt"
global temp_dir ="../temp"
global output_dir="../output"
global f2_output_dir="../../3ModelEstimation/output"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	e1a_load_data
	
	e1_f2a_distance_index
end


prog e1a_load_data
	import delimited using "$puma_centroid_txt", clear
	ren latitude latitude_puma
	ren longitude longitude_puma
	keep puma statefip latitude_puma longitude_puma
	save $temp_dir/e1a_puma.dta, replace
	
	import delimited using "$state_population_centroid_txt", clear
	ren fips bpl
	ren latitude latitude_bpl
	ren longitude longitude_bpl
	keep bpl latitude_bpl longitude_bpl
	save $temp_dir/e1a_state.dta, replace
	
	import delimited using "$pumax2013cbsa_txt", clear
	save $temp_dir/e1a_pumax2013cbsa.dta, replace
	
	import delimited using "$pumax2007cbsa_txt", clear
	save $temp_dir/e1a_pumax2007cbsa.dta, replace
	
	u "$acs2015_dta", clear
	keep if age>=25 & age<=45
	drop if inlist(statefip,15,2) | inlist(bpl,15,2)
	merge n:1 bpl using $temp_dir/e1a_state.dta, nogen keep(match)
	merge n:1 statefip puma using $temp_dir/e1a_puma.dta, nogen keep(match)
	merge n:1 statefip puma using $temp_dir/e1a_pumax2013cbsa.dta, nogen keep(match)
	merge n:1 statefip puma using $temp_dir/e1a_pumax2007cbsa.dta, nogen keep(match)
	geodist latitude_bpl longitude_bpl latitude_puma longitude_puma, generate(geodistance_puma)
	geodist latitude_bpl longitude_bpl latitude_cbsa2013 longitude_cbsa2013, generate(geodistance_cbsa2013)
	geodist latitude_bpl longitude_bpl latitude_cbsa2007 longitude_cbsa2007, generate(geodistance_cbsa2007)
	save $output_dir/e1a_acs.dta, replace
end

prog e1_f2a_distance_index
	u $temp_dir/e1a_state.dta, clear
	drop if inlist(bpl,15,2)
	save $temp_dir/temp1.dta, replace
	
	u $output_dir/e1a_acs.dta, clear
	drop if met2013==0
	collapse (mean) latitude_cbsa2013 longitude_cbsa2013 (p50) statefip, by(met2013)
	save $temp_dir/temp2.dta, replace
	
	gen bpl=1
	forvalues x=2/56{
		append using $temp_dir/temp2.dta
		replace bpl=`x' if bpl==.
	}
	merge n:1 bpl using $temp_dir/temp1.dta, nogen keep(match)
	distinct bpl
	geodist latitude_bpl longitude_bpl latitude_cbsa2013 longitude_cbsa2013, generate(geodistance_cbsa2013)
	
	gen v0=1
	gen v1=0
	gen v2=0
	gen v3=0
	gen v4=0
	replace v0=0 if bpl==statefip
	replace v1=1 if bpl!=statefip & geodistance_cbsa2013>=160 & geodistance_cbsa2013< 500
	replace v2=1 if bpl!=statefip & geodistance_cbsa2013>=500 & geodistance_cbsa2013< 1000
	replace v3=1 if bpl!=statefip & geodistance_cbsa2013>=1000 & geodistance_cbsa2013< 2000
	replace v4=1 if bpl!=statefip & geodistance_cbsa2013>=2000 & geodistance_cbsa2013< 500000
	
	gen mu1=0
	gen mu2=0
	gen mu3=0
	replace mu1=1 if geodistance_cbsa2013< 500
	replace mu2=1 if geodistance_cbsa2013>=500 & geodistance_cbsa2013< 1000
	replace mu3=1 if geodistance_cbsa2013>=1000 & geodistance_cbsa2013< 1500
	
	sort bpl 
	egen bpl_num=group(bpl)
	
	sort met2013
	egen met2013_num=group(met2013)

	forvalues x=1/49{
		gen dist_index`x'=1 if bpl_num==`x'
		replace dist_index`x'=2 if v0==1 & bpl_num==`x'
		replace dist_index`x'=3 if v1==1 & bpl_num==`x'
		replace dist_index`x'=4 if v2==1 & bpl_num==`x'
		replace dist_index`x'=4 if v3==1 & bpl_num==`x'
		replace dist_index`x'=5 if v4==1 & bpl_num==`x'
		
		gen kappa_index`x'=1 if bpl_num==`x'
		replace kappa_index`x'=2 if mu1==1 & bpl_num==`x'
		replace kappa_index`x'=3 if mu2==1 & bpl_num==`x'
	}
	
	collapse (mean) dist_index* kappa_index*, by(met2013)
	order met2013 dist_index* kappa_index*
	sort met2013
	drop met2013
	
	preserve 
	drop kappa_index*
	export delimited using $f2_output_dir/e1_f2a_dist_index.csv, novarnames replace
	
	restore
	keep kappa_index*
	export delimited using $f2_output_dir/e1_f2a_kappa_index.csv, novarnames replace

end



* Execute
main

