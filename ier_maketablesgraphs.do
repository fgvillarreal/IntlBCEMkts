clear all
set more off

local main_path "C:\Users\rothert\Dropbox\work\research\emrers\data"
local stata_lib "C:\Users\rothert\Dropbox\work\research\computing\library\stata\ado"
*local main_path "C:\Users\R2D2\Dropbox\work\research\emrers\data"
*local stata_lib "C:\Users\R2D2\Dropbox\work\research\computing\library\stata\ado"



* choose the filter
* 1 = hp; 2 = y-to-y diff; 3 = quadratic trend
scalar filtertype = 1

scalar AGsample = 0

if AGsample == 0 {
if filtertype == 1 {	
	qui use $main_path\ier2018_results_hp.dta, clear
}
else if filtertype == 2 {		
	qui use $main_path\ier2018_results_diff.dta, clear
}
else {
	qui use $main_path\ier2018_results_quad.dta, clear
}
}

if AGsample == 1 {
	qui use $main_path\ier2018_results_hp_AG.dta, replace	
	}
	




replace country = "NewZealand" 	    if country == "New Zealand"
replace country = "CzechRepublic" 	if country == "Czech Republic"
replace country = "USA" 			if country == "United States"
replace country = "UnitedKingdom" 	if country == "United Kingdom"
replace country = "CostaRica" 		if country == "Costa Rica"
replace country = "SouthAfrica" 	if country == "South Africa"
replace country = "SlovakRepublic"  if country == "Slovak Republic"

qui gen sc_class = 0
qui replace sc_class = 1 if relsd_con > 1
qui replace sc_class = -1 if ISO == "USA"
drop if ISO == "ROM"
drop if ISO == "BOL"
drop if ISO == "PER"

drop if IMF_class == -1

*replace IMF_class = 1 if country == "Iceland"

by IMF_class, sort: egen IMF_class_count  = count(IMF_class)
by sc_class,  sort: egen sc_class_count   = count(sc_class)


*local varlista = "gdp con nxy rex iratio irate inv gdp_usa con_usa"
local varlista  = "gdp con nxy rex iratio irate inv rely relc rer_usa"


if AGsample == 1 {
local varlista  = "gdp con nxy inv rex"
}

local nvar = 0
foreach var of varlist `varlista'{
local nvar = `nvar' + 1
}
scalar Nvar = `nvar'

sort country
qui levelsof country, local(issos)

gen long obsn = _n
su obsn if country == "Mexico", meanonly
scalar mex_index = r(min)
drop obsn
gen long obsn = _n
su obsn if country == "Canada", meanonly
scalar can_index = r(min)
drop obsn
gen long obsn = _n
su obsn if country == "USA", meanonly
scalar usa_index = r(min)
drop obsn
egen cgroup = group(country)
su cgroup, meanonly
scalar Ncountries = r(max)



sort country
qui gen country_index = _n
qui gen country_order = IMF_class + country_index / 2 / Ncountries





sort country
qui levelsof country, local(issos)

* _________________________ TABLE 1 - summary statistics _________________________ *

matrix TABLE1 = J(20,4,0)
matrix colnames TABLE1 = "Emerging" "Developed" "Mexico" "Canada"
matrix rownames TABLE1 = "sdev(Y)$" ///
						 "sdev(C)/sdev(Y)$" ///
						 "sdev(R)/sdev(Y)$" ///
						 "sdev(I)/sdev(Y)$" ///														
						 "sdev(NX)/sdev(Y)$" ///
						 "sdev(RER)/sdev(Y)$" ///
						 "corr(C,Y)$" ///
						 "corr(I,Y)$" ///
						 "corr(NX,Y)$" ///
						 "corr(R,Y)$" ///
						 "corr(RER,Y)$" ///							
						 "corr(RER,C)$" ///
						 "corr(RER,I)$" ///
						 "corr(RER,NX)$" ///							
						 "corr(RER,R)$" ///
						 "corr(RER_t,RER_{t-1})$" ///
						 "corr(RER,IR)$"  ///
						 "corr(IR,R)$"  ///
						 "corr(IR,Y)$"  ///
						 "corr(IR,NX)$"

local varlista1 = ///
"relsd_gdp relsd_con relsd_irate relsd_inv relsd_nxy relsd_rex xc_gdp_con_5 xc_gdp_inv_5 xc_gdp_nxy_5 xc_gdp_irate_5 xc_gdp_rex_5 xc_con_rex_5 xc_inv_rex_5 xc_nxy_rex_5 xc_irate_rex_5 xc_rex_rex_4 xc_iratio_rex_5 xc_iratio_irate_5 xc_gdp_iratio_5 xc_nxy_iratio_5"



local i = 1

foreach var of varlist `varlista1' {
matrix TABLE1[`i',1] = `var'_mean[mex_index]
matrix TABLE1[`i',2] = `var'_mean[can_index]
matrix TABLE1[`i',3] = `var'[mex_index]
matrix TABLE1[`i',4] = `var'[can_index]
local i = `i'+1
}
* -------------------------------------------------------------------------------- *




local varlista_xc_rex = "gdp con nxy iratio inv irate"
local varlista_xc_gdp = "con nxy iratio inv irate"
local varlista_xc_irate = "con nxy iratio inv"



* pre-define cross-correlation tables - RER
* -------------------------------------------------------------------------------- *
foreach var of varlist `varlista_xc_rex' {


matrix TABLE_`var'_rex = J(Ncountries+4,10,0)
matrix colnames TABLE_`var'_rex = "IMFclass" "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" 
matrix rownames TABLE_`var'_rex = `issos' "Developed" "Emerging" "Normal" "Excess"

matrix TABLE_`var'_rex_se = J(4,10,0)
matrix colnames TABLE_`var'_rex_se = "IMFclass" "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" 
matrix rownames TABLE_`var'_rex_se = "Developed_se" "Emerging_se" "Normal_se" "Excess_se"



foreach num of numlist 1/9 {
by IMF_class, sort: egen se_`var'_rx_`num' = sd(xc_`var'_rex_`num')
matrix TABLE_`var'_rex_se[1,`num'+1] = 2*se_`var'_rx_`num'[can_index] / sqrt(IMF_class_count[can_index])
matrix TABLE_`var'_rex_se[2,`num'+1] = 2*se_`var'_rx_`num'[mex_index] / sqrt(IMF_class_count[mex_index])
qui drop se_`var'_rx_`num' 

by sc_class, sort: egen se_`var'_rx_`num' = sd(xc_`var'_rex_`num')
matrix TABLE_`var'_rex_se[3,`num'+1] = 2*se_`var'_rx_`num'[can_index] / sqrt(sc_class_count[can_index])
matrix TABLE_`var'_rex_se[4,`num'+1] = 2*se_`var'_rx_`num'[mex_index] / sqrt(sc_class_count[mex_index])
qui drop se_`var'_rx_`num' 

by sc_class, sort: egen avg_`var'_rx_`num' = mean(xc_`var'_rex_`num')
matrix TABLE_`var'_rex[Ncountries+3,`num'+1] = avg_`var'_rx_`num'[can_index]
matrix TABLE_`var'_rex[Ncountries+4,`num'+1] = avg_`var'_rx_`num'[mex_index]
qui drop avg_`var'_rx_`num'
}

}
* -------------------------------------------------------------------------------- *


* pre-define cross-correlation tables - GDP
* -------------------------------------------------------------------------------- *
foreach var of varlist `varlista_xc_gdp' {

matrix TABLE_gdp_`var' = J(Ncountries+2,10,0)
matrix colnames TABLE_gdp_`var' = "IMFclass" "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" 
matrix rownames TABLE_gdp_`var' = `issos' "Developed" "Emerging"

matrix TABLE_gdp_`var'_se = J(2,10,0)
matrix colnames TABLE_gdp_`var'_se = "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" 
matrix rownames TABLE_gdp_`var'_se = "Developed_se" "Emerging_se"

foreach num of numlist 1/9 {
by IMF_class, sort: egen se_gdp_`var'_`num' = sd(xc_gdp_`var'_`num')
matrix TABLE_gdp_`var'_se[1,`num'+1] = 2*se_gdp_`var'_`num'[can_index] / sqrt(IMF_class_count[can_index])
matrix TABLE_gdp_`var'_se[2,`num'+1] = 2*se_gdp_`var'_`num'[mex_index] / sqrt(IMF_class_count[mex_index])
qui drop se_gdp_`var'_`num' 
}

}
* -------------------------------------------------------------------------------- *



* pre-define cross-correlation tables - R
* -------------------------------------------------------------------------------- *
foreach var of varlist `varlista_xc_irate' {

matrix TABLE_`var'_irate = J(Ncountries+2,10,0)
matrix colnames TABLE_`var'_irate = "IMFclass" "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" 
matrix rownames TABLE_`var'_irate = `issos' "Developed" "Emerging"

matrix TABLE_`var'_irate_se = J(2,10,0)
matrix colnames TABLE_`var'_irate_se = "t_4" "t_3" "t_2" "t_1" "t" "t1" "t2" "t3" "t4" 
matrix rownames TABLE_`var'_irate_se = "Developed_se" "Emerging_se"

foreach num of numlist 1/9 {
by IMF_class, sort: egen se_`var'_irate_`num' = sd(xc_`var'_irate_`num')
matrix TABLE_`var'_irate_se[1,`num'+1] = 2*se_`var'_irate_`num'[can_index] / sqrt(IMF_class_count[can_index])
matrix TABLE_`var'_irate_se[2,`num'+1] = 2*se_`var'_irate_`num'[mex_index] / sqrt(IMF_class_count[mex_index])
qui drop se_`var'_irate_`num' 
}

}
* -------------------------------------------------------------------------------- *




************************************************************************************************************************
* 												DATA COVERAGE TABLES
************************************************************************************************************************
local varlista_0 = "gdp con inv nxy irate rex"
foreach var of varlist `varlista_0' {
qui gen  t0__`var' = string(t0_`var', "%tq")
qui gen  tT__`var' = string(tT_`var', "%tq")
qui drop t0_`var' 
qui drop tT_`var' 
}

qui replace gdp_used = "IMF"  if gdp_used ~= "y_vol_a_sa"
qui replace gdp_used = "OECD" if gdp_used == "y_vol_a_sa"

qui replace con_used = "IMF"  if con_used ~= "con_oecd"
qui replace con_used = "OECD" if con_used == "con_oecd"

qui replace inv_used = "IMF"  if inv_used ~= "inv_oecd"
qui replace inv_used = "OECD" if inv_used == "inv_oecd"

qui replace nxy_used = "IMF"  if inv_used ~= "nxy_oecd"
qui replace nxy_used = "OECD" if inv_used == "nxy_oecd"

qui replace rex_used = "REER"     if rex_used == "ifs_reer_cpi"
qui replace rex_used = "vs. USA"  if rex_used == "rer_usa"
*

order country gdp_used t0__gdp tT__gdp ///
con_used t0__con tT__con ///
inv_used t0__inv tT__inv ///
nxy_used t0__nxy tT__nxy ///
rex_used t0__rex tT__rex ///
t0__irate tT__irate irates_used 

sort IMF_class country
export excel country-irates_used using $main_path\data_coverage_tables.xlsx if IMF_class == 0, sheet("emerging") sheetmodify firstrow(variables) 
export excel country-irates_used using $main_path\data_coverage_tables.xlsx if IMF_class == 1, sheet("developed") sheetmodify firstrow(variables) 

************************************************************************************************************************
************************************************************************************************************************




* _________________________ TABLE 2 - cross correlations _________________________ *

matrix TABLE2 = J(4,9,0)
matrix colnames TABLE2 = "t-4" "t-3" "t-2" "t-1" "t" "t+1" "t+2" "t+3" "t+4" 
matrix rownames TABLE2 = "Emerging" "Developed" "Mexico" "Canada"

foreach num of numlist 1/9 {

	matrix TABLE2[1,`num'] = xc_gdp_rex_`num'_mean[mex_index]
	matrix TABLE2[2,`num'] = xc_gdp_rex_`num'_mean[can_index]
	matrix TABLE2[3,`num'] = xc_gdp_rex_`num'[mex_index]
	matrix TABLE2[4,`num'] = xc_gdp_rex_`num'[can_index]

	}

* -------------------------------------------------------------------------------- *




* TABLE 3 - standard deviations by country 
matrix TABLE3_sdevs = J(Ncountries+2,Nvar+1,0)

* TABLE 4 - correlations with gdp by country
matrix TABLE4_ycors = J(Ncountries+2,Nvar+1,0)

* TABLE 5 - correlations with REX by country
matrix TABLE5_rxcors = J(Ncountries+2,Nvar+1,0)

* TABLE 8 - correlations with R by country
matrix TABLE8_Rcors = J(Ncountries+2,Nvar+1,0)

* TABLE 9 - cross-correlations R-IR by country
matrix TABLE9_Rir_xcor = J(Ncountries+2,9+1,0)

* TABLE 10 - cross-correlations GDP-R by country
matrix TABLE10_y_irate_xcor = J(Ncountries+2,9+1,0)


* TABLE 13 - cross-correlations GDP-IR by country
matrix TABLE13_y_iratio_xcor = J(Ncountries+2,9+1,0)




sort country
qui levelsof country, local(issos)

local i = 1
foreach isso of local issos  {

	matrix TABLE3_sdevs[`i',1] 			= country_order[`i']

	
	
* pre-define cross-correlation tables
* -------------------------------------------------------------------------------- *
foreach var of varlist `varlista_xc_rex' {
matrix TABLE_`var'_rex[`i',1]  = country_order[`i']
}

foreach var of varlist `varlista_xc_gdp' {
matrix TABLE_gdp_`var'[`i',1]  = country_order[`i']
}

foreach var of varlist `varlista_xc_irate' {
matrix TABLE_`var'_irate[`i',1]  = country_order[`i']
}


* -------------------------------------------------------------------------------- *	
	
	
	
	
	
	* _____________ TABLE 3 - standard deviations ____________________ *
	
	local nvar = 1
	foreach var of varlist `varlista' {
		matrix TABLE3_sdevs[`i',`nvar'+1] = relsd_`var'[`i']		
		matrix TABLE3_sdevs[Ncountries+1,`nvar'+1] = relsd_`var'_mean[can_index]		
		matrix TABLE3_sdevs[Ncountries+2,`nvar'+1] = relsd_`var'_mean[mex_index]		
		local nvar = `nvar' + 1
	}
	
	* --------------------------------------------------------------- *
	

	
	
	* ______________ cross-correlations _____________________ *
	
	foreach num of numlist 1/9 {
	
	
		* RER
		* -------------------------------------------------------------------------------- *
		foreach var of varlist `varlista_xc_rex' {
		matrix TABLE_`var'_rex[`i',`num'+1]  			= xc_`var'_rex_`num'[`i']
		matrix TABLE_`var'_rex[Ncountries+1,`num'+1] 	= xc_`var'_rex_`num'_mean[can_index]		
		matrix TABLE_`var'_rex[Ncountries+2,`num'+1] 	= xc_`var'_rex_`num'_mean[mex_index]						
		}		
		* -------------------------------------------------------------------------------- *		

		* GDP
		* -------------------------------------------------------------------------------- *
		foreach var of varlist `varlista_xc_gdp' {
		matrix TABLE_gdp_`var'[`i',`num'+1]  			= xc_gdp_`var'_`num'[`i']
		matrix TABLE_gdp_`var'[Ncountries+1,`num'+1] 	= xc_gdp_`var'_`num'_mean[can_index]		
		matrix TABLE_gdp_`var'[Ncountries+2,`num'+1] 	= xc_gdp_`var'_`num'_mean[mex_index]						
		}		
		* -------------------------------------------------------------------------------- *		
		
		* R
		* -------------------------------------------------------------------------------- *
		foreach var of varlist `varlista_xc_irate' {
		matrix TABLE_`var'_irate[`i',`num'+1]  			= xc_`var'_irate_`num'[`i']
		matrix TABLE_`var'_irate[Ncountries+1,`num'+1] 	= xc_`var'_irate_`num'_mean[can_index]		
		matrix TABLE_`var'_irate[Ncountries+2,`num'+1] 	= xc_`var'_irate_`num'_mean[mex_index]						
		}		
		* -------------------------------------------------------------------------------- *		
		
		
	}
	
	* --------------------------------------------------------------- *			
	
	
	
local i = `i'+1
}


matrix TABLE3_sdevs[Ncountries+1,1] 		= IMF_class[can_index]+0.5
matrix TABLE3_sdevs[Ncountries+2,1] 		= IMF_class[mex_index]+0.5


* RER
* -------------------------------------------------------------------------------- *
foreach var of varlist `varlista_xc_rex' {
matrix TABLE_`var'_rex[Ncountries+1,1]  = IMF_class[can_index]+0.5
matrix TABLE_`var'_rex[Ncountries+2,1]  = IMF_class[mex_index]+0.5
}
* -------------------------------------------------------------------------------- *	
	

* RER
* -------------------------------------------------------------------------------- *
foreach var of varlist `varlista_xc_gdp' {
matrix TABLE_gdp_`var'[Ncountries+1,1]  = IMF_class[can_index]+0.5
matrix TABLE_gdp_`var'[Ncountries+2,1]  = IMF_class[mex_index]+0.5
}
* -------------------------------------------------------------------------------- *	


* R
* -------------------------------------------------------------------------------- *
foreach var of varlist `varlista_xc_irate' {
matrix TABLE_`var'_irate[Ncountries+1,1]  = IMF_class[can_index]+0.5
matrix TABLE_`var'_irate[Ncountries+2,1]  = IMF_class[mex_index]+0.5
}
* -------------------------------------------------------------------------------- *	

	
	


matrix rownames TABLE3_sdevs = `issos' Developed Emerging
matrix colnames TABLE3_sdevs = group `varlista' 



*cd "C:\Users\rothert\Dropbox\work\research\computing\library\stata\ado"
cd `stata_lib'


* sort matrices
* -------------------------------------------------------------------------------- *	
matsort TABLE3_sdevs 1 "up"

foreach var of varlist `varlista_xc_rex' {
matsort TABLE_`var'_rex  1 "up"
matrix TABLE_`var'_rex = TABLE_`var'_rex \ TABLE_`var'_rex_se
}

foreach var of varlist `varlista_xc_gdp' {
matsort TABLE_gdp_`var'  1 "up"
matrix TABLE_gdp_`var' = TABLE_gdp_`var' \ TABLE_gdp_`var'_se
}

foreach var of varlist `varlista_xc_irate' {
matsort TABLE_`var'_irate  1 "up"
matrix TABLE_`var'_irate = TABLE_`var'_irate \ TABLE_`var'_irate_se
}
* -------------------------------------------------------------------------------- *	
	


cd `main_path'

*
if AGsample == 0 {
if filtertype == 1 {	
	putexcel set data_results_hp.xlsx, modify
}
else if filtertype == 2 {		
	putexcel set data_results_diff.xlsx, modify
}
else {
	putexcel set data_results_quad.xlsx, modify
}
}

if AGsample == 1 {
putexcel set data_results_hp_AG.xlsx, modify
}

*



putexcel B5 = matrix(TABLE1, names), sheet(summary_table)
qui sleep 1000
putexcel B5 = matrix(TABLE2, names), sheet(xc_y_rx_avg, replace)
qui sleep 1000
putexcel B5 = matrix(TABLE3_sdevs, names), sheet(sdevs, replace)
qui sleep 1000

foreach var of varlist `varlista_xc_rex' {
putexcel A1 = matrix(TABLE_`var'_rex, names), sheet(xc_`var'_rex, replace)
qui sleep 1000
}
foreach var of varlist `varlista_xc_gdp' {
putexcel A1 = matrix(TABLE_gdp_`var', names), sheet(xc_gdp_`var', replace)
qui sleep 1000
}
foreach var of varlist `varlista_xc_irate' {
putexcel A1 = matrix(TABLE_`var'_irate, names), sheet(xc_`var'_irate, replace)
qui sleep 1000
}
* -------------------------------------------------------------------------------- *	


cd `main_path'
cd ..
cd computing\excel

sort ISO

gen long obsn = _n
su obsn if country == "USA", meanonly
scalar usa_index = r(min)
drop obsn

qui levelsof ISO, local(issos)
matrix estimation_targets = J(73,Ncountries,0)
matrix colnames estimation_targets = `issos'

matrix rownames estimation_targets = 	 "mean_ir1" ///					1
										 "mean_d1_over_y1" ///			2
										 "y_vs_yusa" ///				3
										 "NN" ///						4
										 "Gama" ///						5
										 "NGama" ///					6
										 "teta" ///						7										 
										 "sdevs y1" ///					8
										 "sdevs c1" ///					9
										 "sdevs x1" ///					10
										 "sdevs nxy1" ///				11
										 "sdevs rmex"  ///				12	
										 "sdevs rx"  ///				13
										 "sdevs ir1" ///				14										 										 
										 "corel y1,y1(-1)"  ///			15
										 "corel y1,c1" ///				16
										 "corel y1,nxy1" ///			17
										 "corel y1,rmex(-1)"  ///		18
										 "corel y1,rmex"  ///			19
										 "corel y1,rmex(+1)" ///		20
										 "corel y1,ir1(-1)" ///			21
										 "corel y1,ir1" ///				22
										 "corel y1,ir1(+1)" ///			23
										 "corel y1,rx(-1)"  ///			24
										 "corel y1,rx"  ///				25
										 "corel y1,rx(+1)" ///			26										 
										 "corel nxy1,rx(-1)"  ///		27
										 "corel nxy1,rx"  ///			28
										 "corel nxy1,rx(+1)" ///		29
										 "corel rx,ir1(-1)" ///			30
										 "corel rx,ir1" ///				31
										 "corel rx,ir1(+1)" ///			32
										 "corel rx,rmex(-1)" ///		33
										 "corel rx,rmex" ///			34
										 "corel rx,rmex(+1)" ///		35
										 "corel c1,c1(-1)" ///			36
										 "corel x1,x1(-1)" ///			37
										 "corel nxy1,nxy1(-1)" ///		38
										 "corel rmex,rmex(-1)" ///		39
										 "corel rx,rx(-1)" ///			40										 										 										 										
										 "corel y1,y2" ///				41
										 "corel c1,c2" ///				42
										 "corel c2c1,rx"	///			43
										 "sdevs y2" ///					44 /* country 2 moments */
										 "sdevs c2" ///					45
										 "sdevs x2" ///					46
										 "sdevs rusa"  ///				47	
										 "sdevs ir2" ///				48										 
										 "corel y2,y2(-1)"  ///			49
										 "corel y2,c2" ///				50
										 "corel y2,nxy2" ///			51
										 "corel y2,rusa(-1)"  ///		52
										 "corel y2,rusa"  ///			53
										 "corel y2,rusa(+1)" ///		54
										 "corel y2,ir2(-1)" ///			55
										 "corel y2,ir2" ///				56
										 "corel y2,ir2(+1)" ///			57
										 "corel c2,c2(-1)" ///			58										 "corel x2,x2(-1)" ///			37
										 "corel nxy2,nxy2(-1)" ///		59
										 "corel rusa,rusa(-1)" ///		60
										 "corel c1,rx(-1)"  ///			24
										 "corel c1,rx"  ///				25
										 "corel c1,rx(+1)" ///			26										 
										 "corel x1,rx(-1)"  ///			24
										 "corel x1,rx"  ///				25
										 "corel x1,rx(+1)"  ///				25										 
										 "corel y1,c1(-1)"  ///			24
										 "corel y1,c1(+1)" ///			26										 
										 "corel y1,nxy1(-1)"  ///			24
										 "corel y1,nxy1(+1)" ///			26												 "corel x1,rx(+1)" ///			26													 
										 "corel y1,x1(-1)"  ///			24
										 "corel y1,x1"  ///				25
										 "corel y1,x1(+1)" ///			26												 "corel x1,rx(+1)" ///			26													 
										 
										 
										 
										 
local i = 1
foreach isso of local issos  {
									 
matrix estimation_targets[1,`i']  = iratio[`i']					/* steady-states */	
matrix estimation_targets[2,`i']  = debt_gdp[`i']
matrix estimation_targets[3,`i']  = y_vs_usa[`i']
matrix estimation_targets[4,`i']  = NN[`i']
matrix estimation_targets[5,`i']  = Gama[`i']
matrix estimation_targets[6,`i']  = NGama[`i']
*matrix estimation_targets[7,`i']  = teta[`i']
matrix estimation_targets[8,`i']  = relsd_gdp[`i']				/* standard deviations */
matrix estimation_targets[9,`i']  = relsd_con[`i']
matrix estimation_targets[10,`i'] = relsd_inv[`i']
matrix estimation_targets[11,`i'] = relsd_nxy[`i']
matrix estimation_targets[12,`i'] = relsd_irate[`i']
matrix estimation_targets[13,`i'] = relsd_rex[`i']
matrix estimation_targets[14,`i'] = relsd_iratio[`i']
matrix estimation_targets[15,`i'] = xc_gdp_gdp_4[`i']			/* gdp autocorrelations */
matrix estimation_targets[16,`i'] = xc_gdp_con_5[`i']			/* gdp with cons and trade balance */
matrix estimation_targets[17,`i'] = xc_gdp_nxy_5[`i']
matrix estimation_targets[18,`i'] = xc_gdp_irate_4[`i']			/* gdp with interest rate */
matrix estimation_targets[19,`i'] = xc_gdp_irate_5[`i']
matrix estimation_targets[20,`i'] = xc_gdp_irate_6[`i']
matrix estimation_targets[21,`i'] = xc_gdp_iratio_4[`i']		/* gdp with import ratio */
matrix estimation_targets[22,`i'] = xc_gdp_iratio_5[`i']
matrix estimation_targets[23,`i'] = xc_gdp_iratio_6[`i']
matrix estimation_targets[24,`i'] = xc_gdp_rex_4[`i']			/* gdp with rex */
matrix estimation_targets[25,`i'] = xc_gdp_rex_5[`i']
matrix estimation_targets[26,`i'] = xc_gdp_rex_6[`i']
matrix estimation_targets[27,`i'] = xc_nxy_rex_4[`i']			/* nxy with rex */
matrix estimation_targets[28,`i'] = xc_nxy_rex_5[`i']
matrix estimation_targets[29,`i'] = xc_nxy_rex_6[`i']
matrix estimation_targets[30,`i'] = xc_iratio_rex_6[`i']		/* rex with import ratio */
matrix estimation_targets[31,`i'] = xc_iratio_rex_5[`i']
matrix estimation_targets[32,`i'] = xc_iratio_rex_4[`i']
matrix estimation_targets[33,`i'] = xc_irate_rex_6[`i']			/* rex with interest rate */
matrix estimation_targets[34,`i'] = xc_irate_rex_5[`i']
matrix estimation_targets[35,`i'] = xc_irate_rex_6[`i']
matrix estimation_targets[36,`i'] = xc_con_con_4[`i']			/* auto-corelations */
matrix estimation_targets[37,`i'] = xc_inv_inv_4[`i']	
matrix estimation_targets[38,`i'] = xc_nxy_nxy_4[`i']	
matrix estimation_targets[39,`i'] = xc_irate_irate_4[`i']										 
matrix estimation_targets[40,`i'] = xc_rex_rex_4[`i']										 
*matrix estimation_targets[41,`i'] = xc_gdp_gdp_usa_5[`i']		/* cross-country correlations */
*matrix estimation_targets[42,`i'] = xc_con_con_usa_5[`i']										
*matrix estimation_targets[43,`i'] = xc_relc_rer_usa_5[`i']		/* backus-smith correlation */
matrix estimation_targets[44,`i'] = relsd_gdp[usa_index]
matrix estimation_targets[45,`i'] = relsd_con[usa_index]
matrix estimation_targets[46,`i'] = relsd_inv[usa_index]
matrix estimation_targets[47,`i'] = relsd_irate[usa_index]
matrix estimation_targets[48,`i'] = relsd_iratio[usa_index]
matrix estimation_targets[49,`i'] = xc_gdp_gdp_4[usa_index]
matrix estimation_targets[50,`i'] = xc_gdp_con_5[usa_index]
matrix estimation_targets[51,`i'] = xc_gdp_nxy_5[usa_index]
matrix estimation_targets[52,`i'] = xc_gdp_irate_4[usa_index]
matrix estimation_targets[53,`i'] = xc_gdp_irate_5[usa_index]
matrix estimation_targets[54,`i'] = xc_gdp_irate_6[usa_index]
matrix estimation_targets[55,`i'] = xc_gdp_iratio_4[usa_index]
matrix estimation_targets[56,`i'] = xc_gdp_iratio_5[usa_index]
matrix estimation_targets[57,`i'] = xc_gdp_iratio_6[usa_index]
matrix estimation_targets[58,`i'] = xc_con_con_4[usa_index]
matrix estimation_targets[59,`i'] = xc_nxy_nxy_4[usa_index]
matrix estimation_targets[60,`i'] = xc_irate_irate_4[usa_index]
matrix estimation_targets[61,`i'] = xc_con_rex_4[`i']			/* con with rex */
matrix estimation_targets[62,`i'] = xc_con_rex_5[`i']
matrix estimation_targets[63,`i'] = xc_con_rex_6[`i']
matrix estimation_targets[64,`i'] = xc_inv_rex_4[`i']
matrix estimation_targets[65,`i'] = xc_inv_rex_5[`i']
matrix estimation_targets[66,`i'] = xc_inv_rex_6[`i']
matrix estimation_targets[67,`i'] = xc_gdp_con_4[`i']
matrix estimation_targets[68,`i'] = xc_gdp_con_6[`i']
matrix estimation_targets[69,`i'] = xc_gdp_nxy_4[`i']
matrix estimation_targets[70,`i'] = xc_gdp_nxy_6[`i']
matrix estimation_targets[71,`i'] = xc_gdp_inv_4[`i']
matrix estimation_targets[72,`i'] = xc_gdp_inv_5[`i']
matrix estimation_targets[73,`i'] = xc_gdp_inv_6[`i']

									 
									 
									 
										 local i = `i'+1
										 
										 }
* ----------------------------------------------------------------------------------------------------------------- *




* ----------------------------------------------------------------------------------------------------------------- *
if filtertype == 1 {	
putexcel A1 = matrix(estimation_targets, names) using ier_data.xlsx, sheet(data_moments_hp, replace) keepcellformat modify
qui sleep 1000
}
else if filtertype == 2 {		
putexcel A1 = matrix(estimation_targets, names) using ier_data.xlsx, sheet(data_moments_diff, replace) keepcellformat modify
qui sleep 1000
}
else {
putexcel A1 = matrix(estimation_targets, names) using ier_data.xlsx, sheet(data_moments_quad, replace) keepcellformat modify
qui sleep 1000
}
* ----------------------------------------------------------------------------------------------------------------- *




keep if ( IMF_class == 0 | IMF_class == 1 )

cd `main_path'
cd graphs

if filtertype == 1 {	
cd hp
}
else if filtertype == 2 {		
cd diff
}
else {
cd quad
}
*




* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* 											S C A T T E R P L O T S
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

qui gen sdev_rex     = relsd_rex*relsd_gdp
qui gen sdev_rer_usa = relsd_rer_usa*relsd_gdp
qui gen sdev_con     = relsd_con*relsd_gdp
qui gen sdev_irate   = log(relsd_irate * relsd_gdp)

qui gen yy = .
qui gen xx = .
qui gen xx2 = .



* ___________________ scatter: rho(rx,gdp) vs. rho(gdp,R[t-1]) _____________________________
qui replace yy = xc_gdp_irate_5 
qui replace xx = xc_gdp_rex_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter yy xc_gdp_rex_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(12) ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter yy xc_gdp_rex_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(12)) ///
(scatter yy xc_gdp_rex_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(12) mlabsize(large) )  /// 
(scatter yy xc_gdp_rex_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(12) mlabsize(large))  ///
(lfit    yy xc_gdp_rex_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( Y, R )) xtitle(corr( Y, RER )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(corr(Y,R) vs. corr(Y,RER))
graph save corr_y_R_vs_y_rx.gph, replace
graph export corr_y_R_vs_y_rx.pdf, as(pdf) replace
graph export corr_y_R_vs_y_rx.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------


* ___________________ scatter: sdev(rx) vs. rho(gdp,R[t-1]) _____________________________
qui replace yy = xc_gdp_irate_5 
qui replace xx = sdev_rex 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter yy sdev_rex if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(12) ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter yy sdev_rex if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(12)) ///
(scatter yy sdev_rex if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(12) mlabsize(large))  /// 
(scatter yy sdev_rex if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(12) mlabsize(large))  ///
(lfit    yy sdev_rex, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( Y, R )) xtitle(sdev( RER )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(corr(Y,R) vs. sdev(RER))
graph save corr_y_R_vs_sdev_rx.gph, replace
graph export corr_y_R_vs_sdev_rx.pdf, as(pdf) replace
graph export corr_y_R_vs_sdev_rx.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------



* scatter: rho(rx,gdp) vs. rho(gdp,R) - vs USA _____________________________
qui replace yy = xc_gdp_irate_5 
qui replace xx = xc_gdp_rer_usa_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter yy xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(12) ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter yy xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(12)) ///
(scatter yy xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(12) mlabsize(large))  /// 
(scatter yy xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(12) mlabsize(large))  ///
(lfit    yy xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( Y, R )) xtitle(corr( Y, RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(corr(Y,R) vs. corr(Y,RER vs USA))
graph save corr_y_R_vs_y_rx_vsUSA.gph, replace
graph export corr_y_R_vs_y_rx_vsUSA.pdf, as(pdf) replace
graph export corr_y_R_vs_y_rx_vsUSA.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------



* scatter: sdev(rx,gdp) vs. rho(gdp,R) - vs USA _____________________________
qui replace yy = xc_gdp_irate_5 
qui replace xx = sdev_rer_usa 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter yy xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(12) ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter yy xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(12)) ///
(scatter yy xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(12) mlabsize(large))  /// 
(scatter yy xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(12) mlabsize(large))  ///
(lfit    yy xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( Y, R )) xtitle(sdev( RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(corr(Y,R) vs. sdev(Y,RER vs USA))
graph save corr_y_R_vs_sdev_rx_vsUSA.gph, replace
graph export corr_y_R_vs_sdev_rx_vsUSA.pdf, as(pdf) replace
graph export corr_y_R_vs_sdev_rx_vsUSA.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------






* ___________________ scatter: rho(rx,gdp) vs. sig(c)/sig(y) _____________________________
qui replace yy = relsd_con 
qui replace xx = xc_gdp_rex_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter relsd_con xc_gdp_rex_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter relsd_con xc_gdp_rex_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter relsd_con xc_gdp_rex_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter relsd_con xc_gdp_rex_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    relsd_con xc_gdp_rex_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(sdev(C) / sdev(Y)) xtitle(corr( Y, RER )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(sdev(C) / sdev(Y) vs. corr(Y,RER))
graph save relsd_con_vs_y_rx.gph, replace
graph export relsd_con_vs_y_rx.pdf, as(pdf) replace
graph export relsd_con_vs_y_rx.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------




* ___________________ scatter: sig(rx) vs. sig(c)/sig(y) _____________________________
qui replace yy = relsd_con 
qui replace xx = sdev_rex 
qui replace xx2 = xx^2
qui reg yy xx 
local r2: display %5.4f e(r2)
twoway ///
(scatter relsd_con sdev_rex if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter relsd_con sdev_rex if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter relsd_con sdev_rex if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter relsd_con sdev_rex if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(qfit    relsd_con sdev_rex, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(sdev(C) / sdev(Y)) xtitle( sdev(RER) ) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(sdev(C) / sdev(Y) vs. sdev(RER))
graph save relsd_con_vs_sdev_rx.gph, replace
graph export relsd_con_vs_sdev_rx.pdf, as(pdf) replace
graph export relsd_con_vs_sdev_rx.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------





* ___________________ scatter: sig(rx) vs. sig(c) _____________________________
qui replace yy = sdev_con 
qui replace xx = sdev_rex 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter sdev_con xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter sdev_con xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter sdev_con xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter sdev_con xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    sdev_con xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(sdev(C)) xtitle(sdev(RER) ) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(sdev(C) vs. sdev(RER))
graph save sdev_con_vs_sdev_rx.gph, replace
graph export sdev_con_vs_sdev_rx.pdf, as(pdf) replace
graph export sdev_con_vs_sdev_rx.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------




* scatter: rho(rx,gdp) vs. sig(c)/sig(y) - vs USA_____________________________
qui replace yy = relsd_con 
qui replace xx = xc_gdp_rer_usa_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter yy xc_gdp_rer_usa_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter yy xc_gdp_rer_usa_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter yy xc_gdp_rer_usa_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter yy xc_gdp_rer_usa_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    yy xc_gdp_rer_usa_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(sdev(C) / sdev(Y)) xtitle(corr( Y, RER )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(sdev(C) / sdev(Y) vs. corr(Y,RER vs USA))
graph save relsd_con_vs_y_rx_vsUSA.gph, replace
graph export relsd_con_vs_y_rx_vsUSA.pdf, as(pdf) replace
graph export relsd_con_vs_y_rx_vsUSA.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------





* ___________________ scatter: sig(rx) vs. sig(c) _____________________________
qui replace yy = sdev_con 
qui replace xx = sdev_rer_usa 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter sdev_con xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter sdev_con xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter sdev_con xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter sdev_con xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    sdev_con xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(sdev(C)) xtitle(sdev( RER vs. USA ) ) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(sdev(C) vs. sdev(RER vs USA))
graph save sdev_con_vs_sdev_rx_vsUSA.gph, replace
graph export sdev_con_vs_sdev_rx_vsUSA.pdf, as(pdf) replace
graph export sdev_con_vs_sdev_rx_vsUSA.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------






* _____________________________________________ scatter: rho(rx,gdp) vs. rho(nx,y) _____________________________________
qui replace yy = xc_gdp_nxy_5 
qui replace xx = xc_gdp_rex_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_gdp_nxy_5 xc_gdp_rex_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_gdp_nxy_5 xc_gdp_rex_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_gdp_nxy_5 xc_gdp_rex_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_gdp_nxy_5 xc_gdp_rex_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    xc_gdp_nxy_5 xc_gdp_rex_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( Y, NX )) xtitle(corr( Y, RER )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(Y,NX) vs. corr(Y,RER)) /*   vs. */
graph save corr_y_nx_vs_y_rx.gph, replace
graph export corr_y_nx_vs_y_rx.pdf, as(pdf) replace
graph export corr_y_nx_vs_y_rx.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------






* _____________________________________________ scatter: sig(rx) vs. rho(nx,y) _____________________________________
qui replace yy = xc_gdp_nxy_5 
qui replace xx = sdev_rex 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_gdp_nxy_5 sdev_rex if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_gdp_nxy_5 sdev_rex if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_gdp_nxy_5 sdev_rex if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_gdp_nxy_5 sdev_rex if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    xc_gdp_nxy_5 sdev_rex, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( Y, NX )) xtitle(sdev( RER )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(Y,NX) vs. sdev(RER))
graph save corr_y_nx_vs_sdev_rx.gph, replace
graph export corr_y_nx_vs_sdev_rx.pdf, as(pdf) replace
graph export corr_y_nx_vs_sdev_rx.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------





* scatter: rho(rx,gdp) vs. rho(nx,y) - vs USA _____________________________________
qui replace yy = xc_gdp_nxy_5 
qui replace xx = xc_gdp_rer_usa_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_gdp_nxy_5 xc_gdp_rer_usa_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_gdp_nxy_5 xc_gdp_rer_usa_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_gdp_nxy_5 xc_gdp_rer_usa_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_gdp_nxy_5 xc_gdp_rer_usa_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    xc_gdp_nxy_5 xc_gdp_rer_usa_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( Y, NX )) xtitle(corr( Y, RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(Y,NX) vs. corr(Y,RER vs USA)) 
graph save corr_y_nx_vs_y_rx_vsUSA.gph, replace
graph export corr_y_nx_vs_y_rx_vsUSA.pdf, as(pdf) replace
graph export corr_y_nx_vs_y_rx_vsUSA.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------






* scatter: sdev(rx) vs. rho(nx,y) - vs USA _____________________________________
qui replace yy = xc_gdp_nxy_5 
qui replace xx = sdev_rer_usa 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_gdp_nxy_5 xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_gdp_nxy_5 xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_gdp_nxy_5 xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_gdp_nxy_5 xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    xc_gdp_nxy_5 xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( Y, NX )) xtitle(sdev( RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(Y,NX) vs. sdev(RER vs USA)) 
graph save corr_y_nx_vs_sdev_rx_vsUSA.gph, replace
graph export corr_y_nx_vs_sdev_rx_vsUSA.pdf, as(pdf) replace
graph export corr_y_nx_vs_sdev.eps, as(eps) replace
* ----------------------------------------------------------------------------------------------------------------------






* ________________________________________ scatter: rho(rx,gdp) vs. rho(rx,con) ________________________________________
qui replace yy = xc_con_rex_5 
qui replace xx = xc_gdp_rex_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_con_rex_5 xc_gdp_rex_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_con_rex_5 xc_gdp_rex_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_con_rex_5 xc_gdp_rex_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_con_rex_5 xc_gdp_rex_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    xc_con_rex_5 xc_gdp_rex_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( C, RER )) xtitle(corr(Y,RER)) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(C,RER) vs. corr(Y,RER)) /*   */
graph save corr_c_rx_vs_y_rx.gph, replace
graph export corr_c_rx_vs_y_rx.pdf, as(pdf) replace
graph export corr_c_rx_vs_y_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------







* ________________________________________ scatter: sig(rx) vs. rho(rx,con) ________________________________________
qui replace yy = xc_con_rex_5 
qui replace xx = sdev_rex 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_con_rex_5 sdev_rex if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_con_rex_5 sdev_rex if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_con_rex_5 sdev_rex if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_con_rex_5 sdev_rex if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    xc_con_rex_5 sdev_rex, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( C, RER )) xtitle(sdev( RER)) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(C,RER) vs. sdev(RER))
graph save corr_c_rx_vs_sdev_rx.gph, replace
graph export corr_c_rx_vs_sdev_rx.pdf, as(pdf) replace
graph export corr_c_rx_vs_sdev_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------






* scatter: rho(rx,gdp) vs. rho(rx,con) - vs USA ________________________________________
qui replace yy = xc_relc_rer_usa_5 
qui replace xx = xc_rely_rer_usa_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_relc_rer_usa_5 xc_rely_rer_usa_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_relc_rer_usa_5 xc_rely_rer_usa_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_relc_rer_usa_5 xc_rely_rer_usa_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_relc_rer_usa_5 xc_rely_rer_usa_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    xc_relc_rer_usa_5 xc_rely_rer_usa_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( C vs. USA , RER vs. USA )) xtitle(corr( GDP vs. USA, RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(C/Cusa,RER vs USA) vs. corr(Y/Yusa,RER vs USA))
graph save corr_c_rx_vs_y_rx_vsUSA.gph, replace
graph export corr_c_rx_vs_y_rx_vsUSA.pdf, as(pdf) replace
graph export corr_c_rx_vs_y_rx_vsUSA.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------




* scatter: sig(rx) vs. rho(rx,con) - vs USA ________________________________________
qui replace yy = xc_relc_rer_usa_5 
qui replace xx = sdev_rer_usa 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_relc_rer_usa_5 xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_relc_rer_usa_5 xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_relc_rer_usa_5 xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_relc_rer_usa_5 xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    xc_relc_rer_usa_5 xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( C vs. USA , RER vs. USA )) xtitle(sdev( RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(C/Cusa,RER vs USA) vs. sdev(RER vs USA))
graph save corr_c_rx_vs_sdev_rx_vsUSA.gph, replace
graph export corr_c_rx_vs_sdev_rx_vsUSA.pdf, as(pdf) replace
graph export corr_c_rx_vs_sdev_rx_vsUSA.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------







* ________________________________________ scatter: rho(rx,gdp) vs. rho(rx,nxy) ________________________________________
qui replace yy = xc_nxy_rex_5 
qui replace xx = xc_gdp_rex_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_nxy_rex_5 xc_gdp_rex_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_nxy_rex_5 xc_gdp_rex_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_nxy_rex_5 xc_gdp_rex_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_nxy_rex_5 xc_gdp_rex_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit 	 xc_nxy_rex_5 xc_gdp_rex_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( NX, RER )) xtitle(corr(Y,RER)) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(NX,RER) vs. corr(Y,RER))
graph save corr_nxy_rx_vs_y_rx.gph, replace
graph export corr_nxy_rx_vs_y_rx.pdf, as(pdf) replace
graph export corr_nxy_rx_vs_y_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------





* ________________________________________ scatter: sig(rx) vs. rho(rx,nxy) ________________________________________
qui replace yy = xc_nxy_rex_5 
qui replace xx = sdev_rex 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter yy xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter yy xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter yy xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter yy xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit 	 yy xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( NX, RER )) xtitle(sdev(RER)) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(NX,RER) vs. sdev(RER))
graph save corr_nxy_rx_vs_sdev_rx.gph, replace
graph export corr_nxy_rx_vs_sdev_rx.pdf, as(pdf) replace
graph export corr_nxy_rx_vs_sdev_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------






* ________________________________________ scatter: sig(rx) vs. rho(rx,gdp) ________________________________________
qui replace yy = xc_gdp_rex_5 
qui replace xx = sdev_rex 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter yy xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter yy xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter yy xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter yy xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit 	 yy xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( Y, RER )) xtitle(sdev(RER)) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(Y,RER) vs. sdev(RER))
graph save corr_y_rx_vs_sdev_rx.gph, replace
graph export corr_y_rx_vs_sdev_rx.pdf, as(pdf) replace
graph export corr_y_rx_vs_sdev_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------




* scatter: rho(rx,gdp) vs. rho(rx,nxy) - vs USA ________________________________________
qui replace yy = xc_nxy_rer_usa_5 
qui replace xx = xc_gdp_rer_usa_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_nxy_rer_usa_5 xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_nxy_rer_usa_5 xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_nxy_rer_usa_5 xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_nxy_rer_usa_5 xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    xc_nxy_rer_usa_5 xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( NX , RER vs. USA )) xtitle(corr( GDP, RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(NX, RER vs USA) vs corr(Y, RER vs USA))
graph save corr_nxy_rx_vs_y_rx_vsUSA.gph, replace
graph export corr_nxy_rx_vs_y_rx_vsUSA.pdf, as(pdf) replace
graph export corr_nxy_rx_vs_y_rx_vsUSA.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------





* scatter: sig(rx) vs. rho(rx,nxy) - vs USA ________________________________________
qui replace yy = xc_nxy_rer_usa_5 
qui replace xx = sdev_rer_usa 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_nxy_rer_usa_5 xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_nxy_rer_usa_5 xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_nxy_rer_usa_5 xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_nxy_rer_usa_5 xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    xc_nxy_rer_usa_5 xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( NX , RER vs. USA )) xtitle(sdev( RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') ///
title(corr(NX, RER vs USA) sdev(RER vs USA))
graph save corr_nxy_rx_vs_sdev_rx_vsUSA.gph, replace
graph export corr_nxy_rx_vs_sdev_rx_vsUSA.pdf, as(pdf) replace
graph export corr_nxy_rx_vs_sdev_rx_vsUSA.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------








* ___________________ figure: rho(rx,gdp) vs. rho(rx,R) _____________________________
qui replace yy = xc_irate_rex_5 
qui replace xx = xc_gdp_rex_5 
qui replace xx2 = xx^2
qui reg yy xx xx2
local r2: display %5.4f e(r2)
twoway ///
(scatter yy xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter yy xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter yy xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter yy xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(qfit    yy xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( R, RER )) xtitle(corr( Y, RER )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(corr(R,RER) vs. corr(Y,RER))
graph save corr_rx_R_vs_y_rx.gph, replace
graph export corr_rx_R_vs_y_rx.pdf, as(pdf) replace
graph export corr_rx_R_vs_y_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------



* ___________________ figure: sig(rx) vs. rho(rx,R) _____________________________
qui replace yy = xc_irate_rex_5 
qui replace xx = sdev_rex 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter yy xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter yy xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter yy xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter yy xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    yy xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( R, RER )) xtitle(sdev(RER)) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(corr(R,RER) vs. sdev(RER))
graph save corr_rx_R_vs_sdev_rx.gph, replace
graph export corr_rx_R_vs_sdev_rx.pdf, as(pdf) replace
graph export corr_rx_R_vs_sdev_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------














* ___________________ figure: rho(rx,gdp) vs. rho(rx,R) - vs USA  _____________________________
qui replace yy = xc_irate_rer_usa_5 
qui replace xx = xc_gdp_rer_usa_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter yy xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter yy xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter yy xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter yy xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    yy xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( R, RER vs. USA )) xtitle(corr( Y, RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(corr(R,RER vs USA) vs. corr(Y,RER vs USA))
graph save corr_rx_R_vs_y_rx_vsUSA.gph, replace
graph export corr_rx_R_vs_y_rx_vsUSA.pdf, as(pdf) replace
graph export corr_rx_R_vs_y_rx_vsUSA.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------



* ___________________ figure: sig(rx) vs. rho(rx,R) - vs USA  _____________________________
qui replace yy = xc_irate_rer_usa_5 
qui replace xx = sdev_rer_usa 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter yy xx if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter yy xx if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter yy xx if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter yy xx if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    yy xx, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( R, RER vs. USA )) xtitle(sdev( RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(corr(R,RER vs USA) vs. sdev(RER vs USA))
graph save corr_rx_R_vs_sdev_rx_vsUSA.gph, replace
graph export corr_rx_R_vs_sdev_rx_vsUSA.pdf, as(pdf) replace
graph export corr_rx_R_vs_sdev_rx_vsUSA.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------















* _____________________________ scatter: rho(rx,gdp) vs. sig(R) _____________________________
qui replace yy = sdev_irate 
qui replace xx = xc_gdp_rex_5 
qui replace xx2 = xx^2
qui reg yy xx xx2
local r2: display %5.4f e(r2)
twoway ///
(scatter sdev_irate xc_gdp_rex_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter sdev_irate xc_gdp_rex_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter sdev_irate xc_gdp_rex_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter sdev_irate xc_gdp_rex_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(qfit    sdev_irate xc_gdp_rex_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle( log[ sdev(R) ] ) xtitle(corr( GDP, RER )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(Volatility of the real interest rate)
graph save sdev_R_vs_y_rx.gph, replace
graph export sdev_R_vs_y_rx.pdf, as(pdf) replace
graph export sdev_R_vs_y_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------






* _____________________________ scatter: sig(rx) vs. sig(R) _____________________________
qui replace yy = sdev_irate 
qui replace xx = sdev_rex 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter sdev_irate sdev_rex if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter sdev_irate sdev_rex if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter sdev_irate sdev_rex if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter sdev_irate sdev_rex if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    sdev_irate sdev_rex, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle( log[ sdev(R) ] ) xtitle(sdev( RER )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(Volatility of the real interest rate)
graph save sdev_R_vs_sdev_rx.gph, replace
graph export sdev_R_vs_sdev_rx.pdf, as(pdf) replace
graph export sdev_R_vs_sdev_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------






* _____________________________ scatter: rho(rx,gdp) vs. sig(rer) _____________________________
qui replace yy = sdev_rex 
qui replace xx = xc_gdp_rex_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter sdev_rex xc_gdp_rex_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter sdev_rex xc_gdp_rex_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter sdev_rex xc_gdp_rex_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter sdev_rex xc_gdp_rex_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    sdev_rex xc_gdp_rex_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle( sdev(RER) ) xtitle(corr( GDP, RER )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(sdev(RER) vs. corr(Y,RER))
graph save sdev_rex_vs_y_rx.gph, replace
graph export sdev_rex_vs_y_rx.pdf, as(pdf) replace
graph export sdev_rex_vs_y_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------







* scatter: rho(rx,gdp) vs. sig(R) - vs USA _____________________________
qui replace yy = sdev_irate 
qui replace xx = xc_gdp_rer_usa_5 
qui replace xx2 = xx^2
qui reg yy xx /*xx2*/
local r2: display %5.4f e(r2)
twoway ///
(scatter sdev_irate xc_gdp_rer_usa_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter sdev_irate xc_gdp_rer_usa_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter sdev_irate xc_gdp_rer_usa_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter sdev_irate xc_gdp_rer_usa_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(lfit    sdev_irate xc_gdp_rer_usa_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle( log[ sdev(R) ] ) xtitle(corr( GDP, RER vs. USA )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
legend(off) ///
note(R-squared = `r2') ///
title(Volatility of the real interest rate)
graph save sdev_R_vs_y_rx_vsUSA.gph, replace
graph export sdev_R_vs_y_rx_vsUSA.pdf, as(pdf) replace
graph export sdev_R_vs_y_rx_vsUSA.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------








* _____________________________________________ scatter: sig(c)/sig(y) vs. rho(rx,con) _____________________________________________
qui replace yy = xc_con_rex_5 
qui replace xx = relsd_con 
qui replace xx2 = xx^2
qui reg yy xx xx2
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_con_rex_5 relsd_con if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter xc_con_rex_5 relsd_con if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_con_rex_5 relsd_con if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_con_rex_5 relsd_con if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(qfit    xc_con_rex_5 relsd_con, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr( C, RER )) xtitle( sdev(C) / sdev(GDP) ) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') 
graph save corr_c_rx_vs_relsd_con.gph, replace
graph export corr_c_rx_vs_relsd_con.pdf, as(pdf) replace
graph export corr_c_rx_vs_relsd_con.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------





* _____________________________________________ scatter: sig(c)/sig(y) vs. rho(rx,con vs usa) _____________________________________________
qui replace yy = xc_relc_rer_usa_5 
qui replace xx = relsd_con 
qui replace xx2 = xx^2
qui reg yy xx xx2
local r2: display %5.4f e(r2)
twoway ///
(scatter xc_relc_rer_usa_5 relsd_con if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)  ysc(r(-1 1)) ylabel(-1 -0.5 0 0.5 1)) /// 
(scatter xc_relc_rer_usa_5 relsd_con if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter xc_relc_rer_usa_5 relsd_con if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter xc_relc_rer_usa_5 relsd_con if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(qfit    xc_relc_rer_usa_5 relsd_con, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(corr(C,RER) vs. USA) xtitle(sd(C)/sd(GDP)) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') 
graph save corr_c_rx_usa_vs_relsd_con.gph, replace
graph export corr_c_rx_usa_vs_relsd_con.pdf, as(pdf) replace
graph export corr_c_rx_usa_vs_relsd_con.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------








* ___________________ scatter: rho(rx,nxy) vs. sig(c)/sig(y) _____________________________
qui replace yy = relsd_con 
qui replace xx = xc_nxy_rex_5 
qui replace xx2 = xx^2
qui reg yy xx xx2
local r2: display %5.4f e(r2)
twoway ///
(scatter relsd_con xc_nxy_rex_5 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter relsd_con xc_nxy_rex_5 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter relsd_con xc_nxy_rex_5 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter relsd_con xc_nxy_rex_5 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(qfit 	 relsd_con xc_nxy_rex_5, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(sd(C)/sd(GDP)) xtitle(corr(NX,RER)) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') 
graph save relsd_con_vs_nxy_rx.gph, replace
graph export relsd_con_vs_nxy_rx.pdf, as(pdf) replace
graph export relsd_on_vs_nxy_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------






* ___________________ scatter: rho(rx,rx[t-1]) vs. sig(c)/sig(y) _____________________________
qui replace yy = relsd_con 
qui replace xx = xc_rex_rex_4 
qui replace xx2 = xx^2
qui reg yy xx xx2
local r2: display %5.4f e(r2)
twoway ///
(scatter relsd_con xc_rex_rex_4 if IMF_class == 0 & ISO ~= "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1)) /// 
(scatter relsd_con xc_rex_rex_4 if IMF_class == 1 & ISO ~= "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1)) ///
(scatter relsd_con xc_rex_rex_4 if ISO == "MEX", sort msize(zero) mlabel(ISO) mlabcolor(red) mlabposition(1) mlabsize(large)) /// 
(scatter relsd_con xc_rex_rex_4 if ISO == "CAN", sort msize(zero) mlabel(ISO) mlabcolor(blue) mlabposition(1) mlabsize(large)) ///
(qfit 	 relsd_con xc_rex_rex_4, lcolor(black) lwidth(medthick) lpattern(solid)), ///
ytitle(sd(C)/sd(GDP)) xtitle(corr( RER, RER[t-1] )) ///
graphregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) ///
plotregion(fcolor(white) lcolor(none) ifcolor(white) ilcolor(none)) /// 
legend(off) ///
note(R-squared = `r2') 
graph save relsd_con_vs_rx_rx.gph, replace
graph export relsd_con_vs_rx_rx.pdf, as(pdf) replace
graph export relsd_on_vs_rx_rx.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------








* ____________________ bar chart for sd(rer)
graph bar (mean) sdev_rex, over(IMF_class) over(country, sort(sdev_rex) label(nolabel)) ///
blabel(group, size(vsmall) orientation(vertical)) ///
ytitle(Volatility of the Real Exchange Rate) asyvars ///
stack bar(1, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	  bar(2, color(blue*0.8) lcolor(black) lwidth(0.25)) ///
legend(order( 1 "Emerging" 2 "Developed" )) 
graph save sdev_rex.gph, replace
graph export sdev_rex.pdf, as(pdf) replace
graph export sdev_rex.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------



* ____________________ bar chart for sd(rer) / sd(gdp)
graph bar (mean) relsd_rex, over(IMF_class) over(country, sort(relsd_rex) label(nolabel)) ///
blabel(group, size(vsmall) orientation(vertical)) ///
ytitle(Relative Volatility of the Real Exchange Rate) asyvars ///
stack bar(1, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	  bar(2, color(blue*0.8) lcolor(black) lwidth(0.25)) ///
legend(order( 1 "Emerging" 2 "Developed" )) 
graph save relsd_rex.gph, replace
graph export relsd_rex.pdf, as(pdf) replace
graph export relsd_rex.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------
 
 
 

* ____________________ bar chart for sd(c) / sd(gdp)
graph bar (mean) relsd_con, over(IMF_class) over(country, sort(relsd_con) label(nolabel)) ///
blabel(group, size(vsmall) orientation(vertical)) ///
ytitle(Relative Volatility of Consumption) asyvars ///
stack bar(1, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	  bar(2, color(blue*0.8) lcolor(black) lwidth(0.25)) ///
legend(order( 1 "Emerging" 2 "Developed" )) 
graph save relsd_con.gph, replace
graph export relsd_con.pdf, as(pdf) replace
graph export relsd_con.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------


* ____________________ bar chart for corr(nx,y)
graph bar (mean) xc_gdp_nxy_5, over(IMF_class) over(country, sort(xc_gdp_nxy_5) label(nolabel)) ///
blabel(group, size(vsmall) orientation(vertical)) ///
ytitle(Cyclicality of Trade Balance) asyvars ///
stack bar(1, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	  bar(2, color(blue*0.8) lcolor(black) lwidth(0.25)) ///
legend(order( 1 "Emerging" 2 "Developed" )) 
graph save corr_gdp_nxy.gph, replace
graph export corr_gdp_nxy.pdf, as(pdf) replace
graph export corr_gdp_nxy.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------


* ____________________ bar chart for corr(rer,y)
graph bar (mean) xc_gdp_rex_5, over(IMF_class) over(country, sort(xc_gdp_rex_5) label(nolabel)) ///
blabel(group, size(vsmall) orientation(vertical)) ///
ytitle(Cyclicality of Real Exchange Rate) asyvars ///
stack bar(1, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	  bar(2, color(blue*0.8) lcolor(black) lwidth(0.25)) ///
legend(order( 1 "Emerging" 2 "Developed" )) 
graph save corr_gdp_rex.gph, replace
graph export corr_gdp_rex.pdf, as(pdf) replace
graph export corr_gdp_rex.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------


* ____________________ bar chart for corr(iratio,y)
graph bar (mean) xc_gdp_iratio_5, over(IMF_class) over(country, sort(xc_gdp_iratio_5) label(nolabel)) ///
blabel(group, size(vsmall) orientation(vertical)) ///
ytitle(Cyclicality of Import Ratio) asyvars ///
stack bar(1, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	  bar(2, color(blue*0.8) lcolor(black) lwidth(0.25)) ///
legend(order( 1 "Emerging" 2 "Developed" )) 
graph save corr_gdp_ir.gph, replace
graph export corr_gdp_ir.pdf, as(pdf) replace
graph export corr_gdp_ir.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------


* ____________________ bar chart for corr(iratio,rex)
graph bar (mean) xc_iratio_rex_5, over(IMF_class) over(country, sort(xc_iratio_rex_5) label(nolabel)) ///
blabel(group, size(vsmall) orientation(vertical)) ///
ytitle(Corr(Import Ratio,RER)) asyvars ///
stack bar(1, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	  bar(2, color(blue*0.8) lcolor(black) lwidth(0.25)) ///
legend(order( 1 "Emerging" 2 "Developed" )) 
graph save corr_rex_ir.gph, replace
graph export corr_rex_ir.pdf, as(pdf) replace
graph export corr_rex_ir.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------


* ____________________ bar chart for corr(nxy,rex)
graph bar (mean) xc_nxy_rex_5, over(IMF_class) over(country, sort(xc_nxy_rex_5) label(nolabel)) ///
blabel(group, size(vsmall) orientation(vertical)) ///
ytitle(Corr(NX/GDP , RER)) asyvars ///
stack bar(1, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	  bar(2, color(blue*0.8) lcolor(black) lwidth(0.25)) ///
legend(order( 1 "Emerging" 2 "Developed" )) 
graph save corr_nxy_rex.gph, replace
graph export corr_nxy_rex.pdf, as(pdf) replace
graph export corr_nxy_rex.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------



* ____________________ bar chart for corr(cons,rex)
graph bar (mean) xc_con_rex_5, over(IMF_class) over(country, sort(xc_con_rex_5) label(nolabel)) ///
blabel(group, size(vsmall) orientation(vertical)) ///
ytitle(Corr(C,RER)) asyvars ///
stack bar(1, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	  bar(2, color(blue*0.8) lcolor(black) lwidth(0.25)) ///
legend(order( 1 "Emerging" 2 "Developed" )) 
graph save corr_con_rex.gph, replace
graph export corr_con_rex.pdf, as(pdf) replace
graph export corr_con_rex.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------




* ____________________ bar chart for corr(cons,rex) vs USA
graph bar (mean) xc_relc_rer_usa_5, over(IMF_class) over(country, sort(xc_relc_rer_usa_5) label(nolabel)) ///
blabel(group, size(vsmall) orientation(vertical)) ///
ytitle(Corr(C,RER) vs. USA) asyvars ///
stack bar(1, color(yellow*0.4) lcolor(black) lwidth(0.25)) ///
	  bar(2, color(blue*0.8) lcolor(black) lwidth(0.25)) ///
legend(order( 1 "Emerging" 2 "Developed" )) 
graph save corr_con_rex_usa.gph, replace
graph export corr_con_rex_usa.pdf, as(pdf) replace
graph export corr_con_rex_usa.eps, as(eps) replace
* -----------------------------------------------------------------------------------------------------------------------------
