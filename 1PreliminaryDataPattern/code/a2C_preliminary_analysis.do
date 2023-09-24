********************************************
*a2C_preliminary_analysis
********************************************
/*  Outline:
*/


set more off

global temp_dir ="../temp"
global output_dir="../output"
global a1Bc1_direct_merge= "$output_dir/a1Bc1_direct_merge.dta"


if "`1'"!="function calling"{
prog drop _all
prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/1PreliminaryDataPattern/code"
	
	**a2Ca_summarize_transfer_pattern
	
	*a2Cb_export_transfer_pattern
	
	*a2Cc_export_residence_pattern
	
	a2Cd_export_time_variations
	
	*a2Ce_report_sample_size
	
	*a2Cf_report_fertility_pattern
	
	**a2Cg_proximity_regression
end
}

prog a2Cg_proximity_regression
	a2Ca3a_collapse_HH
	egen kwnkid_change=nvals(kwnkid), by(kidid)
	egen kwnkid_min=min(kwnkid), by(kidid)
	egen kkid_max=max(kkid), by(kidid)
	replace kwnkid_change=kwnkid_change-1 
	replace kwnkid_change=1 if kwnkid_change>=1
	
	gen kkid_new=0 if kwnkid_change==1 & kwnkid_min==0
	replace kkid_new=1 if kkid==1 & kwnkid_change==1 & kwnkid_min==0
	
	encode kstage, generate(kstage_num)
	
	gen kkid_ev=0 if kkid==0 & kkid_max==1
	replace kkid_ev=1 if kkid==1 & kkid_max==1
	
	/*
	eststo clear
	quietly eststo: reg kwlvTmi  kkid kwkdcare kskill i.kstage_num  i.wave
	quietly eststo: reg kwlvTmi  kkid kskill i.kstage_num   i.wave
	esttab, se drop(*.wave)
	
	eststo clear
	
	quietly eststo: reg kwlvTmi kkid_new i.raracem kskill i.kstage_num i.kagenderbg i.wave
	quietly eststo: reg kwlvTmi kkid_new i.raracem kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg i.wave
	quietly eststo: reg kwlvTmi kkid_new i.raracem kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg kwmstat kwmstat#kstage_num i.wave
	quietly eststo: reg kwlvTmi kkid_new i.raracem kwkdcare kskill i.kstage_num i.kagenderbg i.wave
	quietly eststo: reg kwlvTmi kkid_new i.raracem kwkdcare kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg i.wave
	quietly eststo: reg kwlvTmi kkid_new i.raracem kwkdcare kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg kwmstat#kstage_num i.wave
	esttab, se drop(*.wave)
	
	esttab using $output_dir/a2Cg_t16.tex, se drop(*.wave) booktabs replace
	
	eststo clear

	quietly eststo: reg kwlvTmi kkid i.raracem kskill i.kstage_num i.kagenderbg i.wave
	quietly eststo: reg kwlvTmi kkid i.raracem kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg i.wave
	quietly eststo: reg kwlvTmi kkid i.raracem kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg kwmstat kwmstat#kstage_num i.wave
	quietly eststo: reg kwlvTmi kkid i.raracem kwkdcare kskill i.kstage_num i.kagenderbg i.wave
	quietly eststo: reg kwlvTmi kkid i.raracem kwkdcare kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg i.wave
	quietly eststo: reg kwlvTmi kkid i.raracem kwkdcare kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg kwmstat#kstage_num i.wave
	esttab, se drop(*.wave)
	
	esttab using $output_dir/a2Cg_t17.tex, se drop(*.wave) booktabs replace
	
	eststo clear
	*/
	
	quietly eststo: ivregress 2sls kwlvTmi i.raracem kskill i.kstage_num i.kagenderbg i.wave (kwkdcare=kkid)
	quietly eststo: ivregress 2sls kwlvTmi i.raracem kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg i.wave (kwkdcare=kkid)
	quietly eststo: ivregress 2sls kwlvTmi i.raracem kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg kwmstat kwmstat#kstage_num i.wave (kwkdcare=kkid)
	quietly eststo: ivregress 2sls kwlvTmi i.raracem kskill i.kstage_num i.kagenderbg i.wave (kwkdcare=kkid_ev)
	quietly eststo: ivregress 2sls kwlvTmi i.raracem kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg i.wave (kwkdcare=kkid_ev)
	quietly eststo: ivregress 2sls kwlvTmi i.raracem kskill i.kwwork kwownhm  i.kstage_num i.kagenderbg kwmstat kwmstat#kstage_num i.wave (kwkdcare=kkid_ev)
	esttab, se drop(*.wave)
	
	esttab using $output_dir/a2Cg_t18.tex, se drop(*.wave) booktabs replace
	
	eststo clear
end


prog a2Ca3a_collapse_HH

	capture confirm file $temp_dir/a2Ca3_check_HH_data_pattern_temp1.dta
	if _rc!=0{
	a2Ca1_load_dataset
	collapse (firstnm) kstage_detail kstage hacohort kstage_r raracem kagenderbg (max) kwwork kwnkid kwmstat kskill kwcontyr rage kwownhm kwlvTmi kwresd kwinhp kwhelpr kwhltcst kwhlpchr kwhlpfut kwfcany kwkdcare kwtcany klocMove kMoveInS kMoveOutS kMoveWTS kMoveOTS (sum) kwfcamt kwtcamt, by(wave kidid)
	drop if rage<50
	drop if kwlvTmi==. & kwresd==.
	xtile kwconqtile = kwcontyr, nq (4)
	xtile kwconqtile2 = kwcontyr, nq (2)
	replace kwfcamt=. if kwfcamt==0
	replace kwtcamt=. if kwtcamt==0
	gen rstage="50-59" if rage<=59
	replace rstage="60-69" if rage>=60 & rage<=69 
	replace rstage="70-79" if rage>=70 & rage<=79
	replace rstage="80+" if rage>79
	
	replace kwmstat = . if kwmstat >1
	gen kkid = 0 if kwnkid!=.
	replace kkid = 1 if kwnkid>0
	
	gen rstage_mi="50-59 a10" if rstage=="50-59" & kwlvTmi==1
	replace rstage_mi="60-69 a10" if rstage=="60-69" & kwlvTmi==1
	replace rstage_mi="70-79 a10" if rstage=="70-79" & kwlvTmi==1
	replace rstage_mi="80+ a10" if rstage=="80+" & kwlvTmi==1
	replace rstage_mi="50-59 o10" if rstage=="50-59" & kwlvTmi==0
	replace rstage_mi="60-69 o10" if rstage=="60-69" & kwlvTmi==0
	replace rstage_mi="70-79 o10" if rstage=="70-79" & kwlvTmi==0
	replace rstage_mi="80+ o10" if rstage=="80+" & kwlvTmi==0	

	
	gen kstage_mi="25-34 a10" if kstage=="25-34" & kwlvTmi==1
	replace kstage_mi="35-44 a10" if kstage=="35-44" & kwlvTmi==1
	replace kstage_mi="45-54 a10" if kstage=="45-54" & kwlvTmi==1
	replace kstage_mi="55+ a10" if kstage=="55+" & kwlvTmi==1
	replace kstage_mi="25-34 o10" if kstage=="25-34" & kwlvTmi==0
	replace kstage_mi="35-44 o10" if kstage=="35-44" & kwlvTmi==0
	replace kstage_mi="45-54 o10" if kstage=="45-54" & kwlvTmi==0
	replace kstage_mi="55+ o10" if kstage=="55+" & kwlvTmi==0	
	
	gen kstage_s="25-34 a" if kstage=="25-34" & kskill==0
	replace kstage_s="35-44 a" if kstage=="35-44" & kskill==0
	replace kstage_s="45-54 a" if kstage=="45-54" & kskill==0
	replace kstage_s="55+ a" if kstage=="55+" & kskill==0
	replace kstage_s="25-34 o" if kstage=="25-34" & kskill==1
	replace kstage_s="35-44 o" if kstage=="35-44" & kskill==1
	replace kstage_s="45-54 o" if kstage=="45-54" & kskill==1
	replace kstage_s="55+ o" if kstage=="55+" & kskill==1
	
	gen kstage_rmi="25-44 a10" if kstage_r=="25-44" & kwlvTmi==1
	replace kstage_rmi="45+ a10" if kstage_r=="45+" & kwlvTmi==1
	replace kstage_rmi="25-44 o10" if kstage_r=="25-44" & kwlvTmi==0
	replace kstage_rmi="45+ o10" if kstage_r=="45+" & kwlvTmi==0	
	
	gen kstage_rs="25-44 a10" if kstage_r=="25-44" & kskill==0
	replace kstage_rs="45+ a10" if kstage_r=="45+" & kskill==0
	replace kstage_rs="25-44 o10" if kstage_r=="25-44" & kskill==1
	replace kstage_rs="45+ o10" if kstage_r=="45+" & kskill==1	
	
	gen anytransfer=kwkdcare+kwtcany+kwhlpchr+kwinhp+kwfcany if kwkdcare!=. & kwtcany!=. & kwhlpchr!=. & kwinhp!=. & kwfcany!=.
	gen anytransfer_k=kwhlpchr+kwinhp+kwfcany if kwhlpchr!=. & kwinhp!=. & kwfcany!=.
	gen anytransfer_p=kwkdcare+kwtcany if kwkdcare!=. & kwtcany!=.
	replace anytransfer=1 if anytransfer>0 & kwkdcare!=. & kwtcany!=. & kwhlpchr!=. & kwinhp!=. & kwfcany!=.
	replace anytransfer_k=1 if anytransfer_k>0 & kwhlpchr!=. & kwinhp!=. & kwfcany!=.
	replace anytransfer_p=1 if anytransfer_p>0 & kwkdcare!=. & kwtcany!=.
	
	gen cfreq="0-51" if kwcontyr<=51
	replace cfreq="52-364" if kwcontyr>=52 & kwcontyr<365
	replace cfreq="365+" if kwcontyr>=365
	*keep if hacohort==3
	save $temp_dir/a2Ca3_check_HH_data_pattern_temp1.dta, replace
	}

	u $temp_dir/a2Ca3_check_HH_data_pattern_temp1.dta, clear

end


prog a2Cf_report_fertility_pattern
	a2Ca3a_collapse_HH

	tabout kwmstat kstage_detail using $output_dir/a2Cf_t14.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)
	
	tabout kkid kstage_detail using $output_dir/a2Cf_t14_2.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)
	
	preserve
	keep if kskill==0 
	tabout kkid kstage_detail using $output_dir/a2Cf_t14_3.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)

	tabout kwmstat kstage_detail using $output_dir/a2Cf_t14_9.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)
	
	save $temp_dir/temp.dta, replace
	keep if kwlvTmi==0
	tabout kkid kstage_detail using $output_dir/a2Cf_t14_4.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)	
	
	u $temp_dir/temp.dta, clear 
	keep if kwlvTmi==1
	tabout kkid kstage_detail using $output_dir/a2Cf_t14_5.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)	
	restore
	preserve
	keep if kskill==1
	tabout kkid kstage_detail using $output_dir/a2Cf_t14_6.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)
	
	tabout kwmstat kstage_detail using $output_dir/a2Cf_t14_10.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)	
	
	save $temp_dir/temp.dta, replace
	keep if kwlvTmi==0
	tabout kkid kstage_detail using $output_dir/a2Cf_t14_7.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)	
	
	u $temp_dir/temp.dta, clear 
	keep if kwlvTmi==1
	tabout kkid kstage_detail using $output_dir/a2Cf_t14_8.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)	
	
	restore
	
	sort kskill kwlvTmi
	by kskill: tab kwmstat kstage_detail, col
	by kskill: tab kkid kstage_detail, col
	*by kskill kwlvTmi: tab kwmstat kstage_detail, col
	by kskill kwlvTmi: tab kkid kstage_detail, col
	
	
end

prog a2Ce_report_sample_size
	a2Ca3a_collapse_HH
	
	drop if kwlvTmi==. & kwresd==.
	
	gen householdid=real(substr(kidid,1,6))
	distinct kidid householdid
	
	* 382781 kid-year
	
	gen num=1
	preserve
	collapse (sum) num, by(wave householdid)
	collapse (count) num, by(householdid)
	tab num
	
	restore
	collapse (sum) num, by(kidid)
	gen observation=-num
	tab observation
	
	tabout observation using $output_dir/a2Ce_t12.txt.txt, /// 
	replace style(tex) font(bold) oneway c(freq col cum) /// 
	f(0c 1) clab(Count Col_% Cum_%) twidth(11) fn(Footnote)
end

prog a2Cd_export_time_variations
	
	a2Cd1_load_data


end

prog a2Cd1_load_data

	
	*a2Cd1a_collapse_kstage
	a2Cd1a_collapse_kstage_r
end

prog a2Cd1a_collapse_kstage_r

	capture confirm file $temp_dir/a2Cd1a_collapse_kstage_r_temp1.dta
	if _rc!=0{
	a2Ca3a_collapse_HH
	egen ckwlvTmi = nvals(kwlvTmi), by(kidid kstage_r)
	collapse (firstnm) ckwlvTmi kwlvTmi kstage_rs (count) lvTcount=kwlvTmi (max) kwnkid kwcontyr kwresd rage kwownhm kwinhp kwhelpr kwhltcst kwhlpchr kwhlpfut kwfcany kwkdcare kwtcany, by(kidid kstage_r)
	gen cfreq="0-51" if kwcontyr<=51
	replace cfreq="52-364" if kwcontyr>=52 & kwcontyr<365
	replace cfreq="365+" if kwcontyr>=365
	
		
	gen kkid = 0 if kwnkid!=.
	replace kkid = 1 if kwnkid>0
	
	gen moverTmi=kwlvTmi
	replace moverTmi=2 if ckwlvTmi==2
	
	gen kstage_rmove="25-44 a" if kstage_r=="25-44" & moverTmi==1
	replace kstage_rmove="45+ a" if kstage_r=="45+" & moverTmi==1
	replace kstage_rmove="25-44 b" if kstage_r=="25-44" & moverTmi==0
	replace kstage_rmove="45+ b" if kstage_r=="45+" & moverTmi==0	
	replace kstage_rmove="25-44 c" if kstage_r=="25-44" & moverTmi==2
	replace kstage_rmove="45+ c" if kstage_r=="45+" & moverTmi==2	
	
	
	gen anytransfer=kwkdcare+kwtcany+kwhlpchr+kwinhp+kwfcany if kwkdcare!=. & kwtcany!=. & kwhlpchr!=. & kwinhp!=. & kwfcany!=.
	gen anytransfer_k=kwhlpchr+kwinhp+kwfcany if kwhlpchr!=. & kwinhp!=. & kwfcany!=.
	gen anytransfer_p=kwkdcare+kwtcany if kwkdcare!=. & kwtcany!=.
	replace anytransfer=1 if anytransfer>0 & kwkdcare!=. & kwtcany!=. & kwhlpchr!=. & kwinhp!=. & kwfcany!=.
	replace anytransfer_k=1 if anytransfer_k>0 & kwhlpchr!=. & kwinhp!=. & kwfcany!=.
	replace anytransfer_p=1 if anytransfer_p>0 & kwkdcare!=. & kwtcany!=.
	save $temp_dir/a2Cd1a_collapse_kstage_r_temp1.dta, replace
	}
	
	u $temp_dir/a2Cd1a_collapse_kstage_r_temp1.dta, clear
	
	tab lvTcount
	tab lvTcount ckwlvTmi
	
	drop if lvTcount<5
	
	tab moverTmi kstage_r
	tab anytransfer
	tab anytransfer cfreq, col
	tab anytransfer kstage_rmove, col

	tabout cfreq kwkdcare kwtcany kwhlpchr kwinhp kwfcany anytransfer_p anytransfer_k anytransfer kstage_rmove using $output_dir/a2Cd1a_t7.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)
	
	preserve
	keep if kstage_r=="25-44"
	tabout cfreq kwkdcare kwtcany kstage_rmove using $output_dir/a2Cd1a_t7_s1.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)
	restore
	
	tabout moverTmi kstage_rs using $output_dir/a2Cd1a_t10.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)
	
	preserve
	keep if kstage_r=="25-44"
	tabout moverTmi kstage_rs using $output_dir/a2Cd1a_t10_s1.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)
	restore
	
	tabout cfreq kwkdcare kwtcany kwhlpchr kwinhp kwfcany anytransfer_p anytransfer_k anytransfer kstage_rs using $output_dir/a2Cd1a_t11.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)
	
	preserve
	keep if kstage_r=="25-44"
	tabout kwkdcare kwtcany kwinhp kwfcany kstage_rs using $output_dir/a2Cd1a_t11_s1.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)
	restore
	
	tabout moverTmi kstage_r using $output_dir/a2Cd1a_t6.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%)  fn(Footnote)
	




	tabout moverTmi kstage_r using $output_dir/a2Cd1a_freqt6.txt, replace /// 
	c(freq) style(tex) font(italic) twidth(14)  /// 
	f(1 1)  fn(Footnote)
	
	tabout cfreq kwkdcare kwtcany kwhlpchr kwinhp kwfcany anytransfer_p anytransfer_k anytransfer kstage_rmove using $output_dir/a2Cd1a_freqt7.txt, replace /// 
	c(freq) style(tex) font(italic) twidth(14)  /// 
	f(1 1)  fn(Footnote)
end

prog a2Cd1a_collapse_kstage
	
	egen ckwlvTmi = nvals(kwlvTmi), by(kidid kstage)
	collapse (firstnm) ckwlvTmi kwlvTmi (count) lvTcount=kwlvTmi, by(kidid kstage)
	tab lvTcount
	tab lvTcount ckwlvTmi
	tab lvTcount kstage

end 

*Writing

prog a2Cc_export_residence_pattern
	a2Ca3a_collapse_HH

	tabout kwresd kwlvTmi klocMove kMoveInS kMoveOutS kMoveWTS kMoveOTS kstage_detail using $output_dir/a2Cc_t5.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity")
	
	preserve
	keep if kskill==0
	tabout kwresd kwlvTmi klocMove kMoveInS kMoveOutS kMoveWTS kMoveOTS kstage_detail using $output_dir/a2Cc_t5_2.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity")	
	restore
	preserve
	keep if kskill==1
	tabout kwresd kwlvTmi klocMove kMoveInS kMoveOutS kMoveWTS kMoveOTS kstage_detail using $output_dir/a2Cc_t5_3.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity")	
	restore	

	preserve
	keep if kstage_r=="25-44"
	tabout kwresd kwlvTmi klocMove kMoveInS kMoveOutS kMoveWTS kMoveOTS kstage_detail using $output_dir/a2Cc_t5_s1.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity")	
	restore
	preserve
	keep if kstage_r=="25-44"
	keep if kskill==0
	tabout kwresd kwlvTmi klocMove kMoveInS kMoveOutS kMoveWTS kMoveOTS kstage_detail using $output_dir/a2Cc_t5_2_s1.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity")	
	restore
	preserve
	keep if kstage_r=="25-44"
	keep if kskill==1
	tabout kwresd kwlvTmi klocMove kMoveInS kMoveOutS kMoveWTS kMoveOTS kstage_detail using $output_dir/a2Cc_t5_3_s1.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity")	
	restore	
	
	tabout kwresd kwlvTmi klocMove kMoveInS kMoveOutS kMoveWTS kMoveOTS kstage_detail using $output_dir/a2Cc_freqt5.txt, replace /// 
	c(freq) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(N) title("Interactions by Kids Age and Proximity")
end

prog a2Cb_export_transfer_pattern

	
	a2Ca2_export_HH_data_pattern

end

prog a2Ca2_export_HH_data_pattern

	a2Ca3a_collapse_HH
	

	tabout cfreq kwkdcare kwtcany kwhlpchr kwinhp kwfcany anytransfer_p anytransfer_k anytransfer kstage_rmi using $output_dir/a2Ca2_t3.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity") fn(Footnote)
	
	preserve
	keep if kstage_r=="25-44"
	tabout kwkdcare kwtcany kstage_rmi using $output_dir/a2Ca2_t3_s1.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity") fn(Footnote)
	restore
	
	
	tabout cfreq kwkdcare kwtcany kwhlpchr kwinhp kwfcany anytransfer_p anytransfer_k anytransfer kstage_s using $output_dir/a2Ca2_t9.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity") fn(Footnote)

	preserve
	keep if kstage_r=="25-44"
	tabout kwkdcare kwtcany kwhlpchr kwinhp kwfcany anytransfer_p anytransfer_k anytransfer kstage_rs using $output_dir/a2Ca2_t9_s1.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity")
	tabstat kwtcamt kwfcamt, by(kstage_rs) statistics(median n)
	
	restore
	
	preserve
	keep if kkid==1
	tabout kwkdcare kstage_detail using $output_dir/a2Ca2_t15.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)
	
	save $temp_dir/temp.dta, replace
	keep if kskill==0
	tabout kwkdcare kstage_detail using $output_dir/a2Ca2_t15_2.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)	
	save $temp_dir/temp2.dta, replace
	
	keep if kwlvTmi==0
	tabout kwkdcare kstage_detail using $output_dir/a2Ca2_t15_3.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)	
	
	u $temp_dir/temp2.dta, clear
	keep if kwlvTmi==1
	tabout kwkdcare kstage_detail using $output_dir/a2Ca2_t15_4.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)		

	u $temp_dir/temp.dta, clear
	keep if kskill==1
	tabout kwkdcare kstage_detail using $output_dir/a2Ca2_t15_5.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)	
	save $temp_dir/temp2.dta, replace
	
	keep if kwlvTmi==0
	tabout kwkdcare kstage_detail using $output_dir/a2Ca2_t15_6.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)	
	
	u $temp_dir/temp2.dta, clear
	keep if kwlvTmi==1
	tabout kwkdcare kstage_detail using $output_dir/a2Ca2_t15_7.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) fn(Footnote)	
	restore
	
	tabout kwresd kwlvTmi kstage_detail using $output_dir/a2Ca2_t8.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity") fn(Footnote)
	preserve
	keep if kskill ==0
	tabout kwresd kwlvTmi kstage_detail using $output_dir/a2Ca2_t8_2.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity") fn(Footnote)
	restore
	preserve
	keep if kskill ==1
	tabout kwresd kwlvTmi kstage_detail using $output_dir/a2Ca2_t8_3.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity") fn(Footnote)
	restore	
	


	
	preserve
	keep if kwlvTmi==1
	tabout cfreq kwkdcare kwtcany kwhlpchr kwinhp kwfcany anytransfer_p anytransfer_k anytransfer kstage_s using $output_dir/a2Ca2_t13.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity") fn(Footnote)	
	restore
	
	tabout kwresd kwlvTmi kstage_detail using $output_dir/a2Ca2_t1.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Kids Age and Proximity") fn(Footnote)

	
	tabout kwresd kwlvTmi rstage using $output_dir/a2Ca2_t2.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Respondents Age and Proximity") fn(Footnote)
	


	tabout cfreq kwkdcare kwtcany kwhlpchr kwinhp kwfcany anytransfer_p anytransfer_k anytransfer rstage_mi using $output_dir/a2Ca2_t4.txt, replace /// 
	c(col) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(Col_%) title("Interactions by Respondents Age and Proximity") fn(Footnote)
	
	tabstat kwtcamt kwfcamt, by(rstage) statistics(median n)
	tabstat kwtcamt kwfcamt, by(kstage) statistics(median n)
	tabstat kwtcamt kwfcamt, by(rstage_mi) statistics(median n)
	tabstat kwtcamt kwfcamt, by(kstage_mi) statistics(median n)
	tabstat kwtcamt kwfcamt, by(kstage_s) statistics(median n)
	
	tabout kwresd kwlvTmi kstage_detail using $output_dir/a2Ca2_freqt1.txt, replace /// 
	c(freq) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(N) title("Interactions by Kids Age and Proximity") fn(Footnote)

	tabout kwresd kwlvTmi rstage using $output_dir/a2Ca2_freqt2.txt, replace /// 
	c(freq) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(N) title("Interactions by Respondents Age and Proximity") fn(Footnote)
	
	tabout cfreq kwkdcare kwtcany kwhlpchr kwinhp kwfcany anytransfer_p anytransfer_k anytransfer kstage_mi using $output_dir/a2Ca2_freqt3.txt, replace /// 
	c(freq) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(N) title("Interactions by Kids Age and Proximity") fn(Footnote)

	tabout cfreq kwkdcare kwtcany kwhlpchr kwinhp kwfcany anytransfer_p anytransfer_k anytransfer rstage_mi using $output_dir/a2Ca2_freqt4.txt, replace /// 
	c(freq) style(tex) font(italic) twidth(14)  /// 
	f(1 1) clab(N) title("Interactions by Respondents Age and Proximity") fn(Footnote)
	
end

prog a2Ca_summarize_transfer_pattern

	*a2Ca1_load_dataset 

	*a2Ca2_check_data_pattern
	
	a2Ca3_check_HH_data_pattern
	
	*a2Ca4_check_collapse_data
end



prog a2Ca3_check_HH_data_pattern

	a2Ca3a_collapse_HH
	
	log using "$output_dir/a2Ca3_check_HH_data_pattern.txt", replace text
	
	
	tab kwlvTmi
	tab kstage kwlvTmi , row
	tab kwresd
	tab kstage kwresd , row
	
	tab kwinhp
	tab kwhlpfut
	
	display("Transfers from Kids")
	tab kwfcany
	tab kwlvTmi kwfcany , row
	tab kwconqtile kwfcany , row
	tab kstage kwfcany , row
	tab kwhlpchr
	tab kwlvTmi kwhlpchr , row
	tab kwconqtile kwhlpchr , row
	tab kstage kwhlpchr , row
	tab kwhltcst
	tab kwlvTmi kwhltcst , row
	tab kwconqtile kwhltcst , row
	tab kstage kwhltcst , row
	
	
	display("Transfers to Kids")
	tab kwkdcare
	tab kwlvTmi kwkdcare , row
	tab kwconqtile kwkdcare , row
	tab kstage kwkdcare , row
	tab kwtcany
	tab kwlvTmi kwtcany , row
	tab kwconqtile kwtcany , row
	tab kstage kwtcany , row

	log close 
end

prog a2Ca2_check_data_pattern
	keep if hacohort==3
	keep if ragender==2
	
	xtile kwconqtile = kwcontyr, nq (4)
	
	tab wave kstage_detail
	tab kwresd kstage_detail
	* Kids are more likely to be resident before 30
	tab kwresd kwlvTmi
	tab kwlvTmi kstage_detail
	* Kids are near when they are before 34

	tab kwlvTmi kwwork 
	* About the same pattern
	tab kwresd kwwork
	* Coresidence more likely to be not working

	tab kwownhm kwlvTmi
	* If own a house, more likely to live close to parents
	tab kwownhm kstage_detail

	tab kwinhp kwfcany
	* about 5 percents of the kids give some transfers
	tab kwinhp kwhlpfut
	tab kwfcany kwhlpfut


	tab kwinhp kstage_detail
	tab kwfcany kstage_detail

	tab kwkdcare kstage_detail
	tab kwtcany kstage_detail

	tab kwtcany kwfcany
	* parents are more likely to give transfers
	tab kwtcany kwkdcare
	tab kwtcany kwwill 
	* one transfer are correlated with another

	tab kwtcany kwlvTmi
	* proximity is correlated with monetary transfers
	tab kwtcany kwhlpfut
	tab kwtcany kwinhp
	* helper kids are less likely to get financial transfers

	tab kwtcany kwwork 

	tab kwtcany kwconqtile
	tab kwfcany kwconqtile
	tab kwlvTmi kwconqtile
	tab kwkdcare kwconqtile
	tab kwinhp kwconqtile
	tab kstage kwconqtile
	* freq of contacts is associated with all transfers, could be a good proxy
	* of the effect of family interactions. Might be an useful variation. But this will
	* be influenced by proximity, and therefore is endogenous. 

	tab kwinhp
	* why only 3 percents are in the helper file?
	* notice only those help with ADL, IADL, and managing money are considered as helper
	tab kwinhp kwhlpchr
	tab kwfcany
	tab kwtcany
	* 15 percents of parents give monetary transfer, compare to 3 percents of children
	tab kwhlpfin
	tab kwkdcare
	tab kwhltcst
	* very small fraction are helping with healthcare cost
	tab kwhlpchr
	* 16 percents are helping chore
	tab kwlvTmi kwhlpchr 
	tab kwlvTmi kwhlpfut 

	tab kwhlpfut kwconqtile
end

prog a2Ca1_load_dataset
	u $a1Bc1_direct_merge, clear
	gen interview_year=1992+2*(wave-1)
	gen kage=interview_year-kabyearbg
	gen rage=interview_year-rabyear
	gen sage=interview_year-swbyear
	drop if kwlvTmi==. & kwresd==.
	drop if kage<25
	drop if hasplit==1
	keep if rlink==1
	drop if kidid==""
	drop if kwalive==0
	gen kstage="25-34" if kage<=34
	replace kstage="35-44" if kage>34 & kage<=44 
	replace kstage="45-54" if kage>44 & kage<=54 
	replace kstage="55+" if kage>54
	
	gen kstage_detail="25-29" if kage<=29
	replace kstage_detail="30-34" if kage>=30 & kage<=34 
	replace kstage_detail="35-39" if kage>=35 & kage<=39 
	replace kstage_detail="40-44" if kage>=40 & kage<=44 
	replace kstage_detail="45-49" if kage>=45 & kage<=49 
	replace kstage_detail="50-54" if kage>=50 & kage<=54 
	replace kstage_detail="55+" if kage>54
	
	gen kstage_r="25-44" if kage>=25 & kage<=44 
	replace kstage_r="45+" if kage>44
	
	gen kskill=0 if kaeduc!=.
	replace kskill=1 if kaeduc>=16
	
end

prog a2Ca4_check_collapse_data
	capture confirm file $temp_dir/a2Ca4_check_collapse_data_temp1.dta
	if _rc!=0{
	u $temp_dir/a2Ca3_check_HH_data_pattern_temp1.dta, clear
	collapse (firstnm) hacohort (max) kwcontyr kwownhm kwlvTmi kwresd kwinhp kwhelpr kwhltcst kwhlpchr kwhlpfut kwfcany kwkdcare kwtcany, by(kidid kstage)
	xtile kwconqtile = kwcontyr, nq (4)
	save $temp_dir/a2Ca4_check_collapse_data_temp1.dta, replace
	}
	log using "$output_dir/a2Ca4_check_collapse_data.txt", replace text
	
	u $temp_dir/a2Ca4_check_collapse_data_temp1.dta, clear

	tab kwlvTmi
	tab kstage kwlvTmi , row
	tab kwresd
	tab kstage kwresd , row
	
	tab kwinhp
	tab kwhlpfut
	
	display("Transfers from Kids")
	tab kwfcany
	tab kwlvTmi kwfcany , row
	tab kwconqtile kwfcany , row
	tab kstage kwfcany , row
	tab kwhlpchr
	tab kwlvTmi kwhlpchr , row
	tab kwconqtile kwhlpchr , row
	tab kstage kwhlpchr , row
	tab kwhltcst
	tab kwlvTmi kwhltcst , row
	tab kwconqtile kwhltcst , row
	tab kstage kwhltcst , row
	
	
	display("Transfers to Kids")
	tab kwkdcare
	tab kwlvTmi kwkdcare , row
	tab kwconqtile kwkdcare , row
	tab kstage kwkdcare , row
	tab kwtcany
	tab kwlvTmi kwtcany , row
	tab kwconqtile kwtcany , row
	tab kstage kwtcany , row
	
	log close
end




*Execute
if "`1'"!="function calling"{
main 

}
