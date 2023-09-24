********************************************
*a1_spatial_analysis
********************************************
/*  Outline:
	spatial analysis
		construct kid-move variable
		construct kid controls
		construct respondent controls
		construct respondent move variable
		construct parent controls
		construct parent move variable
		conduct analysis
	
*/
set more off

global a1_family_kidlevel_dta ="C:/Users/67311/OneDrive - The Pennsylvania State University/Data/HRS/Rand/Family Data/randhrsfam1992_2014v1_STATA/randhrsfamk1992_2014v1.dta"
global a1_family_reslevel_dta ="C:/Users/67311/OneDrive - The Pennsylvania State University/Data/HRS/Rand/Family Data/randhrsfam1992_2014v1_STATA/randhrsfamr1992_2014v1.dta"
global a1_longitudinal_dta = "C:/Users/67311/OneDrive - The Pennsylvania State University/Data/HRS/Rand/Longitudinal/randhrs1992_2018v1_STATA/randhrs1992_2018v1.dta"
global a1_detail_impu_dta = "C:/Users/67311/OneDrive - The Pennsylvania State University/Data/HRS/Rand/Detailed Imputations/randhrsimp1992_2018v1_STATA/randhrsimp1992_2018v1.dta"


if "`1'"!="function calling"{
prog drop _all
global temp_dir ="../temp"
global output_dir="../output"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/1PreliminaryDataPattern/code"
	
	a1a_kid_res_closen_variables
	
	a1b_kid_controls
	
	a1c_res_par_closen_variables
	
	a1d_res_controls
	
	a1e_par_controls
	
	a1f_kid_res_analysis
end
}

*Writing

prog a1f_kid_res_analysis

	a1f1_merge_dataset
	
	a1f2_kid_res_analysis
	
end

prog a1f1_merge_dataset
	capture confirm file $temp_dir/a1f1_merged_dataset.dta
	
	if _rc!=0{
	u $temp_dir/a1b2_res_controls.dta, clear
	merge 1:1 hhidpn wave using $temp_dir/a1b2_res_controls.dta, keep(match master) nogen
	order householdid, first
	
	a1f1a_pick_hh_res
	
	foreach x of varlist hhidpn-rlivsib{
		replace `x'=. if !((`x'>-100000000000)&(`x'<100000000000))
	}
	save $temp_dir/temp1.dta, replace
	
	u $temp_dir/a1a2_kid_move.dta, clear
	merge 1:1 kidid wave using $temp_dir/a1b2_kid_controls.dta, keep(matched) nogen
	merge m:1 householdid using $temp_dir/temp1.dta, keep(match using) nogen
	save $temp_dir/a1f1_merged_dataset.dta, replace
	
	erase $temp_dir/temp1.dta
	}
end

prog a1f1a_pick_hh_res
	gen count=0
	foreach x of varlist _all {
		capture replace count=count-1 if !((`x'>-100000000000)&(`x'<100000000000))
	}
	egen maxcount=max(count), by (householdid)
	keep if maxcount==count
	gen random=runiform()
	egen maxrand=max(random), by (householdid)
	keep if maxrand==random
	
	drop maxcount count maxrand random
end


prog a1f2_kid_res_analysis
	u $temp_dir/a1f1_merged_dataset.dta, clear
	
	egen kididnum=group(kidid)
	xtset kididnum kage
	
	log using $output_dir/a1f2_kid_analysis.txt, replace text
	foreach x of varlist klv10mi kmoveIn klocMove kdisMove kmoveInChange kdisChange kcloChange{
	eststo clear
	
	quietly eststo: reg `x' kage i.wave
	quietly eststo: reg `x' kage i.wave [aweight=rwthh]
	quietly eststo: reg `x' kage kagenderbg i.wave
	quietly eststo: reg `x' kage kagenderbg i.wave [aweight=rwthh]
	quietly eststo: reg `x' kage kagenderbg kmstat kaeduc kownhm i.wave
	quietly eststo: reg `x' kage kagenderbg kmstat kaeduc kownhm i.wave [aweight=rwthh]
	quietly eststo: reg `x' kage kagenderbg kmstat knkid i.wave
	quietly eststo: reg `x' kage kagenderbg kmstat knkid i.wave [aweight=rwthh]
	quietly eststo: reg `x' kage kagenderbg kmstat knkid kaeduc kownhm i.wave
	quietly eststo: reg `x' kage kagenderbg kmstat knkid kaeduc kownhm i.wave [aweight=rwthh]
	quietly eststo: reg `x' kage kagenderbg kmstat knkid kaeduc kownhm kincmin kincmax i.wave
	quietly eststo: reg `x' kage kagenderbg kmstat knkid kaeduc kownhm kincmin kincmax i.wave [aweight=rwthh]
	esttab, se title("`x' with Kid Controls (unweighted/weighted; yearly fe)")
	
	eststo clear
	quietly eststo: xtreg `x' kage i.wave, fe
	quietly eststo: xtreg `x' kage kownhm knkid i.wave, fe
	quietly eststo: xtreg `x' kage kmstat kownhm i.wave, fe
	quietly eststo: xtreg `x' kage kmstat kownhm knkid i.wave, fe
	esttab, se title("`x' with Kid Controls (unweighted; yearly fe; ind fe)")	
	
	eststo clear
	quietly eststo: reg `x' kage kaeduc kownhm knkid i.wave
	quietly eststo: reg `x' kage kaeduc kownhm knkid i.wave [aweight=rwthh]
	quietly eststo: reg `x' kage kaeduc kownhm knkid rage ragender i.wave
	quietly eststo: reg `x' kage kaeduc kownhm knkid rage ragender i.wave [aweight=rwthh]
	quietly eststo: reg `x' kage kaeduc kownhm knkid raracem i.wave
	quietly eststo: reg `x' kage kaeduc kownhm knkid raracem i.wave [aweight=rwthh]
	quietly eststo: reg `x' kage kaeduc kownhm knkid rage raracem hitot i.wave
	quietly eststo: reg `x' kage kaeduc kownhm knkid rage raracem hitot i.wave[aweight=rwthh]
	quietly eststo: reg `x' kage kaeduc kownhm knkid rage raracem hatotn hatotnc hitot i.wave
	quietly eststo: reg `x' kage kaeduc kownhm knkid rage raracem hatotn hatotnc hitot i.wave[aweight=rwthh]
	esttab, se title("`x' with Respondent Controls (unweighted/weighted; yearly fe)")	
	
	eststo clear
	quietly eststo: xtreg `x' kage kownhm knkid i.wave, fe
	quietly eststo: xtreg `x' kage kownhm knkid rage i.wave, fe
	quietly eststo: xtreg `x' kage kownhm knkid rage hitot hatotn hatotnc i.wave, fe
	esttab, se title("`x' with Respondent Controls (unweighted; yearly fe; ind fe)")		
	}
	
	log close
	
end



*Pending

prog a1a_kid_res_closen_variables
	capture confirm file $temp_dir/a1a2_kid_move.dta
	
	if _rc!=0{
	a1a1_load_kid_file
	
	a1a2_define_variables
	
	}
end

prog a1b_kid_controls
	capture confirm file $temp_dir/a1b2_kid_controls.dta
	
	if _rc!=0{
	a1a1_load_kid_file
	
	a1b2_select_variable
	}
end

prog a1c_res_par_closen_variables
	capture confirm file $temp_dir/a1c2_res_move.dta
	
	if _rc!=0{
	a1c1_load_fam_res_file
	
	a1c2_define_variables
	}
end

prog a1d_res_controls
	capture confirm file $temp_dir/a1b2_res_controls.dta
	
	if _rc!=0{
	a1d1_load_fam_res_file
	
	a1d2_select_variables
	}
end

prog a1e_par_controls
	capture confirm file $temp_dir/a1e2_par_controls.dta
	
	if _rc!=0{
	a1c1_load_fam_res_file
	
	a1e2_select_variables
	}
end

*Secondary
prog a1a1_load_kid_file
	capture confirm file "$temp_dir/a1a1_kid_sorted_file.dta"
	
	if _rc!=0{
		u "$a1_family_kidlevel_dta", clear
		*keep if hacohort==3
		keep if link==1
		*ex1a_examine_kidid
		tab hasplit
		drop if hasplit==1

		gsort kidid -kapick -k1pick -k2pick -k3pick -k4pick -k5pick -k6pick -k7pick ///
		-k8pick -k9pick -k10pick -k11pick -k12pick 
		order kidid, first
		collapse (firstnm)hhidpn-inw12, by(kidid)
		gen householdid=real(substr(kidid,1,6))
		save $temp_dir/a1a1_kid_sorted_file.dta, replace
	}
	else{
		u $temp_dir/a1a1_kid_sorted_file.dta, clear
	}
end

prog a1a2_define_variables
	keep kabyearbg k*lv10mi kidid
	foreach x of varlist  k*lv10mi{
		replace `x'=2 if `x'==.l
		replace `x'=. if ~ inlist(`x',0,1,2)
	}
	
	gen kage=1992-kabyearbg
	drop if kage==.
	
	forvalue i=1/12{
		gen kage`i'=kage+(`i'-1)*2
	}
	drop kage kabyearbg	

	
	forvalue i=2/12{
		local j=`i'-1
		
		gen klocMove`i'=0 if k`j'lv10mi!=. & k`i'lv10mi!=.
		replace klocMove`i'=1 if (k`j'lv10mi!=k`i'lv10mi) & klocMove`i'==0
		
		gen kdisMove`i'=0 if k`j'lv10mi!=. & k`i'lv10mi!=.
		replace kdisMove`i'=1 if (k`j'lv10mi==0 & inlist(k`i'lv10mi,1)) & kdisMove`i'==0
		replace kdisMove`i'=1 if (k`i'lv10mi==0 & inlist(k`j'lv10mi,1)) & kdisMove`i'==0
	}
	
	forvalue i=2/12{
		local j=`i'-1
		
		*from 0,1 to 2
		gen kmoveInChange`i'=0 if k`j'lv10mi==2 & inlist(k`i'lv10mi,0,1)
		replace kmoveInChange`i'=1 if k`i'lv10mi==2 & inlist(k`j'lv10mi,0,1)
		
		*from 0 to 1
		gen kdisChange`i'=0 if k`i'lv10mi==0 & inlist(k`j'lv10mi,1)
		replace kdisChange`i'=1 if k`j'lv10mi==0 & inlist(k`i'lv10mi,1)
		
		*from 0 to 1,2; from 1 to 2
		gen kcloChange`i'=0 if k`j'lv10mi==2 & inlist(k`i'lv10mi,0,1)
		replace kcloChange`i'=0 if k`j'lv10mi==1 & inlist(k`i'lv10mi,0)
		replace kcloChange`i'=1 if k`i'lv10mi==1 & inlist(k`j'lv10mi,0)
		replace kcloChange`i'=1 if k`i'lv10mi==2 & inlist(k`j'lv10mi,0,1)
	}
	
	forvalue i=1/12{
		ren k`i'lv10mi klv10mi`i'
		gen kmoveIn`i'=0 if inlist(klv10mi`i',0,1)
		replace kmoveIn`i'=1 if inlist(klv10mi`i',2)
		replace klv10mi`i'=. if klv10mi`i'==2
	}
	
	reshape long kage klocMove kdisMove kmoveInChange kdisChange kcloChange klv10mi kmoveIn, i(kidid) j(wave)
	drop if kage<=25
	save $temp_dir/a1a2_kid_move.dta, replace
end


prog a1b2_select_variable
	keep kidid householdid k*agebg kagenderbg k*mstat k*nkid kaeduc k*incmin k*incmax k*ownhm r*wthh
	drop kp*mstat
	
	forvalue i=1/12{
		foreach x in "agebg" "mstat" "nkid" "incmin" "incmax" "ownhm" {
			capture ren k`i'`x' k`x'`i'
		}
		ren r`i'wthh rwthh`i' 
	}
	
	reshape long kagebg kmstat knkid kincmin kincmax kownhm rwthh, i(kidid) j(wave)
	
	save $temp_dir/a1b2_kid_controls.dta, replace
end


prog a1c1_load_fam_res_file
	u "$a1_family_reslevel_dta", clear
	*keep if hacohort==3
	gen householdid=floor(hhidpn/1000)
end

prog a1c2_define_variables
	keep householdid hhidpn r*mlv10mi s*mlv10mi r*flv10mi s*flv10mi
	foreach x of varlist  r*mlv10mi s*mlv10mi r*flv10mi s*flv10mi{
		replace `x'=. if ~ inlist(`x',0,1)
	}

	forvalue i=1/12{
		foreach p in "r" "s"{
			foreach x in "mlv10mi" "mlv10mi" "flv10mi" "flv10mi"{
				capture ren `p'`i'`x' `p'`x'`i'
			}
		}
	}
	
	forvalue i=2/12{
		foreach p in "rm" "sm" "rf" "sf"{
				local j=`i'-1
				capture gen rdisChange_`p'`i'=0 if `p'lv10mi`i'==0 & `p'lv10mi!`j'==1
				capture replace rdisChange_`p'`i'=1 if `p'lv10mi`i'==1 & `p'lv10mi!`j'==0
		}
	}
	
	reshape long rmlv10mi smlv10mi rflv10mi rdisChange_rm rdisChange_sm rdisChange_rf rdisChange_sf, i(hhidpn) j(wave)
	save $temp_dir/a1c2_res_move.dta, replace
end

prog a1d1_load_fam_res_file

	a1c1_load_fam_res_file
	
	merge 1:1 hhidpn using "$a1_longitudinal_dta", nogen keep(match)
	*keep if hacohort==3
	replace householdid=floor(hhidpn/1000)
end

prog a1d2_select_variables
	keep hhidpn householdid ragender raracem r*wthh rabyear s*byear r*oopmd s*oopmd h*atotnc ///
	h*atotn h*itot h*child
	
	*adjust raracem to be indicator of white
	replace raracem=1 if raracem==2
	
	gen rage=1992-rabyear
	
	forvalue i=1/12{
		gen rage`i'=rage+(`i'-1)*2
	}
	drop rage rabyear	
	
	
	forvalue i=1/12{
		capture ren r`i'wthh rwthh`i'
		capture ren r`i'oopmd roopmd`i' 
		capture ren s`i'oopmd soopmd`i' 
		capture ren h`i'atotnc hatotnc`i' 
		capture ren h`i'atotn hatotn`i' 
		capture ren h`i'itot hitot`i' 
		capture ren h`i'child hchild`i'
		capture gen sage`i'= s`i'byear
	}
	drop s*byear
	reshape long rwthh rage sage roopmd soopmd hatotnc hatotn hitot hchild, i(hhidpn) j(wave)
	
	save $temp_dir/a1b2_res_controls.dta, replace
end

prog a1e2_select_variables
	keep hhidpn r*mpchelp s*mpchelp r*fpchelp s*fpchelp rameduc rafeduc r*mlvlone s*mlvlone r*livsib s*livsib
	
	gen householdid=floor(hhidpn/1000)
	
	forvalue i=1/12{
		foreach x in "r" "s"{
			foreach y in "mpchelp" "fpchelp" "mlvlone" "livsib"{
				capture ren `x'`i'`y' `x'`y'`i'
			}
		}
	}
	reshape long rmpchelp smpchelp rfpchelp sfpchelp rmlvlone smlvlone rlivsib slivsib, i(hhidpn) j(wave)
	
	save $temp_dir/a1e2_par_controls.dta, replace
end





*Examine
	/*
prog ex1a_examine_kidid
	
	* Keep observations with the same kidids and check if they are the same person
	egen idcount=count(hhid), by(kidid)
	keep if idcount==2
	sort kidid
	/*
		People with the same kidid share the same basic information,
		but differ in hhidpn and many other information. 
		
		If having multiple records is the result of household splits, then they
		should differ in hhidpn as well, but they are not
		
		I should check if there is any instance they also differ in hhid
	*/
	tab hasplit
	drop if hasplit==1
	/*
		Most are never split. Why records are differed in hhidpn?
		Each correspondent could discuss differently about the same kid? Yes
		
		Try gsort and then collapse
	*/
end
	*/

*Execute

if "`1'"!="function calling"{
main
}
