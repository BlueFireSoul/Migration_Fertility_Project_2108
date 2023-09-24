********************************************
*a2B_preliminary_analysis
********************************************
/*  Outline:
*/


set more off

global temp_dir ="../temp"
global output_dir="../output"
global a1Bc1_direct_merge= "$output_dir/a1Bc1_direct_merge.dta"
global a1Bc2_collapse_kid_merge= "$output_dir/a1Bc2_collapse_kid_merge.dta"
global a1Bc3_collapse_res_merge= "$output_dir/a1Bc3_collapse_res_merge.dta"
global a1Bc4_double_collapse_merge= "$output_dir/a1Bc4_double_collapse_merge.dta"


if "`1'"!="function calling"{
prog drop _all
prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/1PreliminaryDataPattern/code"
	
	a2Ba_spatial_analysis "`1'"
	
	a2Bb_transfer_analysis "`1'"
	

end
}

*Writing

prog a2Bb_transfer_analysis

	a2Ba1_load_dataset "`1'"

	a2Bb2_from_kid_analysis
	
	a2Bb3_to_kid_analysis
end

prog a2Bb3_to_kid_analysis
	capture confirm file $output_dir/a2Bb3a_kid_control.txt
	if _rc!=0{
		a2Bb3a_kid_control
	}
	
	capture confirm file $output_dir/a2Bb3b_kid_movement.txt
	if _rc!=0{
		a2Bb3b_kid_movement
	}

	capture confirm file $output_dir/a2Bb3c_res_control.txt
	if _rc!=0{
		a2Bb3c_res_control
	}
end

prog a2Bb3c_res_control
#delimit ;
local dependent_vars "kwkdcare
kwtcany
kwwill
kwtcntran
kwtcamt
";
local independent_vars "rage@sage
";
local control_vars "rwshlt
rwshlt@rwoopmd
rwshlt@rwoopmd@i.raracem@raedyrs@swedyrs
rwshlt@rwoopmd@i.raracem@raedyrs@swedyrs@i.rwsayret
rwshlt@rwoopmd@i.raracem@raedyrs@swedyrs@i.rwsayret@hwatotb@hwatotn@hwitot
";
local ind_control_vars "rwshlt
rwshlt@rwoopmd
rwshlt@rwoopmd@i.rwsayret
rwshlt@rwoopmd@i.rwsayret@hwatotb@hwatotn@hwitot
";
#delimit cr	
	a2Ba2a_regression_tool "`dependent_vars'" "`independent_vars'" "`control_vars'" "`ind_control_vars'" " with Respondent Controls" "a2Bb3c_res_control"


end

prog a2Bb3b_kid_movement
#delimit ;
local dependent_vars "kwkdcare
kwtcany
kwwill
kwtcntran
kwtcamt
";
local independent_vars "kage@kagenderbg@kaeduc@i.kwwork
";
local control_vars "klocMove
kdisMove
kmoveInChange
kdisChange
kcloChange
";
local ind_control_vars "klocMove
kdisMove
kmoveInChange
kdisChange
kcloChange
";
#delimit cr	
	a2Ba2a_regression_tool "`dependent_vars'" "`independent_vars'" "`control_vars'" "`ind_control_vars'" " with Kid Controls" "a2Bb3b_kid_movement"

end

prog a2Bb3a_kid_control
#delimit ;
local dependent_vars "kwkdcare
kwtcany
kwwill
kwtcntran
kwtcamt
";
local independent_vars "kage@kwlvTmi@kwresd
";
local control_vars "kagenderbg 
kagenderbg@kwmstat@kwnkid
kagenderbg@kwmstat@kaeduc@kwownhm@i.kwwork
kagenderbg@kwmstat@kwnkid@kaeduc@kwownhm@i.kwwork
kagenderbg@kwmstat@kwnkid@kaeduc@kwownhm@kwincmin@i.kwwork
";
local ind_control_vars "kwmstat@kwnkid
kwmstat@kwownhm@i.kwwork
kwmstat@kwnkid@kwownhm@i.kwwork
kwmstat@kwnkid@kwownhm@kwincmin@i.kwwork
";
#delimit cr	
	a2Ba2a_regression_tool "`dependent_vars'" "`independent_vars'" "`control_vars'" "`ind_control_vars'" " with Kid Controls" "a2Bb3a_kid_control"


end

prog a2Bb2_from_kid_analysis
	capture confirm file $output_dir/a2Bb2a_kid_control.txt
	if _rc!=0{
		a2Bb2a_kid_control
	}
	
	capture confirm file $output_dir/a2Bb2b_kid_movement.txt
	if _rc!=0{
		a2Bb2b_kid_movement
	}

	capture confirm file $output_dir/a2Bb2c_res_control.txt
	if _rc!=0{
		a2Bb2c_res_control
	}
end

prog a2Bb2c_res_control
#delimit ;
local dependent_vars "kwinhp
kwhelpr
kwfcany
kwhlpfut
kwhlpadl
kwhlpiadl
kwhlpfin
kwhlpchr
kwhltcst
kwhlpdays
kwhlphrs
kwfcntran
kwfcamt
";
local independent_vars "rage@sage
";
local control_vars "rwshlt
rwshlt@rwoopmd
rwshlt@rwoopmd@i.raracem@raedyrs@swedyrs
rwshlt@rwoopmd@i.raracem@raedyrs@swedyrs@i.rwsayret
rwshlt@rwoopmd@i.raracem@raedyrs@swedyrs@i.rwsayret@hwatotb@hwatotn@hwitot
";
local ind_control_vars "rwshlt
rwshlt@rwoopmd
rwshlt@rwoopmd@i.rwsayret
rwshlt@rwoopmd@i.rwsayret@hwatotb@hwatotn@hwitot
";
#delimit cr	
	a2Ba2a_regression_tool "`dependent_vars'" "`independent_vars'" "`control_vars'" "`ind_control_vars'" " with Respondent Controls" "a2Bb2c_res_control"


end

prog a2Bb2b_kid_movement
#delimit ;
local dependent_vars "kwinhp
kwhelpr
kwfcany
kwhlpfut
kwhlpadl
kwhlpiadl
kwhlpfin
kwhlpchr
kwhltcst
kwhlpdays
kwhlphrs
kwfcntran
kwfcamt
";
local independent_vars "kage@kagenderbg@kaeduc@i.kwwork
";
local control_vars "klocMove
kdisMove
kmoveInChange
kdisChange
kcloChange
";
local ind_control_vars "klocMove
kdisMove
kmoveInChange
kdisChange
kcloChange
";
#delimit cr	
	a2Ba2a_regression_tool "`dependent_vars'" "`independent_vars'" "`control_vars'" "`ind_control_vars'" " with Kid Controls" "a2Bb2b_kid_movement"

end

prog a2Bb2a_kid_control
#delimit ;
local dependent_vars "kwinhp
kwhelpr
kwfcany
kwhlpfut
kwhlpadl
kwhlpiadl
kwhlpfin
kwhlpchr
kwhltcst
kwhlpdays
kwhlphrs
kwfcntran
kwfcamt
";
local independent_vars "kage@kwlvTmi@kwresd
";
local control_vars "kagenderbg 
kagenderbg@kwmstat@kwnkid
kagenderbg@kwmstat@kaeduc@kwownhm@i.kwwork
kagenderbg@kwmstat@kwnkid@kaeduc@kwownhm@i.kwwork
kagenderbg@kwmstat@kwnkid@kaeduc@kwownhm@kwincmin@i.kwwork
";
local ind_control_vars "kwmstat@kwnkid
kwmstat@kwownhm@i.kwwork
kwmstat@kwnkid@kwownhm@i.kwwork
kwmstat@kwnkid@kwownhm@kwincmin@i.kwwork
";
#delimit cr	
	a2Ba2a_regression_tool "`dependent_vars'" "`independent_vars'" "`control_vars'" "`ind_control_vars'" " with Kid Controls" "a2Bb2a_kid_control"


end

*Done
prog a2Ba_spatial_analysis

	a2Ba1_load_dataset "`1'"

	a2Ba2_analysis

end


prog a2Ba2_analysis
	capture confirm file $output_dir/a2Ba2a_kid_control.txt
	if _rc!=0{
		a2Ba2a_kid_control
	}
	
	capture confirm file $output_dir/a2Ba2b_res_control.txt
	if _rc!=0{
		a2Ba2b_res_control
	}
	
	capture confirm file $output_dir/a2Ba2c_resKn_control.txt
	if _rc!=0{
		a2Ba2c_resKn_control
	}
	
end


prog a2Ba1_load_dataset
	u "`1'", clear
	gen interview_year=1992+2*(wave-1)
	gen kage=interview_year-kabyearbg
	gen rage=interview_year-rabyear
	gen sage=interview_year-swbyear
	drop if kage<25
	drop if hasplit==1
	keep if rlink==1
	gen num=1
	drop if kidid==""
	
	if "`1'"=="$a1Bc4_double_collapse_merge"{
		egen kididnum=group(kidid)
		xtset kididnum wave
	}

end

prog a2Ba2a_kid_control
#delimit ;
local dependent_vars "kwlvTmi 
kwresd
klocMove 
kdisMove 
kmoveInChange 
kdisChange 
kcloChange
";
local independent_vars "kage
";
local control_vars "kagenderbg 
kagenderbg@kwmstat@kwnkid
kagenderbg@kwmstat@kaeduc@kwownhm@i.kwwork
kagenderbg@kwmstat@kwnkid@kaeduc@kwownhm@i.kwwork
kagenderbg@kwmstat@kwnkid@kaeduc@kwownhm@kwincmin@i.kwwork
";
local ind_control_vars "kwmstat@kwnkid
kwmstat@kwownhm@i.kwwork
kwmstat@kwnkid@kwownhm@i.kwwork
kwmstat@kwnkid@kwownhm@kwincmin@i.kwwork
";
#delimit cr	
	a2Ba2a_regression_tool "`dependent_vars'" "`independent_vars'" "`control_vars'" "`ind_control_vars'" " with Kid Controls" "a2Ba2a_kid_control"
end

prog a2Ba2b_res_control
#delimit ;
local dependent_vars "kwlvTmi 
kwresd
klocMove 
kdisMove 
kmoveInChange 
kdisChange 
kcloChange
";
local independent_vars "rage@sage
";
local control_vars "rwshlt
rwshlt@rwoopmd
rwshlt@rwoopmd@i.raracem@raedyrs@swedyrs
rwshlt@rwoopmd@i.raracem@raedyrs@swedyrs@i.rwsayret
rwshlt@rwoopmd@i.raracem@raedyrs@swedyrs@i.rwsayret@hwatotb@hwatotn@hwitot
";
local ind_control_vars "rwshlt
rwshlt@rwoopmd
rwshlt@rwoopmd@i.rwsayret
rwshlt@rwoopmd@i.rwsayret@hwatotb@hwatotn@hwitot
";
#delimit cr	
	a2Ba2a_regression_tool "`dependent_vars'" "`independent_vars'" "`control_vars'" "`ind_control_vars'" " with Respondent Controls" "a2Ba2b_res_control"

end

prog a2Ba2c_resKn_control
#delimit ;
local dependent_vars "kwlvTmi 
kwresd
klocMove 
kdisMove 
kmoveInChange 
kdisChange 
kcloChange
";
local independent_vars "rage@sage@rwshlt@hwatotn@hwitot
";
local control_vars "hwschlkn
hworesdkn
hwochild
hwoworkftkn
hwoworkptkn
hwolvTmikn
hwoownhmkn
";
local ind_control_vars "hwschlkn
hwochild
hwoworkftkn
hwoworkptkn
hwolvTmikn
hwoownhmkn
";
#delimit cr	
	a2Ba2a_regression_tool "`dependent_vars'" "`independent_vars'" "`control_vars'" "`ind_control_vars'" " with Respondent KN Controls"	"a2Ba2c_resKn_control"
end


prog a2Ba2a_regression_tool
	local dependent_vars="`1'"
	local independent_vars="`2'"
	local control_vars="`3'"
	local ind_control_vars="`4'"
	local regression_note="`5'"
	local log_name="`6'"
	local dep_count: word count `dependent_vars'
	local ind_count: word count `independent_vars'
	local con_count: word count `control_vars'
	local ind_con_count: word count `ind_control_vars'
	
	log using "$output_dir/`log_name'.txt", replace text
	
	forvalue x=1/`dep_count'{	
		local dependent_var : word `x' of `dependent_vars'
		
		forvalue y=1/`ind_count'{
			local independent_var : word `y' of `independent_vars'
			local independent_var = subinstr("`independent_var'", "@", " ",.)
			
			eststo clear
			
			quietly eststo: reg `dependent_var' `independent_var' i.wave
			
			forvalue z=1/`con_count'{
				local control_var : word `z' of `control_vars'
				local control_var = subinstr("`control_var'", "@", " ",.)
				
				quietly eststo: reg `dependent_var' `independent_var' `control_var' i.wave
			}
			esttab, se title("`dependent_var'`regression_note'(yearly fe)") drop(*.wave)
			
			eststo clear
			
			quietly eststo: xtreg `dependent_var' `independent_var' i.wave, fe
			
			forvalue z=1/`ind_con_count'{
				local control_var : word `z' of `ind_control_vars'
				local control_var = subinstr("`control_var'", "@", " ",.)
				
				quietly eststo: xtreg `dependent_var' `independent_var' `control_var' i.wave, fe
			}
			esttab, se title("`dependent_var'`regression_note'(yearly fe; ind fe)") drop(*.wave)
			
		}
	}
	log close
	
end





*Execute
if "`1'"!="function calling"{
main "$a1Bc4_double_collapse_merge"

}
