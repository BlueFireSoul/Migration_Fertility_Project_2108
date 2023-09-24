********************************************
*a0_latex_output_practice
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
	
	a0_tabout
	

end
}

*Writing
prog a0_tabout
	a0a_create_tables
end

prog a0a_create_tables
a0a1_setup
tabout south race union sex using table1.xlsx, ///
replace c(col) nlab(Sample) f(0c 1) font(bold) style(xlsx) ///
title(Table 1: A Simple Example) ///
fn(Source: nlsw88.dta) open

a0a2_cancer_setup
tabout stime died using table4.xlsx, ///
replace c(freq col cum) style(xlsx) ///
font(italic)  ///
f(0 1) clab(No. Col_% Cum_%) ///
title(Table 4: Example of a simple ///
cross tabulation) fn(Source: cancer.dta) open 
end

*Done
prog a0a2_cancer_setup
sysuse cancer, clear
la var died "Patient died"
la def ny  0 "No" 1 "Yes", modify
la val died ny
recode studytime ///
    (min/10 = 1 "10 or less months") ///
    (11/20 = 2 "11 to 20 months") ///
    (21/30 = 3 "21 to 30 months") ///
    (31/max = 4 "31 or more months") ///
    , gen(stime)
la var stime "To died or exp. end"

la var drug "Drug type"
la def drug 1 "Placebo" 2 "Trial drug 1" ///
    3 "Trial drug 2", modify
la val drug drug
end

prog a0a1_setup
set seed 14921918
sysuse nlsw88, clear

la var union "Member of a union"
la def union 0 "Not a union member" ///
	1 "Union member", modify
la val union union

la var south "Location"
la def south 0 "Does not live in the South" ///
	1 "Lives in the South", modify
la val south south

la var race "Race"
la def race 1 "White" 2 "Black" ///
	3 "Other", modify
la val race race

la var collgrad "Education"
la def collgrad 0 "Not college graduate"  ///
	1 "College graduate", modify
la val collgrad collgrad

la var married "Marital status"
la def married 0 "Single" 1 "Married", modify
la val married married

gen wt = 10 * runiform()
gen int fwt = ceil(wt)

gen inc = 1000 * runiform()
gen income = cond(inc < 300, inc + 360, inc +200)
la var income "Income"

gen sex = cond(wt<5, 1, 2)
la var sex "Sex"
la def sex 1 "Male" 2 "Female", modify
replace sex = cond(wt<0.5, ., sex)
la val sex sex

gen pregnant = cond(wt>8.5, 1, 2)
la var pregnant "Currently pregnant"
la def pregnant 1 "Pregnant" 2 "Not pregnant" ///
	, modify
replace pregnant = cond(sex==1, ., pregnant)
la val pregnant pregnant

la var industry "Industry"
la var occupation "Occupation"


end



*Execute
if "`1'"!="function calling"{
main 

}
