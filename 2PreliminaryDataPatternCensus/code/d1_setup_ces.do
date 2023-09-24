********************************************
*d1_setup_ces
********************************************
/*  Outline:
	
*/
prog drop _all
set more off

global ces_dir="../data/CES"
global temp_dir ="../temp"
global output_dir="../output"
global cpi_csv="../data/categorical_cpi.csv"

prog main
	cd "C:/Users/67311/OneDrive - The Pennsylvania State University/Analysis/2108HouseholdMigration/1Clean/2PreliminaryDataPatternCensus/code"
	
	d1a_load_cpi
	d1b_load_ces_data
end

prog d1a_load_cpi
	import delimited using $cpi_csv, clear
	gen file_year=year-2000
	replace file_year=file_year+1 if quarter==4
	gen file_quarter="1x" if quarter==4
	replace file_quarter="2" if quarter==1
	replace file_quarter="3" if quarter==2
	replace file_quarter="4" if quarter==3
	ren year cpi_year
	ren quarter cpi_quarter
	
	foreach x of varlist *_cpi{
		replace `x'=`x'[20]/`x'
		ren `x' `x'_de
	}
	save $temp_dir/d1a_load_cpi.dta, replace
end

prog d1b_load_ces_data
	u $ces_dir/intrvw15/fmli152.dta, clear
	gen file_year=15
	gen file_quarter="2"
	forvalues i = 15/19{
		foreach x in "1x" "2" "3" "4"{
			if (`i' != 15 | "`x'"!="1x") & (`i' != 15 | "`x'"!="2") {
				append using "$ces_dir/intrvw`i'/fmli`i'`x'.dta", force
				replace file_year=`i' if file_year==.
				replace file_quarter="`x'" if file_quarter==""
			}
		}
	}
	append using $ces_dir/intrvw19/fmli201.dta, force
	replace file_year=20 if file_year==.
	replace file_quarter="1x" if file_quarter==""
	
	keep newid finlwt21 qintrvyr qintrvmo age_ref age2 educ_ref educa2 sex_ref marital childage finatxem fincbtxm inc_rnkm inclass2 region state division psu popsize smsastat file_year file_quarter ///
	 totex4pq foodpq alcbevpq houspq apparpq transpq healthpq entertpq perscapq readpq educapq tobaccpq lifinspq miscpq cashcopq retpenpq grlfifpq boyfifpq chldrnpq bbydaypq 
	 
	order newid finlwt21 qintrvyr qintrvmo age_ref age2 educ_ref educa2 sex_ref marital childage finatxem fincbtxm inc_rnkm inclass2 region state division psu popsize smsastat file_year file_quarter ///
	 totex4pq foodpq alcbevpq houspq apparpq transpq healthpq entertpq perscapq readpq educapq tobaccpq lifinspq miscpq cashcopq retpenpq grlfifpq boyfifpq chldrnpq bbydaypq 
	
	drop if houspq<=0
	drop if totex4pq<=0
	
	merge n:1 file_year file_quarter using $temp_dir/d1a_load_cpi.dta, nogen
	save $output_dir/d1b_ces15_19.dta, replace
end


* Execute
main

