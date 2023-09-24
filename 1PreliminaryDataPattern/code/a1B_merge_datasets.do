********************************************
*a1B_merge_datasets
********************************************
/*  Outline:
	
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
	
	a1Ba_clean_kid_resp_data
	
	a1Bb_clean_resp_data
	
	a1Bc_merge_data_set_robust
end
}

*Writing
prog a1Bc_merge_data_set_robust

	capture confirm file $output_dir/a1Bc1_direct_merge.dta
	if _rc!=0{
	a1Bc1_direct_merge
	}

	capture confirm file $output_dir/a1Bc2_collapse_kid_merge.dta
	if _rc!=0{
	a1Bc2_collapse_kid_merge
	}

	capture confirm file $output_dir/a1Bc3_collapse_res_merge.dta
	if _rc!=0{
	a1Bc3_collapse_res_merge
	}

	capture confirm file $output_dir/a1Bc4_double_collapse_merge.dta
	if _rc!=0{
	a1Bc4_double_collapse_merge
	}
	
end

prog a1Bc4_double_collapse_merge
	u $temp_dir/a1Bb_original_resp_data.dta, clear
	gen householdid=floor(hhidpn/1000)
	a1Bc2a_random_pick "householdid wave"
	save $temp_dir/temp1.dta, replace
	
	u $temp_dir/a1Ba_original_kid_resp_data.dta, clear
	gsort kidid -kapick
	gen first=1
	gen last=1
	order kidid wave first, first
	order last, last
	collapse (firstnm) first-last, by(kidid wave)
	gen householdid=real(substr(kidid,1,6))
	drop first last
	
	merge n:1 householdid wave using $temp_dir/temp1.dta, nogen
	
	a1Bc1a_construct_variables
	
	save $output_dir/a1Bc4_double_collapse_merge.dta, replace
end


prog a1Bc3_collapse_res_merge
	u $temp_dir/a1Bb_original_resp_data.dta, clear
	gen householdid=floor(hhidpn/1000)
	a1Bc2a_random_pick "householdid wave"
	save $temp_dir/temp1.dta, replace

	u $temp_dir/a1Ba_original_kid_resp_data.dta, clear
	gen householdid=real(substr(kidid,1,6))	
	merge n:1 householdid wave using $temp_dir/temp1.dta, nogen
	
	a1Bc1a_construct_variables
	
	save $output_dir/a1Bc3_collapse_res_merge.dta, replace
end

prog a1Bc2_collapse_kid_merge
	u $temp_dir/a1Bb_original_resp_data.dta, clear
	gen householdid=floor(hhidpn/1000)
	a1Bc2a_random_pick "householdid wave ragender"
	preserve
	keep if ragender==1
	save $temp_dir/temp1.dta, replace
	restore
	keep if ragender==2
	save $temp_dir/temp2.dta, replace
	

	u $temp_dir/a1Ba_original_kid_resp_data.dta, clear
	gsort kidid -kapick
	gen first=1
	gen last=1
	order kidid wave first, first
	order last, last
	collapse (firstnm) first-last, by(kidid wave)
	gen householdid=real(substr(kidid,1,6))
	drop first last
	preserve 
	merge n:1 householdid wave using $temp_dir/temp1.dta, nogen
	save $temp_dir/temp3.dta, replace
	restore 
	merge n:1 householdid wave using $temp_dir/temp2.dta, nogen
	append using $temp_dir/temp3.dta
	
	a1Bc1a_construct_variables
	
	save $output_dir/a1Bc2_collapse_kid_merge.dta, replace
end

prog a1Bc2a_random_pick
	local identifier="`1'"
	gen count=0
	foreach x of varlist _all {
		capture replace count=count-1 if !((`x'>-100000000000)&(`x'<100000000000))
	}
	egen maxcount=max(count), by (`identifier')
	keep if maxcount==count
	gen random=runiform()
	egen maxrand=max(random), by (`identifier')
	keep if maxrand==random
	
	drop maxcount count maxrand random
end


prog a1Bc1_direct_merge
	u $temp_dir/a1Ba_original_kid_resp_data.dta, clear
	merge n:1 hhidpn wave using $temp_dir/a1Bb_original_resp_data.dta, nogen
	
	a1Bc1a_construct_variables
	
	save $output_dir/a1Bc1_direct_merge.dta, replace
end

prog a1Bc1a_construct_variables
	replace kwresd=1 if kwresd==2
	gen hwochild=hwchild-1 if kwcontyr==0
	gen hworesdkn=hwresdkn-1 if inlist(hwresdkn,1)
	gen hwoworkftkn=hwworkftkn-1 if kwwork==2
	gen hwoworkptkn=hwworkptkn-1 if kwwork==1
	gen hwolvTmikn=hwlvTmikn-1 if kwlvTmi==1
	gen hwoownhmkn=hwownhmkn-1 if kwownhm==1
	drop if kidid==""
end


*Done
prog a1Ba_clean_kid_resp_data
	capture confirm file  $temp_dir/a1Ba_original_kid_resp_data.dta
	
	if _rc!=0{
	
	a1Ba1_select_variables
	
	a1Ba2_construct_variables

	a1Ba3_reshape_data
	
	save $temp_dir/a1Ba_original_kid_resp_data.dta, replace
	}
end

prog a1Ba2_construct_variables
	foreach x of varlist  k*lv10mi{
		replace `x'=2 if `x'==.l
		replace `x'=. if ~ inlist(`x',0,1,2)
	}
	forvalue i=2/12{
		local j=`i'-1
		
		gen klocMove`i'=0 if k`j'lv10mi!=. & k`i'lv10mi!=.
		replace klocMove`i'=1 if (k`j'lv10mi!=k`i'lv10mi) & klocMove`i'==0
		
		gen kdisMove`i'=0 if k`j'lv10mi!=. & k`i'lv10mi!=.
		replace kdisMove`i'=1 if (k`j'lv10mi==0 & inlist(k`i'lv10mi,1)) & kdisMove`i'==0
		replace kdisMove`i'=1 if (k`i'lv10mi==0 & inlist(k`j'lv10mi,1)) & kdisMove`i'==0
		
		gen kMoveInS`i'=0 if k`j'lv10mi!=. & k`i'lv10mi!=.
		replace kMoveInS`i'=1 if k`i'lv10mi==2 & klocMove`i'==1
		
		gen kMoveOutS`i'=0 if k`j'lv10mi!=. & k`i'lv10mi!=.
		replace kMoveOutS`i'=1 if k`j'lv10mi==2 & klocMove`i'==1
		
		gen kMoveWTS`i'=0 if k`j'lv10mi!=. & k`i'lv10mi!=.
		replace kMoveWTS`i'=1 if k`j'lv10mi==0 & k`i'lv10mi==1 & klocMove`i'==1
		
		gen kMoveOTS`i'=0 if k`j'lv10mi!=. & k`i'lv10mi!=.
		replace kMoveOTS`i'=1 if k`j'lv10mi==1 & k`i'lv10mi==0 & klocMove`i'==1
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
	
	foreach x of varlist  k*lv10mi{
		replace `x'=. if `x'==2
	} 

end

prog a1Bb_clean_resp_data
	capture confirm file  $temp_dir/a1Bb_original_resp_data.dta
	
	if _rc!=0{
	a1Bb1_select_variables
	
	a1Bb2_construct_variables
	
	a1Ba3_reshape_data

	save $temp_dir/a1Bb_original_resp_data.dta, replace
	}
end

prog a1Bb2_construct_variables
	foreach x in "r" "s"{
		foreach y in "m" "f"{
			forvalue i=2/12{
				local j=`i'-1
				gen `x'`y'locChange`i'=0 if `x'`j'`y'lv10mi!=. & `x'`i'`y'lv10mi!=.
				replace `x'`y'locChange`i'=1 if (`x'`j'`y'lv10mi!=`x'`i'`y'lv10mi) & `x'`y'locChange`i'==0
				gen `x'`y'cloChange`i'=0 if `x'`y'locChange`i'==1
				replace `x'`y'cloChange`i'=1 if `x'`i'`y'lv10mi==1 & `x'`y'cloChange`i'==0
		
			}
		}
	}
end


prog a1Ba1_select_variables
	u "$a1_family_kidlevel_dta", clear
	keep hhidpn kidid k*alive kapick k*pick hasplit ///
		kabyearbg kagenderbg k*mstat kaeduc k*nkid ///
		k*resd k*hhfin k*lv10mi ///
		k*contyr ///
		k*incmin k*work ///
		k*ownhm ///
		k*inhp k*helpr k*fcany k*hlpfut ///
		k*hlpadl k*hlpiadl k*hlpfin k*hlpchr k*hltcst ///
		k*hlpdays k*hlphrs k*fcntran k*fcamt ///
		k*kdcare k*tcany k*will ///
		k*tcntran k*tcamt
end

prog a1Ba3_reshape_data
	foreach x of varlist _all {
		local name_last=""
	    if regexm("`x'", "([0-9]+)") {
			local wave = regexs(1) 
			local name = regexr("`x'", "([0-9]+)", "w")
			local name = regexr("`name'", "([0-9]+)", "T")
			ren `x' `name'`wave'
		}
	}
	order _all, sequential
	
	local reshape_list=""
	local name_last=""
	foreach x of varlist _all {
	    if regexm("`x'", "([0-9]+)") {
			local name = regexr("`x'", "([0-9]+)", "")
			if "`name'"!="`name_last'"{
				local reshape_list="`reshape_list'"+" "+"`name'"
			}
			local name_last="`name'"
		}
	}	
	
	di "`reshape_list'"
	gen obs = _n
	reshape long `reshape_list', i(obs) j(wave)
	drop obs

end


prog a1Bb1_select_variables
	u "$a1_longitudinal_dta", clear
	merge 1:1 hhidpn using "$a1_family_reslevel_dta", nogen
	
	keep hhidpn r*wthh hacohort rlink ///
		rabyear s*byear ragender raracem s*racem raedyrs s*edyrs ///
		*shlt *oopmd *hlthlm ///
		h*atotb h*atotn ///
		*iearn h*itot ///
		*sayret *rplnyr ///
		*work *work2 *jhours *jhour2 *wgihr ///
		h*schlkn h*child h*resdkn h*workftkn h*workptkn h*lv10mikn h*ownhmkn ///
		h*fcanykn *inhpkn *hlpfutkn ///
		h*kdcarekn h*tcanykn *willkn ///
		*momliv *dadliv ///
		rameduc rafeduc s*meduc s*feduc ///
		*pchelp *lvlone ///
		*livwho *lv10mi ///
		*contmo *ppcr *perd ///
		*sbl10m *sbfhlp *sbphlp
end

*Execute

if "`1'"!="function calling"{
main
}
