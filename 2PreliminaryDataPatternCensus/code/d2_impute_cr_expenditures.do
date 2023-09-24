********************************************
*d2_inpute_cr_expenditures
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global ces_dir="../data/CES"
global temp_dir ="../temp"
global output_dir="../output"
global d1b_ces15_19_dta="$output_dir/d1b_ces15_19.dta"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	*d2a_preliminary_check
	
	*d2b_estimate_food
	
	*d2c_estimate_daycare
	
	*d2d_estimate_educ
	
	*d2e_estimate_trans
	
	d2f_estimate_educ_daycare
	
	*manually create d2_cr_price.txt
end

prog d2f_estimate_educ_daycare
	d2a1_initiate_data
	
	keep if age_ref<=60 & age_ref>=30
	keep if age2<=60 & age2>=30	
	drop if childage=="6" & childage=="0"
	
	gen educday=bbydaypq+educapq
	keep if educday!=0
	sort psu
	eststo clear
	quietly by psu:  eststo: reg educday [pweight=finlwt21]
	esttab, se 	
	
	sort group_num
	eststo clear
	quietly by group_num:  eststo: reg educday [pweight=finlwt21]
	esttab, se 	


end

prog d2e_estimate_trans

	d2a1_initiate_data
	
	keep if age_ref<=40 & age_ref>=20
	keep if age2<=40 & age2>=20
	
	drop if childage=="1"
	
	
	sort psu
	eststo clear
	quietly by psu:  eststo: reg transpq withchild [pweight=finlwt21]
	esttab, se 	

	sort group_num
	eststo clear
	quietly by group_num:  eststo: reg transpq withchild [pweight=finlwt21]
	esttab, se 	
end


prog d2d_estimate_educ
	d2a1_initiate_data
	
	keep if age_ref<=60 & age_ref>=30
	keep if age2<=60 & age2>=30	
	keep if inlist(childage,"3","4","5")
	keep if educapq!=0

	sort psu
	eststo clear
	quietly by psu:  eststo: reg educapq [pweight=finlwt21]
	esttab, se 	
	
	sort group_num
	eststo clear
	quietly by group_num:  eststo: reg educapq [pweight=finlwt21]
	esttab, se 	
end

prog d2c_estimate_daycare

	d2a1_initiate_data
	
	keep if age_ref<=60 & age_ref>=20
	keep if age2<=60 & age2>=20
	
	keep if inlist(childage,"1","2")
	keep if bbydaypq!=0
	sum bbydaypq, detail
	
	sort psu
	eststo clear
	quietly by psu:  eststo: reg bbydaypq [pweight=finlwt21]
	esttab, se 	
	
	sort group_num
	eststo clear
	quietly by group_num:  eststo: reg bbydaypq [pweight=finlwt21]
	esttab, se 	
end

prog d2b_estimate_food

	d2a1_initiate_data
	
	keep if age_ref<=60 & age_ref>=20
	keep if age2<=60 & age2>=20
	
	drop if childage=="1"
	
	
	sort psu
	eststo clear
	quietly by psu:  eststo: reg foodpq withchild [pweight=finlwt21]
	esttab, se 	

	sort group_num
	eststo clear
	quietly by group_num:  eststo: reg foodpq withchild [pweight=finlwt21]
	esttab, se 	
end

prog d2a1_initiate_data
	u $d1b_ces15_19_dta, clear
	
	* keep marriage
	keep if marital=="1"
	
	
	drop if childage=="7"
	
	gen withchild=1
	replace withchild=0 if childage=="0"
	
	sort childage
	egen childage_num=group(childage)
	
	gen oldchildstage=0 if childage_num==1
	replace oldchildstage=1 if inlist(childage_num,2)
	replace oldchildstage=2 if inlist(childage_num,3,4)
	replace oldchildstage=3 if inlist(childage_num,5,6)
	replace oldchildstage=4 if inlist(childage_num,7,8) 
	
	sort division
	egen division_num=group(division)
	
	sort popsize
	egen popsize_num=group(popsize)
	
	sort smsastat
	egen smsastat_num=group(smsastat)
	
	replace psu="" if ~(psu=="S12A" | psu=="S49A" | psu== "S23A")
	sort psu
	egen psu_num=group(psu)
	
	gen division_msa=division_num if smsastat_num==1
	replace division_msa=10 if smsastat_num==2
	sort division_msa
	egen group_num=group(division_msa)
	
	replace division_msa=. if psu!=""
	
	replace foodpq=foodpq*food_cpi_de
	replace transpq=transpq*trans_cpi_de
	replace apparpq=apparpq*appa_cpi_de
	replace educapq=educapq*edu_cpi_de
	replace healthpq=healthpq*medi_cpi_de
	
	replace fincbtxm=fincbtxm*total_cpi_de
	
	gen income_bracket=1 if fincbtxm<59200
	replace income_bracket=2 if fincbtxm>=59200 & fincbtxm<=107400
	replace income_bracket=3 if fincbtxm>107400
	
	gen totex=foodpq+transpq+educapq+healthpq+grlfifpq+boyfifpq+chldrnpq+bbydaypq 
end


prog d2a_preliminary_check
	d2a1_initiate_data
	
	*reg rnhtotexq withchild i.division_num i.cpi_year i.cpi_month i.popsize_num i.smsastat_num
	
	eststo clear
	quietly eststo: reg foodpq withchild i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg houspq withchild i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg transpq withchild  i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg apparpq withchild  i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg healthpq withchild  i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg entertpq withchild  i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg perscapq withchild  i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg readpq withchild  i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg tobaccpq withchild  i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg lifinspq withchild  i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg miscpq withchild  i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg cashcopq withchild  i.division_num i.popsize_num i.smsastat_num
	quietly eststo: reg retpenpq withchild  i.division_num i.popsize_num i.smsastat_num
	esttab, se keep(withchild _cons)
end


* Execute
main

