********************************************
*e3A_fertility_and_rent_pattern
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global temp_dir ="../temp"
global output_dir="../output"
global object_dir="../object"
global e1a_acs_dta="$output_dir/e1a_acs.dta"
global e2c_met2013_rent_dta="$output_dir/e2c_met2013_rent.dta"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	*e3Aa_first_look
	
	*e3Ab_check_age_group_differences
	
	*e3Ac_by_skill_level
	
	*e3Ad_by_skill_sex
	
	e3Ae_figure_for_paper
end

prog e3Ae_figure_for_paper

	u $e1a_acs_dta, clear
	
	gen popcount=1
	collapse (sum) popcount [pweight=perwt], by(met2013)
	save $temp_dir/temp2.dta, replace
	
	
	u $e1a_acs_dta, clear
	keep if age>=35 & age<=39
	keep if sex==2

	gen withchild=0 if nchild==0
	replace withchild=1 if nchild>0 & nchild<99
	drop if met2013==0

	replace nchild=. if nchild==0

	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	
	gen popcount=1
	
	preserve
	keep if coll_educ==0
	collapse (sum) popcount (mean) withchild nchild [pweight=perwt], by(met2013)
	ren withchild f_L
	ren nchild n_L
	ren popcount popcount_L
	save $temp_dir/temp1.dta, replace
	restore
	
	keep if coll_educ==1
	collapse (sum) popcount (mean) withchild nchild [pweight=perwt], by(met2013)
	ren withchild f_H
	ren nchild n_H
	ren popcount popcount_H
	merge 1:1 met2013 using $temp_dir/temp1.dta, nogen
	merge 1:1 met2013 using $temp_dir/temp2.dta, nogen
	merge 1:1 met2013 using $e2c_met2013_rent_dta, nogen keep(match)
	
	*gen logpop=log(popcount)

	*twoway scatter f_L logpop,msymbol(circle_hollow)|| lfit f_L logpop, saving($temp_dir/lowskill.gph,replace) leg(off)  ylabel(0.5(0.1)1) ytitle("Share of HHs with children") xtitle("Log city population") title("Low skill sample") 
	*twoway scatter f_H logpop, msymbol(circle_hollow) || lfit f_H logpop, saving($temp_dir/highskill.gph,replace) leg(off) ylabel(0.5(0.1)1)  ytitle("") xtitle("Log city population") title("High skill sample") yscale(off)
	*gr combine $temp_dir/lowskill.gph $temp_dir/highskill.gph, ysize(5) xsize(10)
	*graph export $object_dir/e3Ae_share_on_size.png, replace
	
	gen logrent=log(met2013_rent)
	label variable f_L "low skill"
	label variable f_H "high skill"
	twoway scatter f_L logrent,msymbol(circle_hollow) mcolor(red) || lfit f_L logrent, lcolor(red) || scatter f_H logrent,msymbol(X) mcolor(blue) || lfit f_H logrent, ylabel(0.4(0.1)1) lcolor(blue) leg(order(1 3) rows(2) ring(0) position(1) bmargin(large)) ytitle("Share of HHs with children") xtitle("Log rent") ylabel(, nogrid) bgcolor(white) graphregion(color(white))
	graph export $object_dir/e3Ae_share_on_rent.png, replace
end


prog e3Ad_by_skill_sex
	u $e1a_acs_dta, clear
	keep if age>=35 & age<=39
	keep if sex==2

	gen withchild=0 if nchild==0
	replace withchild=1 if nchild>0 & nchild<99
	drop if met2013==0

	replace nchild=. if nchild==0

	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	
	gen popcount=1
	
	preserve
	keep if coll_educ==0
	collapse (sum) popcount (mean) withchild nchild [pweight=perwt], by(met2013)
	ren withchild f_L
	ren nchild n_L
	ren popcount popcount_L
	save $temp_dir/temp1.dta, replace
	restore
	
	keep if coll_educ==1
	collapse (sum) popcount (mean) withchild nchild [pweight=perwt], by(met2013)
	ren withchild f_H
	ren nchild n_H
	ren popcount popcount_H
	merge 1:1 met2013 using $temp_dir/temp1.dta, nogen
	merge 1:1 met2013 using $e2c_met2013_rent_dta, nogen keep(match)
	
	gen popcount=popcount_L+popcount_H
	
	twoway scatter f_L met2013_rent [w=popcount],msymbol(circle_hollow)|| lfit f_L met2013_rent, name(graph1, replace)
	twoway scatter n_L met2013_rent [w=popcount],msymbol(circle_hollow)|| lfit n_L met2013_rent, name(graph2, replace)
	twoway scatter f_H met2013_rent [w=popcount],msymbol(circle_hollow)|| lfit f_H met2013_rent, name(graph3, replace)
	twoway scatter n_H met2013_rent [w=popcount],msymbol(circle_hollow)|| lfit n_H met2013_rent, name(graph4, replace)
end


prog e3Ac_by_skill_level
	u $e1a_acs_dta, clear
	keep if age>=30 & age<=39
	gen withchild=0 if nchild==0
	replace withchild=1 if nchild>0 & nchild<99
	drop if met2013==0
	
	replace nchild=. if nchild==0
	
	gen coll_educ=0 
	replace coll_educ=1 if educ==10 | educ==11
	
	gen popcount=1
	
	preserve
	keep if age>=30 & age<=34 & coll_educ==0
	collapse (sum) popcount (mean) withchild nchild [pweight=perwt], by(met2013)
	ren withchild f34_L
	ren nchild n34_L
	ren popcount popcount34_L
	save $temp_dir/temp1.dta, replace
	restore
	
	preserve
	keep if age>=35 & age<=39 & coll_educ==0
	collapse (sum) popcount (mean) withchild nchild [pweight=perwt], by(met2013)
	ren withchild f39_L
	ren nchild n39_L
	ren popcount popcount39_L
	save $temp_dir/temp2.dta, replace
	restore

	preserve
	keep if age>=30 & age<=34 & coll_educ==1
	collapse (sum) popcount (mean) withchild nchild [pweight=perwt], by(met2013)
	ren withchild f34_H
	ren nchild n34_H
	ren popcount popcount34_H
	save $temp_dir/temp3.dta, replace
	restore
	
	preserve
	keep if age>=35 & age<=39 & coll_educ==1
	collapse (sum) popcount (mean) withchild nchild [pweight=perwt], by(met2013)
	ren withchild f39_H
	ren nchild n39_H
	ren popcount popcount39_H
	save $temp_dir/temp4.dta, replace
	restore
	
	preserve
	keep if age>=30 & age<=39 & coll_educ==0
	collapse (sum) popcount (mean) withchild nchild [pweight=perwt], by(met2013)
	ren withchild f_L
	ren nchild n_L
	ren popcount popcount_L
	save $temp_dir/temp5.dta, replace
	restore
	
	keep if age>=30 & age<=39 & coll_educ==1
	collapse (sum) popcount (mean) withchild nchild [pweight=perwt], by(met2013)
	ren withchild f_H
	ren nchild n_H
	ren popcount popcount_H
	
	merge 1:1 met2013 using $temp_dir/temp1.dta, nogen
	merge 1:1 met2013 using $temp_dir/temp2.dta, nogen
	merge 1:1 met2013 using $temp_dir/temp3.dta, nogen
	merge 1:1 met2013 using $temp_dir/temp4.dta, nogen
	merge 1:1 met2013 using $temp_dir/temp5.dta, nogen
	merge 1:1 met2013 using $e2c_met2013_rent_dta, nogen keep(match)
	gen skill_ratio= popcount_H/(popcount_H+popcount_L)
	
	gen diff39=f39_H-f39_L
	gen diff34_39_L=f39_L-f34_L
	twoway scatter f34_L met2013_rent || lfit f34_L met2013_rent, name(graph1, replace)
	twoway scatter f39_L met2013_rent [w=popcount39_L],msymbol(circle_hollow)|| lfit f39_L met2013_rent, name(graph2, replace) msymbol(circle_hollow)
	twoway scatter f34_H met2013_rent || lfit f34_H met2013_rent, name(graph3, replace)	
	twoway scatter f39_H met2013_rent [w=popcount39_H],msymbol(circle_hollow) || lfit f39_H met2013_rent, name(graph4, replace) 
	twoway scatter f_L met2013_rent || lfit f_L met2013_rent, name(graph5, replace)	
	twoway scatter f_H met2013_rent || lfit f_H met2013_rent, name(graph6, replace)	
	twoway scatter skill_ratio met2013_rent || lfit skill_ratio met2013_rent, name(graph7, replace)	
	twoway scatter diff39 met2013_rent || lfit diff39 met2013_rent, name(graph8, replace)	
	twoway scatter diff34_39_L met2013_rent || lfit diff34_39_L met2013_rent, name(graph9, replace)	
	twoway scatter n39_L met2013_rent || lfit n39_L met2013_rent, name(graph10, replace)
	twoway scatter n39_H met2013_rent || lfit n39_H met2013_rent, name(graph11, replace)
	
	
end

prog e3Ab_check_age_group_differences
	u $e1a_acs_dta, clear
	gen withchild=0 if nchild==0
	replace withchild=1 if nchild>0 & nchild<99
	drop if met2013==0
	
	
	preserve
	keep if age>=30 & age<=34
	collapse (mean) withchild [pweight=perwt], by(met2013)
	ren withchild f34
	save $temp_dir/temp1.dta, replace
	restore
	
	preserve
	keep if age>=35 & age<=39
	collapse (mean) withchild [pweight=perwt], by(met2013)
	ren withchild f39
	save $temp_dir/temp2.dta, replace
	restore
	
	keep if age>=40 & age<=44
	collapse (mean) withchild [pweight=perwt], by(met2013)
	ren withchild f44
	merge 1:1 met2013 using $temp_dir/temp1.dta, nogen
	merge 1:1 met2013 using $temp_dir/temp2.dta, nogen
	merge 1:1 met2013 using $e2c_met2013_rent_dta, nogen keep(match)
	
	gen diff34_39=f39-f34
	gen diff39_44=f44-f39
	gen diff34_44=f44-f34
	twoway scatter diff34_39 met2013_rent || lfit diff34_39 met2013_rent, name(graph1, replace)
	twoway scatter diff39_44 met2013_rent || lfit diff39_44 met2013_rent, name(graph2, replace)
	twoway scatter diff34_44 met2013_rent || lfit diff34_44 met2013_rent, name(graph3, replace)
	

end

prog e3Aa_first_look
	u $e1a_acs_dta, clear
	
	keep if age>=35 & age<=39
	gen withchild=0 if nchild==0
	replace withchild=1 if nchild>0 & nchild<99
	drop if met2013==0
	
	gen popcount=1
	
	collapse (sum) popcount (mean) withchild [pweight=perwt], by(met2013)
	ren withchild f_rate
	merge 1:1 met2013 using $e2c_met2013_rent_dta, nogen keep(match)
	gen logpop=log(popcount)
	gen logrent=log(met2013_rent)
	gen log_f=log(f_rate)
	kdensity f_rate, name(graph1, replace)
	twoway scatter f_rate met2013_rent || lfit f_rate met2013_rent, name(graph3, replace)
	reg f_rate met2013_rent
end



* Execute
main

