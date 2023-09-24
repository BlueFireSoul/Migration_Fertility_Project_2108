********************************************
*h1_setup_census2000
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global state_population_centroid_txt ="C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/2000state_population_centroid.txt"
global census2000_dta = "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/census_2000.dta"
global puma2000_centroid_txt="C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\2PreliminaryDataPatternCensus\data\ipums_puma_2000\2000puma_centroid.txt"
global puma2000_area_txt="C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\2PreliminaryDataPatternCensus\data\ipums_puma_2000\2000puma_area.txt"
global puma2000_shapex_txt="C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\2PreliminaryDataPatternCensus\data\ipums_puma_2000\2000puma_2013cbsa_shape_x.txt"
global e2d_met2013_inc_dta="C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\2PreliminaryDataPatternCensus\output\e2d_met2013_inc.dta"
global temp_dir ="../temp"
global output_dir="../output"
global f2_output_dir="../../3ModelEstimation/output"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	h1a_load_data
	h1b_estimate_migration_friction
	h1c_compile_puma_level_data
	h1d_obtain_met2013_inc
	*h1e_obtain_met2013_pop
end

prog h1e_obtain_met2013_pop
	import delimited using "$puma2000_shapex_txt", clear
	keep statefip puma cbsafp shape_area
	merge n:1 statefip puma using $temp_dir/h1c_puma2000_inc.dta, nogen keep(match)
	gen area_pt=shape_area/shape_area_puma
	gen popLw=popL*area_pt
	gen popHw=popH*area_pt
	collapse (sum) popLw popHw, by(cbsafp)
	ren cbsafp met2013
	merge 1:1 met2013 using "$e2d_met2013_inc_dta", nogen keep(match)
	sort met2013
	
	
end

prog h1d_obtain_met2013_inc
	import delimited using "$puma2000_shapex_txt", clear
	keep statefip puma cbsafp shape_area
	merge n:1 statefip puma using $temp_dir/h1c_puma2000_inc.dta, nogen keep(match)
	gen area_pt=shape_area/shape_area_puma
	gen popLw=popL*area_pt
	gen popHw=popH*area_pt
	
	preserve
	collapse (mean) puma_incL [aweight=popLw], by(cbsafp)
	save $temp_dir/temp1.dta, replace
	restore
	collapse (mean) puma_incH [aweight=popHw], by(cbsafp)
	merge 1:1 cbsafp using $temp_dir/temp1.dta, nogen keep(match)
	ren cbsafp met2013
	merge 1:1 met2013 using "$e2d_met2013_inc_dta", nogen keep(match)
	sort met2013
	keep met2013 puma_incL puma_incH
	order met2013 puma_incL puma_incH
	export delimited using $f2_output_dir/h1d_2000met2013_inc.csv, replace
end

prog h1c_compile_puma_level_data
	u $output_dir/h1a_census2000.dta, clear
	
	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	
	keep if incwage>10
	keep if empstat==1
	gen popcount=1
	collapse (mean)incwage (sum)popcount [pweight=perwt], by(statefip puma coll_educ)
	ren incwage puma_inc
	sum puma_inc, detail
	reshape wide puma_inc popcount, i(statefip puma) j(coll_educ)
	ren puma_inc0 puma_incL
	ren puma_inc1 puma_incH
	ren popcount0 popL
	ren popcount1 popH
	merge 1:1 statefip puma using $temp_dir/h1a_puma_area.dta, nogen keep(match)
	save $temp_dir/h1c_puma2000_inc.dta, replace
end

prog h1b_estimate_migration_friction
	u $output_dir/h1a_census2000.dta, clear
	
	drop if metarea==0
	
	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	
	gen popcount=1
	
	gen v0=1
	gen v1=0
	gen v2=0
	gen v3=0
	gen v4=0
	replace v0=0 if bpl==statefip
	replace v1=1 if bpl!=statefip & geodistance_puma>=160 & geodistance_puma< 500
	replace v2=1 if bpl!=statefip & geodistance_puma>=500 & geodistance_puma< 1000
	replace v3=1 if bpl!=statefip & geodistance_puma>=1000 & geodistance_puma< 2000
	replace v4=1 if bpl!=statefip & geodistance_puma>=2000 & geodistance_puma< 500000

	preserve 
	keep if age>=35 & age<=39
	collapse (mean) withchild [pweight=perwt], by(bpl metarea coll_educ)
	ren withchild f_rate
	drop if f_rate==1 | f_rate==0
	save $temp_dir/temp1.dta, replace
	restore
	
	collapse (sum) popcount (mean) geodistance_puma (p50) v* [pweight=perwt], by(bpl metarea coll_educ)
	merge 1:1 bpl metarea coll_educ using $temp_dir/temp1.dta, nogen keep(match)
	
	
	gen f_control=1/(1-f_rate)
	gen logpop=log(popcount)
	
	egen bpl_num=group(bpl)
	forvalues x=1/49{
		gen beta`x'=0
		replace beta`x'=f_control if bpl_num==`x'
	}
	
	eststo clear
	preserve
	drop if coll_educ==1	
	quietly eststo: reg logpop v0 v1 v2 v3 v4 i.bpl i.metarea beta*, noconstant
	restore
	drop if coll_educ==0	
	quietly eststo: reg logpop v0 v1 v2 v3 v4 i.bpl i.metarea beta*, noconstant
	esttab, se keep(v*)
	esttab using $f2_output_dir/h1b_migration_cost_theta.csv, not noobs keep(v*) replace plain
end


prog h1a_load_data
	import delimited using "$puma2000_centroid_txt", clear
	ren latitude latitude_puma
	ren longitude longitude_puma
	keep puma statefip latitude_puma longitude_puma
	save $temp_dir/h1a_puma.dta, replace
	
	import delimited using "$state_population_centroid_txt", clear
	ren fips bpl
	ren latitude latitude_bpl
	ren longitude longitude_bpl
	keep bpl latitude_bpl longitude_bpl
	save $temp_dir/h1a_state.dta, replace
	
	import delimited using "$puma2000_area_txt", clear
	ren shape_area shape_area_puma
	keep statefip puma shape_area_puma
	save $temp_dir/h1a_puma_area.dta, replace
	
	u "$census2000_dta", clear
	keep if age>=25 & age<=45
	
	gen withchild=0 if nchild==0
	replace withchild=1 if nchild>0 & nchild<99
	drop if met2013==0
	
	drop if inlist(statefip,15,2) | inlist(bpl,15,2)
	merge n:1 bpl using $temp_dir/h1a_state.dta, nogen keep(match)
	merge n:1 statefip puma using $temp_dir/h1a_puma.dta, nogen keep(match)
	geodist latitude_bpl longitude_bpl latitude_puma longitude_puma, generate(geodistance_puma)
	save $output_dir/h1a_census2000.dta, replace
end




* Execute
main

