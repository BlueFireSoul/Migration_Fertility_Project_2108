********************************************
*h3_compare_pop_dist_over_time
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

global census1990_dta = "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/census_1990_5pc.dta"
global puma1990_centroid_txt="C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\2PreliminaryDataPatternCensus\data\ipums_puma_1990_5pct\1990puma_centroid.txt"
global puma1990_area_txt="C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\2PreliminaryDataPatternCensus\data\ipums_puma_1990_5pct\1990puma_area.txt"
global puma1990_shapex_txt="C:\Users\67311\OneDrive - The Pennsylvania State University\Analysis\2108HouseholdMigration\1Clean\2PreliminaryDataPatternCensus\data\ipums_puma_1990_5pct\1990puma_2013cbsa_shape_x.txt"

global acs2015_dta = "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/data/acs_00017.dta"

global e2c_rent_dta="..\output\e2c_met2013_rent.dta"

global temp_dir ="../temp"
global output_dir="../output"
global f2_output_dir="../../3ModelEstimation/output"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	*h3a_obtain_1990_popdist
	*h3b_obtain_2000_popdist
	*h3c_obtain_acs_popdist
	*h3d_obtain_acs_fertility_dist
	h4e_compile_msa
	
	*h3f_obtain_alt_2000_popdist
	*h4g_compile_alt_msa
end

prog h4g_compile_alt_msa
	u $temp_dir/h3c_acs_popdist.dta, clear
	merge 1:1 met2013 using $temp_dir/h3f_alt_2000_popdist.dta, nogen keep(match)
	merge 1:1 met2013 using $e2c_rent_dta, nogen keep(match)
	merge 1:1 met2013 using $temp_dir/h3d_acs_f_dist.dta, nogen keep(match)

	gen pop2015=popL2015+popH2015
	
	gen ptcL_00_15=popL2015/popL2000alt
	gen ptcH_00_15=popH2015/popH2000alt

	reg ptcL_00_15 f_rateL2015 [aweight=popL2015]
	reg ptcH_00_15 f_rateH2015 [aweight=popH2015]
end

prog h3f_obtain_alt_2000_popdist
	u "$census2000_dta", clear
	drop if met2013==0
	keep if age>=25 & age<=45
	drop if inlist(statefip,15,2) | inlist(bpl,15,2)
	
	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	
	gen popcount=1
	collapse (sum)popcount [pweight=perwt], by(met2013 coll_educ)
	reshape wide popcount, i(met2013) j(coll_educ)
	ren popcount0 popL2000alt
	ren popcount1 popH2000alt
	
	save $temp_dir/h3f_alt_2000_popdist.dta, replace
end

prog h4e_compile_msa
	u $temp_dir/h3c_acs_popdist.dta, clear
	merge 1:1 met2013 using $temp_dir/h3d_acs_f_dist.dta, nogen keep(match)
	merge 1:1 met2013 using $temp_dir/h3a_1990_popdist.dta, nogen keep(match)
	merge 1:1 met2013 using $temp_dir/h3b_2000_popdist.dta, nogen keep(match)
	merge 1:1 met2013 using $e2c_rent_dta, nogen keep(match)
	
	gen pop2015=popL2015+popH2015
	
	gen ptcL_90_15=log(popL2015/popL1990)
	gen ptcL_90_00=log(popL2000/popL1990)
	gen ptcL_00_15=log(popL2015/popL2000)
	
	gen ptcH_90_15=log(popH2015/popH1990)
	gen ptcH_90_00=log(popH2000/popH1990)
	gen ptcH_00_15=log(popH2015/popH2000)

	reg ptcL_90_15 f_rateL2015 [aweight=popL2015]
	reg ptcL_90_00 f_rateL2015 [aweight=popL2015]
	reg ptcL_00_15 f_rateL2015 [aweight=popL2015]
	
	reg ptcH_90_15 f_rateH2015 [aweight=popH2015]
	reg ptcH_90_00 f_rateH2015 [aweight=popH2015]
	reg ptcH_00_15 f_rateH2015 [aweight=popH2015]
	
	reg ptcL_90_15 met2013_rent [aweight=popL2015]
	reg ptcL_90_00 met2013_rent [aweight=popL2015]
	reg ptcL_00_15 met2013_rent [aweight=popL2015]
	
	reg ptcH_90_15 met2013_rent [aweight=popH2015]
	reg ptcH_90_00 met2013_rent [aweight=popH2015]
	reg ptcH_00_15 met2013_rent [aweight=popH2015]
	
	twoway scatter ptcL_90_15 f_rateL2015 [w=pop2015],msymbol(circle_hollow)|| lfit ptcL_90_15 f_rateL2015, name(graph1, replace)
	twoway scatter ptcL_90_00 f_rateL2015 [w=pop2015],msymbol(circle_hollow)|| lfit ptcL_90_00 f_rateL2015, name(graph2, replace)
	twoway scatter ptcL_00_15 f_rateL2015 [w=pop2015],msymbol(circle_hollow)|| lfit ptcL_00_15 f_rateL2015, name(graph3, replace)
	
	twoway scatter ptcH_90_15 f_rateH2015 [w=pop2015],msymbol(circle_hollow)|| lfit ptcH_90_15 f_rateH2015, name(graph4, replace)
	twoway scatter ptcH_90_00 f_rateH2015 [w=pop2015],msymbol(circle_hollow)|| lfit ptcH_90_00 f_rateH2015, name(graph5, replace)
	twoway scatter ptcH_00_15 f_rateH2015 [w=pop2015],msymbol(circle_hollow)|| lfit ptcH_00_15 f_rateH2015, name(graph6, replace)
	
	foreach x of varlist popL2015 popL1990 popL2000{
		preserve
		collapse (mean) f_rateL2015 [aweight=`x']
		display(f_rateL2015[1])
		restore
	}
	
	foreach x of varlist popH2015 popH1990 popH2000{
		preserve
		collapse (mean) f_rateH2015 [aweight=`x']
		display(f_rateH2015[1])
		restore
	}
end


prog h3d_obtain_acs_fertility_dist
	u "$acs2015_dta", clear
	drop if met2013==0
	keep if age>=35 & age<=39
	drop if inlist(statefip,15,2) | inlist(bpl,15,2)
	
	gen withchild=0 if nchild==0
	replace withchild=1 if nchild>0 & nchild<99
	
	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	

	collapse (mean) withchild [pweight=perwt], by(met2013 coll_educ)
	ren withchild f_rate
	reshape wide f_rate, i(met2013) j(coll_educ)
	ren f_rate0 f_rateL2015
	ren f_rate1 f_rateH2015

	save $temp_dir/h3d_acs_f_dist.dta, replace
end

prog h3c_obtain_acs_popdist
	u "$acs2015_dta", clear
	drop if met2013==0
	keep if age>=25 & age<=45
	drop if inlist(statefip,15,2) | inlist(bpl,15,2)
	
	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	
	gen popcount=1
	collapse (sum)popcount [pweight=perwt], by(met2013 coll_educ)
	reshape wide popcount, i(met2013) j(coll_educ)
	ren popcount0 popL2015
	ren popcount1 popH2015

	save $temp_dir/h3c_acs_popdist.dta, replace
end

prog h3a_obtain_1990_popdist
	import delimited using "$puma1990_area_txt", clear
	ren shape_area shape_area_puma
	keep statefip puma shape_area_puma
	save $temp_dir/h3a_puma_area.dta, replace
	
	****
	
	u "$census1990_dta", clear
	keep if age>=25 & age<=45
	drop if inlist(statefip,15,2) | inlist(bpl,15,2)
	
	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	
	gen popcount=1
	collapse (sum)popcount [pweight=perwt], by(statefip puma coll_educ)
	reshape wide popcount, i(statefip puma) j(coll_educ)
	ren popcount0 popL
	ren popcount1 popH
	merge 1:1 statefip puma using $temp_dir/h3a_puma_area.dta, nogen keep(match)
	save $temp_dir/temp1.dta, replace
	
	******
	
	import delimited using "$puma1990_shapex_txt", clear
	keep statefip puma cbsafp shape_area
	merge n:1 statefip puma using $temp_dir/temp1.dta, nogen keep(match)
	gen area_pt=shape_area/shape_area_puma
	gen popL1990=popL*area_pt
	gen popH1990=popH*area_pt
	
	collapse (sum) popL1990 popH1990, by(cbsafp)
	ren cbsafp met2013
	
	save $temp_dir/h3a_1990_popdist.dta, replace
end

prog h3b_obtain_2000_popdist
	import delimited using "$puma2000_area_txt", clear
	ren shape_area shape_area_puma
	keep statefip puma shape_area_puma
	save $temp_dir/h3b_puma_area.dta, replace
	
	****
	
	u "$census2000_dta", clear
	keep if age>=25 & age<=45
	drop if inlist(statefip,15,2) | inlist(bpl,15,2)
	
	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	
	gen popcount=1
	collapse (sum)popcount [pweight=perwt], by(statefip puma coll_educ)
	reshape wide popcount, i(statefip puma) j(coll_educ)
	ren popcount0 popL
	ren popcount1 popH
	merge 1:1 statefip puma using $temp_dir/h3b_puma_area.dta, nogen keep(match)
	save $temp_dir/temp1.dta, replace
	
	******
	
	import delimited using "$puma2000_shapex_txt", clear
	keep statefip puma cbsafp shape_area
	merge n:1 statefip puma using $temp_dir/temp1.dta, nogen keep(match)
	gen area_pt=shape_area/shape_area_puma
	gen popL2000=popL*area_pt
	gen popH2000=popH*area_pt
	
	collapse (sum) popL2000 popH2000, by(cbsafp)
	ren cbsafp met2013
	
	save $temp_dir/h3b_2000_popdist.dta, replace
end




* Execute
main

