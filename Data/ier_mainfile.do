clear all
set more off

* make sure the path is correct
* define the folder where the data file is located
global main_path "C:\Users\rothert\Dropbox\work\research\emrers\data"
local main_path "C:\Users\rothert\Dropbox\work\research\emrers\data"




* install stata packages (if necessary) 
/*
ssc install tsspell
*/



* load dataset
qui use $main_path\ier2018_dataset.dta, clear


* choose sample (1 if AG, 0 otherwise)
scalar AGsample = 0


* choose the filter
* 1 = hp; 2 = y-to-y diff; 3 = quadratic trend
scalar filtertype = 1


* criteria for keeping data
drop if date < 80
scalar tmin = 60		/*	at least 15 years of data	*/



* declare panel data
qui format date %tq
qui encode ISO, gen(id)
qui xtset id date, q





* __________________________ create developed / emerging / other labels ______________________________ *

qui replace Country = "New_Zealand" 	if Country == "New Zealand"
qui replace Country = "Czech_Republic" 	if Country == "Czech Republic"
qui replace Country = "USA" 			if Country == "United States"
qui replace Country = "United_Kingdom" 	if Country == "United Kingdom"
qui replace Country = "Costa_Rica" 		if Country == "Costa Rica"
qui replace Country = "South_Africa" 	if Country == "South Africa"
qui replace Country = "Slovak_Republic" if Country == "Slovak Republic"




bysort ISO: egen IMFcode = max(IFScode)
qui replace IFScode = IMFcode if IFScode == .
qui drop IMFcode

qui gen IMF_class = .
*  1: developed
*  0: emerging
* -1: other
qui replace IMF_class = 1 if (IFScode==193 | IFScode==122 | IFScode==124 | IFScode==156 | IFScode==128 | IFScode==172 | ///
						  IFScode==132 | IFScode==134 | IFScode==178 | IFScode==436 | IFScode==136 | IFScode==158 | ///
						  IFScode==137 | IFScode==138 | IFScode==196 | IFScode==182 | IFScode==184 | IFScode==144 | ///
						  IFScode==112 | IFScode==935 | IFScode==939 | IFScode==174 | IFScode==146 | IFScode==176 | ///
						  IFScode==936 | IFScode==961 | IFScode==111 | IFScode==142 )
qui replace IMF_class = 0 if (IFScode==213 | IFScode==218 | IFScode==223 | IFScode==228 | IFScode==243 | IFScode==941 | ///
						  IFScode==278 | IFScode==968 | IFScode==578 | IFScode==298 | IFScode==273 | IFScode==922 | ///
						  IFScode==964 | IFScode==944 | IFScode==199 | IFScode==233 | IFScode==238 | IFScode==542 | ///
						  IFScode==181 | ISO == "LTU" | ISO == "IDN" | ISO == "IND" | ISO == "TUR" )
									
*Code switchers as emerging( 176== iceland; 436 israel; 936 slovakia; slovenia; czech rep., estonia)
qui replace IMF_class=0 if (IFScode==436 | IFScode==176 | IFScode==936 | ISO == "SVN" | ISO == "CZE" | ISO == "EST" | ///
										   ISO == "ARG" | ISO == "BRA" | ISO == "KOR" | ISO == "MEX" | ISO == "PHL" | ///
								           ISO == "ECU" | ISO == "ISR" | ISO == "MYS" | ISO == "PER" | ISO == "SVK" | ///
								           ISO == "ZAF" | ISO == "THA" | ISO == "TUR" )
*drop what we don't use
qui replace IMF_class = -1 if IMF_class == .
*large developed countries
qui replace IMF_class = 2 if (ISO == "JPN" | ISO == "DEU" | ISO == "ITA" | ISO == "GBR" | ISO == "USA" | ISO == "FRA")




qui gen EUROzone = 0
qui replace EUROzone = 1 if ( ISO == "DEU" | ISO == "ITA" | ISO == "FRA" | ISO == "AUT" | ISO == "PRT" | ISO == "ESP" | ///
						  ISO == "NLD" | ISO == "FIN" | ISO == "IRL" | ISO == "LUX" | ISO == "BEL" ) & date >= 156		
qui replace EUROzone = 1 if ISO == "GRC" & date >= 164
qui replace EUROzone = 1 if ISO == "SVN" & date >= 188
qui replace EUROzone = 1 if ISO == "MLT" & date >= 192
qui replace EUROzone = 1 if ISO == "CYP" & date >= 192
qui replace EUROzone = 1 if ISO == "SVK" & date >= 196
qui replace EUROzone = 1 if ISO == "EST" & date >= 204
qui replace EUROzone = 1 if ISO == "LVA" & date >= 216
qui replace EUROzone = 1 if ISO == "LTU" & date >= 220						  
						  
by ISO, sort: egen EUROmember = max(EUROzone)
			  
* local currency to euro conversion for the EURO zone
* --------------------------------------------------------
qui gen  	 LOCAL_2_EURO =	13.7603	 	if ISO == "AUT"
qui replace  LOCAL_2_EURO =	40.3399	 	if ISO == "BEL"
qui replace  LOCAL_2_EURO =	2.20371	 	if ISO == "NLD"
qui replace  LOCAL_2_EURO =	5.94573	 	if ISO == "FIN"
qui replace  LOCAL_2_EURO =	6.55957	 	if ISO == "FRA"
qui replace  LOCAL_2_EURO =	1.95583	 	if ISO == "DEU"
qui replace  LOCAL_2_EURO =	0.787564	if ISO == "IRL"
qui replace  LOCAL_2_EURO =	1936.27	 	if ISO == "ITA"
qui replace  LOCAL_2_EURO =	40.3399	 	if ISO == "LUX"
qui replace  LOCAL_2_EURO =	200.482	 	if ISO == "PRT"
qui replace  LOCAL_2_EURO =	166.386	 	if ISO == "ESP"

qui replace  LOCAL_2_EURO =	340.75	 	if ISO == "GRC"
qui replace  LOCAL_2_EURO =	15.6466	 	if ISO == "EST"
qui replace  LOCAL_2_EURO =	0.585274	if ISO == "CYP"
qui replace  LOCAL_2_EURO =	30.126	 	if ISO == "SVK"
qui replace  LOCAL_2_EURO =	239.64	 	if ISO == "SVN"
qui replace  LOCAL_2_EURO =	0.4293	 	if ISO == "MLT"
qui replace  LOCAL_2_EURO =	0.702804	if ISO == "LVA"
qui replace  LOCAL_2_EURO =	3.4528	 	if ISO == "LTU"
* --------------------------------------------------------				  
by ISO, sort: egen local_to_euro = mode(LOCAL_2_EURO)
						  

						  
						  
* generate euro/usd exchange rate
qui gen euro_usd = ifs_xrate_euro if ISO == "USA"
by date, sort: egen xrate_euro_usd = mode(euro_usd)
qui replace xrate_euro_usd = 1/xrate_euro_usd 
qui drop euro_usd

replace xrate_euro_usd = ifs_xrate_usd/local_to_euro if xrate_euro_usd == .
replace ifs_xrate_usd = xrate_euro_usd if EUROmember == 1
qui drop xrate_euro_usd
						  
						  
* ---------------------------------------------------------------------------------------------------- *





************************************************************************************************************************
* ------------------------------------------------- NP and AG COUNTRIES ------------------------------------------------
************************************************************************************************************************

qui gen NP_country = 0
qui replace NP_country = 1 if ( ISO == "ARG" | ISO == "BRA" | ISO == "KOR" | ISO == "MEX" | ISO == "PHL" | /// 
								ISO == "AUS" | ISO == "CAN" | ISO == "NLD" | ISO == "NZL" | ISO == "SWE" ) 
								
qui gen AG_country = 0
qui replace AG_country = 1 if ( ISO == "ARG" | ISO == "BRA" | ISO == "KOR" | ISO == "MEX" | ISO == "PHL" | ///
								ISO == "ECU" | ISO == "ISR" | ISO == "MYS" | ISO == "PER" | ISO == "SVK" | ///
								ISO == "ZAF" | ISO == "THA" | ISO == "TUR" | 							   ///
								ISO == "AUS" | ISO == "CAN" | ISO == "NLD" | ISO == "NZL" | ISO == "SWE" | ///
								ISO == "AUT" | ISO == "BEL" | ISO == "DNK" | ISO == "FIN" | ISO == "NOR" | ///
								ISO == "PRT" | ISO == "ESP" | ISO == "CHE" ) 
								
scalar AG_start = 80
scalar AG_end   = 80+94

************************************************************************************************************************
************************************************************************************************************************


if AGsample == 1 {
keep if AG_country == 1 | ISO == "USA"
keep if date >= AG_start
keep if date <= AG_end
drop if ISO == "PER" & date < 100
}
*




************************************************************************************************************************
* -------------------------------------------- CLEANING FOR INDIV COUNTRIES -------------------------------------------
************************************************************************************************************************







************************************************************************************************************************
* -------------------------------------------- PICK BEST SERIES FOR REAL GDP -------------------------------------------
************************************************************************************************************************

* pre-generate new variable
gen new_variable = .
gen mis_variable = 1
gen variable_used = "none"
gen max_t_0 = 0


* define a generic varlist
local varlista = "y_vol_a_sa ifs_yreal_sa ifs_yreal_spliced_sa ifs_yreal_spliced_index_sa ifs_yreal_spliced ifs_yreal_spliced_index"


replace ifs_yreal_spliced 		= exp(ifs_yreal_spliced)
replace ifs_yreal_spliced_index = exp(ifs_yreal_spliced_index)



* first decide which variable to use
foreach var of varlist `varlista' {

	* calculate how many non-missing values we have
	bysort ISO (date): egen max_t = count(`var')

	* identify gaps in time series for each variable, for each country
	tsspell `var' , c(`var' ~= .)
	bysort ISO (date): egen maxspell = max(_spell)	

	replace new_variable  = `var' 	if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	replace variable_used = "`var'" if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	replace mis_variable  = 0 		if max_t>tmin & maxspell <= 1	

	replace max_t_0 = max_t if max_t > max_t_0
	drop max_t maxspell _seq _spell _end
}
*




gen gdp = ln(new_variable)
gen gdp_used = variable_used

drop new_variable mis_variable variable_used max_t_0

************************************************************************************************************************
************************************************************************************************************************




************************************************************************************************************************
* ------------------------------------------- PICK BEST SERIES FOR NOMINAL GDP -----------------------------------------
************************************************************************************************************************

* pre-generate new variable
qui gen new_variable = .
qui gen mis_variable = 1
qui gen variable_used = "none"
qui gen max_t_0 = 0

* define a generic varlist
local varlista = "y_nom_a_sa ifs_ynom_sa ifs_ynom"




replace ifs_ynom 		= exp(ifs_ynom)



* first decide which variable to use
foreach var of varlist `varlista' {

	* calculate how many non-missing values we have
	bysort ISO (date): egen max_t = count(`var')

	* identify gaps in time series for each variable, for each country
	tsspell `var' , c(`var' ~= .)
	bysort ISO (date): egen maxspell = max(_spell)	

	qui replace new_variable  = `var' 	if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace variable_used = "`var'" if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace mis_variable  = 0 		if max_t>tmin & maxspell <= 1	

	qui replace max_t_0 = max_t if max_t > max_t_0
	qui drop max_t maxspell _seq _spell _end
}

qui gen y_nom 		= ln(new_variable)
qui gen y_nom_used 	= variable_used

qui drop new_variable mis_variable variable_used max_t_0

qui gen ydefl = y_nom - gdp

qui gen ydefl_used = y_nom_used
qui replace ydefl_used = "none" if gdp_used == "none"
bysort ISO (date): egen max_t = count(ydefl)
qui replace ydefl_used = "none" if max_t < 20
qui drop max_t 

************************************************************************************************************************
************************************************************************************************************************









************************************************************************************************************************
* ----------------------------------------- PICK BEST SERIES FOR INTEREST RATE -----------------------------------------  
************************************************************************************************************************

*  rename interest rates vars from the IFS data 
* ------------------------------------------------------------------------------------------------------- *
rename ifs_r_corpo 		r_corpo
rename ifs_r_deposit 	r_dpst
rename ifs_r_gyield 	r_gyld
rename ifs_r_gbond 		r_gbond
rename ifs_r_tbill 		r_tbill
rename ifs_r_lend 		r_lend
rename ifs_r_ffr 		r_ffr
rename ifs_r_mmkt 		r_mmkt
rename ifs_r_savrate 	r_save
* ------------------------------------------------------------------------------------------------------- *

* CRITERIA
* 1) at least 15 years and no gaps
* 2) ORDER OF PREFERENCE
* 	a) corporate
* 	b) lending rate
* 	c) money market
* 	d) t-bill
* 	e) ffr
* otherwise drop the country

* pre-generate new variable
qui gen new_variable = .
qui gen mis_variable = 1
qui gen variable_used = "none"
qui gen max_t_0 = 0

* define a generic varlist   r_tbill r_ffr r_corpo
local varlista = "r_lend r_mmkt"


* first decide which variable to use
foreach var of varlist `varlista' {

	* calculate how many non-missing values we have
	bysort ISO (date): egen max_t = count(`var')

	* identify gaps in time series for each variable, for each country
	tsspell `var' , c(`var' ~= .)
	bysort ISO (date): egen maxspell = max(_spell)	
	
	qui replace new_variable  = `var' 	if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	
	qui gen `var'_covered = 0
	qui replace `var'_covered = 1 if max_t>tmin 		& maxspell <= 1 	
	qui replace variable_used = "`var'" if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace mis_variable  = 0 		if max_t>tmin 		& maxspell <= 1	

	qui replace max_t_0 = max_t if max_t > max_t_0
	qui drop max_t maxspell _seq _spell _end
}

qui gen irate = new_variable/100
qui gen irate_used = variable_used
qui drop new_variable mis_variable variable_used max_t_0

keep if r_lend_covered == 1
* keep if r_mmkt_covered == 1
qui replace irate = r_lend/100
* qui replace irate = r_mmkt/100
* replace irate = r_tbill/100
* replace irate = r_ffr/100
* replace irate = r_corpo/100


************************************************************************************************************************
************************************************************************************************************************









************************************************************************************************************************
* ---------------------------------------- PICK BEST SERIES FOR REAL CONSUMPTION ---------------------------------------
************************************************************************************************************************

replace ifs_cpriv_nom 		= exp(ifs_cpriv_nom)

gen con_imf_adj  = ifs_cpriv_nom / (ifs_ynom/ifs_yreal_spliced)
gen con_imf      = ifs_cpriv_nom_sa / (ifs_ynom_sa/ifs_yreal_spliced_sa)
gen con_oecd     = cpriv_vol_a_sa


* CRITERIA
* 1) at least 15 years and no gaps
* 2) ORDER OF PREFERENCE
* 	a) OECD
* 	b) IFS
* otherwise drop the country

* pre-generate new variable
qui gen new_variable = .
qui gen mis_variable = 1
qui gen variable_used = "none"
qui gen max_t_0 = 0

* define a generic varlist
local varlista = "con_oecd con_imf con_imf_adj"

* first decide which variable to use
foreach var of varlist `varlista' {

	* calculate how many non-missing values we have
	bysort ISO (date): egen max_t = count(`var')

	* identify gaps in time series for each variable, for each country
	tsspell `var' , c(`var' ~= .)
	bysort ISO (date): egen maxspell = max(_spell)	

	qui replace new_variable  = `var' 	if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace variable_used = "`var'" if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace mis_variable  = 0 		if max_t>tmin 		& maxspell <= 1	

	replace max_t_0 = max_t if max_t > max_t_0
	qui drop max_t maxspell _seq _spell _end
}
*


qui gen con = ln(new_variable)
qui gen con_used = variable_used
qui drop new_variable mis_variable variable_used max_t_0 con_imf con_oecd

************************************************************************************************************************
************************************************************************************************************************





************************************************************************************************************************
* --------------------------------------------- PICK BEST SERIES FOR NX/GDP --------------------------------------------
************************************************************************************************************************



qui gen nxy_oecd    = (ex_nom_a_sa - im_nom_a_sa)/y_nom_a_sa	
qui gen nxy_imf     = (bop_ca_gs_cr - bop_ca_gs_db)/(ifs_ynom_sa / ifs_xrate_usd)
qui gen nxy_imf_adj = (bop_ca_gs_cr - bop_ca_gs_db)/(ifs_ynom /ifs_xrate_usd)

* CRITERIA
* 1) at least 15 years and no gaps
* 2) ORDER OF PREFERENCE
* 	a) OECD
* 	b) IFS
* otherwise drop the country

* pre-generate new variable
qui gen new_variable = .
qui gen mis_variable = 1
qui gen variable_used = "none"
qui gen max_t_0 = 0

* define a generic varlist
local varlista = "nxy_oecd nxy_imf nxy_imf_adj"

* first decide which variable to use
foreach var of varlist `varlista' {

	* calculate how many non-missing values we have
	bysort ISO (date): egen max_t = count(`var')

	* identify gaps in time series for each variable, for each country
	tsspell `var' , c(`var' ~= .)
	bysort ISO (date): egen maxspell = max(_spell)	

	qui replace new_variable  = `var' 	if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace variable_used = "`var'" if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace mis_variable  = 0 		if max_t>tmin 		& maxspell <= 1	

	qui replace max_t_0 = max_t if max_t > max_t_0
	qui drop max_t maxspell _seq _spell _end
}

qui gen nxy = (new_variable)
qui gen nxy_used = variable_used
qui replace nxy = nxy_oecd if ISO == "COL"
qui replace nxy_used = "nxy_oecd" if ISO == "COL"
qui drop new_variable mis_variable variable_used max_t_0 nxy_imf nxy_oecd

************************************************************************************************************************
************************************************************************************************************************








************************************************************************************************************************
* ---------------------------------------------- PICK BEST SERIES FOR INV ----------------------------------------------
************************************************************************************************************************


qui gen inv_oecd    = gfcf_vol_a_sa
qui gen inv_imf     = ifs_gfcf_nom_sa  / (ifs_ynom_sa/ifs_yreal_spliced_sa)
qui gen inv_imf_adj = ifs_gfcf_nom  / (ifs_ynom/ifs_yreal_spliced)

* CRITERIA
* 1) at least 15 years and no gaps
* 2) ORDER OF PREFERENCE
* 	a) OECD
* 	b) IFS
* otherwise drop the country

* pre-generate new variable
qui gen new_variable = .
qui gen mis_variable = 1
qui gen variable_used = "none"
qui gen max_t_0 = 0

* define a generic varlist
local varlista = "inv_oecd inv_imf inv_imf_adj"

* first decide which variable to use
foreach var of varlist `varlista' {

	* calculate how many non-missing values we have
	bysort ISO (date): egen max_t = count(`var')

	* identify gaps in time series for each variable, for each country
	tsspell `var' , c(`var' ~= .)
	bysort ISO (date): egen maxspell = max(_spell)	

	qui replace new_variable  = `var' 	if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace variable_used = "`var'" if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace mis_variable  = 0 		if max_t>tmin 		& maxspell <= 1	

	qui replace max_t_0 = max_t if max_t > max_t_0
	qui drop max_t maxspell _seq _spell _end
}

qui gen inv = ln(new_variable)
qui gen inv_used = variable_used
qui drop new_variable mis_variable variable_used max_t_0 inv_imf inv_oecd

************************************************************************************************************************
************************************************************************************************************************









************************************************************************************************************************
* ---------------------------------------------- PICK BEST SERIES FOR GOV ----------------------------------------------
************************************************************************************************************************

qui gen gov_oecd  = gov_vol_a_sa
qui gen gov_imf   = ifs_gov_nom_sa  / (ifs_ynom_sa/ifs_yreal_spliced_sa)  

* CRITERIA
* 1) at least 15 years and no gaps
* 2) ORDER OF PREFERENCE
* 	a) OECD
* 	b) IFS
* otherwise drop the country

* pre-generate new variable
qui gen new_variable = .
qui gen mis_variable = 1
qui gen variable_used = "none"
qui gen max_t_0 = 0

* define a generic varlist
local varlista = "gov_oecd gov_imf"

* first decide which variable to use
foreach var of varlist `varlista' {

	* calculate how many non-missing values we have
	bysort ISO (date): egen max_t = count(`var')

	* identify gaps in time series for each variable, for each country
	tsspell `var' , c(`var' ~= .)
	bysort ISO (date): egen maxspell = max(_spell)	

	qui replace new_variable  = `var' 	if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace variable_used = "`var'" if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace mis_variable  = 0 		if max_t>tmin 		& maxspell <= 1	

	qui replace max_t_0 = max_t if max_t > max_t_0
	qui drop max_t maxspell _seq _spell _end
}

qui gen gov = ln(new_variable)
qui gen gov_used = variable_used
qui drop new_variable mis_variable variable_used max_t_0 gov_imf gov_oecd

************************************************************************************************************************
************************************************************************************************************************







************************************************************************************************************************
* ----------------------------------------- PICK BEST SERIES FOR IMPORT RATIO ------------------------------------------
************************************************************************************************************************

qui gen iratio_oecd    = im_nom_a_sa/(y_nom_a_sa - ex_nom_a_sa)
qui gen iratio_imf     = bop_ca_gs_db / ((ifs_ynom_sa)/ifs_xrate_usd - bop_ca_gs_cr)
qui gen iratio_imf_adj = bop_ca_gs_db / ((ifs_ynom)/ifs_xrate_usd - bop_ca_gs_cr)

* CRITERIA
* 1) at least 15 years and no gaps
* 2) ORDER OF PREFERENCE
* 	a) OECD
* 	b) IFS
* otherwise drop the country

* pre-generate new variable
qui gen new_variable = .
qui gen mis_variable = 1
qui gen variable_used = "none"
qui gen max_t_0 = 0

* define a generic varlist
local varlista = "iratio_oecd iratio_imf iratio_imf_adj"

* first decide which variable to use
foreach var of varlist `varlista' {

	* calculate how many non-missing values we have
	bysort ISO (date): egen max_t = count(`var')

	* identify gaps in time series for each variable, for each country
	tsspell `var' , c(`var' ~= .)
	bysort ISO (date): egen maxspell = max(_spell)	

	qui replace new_variable  = `var' 	if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace variable_used = "`var'" if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace mis_variable  = 0 		if max_t>tmin 		& maxspell <= 1	

	qui replace max_t_0 = max_t if max_t > max_t_0
	qui drop max_t maxspell _seq _spell _end
}

qui gen iratio = ln(new_variable)
qui gen iratio_used = variable_used
qui drop new_variable mis_variable variable_used max_t_0 

bysort ISO (date): egen s_1 = mean(iratio)
qui replace s_1 = 1 - s_1

************************************************************************************************************************
************************************************************************************************************************










************************************************************************************************************************
* ---------------------------------------------- PICK BEST SERIES FOR RER ----------------------------------------------
************************************************************************************************************************

* nominal exchange rates against USD and EURO
qui gen nex_usd_eop   	= ln(ifs_xrate_usd_eop)						/* nominal exchange rate - end of period  */
qui gen nex_euro_eop  	= ln(ifs_xrate_euro_eop)					/* nominal exchange rate - end of period  */
qui gen nex_usd   		= ln(ifs_xrate_usd)							/* nominal exchange rate - period average */
qui gen nex_euro  		= ln(ifs_xrate_euro)						/* nominal exchange rate - period average */

* RER vs. USA 
qui gen ydefl_usa = ydefl if ISO == "USA"
by date, sort: egen ydeflusa = max(ydefl_usa)
qui gen rer_usa = exp(ydefl - ydeflusa) / ifs_xrate_usd
qui drop ydefl_usa 

* CRITERIA
* 1) at least 15 years and no gaps
* 2) ORDER OF PREFERENCE
* 	a) IFS reer based on cpi
* 	b) IFS reer based on ulc
*   c) rer against USA
* otherwise drop the country

* pre-generate new variable
qui gen new_variable = .
qui gen mis_variable = 1
qui gen variable_used = "none"
qui gen max_t_0 = 0

* define a generic varlist
*ifs_reer_ulc 
local varlista = "ifs_reer_cpi rer_usa"

* first decide which variable to use
foreach var of varlist `varlista' {

	* calculate how many non-missing values we have
	bysort ISO (date): egen max_t = count(`var')

	* identify gaps in time series for each variable, for each country
	tsspell `var' , c(`var' ~= .)
	bysort ISO (date): egen maxspell = max(_spell)	

	qui replace new_variable  = `var' 	if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace variable_used = "`var'" if max_t>tmin 		& maxspell <= 1 & mis_variable == 1	
	qui replace mis_variable  = 0 		if max_t>tmin 		& maxspell <= 1	

	qui replace max_t_0 = max_t if max_t > max_t_0
	qui drop max_t maxspell _seq _spell _end
}

gen rex = ln(new_variable)
gen rex_used = variable_used
drop new_variable mis_variable variable_used max_t_0 

************************************************************************************************************************
************************************************************************************************************************







************************************************************************************************************************
* ---------------------------------------------- GENERATE OTHER VARIABLES ----------------------------------------------
************************************************************************************************************************

* nominal GDP in USD
qui gen ynom			= exp(y_nom) / ifs_xrate_usd

* x-rate regime ( 1 = fixed;  0 = flexible )
xtset id date, q
qui gen xrate_regime = 0
qui replace xrate_regime = 1 if ( abs(nex_euro_eop - nex_euro) < 0.01 | abs(l.nex_euro_eop - nex_euro) < 0.01 ) & nex_euro ~= .
qui replace xrate_regime = 1 if ( abs(nex_usd_eop  - nex_usd ) < 0.01 | abs(l.nex_usd_eop  - nex_usd ) < 0.01 ) & nex_usd  ~= .
qui replace xrate_regime = 0 if ISO == "USA"

* inflation
qui gen inflation = ydefl - l.ydefl

* real interest rates
qui replace irate  = irate - 														   f.inflation
*qui replace irate = irate - ( 				 				 l.inflation + inflation + f.inflation ) / 3
*qui replace irate = irate - ( l3.inflation + l2.inflation + l.inflation + inflation			   ) / 4



************************************************************************************************************************
************************************************************************************************************************



local AGvars = "gdp_ag con_ag inv_ag nxy_ag irate_ag"
keep ISO IFScode date debt_gdp NGama-s_1 rex rex_used rer_usa ynom xrate_regime Country `AGvars'
order ISO Country IFScode IMF_class id date NN NGama Gama debt_gdp 


qui replace irate_used = "none" if ydefl_used == "none"


qui gen rusa = irate if ISO == "USA"
qui gen gdpusa = gdp if ISO == "USA"
qui gen conusa = con if ISO == "USA"
by date, sort: egen gdp_usa = mode(gdpusa)
by date, sort: egen con_usa = mode(conusa)
by date, sort: egen r_usa   = mode(rusa)
qui gen relc = con - con_usa
qui gen rely = gdp - gdp_usa

xtset id date, q

if AGsample == 1 {
local varlista  = "gdp con nxy inv irate"
foreach var of varlist `varlista' {
qui replace `var'      =  `var'_ag  
qui replace `var'_used = "`var'_ag"  
}
replace irate = 0 if ISO == "TUR"  /*  no interest rate data  */
replace irate = 0 if ISO == "PER"  /*  no interest rate data  */
}
*




qui replace rer_usa = ln(rer_usa)
local varlista  = "gdp con nxy iratio inv irate rely relc rex rer_usa"



* change variables if just looking at AG sample
* ------------------------------------------------------
if AGsample == 1 {
local varlista  = "gdp con nxy inv irate rex"
}
* ------------------------------------------------------





* ___________________ generate trends, identify gaps, find initial/final observation, drop countries ___________________
egen cgroup = group(id)
su cgroup, meanonly
foreach var of varlist `varlista' {
			
			* trend and quadratic trend for each variable, for each country
			gen `var'_t = .
			bysort cgroup (date) : replace `var'_t =cond((!missing(`var') & missing(`var'[_n-1])), 1, `var'_t[_n-1] + 1,.) 
			replace `var'_t = . if `var'==.
			gen `var'_t2 = `var'_t^2
			egen max_t`var' = max(`var'_t), by(cgroup) 	
			replace max_t`var' = 0 if max_t`var' == .
			gen s`var'=0
			replace s`var' = 1 if max_t`var'>tmin 			
			
			* identify gaps in time series for each variable, for each country
			tsspell `var' , c(`var' ~= .)
			gen `var'_seq = _seq
			gen `var'_spell = _spell
			gen `var'_end = _end
			drop _seq _spell _end			
			bysort cgroup (date): egen `var'_maxspell = max(`var'_spell)			
			
			* initial and final observation for each variable			
			gen `var'_t0 = .
			gen `var'_tT = .			
			bysort cgroup (date): replace `var'_t0 = cond((!missing(`var') & missing(`var'[_n-1])), date, . ,.) 
			bysort cgroup (date): replace `var'_tT = cond((!missing(`var') & missing(`var'[_n+1])), date, . ,.) 			
			egen t0_`var' = max(`var'_t0), by(cgroup)
			egen tT_`var' = max(`var'_tT), by(cgroup)
			drop `var'_t0 `var'_tT
			*gen max_t`var' = tT_`var' - t0_`var' + 1			
			
			* drop countries with gaps and/or insufficient number of observations
			drop if `var'_maxspell > 1  
			drop if max_t`var' < tmin	
						
}

drop cgroup
* -------------------------------------------------------------------------------------------------------------------- *





* __________ generate filtered series:    hp     OR     y-to-y     OR     quad trend residuals    ____________ *
xtset id date, q
foreach var of varlist `varlista' {									
				
	if filtertype == 1 {							/*  hp	*/			
		qui tsfilter hp `var'_filt = `var'			
	}	
	
	else if filtertype == 2 {						/*  y-to-y diff	*/
		qui gen `var'_filt = `var' - l4.`var'		
	}
	
	else {											/*  residual from quadratic trend	*/	
		qui gen `var'_filt = .
		egen cgroup = group(id)
		su cgroup, meanonly
		forvalues i = 1/`r(max)' {
			qui reg `var' `var'_t `var'_t2 if (cgroup == `i')
			qui predict ttemp2 if (cgroup == `i'), residuals
			qui replace `var'_filt = ttemp2 if (cgroup == `i')  	
			drop ttemp2
		}
		drop cgroup		
		drop `var'_t `var'_t2
	}			
}		

* -------------------------------------------------------------------------------------------------------------------- *




* ______________________ compute standard deviations /pre-define xcorrs ______________________ *
foreach var1 of varlist `varlista' {

	* averages
	qui bysort ISO: egen `var1'_mean = mean(`var1')
	
	

	* standard deviations
	qui bysort ISO (date): egen sd_`var1' = sd(`var1'_filt)	
	qui replace	sd_`var1' = 100*sd_`var1' 

	* cross-correlation matrices
	foreach var2 of varlist `varlista' {		
		foreach num of numlist 1/9 {	
		capture confirm variable xc_`var2'_`var1'_`num'
					if !_rc {
					di in red "variable exists"
					}
					else{
					qui gen xc_`var1'_`var2'_`num' = .							
					
					}
					
		}		
	}	
}
								
* -------------------------------------------------------------------------------------------------------------------- *


* ______________________________ compute cross-correlations for each country_____________________________
qui levelsof ISO, local(issos)
xtset id date, q
foreach isso of local issos {
	foreach var1 of varlist `varlista'  {										
			foreach var2 of varlist `varlista' {

			
				qui xcorr `var1'_filt `var2'_filt if ISO == "`isso'", generate(xc_temp) table lags(4)	
				foreach num of numlist 1/9 {
						capture confirm variable xc_`var1'_`var2'_`num'
					if !_rc {
					qui replace xc_`var1'_`var2'_`num' = xc_temp[`num'] if ISO == "`isso'"
					}
				}
				qui drop xc_temp			

			}
	}
}	
* -------------------------------------------------------------------------------------------------------------------- *





xtset id date, q

qui gen s2 = 0.88
qui rename s_1 s1

qui gen yusa = ynom if ISO == "USA"
bysort date: egen y_usa = max(yusa)
qui gen y_vs_usa = (y_usa/ynom)





qui order ISO Country IFScode IMF_class NGama NN Gama debt_gdp y_vs_usa `varlista' *_used sd_* xc_* t0* tT* 



qui drop if ISO == "ROM" 	/* huge RER outlier */
qui drop if ISO == "BOL" 	/* huge RER outlier */
qui drop if IMF_class == -1


bysort ISO: egen country = mode(Country)




* _____________________________ collapse the dataset ________________________________________ *
qui collapse r_lend_covered r_mmkt_covered IFScode xrate_regime (mean) IMF_class NGama NN Gama debt_gdp y_vs_usa `varlista'  sd_* xc_* t0* tT* s1 s2, by(ISO country *_used)
qui format t0* tT*  %tq
* ------------------------------------------------------------------------------------------- *
		
		
qui gen irates_used = "none"
qui replace irates_used = "lend, mmkt" if r_lend_covered == 1 & r_mmkt_covered == 1
qui replace irates_used = "lend" if r_lend_covered == 1 & r_mmkt_covered == 0
qui replace irates_used = "mmkt" if r_lend_covered == 0 & r_mmkt_covered == 1
qui drop r_lend_covered r_mmkt_covered 

								
								
* ___________________ compute relative sdevs and group averages and medians __________________ *

foreach var of varlist `varlista' {
	qui gen relsd_`var' = sd_`var' / sd_gdp	
}
qui replace relsd_gdp = sd_gdp 


foreach var of varlist `varlista' {
	qui bysort IMF_class: egen relsd_`var'_mean = mean(relsd_`var')
	qui bysort IMF_class: egen relsd_`var'_median = median(relsd_`var')
	drop sd_`var'
}

* ------------------------------------------------------------------------------------------- *






* ________________ compute group averages and medians for cross-correlations __________________ *

foreach var1 of varlist `varlista' {
	foreach var2 of varlist `varlista' {
		foreach num of numlist 1 / 9 {
			capture confirm variable xc_`var1'_`var2'_`num'
			if !_rc {
			qui bysort IMF_class: egen xc_`var1'_`var2'_`num'_mean = mean(xc_`var1'_`var2'_`num')
			qui bysort IMF_class: egen xc_`var1'_`var2'_`num'_median = median(xc_`var1'_`var2'_`num')			
			}
		}
	}
}
* ------------------------------------------------------------------------------------------- *






qui drop if IMF_class == 2 & ISO ~= "USA"



*
if AGsample == 0 {

		if filtertype == 1 {	
			qui save $main_path\ier2018_results_hp.dta, replace	
			}
		else if filtertype == 2 {		
			qui save $main_path\ier2018_results_diff.dta, replace
			}
		else {
			qui save $main_path\ier2018_results_quad.dta, replace
			}
}

if AGsample == 1 {
	qui save $main_path\ier2018_results_hp_AG.dta, replace	
	}	
*

* make sure the path is correct
cd $main_path\do-files
run ier_maketablesgraphs.do
