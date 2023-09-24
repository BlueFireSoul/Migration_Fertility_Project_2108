********************************************
*f1_estimate_frictions
********************************************
/*  Outline:
	
*/
prog drop _all
set more off


global temp_dir ="../temp"
global output_dir="../output"
global object_dir="../object"
global e1a_acs_dta="..\..\2PreliminaryDataPatternCensus\output\e1a_acs.dta"
global e2c_rent_dta="..\..\2PreliminaryDataPatternCensus\output\e2c_met2013_rent.dta"
global e2d_wage_dta="..\..\2PreliminaryDataPatternCensus\output\e2d_met2013_inc.dta"
global e4c_amenity_dta="..\..\2PreliminaryDataPatternCensus\output\e4c_amenity_proxy.dta"
global e5b_land_elast_csv="..\..\2PreliminaryDataPatternCensus\output\e5b_land_elast.csv"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/3ModelEstimation/code"
	
	*f1a_estimate_migration_cost
	
	*f1c_estimate_support_by_skill
	
	*f1e_taste_estimation
	
	*f2a_state_level_input
	
	*f2b_msa_level_input
	
	*f3a_fertility_regression
	
	*f3b_composition_regression
	
	*f3c_fertility_scatterplot
	
	f3e_fertility_regression_fixed
	
	*-- Archive ---
	*f1d_preliminary_taste
	*f1b_estimate_support_friction
end

prog f3e_fertility_regression_fixed
	f1a1_load_data
	keep if sex==2
	
	eststo clear
	preserve
	drop if coll_educ==1	
	quietly eststo: reg withchild mu1 mu2 i.met2013 i.bpl i.age [pweight=perwt], noconstant
	restore
	preserve
	drop if coll_educ==0	
	quietly eststo: reg withchild mu1 mu2 i.met2013 i.bpl i.age [pweight=perwt], noconstant
	restore
	preserve
	drop if coll_educ==1	
	quietly eststo: reg withchild mu1 mu2 i.met2013 i.bpl i.age i.year [pweight=perwt], noconstant
	restore
	preserve
	drop if coll_educ==0	
	quietly eststo: reg withchild mu1 mu2 i.met2013 i.bpl i.age i.year [pweight=perwt], noconstant
	restore
	esttab, se keep(mu* *age)
	esttab using $object_dir/f3e_fert_on_dist.tex, se keep(mu*) booktabs replace

end

prog f3c_fertility_scatterplot
	f1a1_load_data
	
	preserve
	keep if age>=35 & age<=39
	keep if sex==2
	replace popcount=popcount/perwt
	collapse (sum)popcount (mean) withchild [pweight=perwt], by(bpl met2013 coll_educ)
	ren withchild f_rate
	drop if f_rate==0 | f_rate==1
	drop if popcount<30
	drop popcount
	save $temp_dir/temp1.dta, replace
	restore
	
	collapse (p50) geodistance_puma [pweight=perwt], by(bpl met2013)
	merge 1:n bpl met2013 using $temp_dir/temp1.dta, nogen keep(match)
	reshape wide f_rate, i(met2013 bpl) j(coll_educ)
	
	gen logdist=log(geodistance_puma)
	label variable f_rate0 "low skill"
	label variable f_rate1 "high skill"
	twoway scatter f_rate0 logdist,msymbol(circle_hollow) mcolor(red) || lfit f_rate0 logdist, lcolor(red) || scatter f_rate1 logdist,msymbol(X) mcolor(blue) || lfit f_rate1 logdist, lcolor(blue) ylabel(, nogrid) leg(order(1 3) rows(2) ring(0) position(7) bmargin(large)) ytitle("Share of HHs with children") xtitle("Log distance")  bgcolor(white) graphregion(color(white))
	graph export $object_dir/f3c_fertility_scatterplot.png, replace	

end

prog f3b_composition_regression
	u $e1a_acs_dta, clear
	drop if met2013==0
	gen popcount=1
	collapse (sum) popcount [pweight=perwt], by(met2013)
	gen logpop=log(popcount)
	save $temp_dir/temp1.dta, replace
	
	f1a1_load_data
	
	gen long_distant=0
	replace long_distant=1 if mu1==0 & mu2==0
	
	collapse (mean) long_distant [pweight=perwt], by(met2013 coll_educ)
	reshape wide long_distant, i(met2013) j(coll_educ)
	merge 1:1 met2013 using $temp_dir/temp1.dta, nogen keep(match)
	merge 1:1 met2013 using $e2c_rent_dta, nogen keep(match)
	
	gen logrent=log(met2013_rent)
	
	*twoway scatter long_distant0 logrent,msymbol(circle_hollow)|| lfit long_distant0 logrent, saving($temp_dir/lowskill.gph,replace) leg(off)  ytitle("Share of long-distant migrants") xtitle("Log rent") title("Low skill sample") 
	*twoway scatter long_distant1 logrent, msymbol(circle_hollow) || lfit long_distant1 logrent, saving($temp_dir/highskill.gph,replace) leg(off)  ytitle("") xtitle("Log rent") title("High skill sample") yscale(off)
	*gr combine $temp_dir/lowskill.gph $temp_dir/highskill.gph, ysize(5) xsize(10) ycommon
	*graph export $object_dir/f3b_comp_share_on_rent.png, replace	
	
	label variable long_distant0 "low skill"
	label variable long_distant1 "high skill"
	twoway scatter long_distant0 logrent,msymbol(circle_hollow) mcolor(red) || lfit long_distant0 logrent, lcolor(red) || scatter long_distant1 logrent,msymbol(X) mcolor(blue) || lfit long_distant1 logrent, lcolor(blue) ylabel(0(0.1)0.8, nogrid) leg(order(1 3) rows(2) ring(0) position(1) bmargin(large)) ytitle("Share of long-distance migrants") xtitle("Log rent")  bgcolor(white) graphregion(color(white))
	graph export $object_dir/f3b_comp_share_on_rent.png, replace	
	sort met2013
	keep logrent long_distant0 long_distant1
	order logrent long_distant0 long_distant1
	export delimited using $output_dir/f3b_comp_share_figure_input_pass.csv, replace
end

prog f3a_fertility_regression
	f1a1_load_data
	keep if age>=35 & age<=39
	keep if sex==2
	
	eststo clear
	preserve
	drop if coll_educ==1	
	quietly eststo: reg withchild mu1 mu2 i.met2013 i.bpl [pweight=perwt], noconstant
	restore
	drop if coll_educ==0	
	quietly eststo: reg withchild mu1 mu2 i.met2013 i.bpl [pweight=perwt], noconstant
	esttab, se keep(mu*)
	esttab using $object_dir/f3a_fert_on_dist.tex, se keep(mu*) booktabs replace
end

prog f1e_taste_estimation
	f1d1_prepare_taste_estimation
	merge 1:1 met2013 using $e4c_amenity_dta, nogen keep(match)
	*merge 1:1 met2013 using $temp_dir/temp1.dta, nogen keep(match)
	local y = 1
	foreach x of varlist pui_tea_ratio-b_count72{
		ren `x' c`y'
		local y = `y'+1
	}
	foreach x of varlist c*{
		gen log_`x'=log(`x')
		gen og_`x'=log(log_`x')
		gen sq_`x'=`x'*`x'
	}
	gen log_pop=log(popcount)
	eststo clear
	quietly eststo: regress fixed_L rent_regressor c1 log_c2 log_c3 log_c4 log_c5
	quietly eststo: regress fixed_H rent_regressor c1 log_c2 log_c3 log_c4 log_c5
	quietly eststo: regress fixed_L rent_regressor c1 log_c2 log_c3  
	quietly eststo: regress fixed_H rent_regressor c1 log_c2 log_c3 
	quietly eststo: regress fixed_L rent_regressor c1 log_c2 log_c3 log_c4 
	quietly eststo: regress fixed_H rent_regressor c1 log_c2 log_c3 log_c4 
	quietly eststo: regress fixed_L rent_regressor c1 log_c2 log_c3 log_c5 
	quietly eststo: regress fixed_H rent_regressor c1 log_c2 log_c3 log_c5 
	quietly eststo: regress fixed_L rent_regressor c1 log_c2 log_c3 log_c4 log_c5 log_pop
	quietly eststo: regress fixed_H rent_regressor c1 log_c2 log_c3 log_c4 log_c5 log_pop
	esttab, se ar2
	
	eststo clear
	quietly eststo: regress fixed_L rent_regressor
	quietly eststo: regress fixed_H rent_regressor
	quietly eststo: regress fixed_L rent_regressor c1 log_c2 log_c3 log_c4 log_c5
	quietly eststo: regress fixed_H rent_regressor c1 log_c2 log_c3 log_c4 log_c5
	esttab, se ar2
	
	esttab using $object_dir/f1e_taste_estimation.tex, se keep(rent_regressor) booktabs replace
end

prog f1d_preliminary_taste
	f1d1_prepare_taste_estimation
	
	eststo clear
	quietly eststo: regress fixed_L rent_regressor
	quietly eststo: regress fixed_H rent_regressor
	esttab, p
end

prog f2b_msa_level_input
	import delimited using $e5b_land_elast_csv, clear
	save $temp_dir/temp1.dta, replace
	
	f1a1_load_data
	preserve
	keep if age>=35 & age<=39
	keep if sex==2
	collapse (mean) withchild [pweight=perwt], by(met2013 coll_educ)
	save $temp_dir/temp2.dta, replace
	sum withchild, detail
	restore
	
	collapse (sum) popcount [pweight=perwt], by(met2013 coll_educ)
	merge 1:1 met2013 coll_educ using $temp_dir/temp2.dta, nogen keep(match)
	reshape wide popcount withchild, i(met2013) j(coll_educ)
	ren popcount0 popcountL
	gen popcount_wkL=popcountL*withchild0
	ren popcount1 popcountH
	gen popcount_wkH= popcountH*withchild1
	drop withchild*
	merge 1:1 met2013 using $e2d_wage_dta, nogen keep(match)
	merge 1:1 met2013 using $e2c_rent_dta, nogen keep(match)
	merge 1:1 met2013 using $temp_dir/temp1.dta, nogen keep(match)
	sort met2013
	
	order met2013 popcountL	popcount_wkL popcountH	popcount_wkH met2013_incL met2013_incH	met2013_rent epsilon

	export delimited using $output_dir/f2b_msa_level_input.csv, replace nolabel
end

prog f2a_state_level_input
	f1a1_load_data

	collapse (sum) popcount [pweight=perwt], by(bpl coll_educ)
	reshape wide popcount, i(bpl) j(coll_educ)
	ren popcount0 popcountL
	ren popcount1 popcountH
	sort bpl
	
	export delimited using $output_dir/f2a_state_level_input.csv, replace nolabel
end


prog f1d1_prepare_taste_estimation
	import delimited using $output_dir/f1c_network_fixed_effect.csv, clear varnames(2)
	ren b fixed_L
	ren v3 fixed_H
	split v1, parse(".") gen(k)
	gen met2013=real(k1)
	drop v1 k1 k2
	order met2013, first
	merge 1:1 met2013 using $e2c_rent_dta, nogen keep(match)
	merge 1:1 met2013 using $e2d_wage_dta, nogen keep(match)
	gen rent_regressor=0.39*0.29*log(met2013_rent)
end

prog f1c_estimate_support_by_skill
	f1a1_load_data
	
	preserve
	keep if age>=35 & age<=39
	*keep if sex==2
	replace popcount=popcount/perwt
	collapse (sum)popcount (mean) withchild [pweight=perwt], by(bpl met2013 coll_educ)
	ren withchild f_rate
	drop if f_rate==0 | f_rate==1
	*drop if popcount<5
	drop popcount
	gen regressand=log(f_rate/(1-f_rate))
	save $temp_dir/temp1.dta, replace
	restore
	
	collapse (sum) popcount (p50) mu* [pweight=perwt], by(bpl met2013 coll_educ)
	merge 1:1 bpl met2013 coll_educ using $temp_dir/temp1.dta, nogen keep(match)
	
	sort met2013

	eststo clear
	preserve
	drop if coll_educ==1
	quietly eststo: regress regressand mu1 mu2 i.met2013, noconstant
	restore
	drop if coll_educ==0
	quietly eststo: regress regressand mu1 mu2 i.met2013, noconstant
	esttab, se keep(mu*)
	*esttab, se drop(mu*)
	esttab using $output_dir/f1c_network_support_eta.csv, not noobs keep(mu*) replace plain
	esttab using $object_dir/f1c_network_support_eta.tex, se keep(mu*) booktabs replace
	esttab using $output_dir/f1c_network_fixed_effect.csv, not noobs drop(mu*) replace plain

end

prog f1a_estimate_migration_cost
	f1a1_load_data
	
	preserve
	keep if age>=35 & age<=39
	keep if sex==2
	collapse (mean) withchild [pweight=perwt], by(bpl met2013 coll_educ)
	ren withchild f_rate
	drop if f_rate==1 | f_rate==0
	save $temp_dir/temp1.dta, replace
	restore
	
	collapse (sum) popcount (p50) v* [pweight=perwt], by(bpl met2013 coll_educ)
	merge 1:1 bpl met2013 coll_educ using $temp_dir/temp1.dta, nogen keep(match)
	
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
	quietly eststo: reg logpop v0 v1 v2 v3 v4 i.bpl i.met2013 beta*, noconstant
	restore
	preserve
	drop if coll_educ==0	
	quietly eststo: reg logpop v0 v1 v2 v3 v4 i.bpl i.met2013 beta*, noconstant
	esttab, se keep(v*)
	restore
	esttab using $output_dir/f1a_migration_cost_theta.csv, not noobs keep(v*) replace plain
	
	eststo clear
	preserve
	drop if coll_educ==1	
	quietly eststo: reg logpop v0 v1 v2 v3 v4 i.bpl i.met2013, noconstant
	restore
	preserve
	drop if coll_educ==0	
	quietly eststo: reg logpop v0 v1 v2 v3 v4 i.bpl i.met2013, noconstant
	restore
	preserve
	drop if coll_educ==1	
	quietly eststo: reg logpop v0 v1 v2 v3 v4 i.bpl i.met2013 beta*, noconstant
	restore
	drop if coll_educ==0	
	quietly eststo: reg logpop v0 v1 v2 v3 v4 i.bpl i.met2013 beta*, noconstant
	esttab, se keep(v*)
	esttab using $object_dir/f1a_migration_cost.tex, se keep(v*) booktabs replace
end


prog f1a1_load_data
	u $e1a_acs_dta, clear
	drop if met2013==0
	
	gen withchild=0 if nchild==0
	replace withchild=1 if nchild>0 & nchild<99
	
	
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
	
	gen mu1=0
	gen mu2=0
	replace mu1=1 if geodistance_puma< 500
	replace mu2=1 if geodistance_puma>=500 & geodistance_puma< 1000
end


prog f1b_estimate_support_friction
	f1a1_load_data
	
	collapse (sum) popcount (mean) withchild geodistance_cbsa2013 (p50) mu*, by(bpl met2013)
	ren withchild f_rate
	drop if f_rate==0 | popcount<10 | met2013==0
	gen regressand=log(f_rate/(1-f_rate))
	
	regress regressand mu1 mu2 mu3 i.met2013
end

* Execute
main

