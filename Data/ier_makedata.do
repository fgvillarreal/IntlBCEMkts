clear all
set more off

*local main_path "C:\Users\R2D2\Dropbox\work\research\"
local main_path "C:\Users\rothert\Dropbox\work\research\"






************************************************************************************************
*										AG DATA 
************************************************************************************************
qui cd `main_path'
qui cd emrers\data



* ------------------------------------------------------------------
foreach num of numlist 1/26 {
clear
import excel AGdata_series.xlsx, sheet("c`num'") firstrow 
generate double date = qofd(time)
qui gen nxy_ag = nx/y
qui gen gdp_ag  = ln(y)
qui gen con_ag  = ln(c)
qui gen inv_ag  = ln(x)
qui gen irate_ag = r
qui gen cnum = `num'
drop if con == .
keep cnum date gdp_ag con_ag nxy_ag inv_ag irate_ag
save c`num'.dta, replace
}
* ------------------------------------------------------------------



* ------------------------------------------------------------------
use c1.dta, clear
foreach num of numlist 2/26 {
append using c`num'.dta
rm c`num'.dta
}
* ------------------------------------------------------------------


* ------------------------------------------------------------------
qui gen ISO = ""
qui replace ISO = 	"ARG"	if cnum == 	1
qui replace ISO = 	"BRA"	if cnum == 	2
qui replace ISO = 	"ECU"	if cnum == 	3
qui replace ISO = 	"ISR"	if cnum == 	4
qui replace ISO = 	"KOR"	if cnum == 	5
qui replace ISO = 	"MYS"	if cnum == 	6
qui replace ISO = 	"MEX"	if cnum == 	7
qui replace ISO = 	"PER"	if cnum == 	8
qui replace ISO = 	"PHL"	if cnum == 	9
qui replace ISO = 	"SVK"	if cnum == 	10
qui replace ISO = 	"ZAF"	if cnum == 	11
qui replace ISO = 	"THA"	if cnum == 	12
qui replace ISO = 	"TUR"	if cnum == 	13
qui replace ISO = 	"AUS"	if cnum == 	14
qui replace ISO = 	"AUT"	if cnum == 	15
qui replace ISO = 	"BEL"	if cnum == 	16
qui replace ISO = 	"CAN"	if cnum == 	17
qui replace ISO = 	"DNK"	if cnum == 	18
qui replace ISO = 	"FIN"	if cnum == 	19
qui replace ISO = 	"NLD"	if cnum == 	20
qui replace ISO = 	"NZL"	if cnum == 	21
qui replace ISO = 	"NOR"	if cnum == 	22
qui replace ISO = 	"PRT"	if cnum == 	23
qui replace ISO = 	"ESP"	if cnum == 	24
qui replace ISO = 	"SWE"	if cnum == 	25
qui replace ISO = 	"CHE"	if cnum == 	26
drop cnum
* ------------------------------------------------------------------


order ISO date


save AG_data.dta, replace
rm c1.dta

************************************************************************************************
************************************************************************************************



/*

************************************************************************************************
*							WORLD BANK (WDI) DATA ON LABOR FORCE
************************************************************************************************
qui cd `main_path'
qui cd data\wdi
import delimited wdi_data.csv, clear
gen ell = labfor * (1-u_ilo/100)
gen Lusa = ell if wbcode == "USA"
by year, sort: egen Nusa = max(Lusa)
gen NN = Nusa / ell
gen Ausa = y_pwk if wbcode == "USA"
by year, sort: egen A_usa = max(Ausa)
gen Gama = A_usa / y_pwk
gen NGama = Gama*NN
collapse NGama NN Gama, by (wbcode)
rename wbcode ISO
replace ISO = "ROM" if ISO == "ROU"
qui cd `main_path'
qui cd emrers\data
qui save wdi_data.dta, replace
************************************************************************************************
************************************************************************************************




************************************************************************************************
* 			LANE & MILESI-FERRETI DATA ON NET FOREIGN ASSET POTISION
************************************************************************************************
qui cd `main_path'
qui cd data\LMF
qui use EWNII.dta, clear
qui gen debt_gdp = - lmf_nfa/ lmf_gdp
qui collapse debt_gdp, by (iso ifscode)
qui rename ifscode IFScode 
qui cd `main_path'
qui cd emrers\data
qui save lmf_debt_data.dta, replace
************************************************************************************************
************************************************************************************************
*/




/*
qui cd `main_path'
qui cd data\IMF\ifs


import delimited IFS_data.csv, clear




qui drop  q1-q4
qui drop v298-v307
qui drop v10-v149

qui keep if attribute == "Value"

qui gen nipa     = strpos(indicatorname, "National Accounts")
qui gen ygdp     = strpos(indicatorname, "Gross Domestic Product")
qui gen cgdp     = strpos(indicatorname, "Household Consumption Expenditure")
qui gen xgdp     = strpos(indicatorname, "Gross Capital Formation")
qui gen irates   = strpos(indicatorname, "Interest Rates")
qui gen xrates   = strpos(indicatorname, "Exchange Rates")
qui gen trade    = strpos(indicatorname, "External Trade")
qui gen prices   = strpos(indicatorname, "Prices")


qui gen keepers = nipa + ygdp + cgdp + xgdp + irates + xrates + trade + prices
qui keep if keepers > 0     



qui tostring countrycode, replace
qui egen country_indicator = concat(indicatorcode countrycode)
qui destring countrycode, replace

foreach num of numlist 150/297 {
qui rename v`num' yy`num'
}

foreach num of numlist 150 / 297 {
qui destring yy`num', replace
}


reshape long yy, i(country_indicator) j(date)
replace date = date - 70

* --------------------------------------------------------------------------------------- *



/* ________________________________ create new variables ______________________________ */

qui gen	ifs_xrate_euro_eop	 		= yy if indicatorcode == "ENEE_XDC_EUR_RATE"		
qui gen	ifs_xrate_usd_eop	 		= yy if indicatorcode == "ENDE_XDC_USD_RATE"		
qui gen	ifs_xrate_euro 				= yy if indicatorcode == "ENEA_XDC_EUR_RATE"
qui gen	ifs_xrate_sdr	 			= yy if indicatorcode == "ENSA_XDC_XDR_RATE"
qui gen	ifs_xrate_usd	 			= yy if indicatorcode == "ENDA_XDC_USD_RATE"
qui gen	ifs_neer_ulc	 			= yy if indicatorcode == "ENEER_ULC_IX"
qui gen	ifs_neer	 				= yy if indicatorcode == "ENEER_IX"
qui gen	ifs_reer_cpi	 			= yy if indicatorcode == "EREER_IX"
qui gen	ifs_reer_ulc	 			= yy if indicatorcode == "EREER_ULC_IX"
qui gen	ifs_equities_eop			= yy if indicatorcode == "FPE_EOP_IX"
qui gen	ifs_equities	 			= yy if indicatorcode == "FPE_IX"
qui gen	ifs_r_fed_borrow			= yy if indicatorcode == "FIBFR_PA"
qui gen	ifs_r_corpo	 				= yy if indicatorcode == "FICPR_PA"
qui gen	ifs_r_deposit	 			= yy if indicatorcode == "FIDR_PA"
qui gen	ifs_r_gyield	 			= yy if indicatorcode == "FIGBY_SM_PA"
qui gen	ifs_r_gbond	 				= yy if indicatorcode == "FIGB_PA"
qui gen	ifs_r_tbill	 				= yy if indicatorcode == "FITB_PA"
qui gen	ifs_r_lend	 				= yy if indicatorcode == "FILR_PA"
qui gen	ifs_r_ffr	 				= yy if indicatorcode == "FPOLM_PA"
qui gen	ifs_r_mmkt	 				= yy if indicatorcode == "FIMM_PA"
qui gen	ifs_r_savrate	 			= yy if indicatorcode == "FISR_PA"
qui gen	ifs_dinvent_nom_sa			= yy if indicatorcode == "NINV_SA_XDC"
qui gen	ifs_gfcf_nom_sa	 			= yy if indicatorcode == "NFI_SA_XDC"
qui gen	ifs_gfcf_nom	 			= yy if indicatorcode == "NFI_XDC"
qui gen	ifs_d1ydefl_sa	 			= yy if indicatorcode == "NGDP_D_PC_PP_SA_PT"
qui gen	ifs_d4ydefl  	 			= yy if indicatorcode == "NGDP_D_PC_CP_A_PT"
qui gen	ifs_ydefl_sa	 			= yy if indicatorcode == "NGDP_D_SA_IX"
qui gen	ifs_d1ynom_sa	 			= yy if indicatorcode == "NGDP_PC_CP_A_SA_PT"
qui gen	ifs_d4ynom_sa	 			= yy if indicatorcode == "NGDP_PC_PP_SA_PT"
qui gen	ifs_d4ynom		 			= yy if indicatorcode == "NGDP_PC_CP_A_PT"
qui gen	ifs_ynom_sa	 				= yy if indicatorcode == "NGDP_SA_XDC"
qui gen	ifs_ynom	 				= yy if indicatorcode == "NGDP_XDC"
qui gen	ifs_d4yreal_sa	 			= yy if indicatorcode == "NGDP_R_PC_CP_A_SA_PT"
qui gen	ifs_d4yreal		 			= yy if indicatorcode == "NGDP_R_PC_CP_A_PT"
qui gen	ifs_d1yreal_sa	 			= yy if indicatorcode == "NGDP_R_PC_PP_SA_PT"
qui gen	ifs_yreal_sa	 			= yy if indicatorcode == "NGDP_R_SA_XDC"
qui gen	ifs_yreal_spliced_sa 		= yy if indicatorcode == "NGDP_R_K_SA_XDC"
qui gen	ifs_yreal_spliced    		= yy if indicatorcode == "NGDP_R_K_XDC"
qui gen	ifs_cpriv_nom_sa			= yy if indicatorcode == "NCP_SA_XDC"
qui gen	ifs_cpriv_nom   			= yy if indicatorcode == "NCP_XDC"
qui gen	ifs_cpriv_np_nom   			= yy if indicatorcode == "NCPHI_XDC"
qui gen	ifs_dK_nom_sa	 			= yy if indicatorcode == "NYFC_SA_XDC"
qui gen	ifs_d4ydefl_sa	 			= yy if indicatorcode == "NGDP_D_PC_CP_A_SA_PT"
qui gen	ifs_yreal_spliced_index_sa	= yy if indicatorcode == "NGDP_R_K_SA_IX"
qui gen	ifs_yreal_spliced_index  	= yy if indicatorcode == "NGDP_R_K_IX"
qui gen	ifs_nfp_nom_sa	 			= yy if indicatorcode == "NYCT_SA_XDC"
qui gen	ifs_gov_nom_sa	 			= yy if indicatorcode == "NCGG_SA_XDC"
qui gen	ifs_imp_nom 	 			= yy if indicatorcode == "NM_XDC"
qui gen	ifs_exp_nom 	 			= yy if indicatorcode == "NX_XDC"
qui gen	ifs_cpi	 					= yy if indicatorcode == "PCPI_IX"
qui gen	ifs_ppi	 					= yy if indicatorcode == "PPPI_IX"
qui gen ifs_nxy = (ifs_exp_nom- ifs_imp_nom) / ifs_ynom

* --------------------------------------------------------------------------------------- *



/* __________________________ collapse to create a proper panel _________________________ */

qui drop yy
qui destring countrycode, replace
qui rename countrycode IFScode
qui collapse (firstnm) ifs_xrate_euro_eop-ifs_nxy IFScode, by(countryname date)

* --------------------------------------------------------------------------------------- *






/* ________________________________ label all variables ______________________________ */

lab var	ifs_xrate_euro_eop			"Exchange Rates, Domestic Currency per Euro, End of Period, Rate"
lab var	ifs_xrate_euro				"Exchange Rates, Domestic Currency per Euro, Period Average, Rate"
lab var	ifs_xrate_sdr				"Exchange Rates, Domestic Currency per SDR, Period Average"
lab var	ifs_xrate_usd_eop			"Exchange Rates, Domestic Currency Per US Dollar, End of Period, Rate"
lab var	ifs_xrate_usd				"Exchange Rates, Domestic Currency Per US Dollar, Period Average, Rate"
lab var	ifs_neer_ulc				"Exchange Rates, Nominal Effective Exchange Rate based on Unit Labor Costs, Index"
lab var	ifs_neer					"Exchange Rates, Nominal Effective Exchange Rate, Index"
lab var	ifs_reer_cpi				"Exchange Rates, Real Effective Exchange Rate based on Consumer Price Index, Index"
lab var	ifs_reer_ulc				"Exchange Rates, Real Effective Exchange Rate based on Unit Labor Costs, Index"
lab var	ifs_equities_eop			"Financial Market Prices, Equities, End of Period, Index"
lab var	ifs_equities				"Financial Market Prices, Equities, Index"
lab var	ifs_r_fed_borrow			"Financial, Interest Rates, Central Bank Borrowing Facility Rate"
lab var	ifs_r_corpo					"Financial, Interest Rates, Corporate Paper Rate"
lab var	ifs_r_deposit				"Financial, Interest Rates, Deposit, Percent per annum"
lab var	ifs_r_gyield				"Financial, Interest Rates, Government Bond Yields, Short- to Medium-Term"
lab var	ifs_r_gbond					"Financial, Interest Rates, Government Securities, Government Bonds, Percent per annum"
lab var	ifs_r_tbill					"Financial, Interest Rates, Government Securities, Treasury Bills, Percent per annum"
lab var	ifs_r_lend					"Financial, Interest Rates, Lending Rate, Percent per annum"
lab var	ifs_r_ffr					"Financial, Interest Rates, Monetary Policy-Related Interest Rate, Percent per annum"
lab var	ifs_r_mmkt					"Financial, Interest Rates, Money Market, Percent per annum"
lab var	ifs_r_savrate				"Financial, Interest Rates, Savings Rate, Percent per annum"
lab var	ifs_dinvent_nom_sa			"Gross Capital Formation, Change in Inventories, Nominal, Seasonally Adjusted, Domestic Currency"
lab var	ifs_gfcf_nom_sa				"Gross Capital Formation, Gross Fixed Capital Formation, Corporations, Households, and Non-profit Institutions Serving Households Nominal, Seasonally Adjusted, Domestic Currency"
lab var	ifs_gfcf_nom				"Gross Capital Formation, Gross Fixed Capital Formation, Corporations, Households, and Non-profit Institutions Serving Households Nominal, Domestic Currency"
lab var	ifs_d1ydefl_sa				"Gross Domestic Product, Deflator, Percentage change, previous period, Seasonally adjusted, Percent"
lab var	ifs_d4ydefl					"Gross Domestic Product, Deflator, Percentage change, previous year, Percent"
lab var	ifs_ydefl_sa				"Gross Domestic Product, Deflator, Seasonally Adjusted, Index"
lab var	ifs_d1ynom_sa				"Gross Domestic Product, Nominal, Percentage change, corresponding period previous year, Seasonally adjusted, Percent"
lab var	ifs_d4ynom_sa				"Gross Domestic Product, Nominal, Percentage change, previous period, Seasonally adjusted, Percent"
lab var	ifs_d4ynom		 			"Gross Domestic Product, Nominal, Percentage change, previous period, Percent"
lab var	ifs_ynom_sa					"Gross Domestic Product, Nominal, Seasonally Adjusted, Domestic Currency"
lab var	ifs_ynom	 				"Gross Domestic Product, Nominal, Domestic Currency"
lab var	ifs_d4yreal_sa				"Gross Domestic Product, Real, Percentage change, corresponding period previous year, Seasonally adjusted, Percent"
lab var	ifs_d4yreal		 			"Gross Domestic Product, Real, Percentage change, corresponding period previous year, Percent"
lab var	ifs_d1yreal_sa				"Gross Domestic Product, Real, Percentage change, previous period, Seasonally adjusted, Percent"
lab var	ifs_yreal_sa				"Gross Domestic Product, Real, Seasonally adjusted, Domestic Currency"
lab var	ifs_yreal_spliced_sa		"Gross Domestic Product, Real, Spliced Historical Series, Seasonally adjusted, Domestic Currency"
lab var	ifs_yreal_spliced    		"Gross Domestic Product, Real, Spliced Historical Series, Domestic Currency"
lab var	ifs_cpriv_nom_sa			"Household Consumption Expenditure, incl. NPISHs, Nominal, Seasonally Adjusted, Domestic Currency"
lab var	ifs_cpriv_nom   			"Household Consumption Expenditure, Nominal, Domestic Currency"
lab var	ifs_cpriv_np_nom   			"Household Consumption Expenditure, incl. NPISHs, Nominal, Domestic Currency"
lab var	ifs_dK_nom_sa				"National Accounts, Expense, Consumption of fixed capital, Nominal, Seasonally Adjusted, Domestic Currency"
lab var	ifs_d4ydefl_sa				"National Accounts, Gross Domestic Product, Deflator, Percentage change, corresponding period previous year, Seasonally adjusted, Percent"
lab var	ifs_yreal_spliced_index_sa	"National Accounts, Gross Domestic Product, Real, Spliced Historical Series, Seasonally adjusted, Index"
lab var	ifs_yreal_spliced_index  	"National Accounts, Gross Domestic Product, Real, Spliced Historical Series, Index"
lab var	ifs_nfp_nom_sa				"National Accounts, Net Current Transfers from Abroad, Nominal, Seasonally Adjusted, Domestic Currency"
lab var	ifs_gov_nom_sa				"National Accounts, Public Final Consumption Expenditure, General Government, Nominal, Seasonally adjusted, Domestic Currency"
lab var	ifs_imp_nom 	 			"National Accounts, Nominal Imports"
lab var	ifs_exp_nom 	 			"National Accounts, Nominal Exports"
lab var	ifs_cpi						"Prices, Consumer Price Index, All items, Index"
lab var	ifs_ppi						"Prices, Producer Price Index, All Commodities, Index"
lab var	ifs_nxy 					"NX / GDP IFS DATA"
* ------------------------------------------------------------------------------------- *



/* ____________________ load mapping between IFS and ISO codes _____________________ */

qui cd `main_path'
qui cd data\CountryCodes
qui joinby IFScode using CountryCodes.dta, unmatched(none)
qui drop IFS_country_name

* ----------------------------------------------------------------------------------- *



/* ____________________ create a unique country-date identifier _____________________ */

qui tostring date, replace
qui egen ISOdate = concat(ISO date)
qui destring date, replace
qui sort ISO date
isid ISOdate
qui order ISOdate IFScode ISO Country date 

* ----------------------------------------------------------------------------------- *

encode ISO, gen(id)
xtset id date, q






************************************************************************************************************************
*							UPDATE THE LINES BELOW TO INCLUDE NOMINAL GDP AND DEFLATOR MEASURES
************************************************************************************************************************

local varlista = "ifs_cpriv_nom ifs_gfcf_nom ifs_ynom ifs_yreal_spliced_index ifs_yreal_spliced"
scalar tmin = 40
foreach var of varlist `varlista' {

qui replace `var' = log(`var')
bysort ISO (date): egen max_t = count(`var')
tsspell `var', c(`var' ~= .)
bysort ISO (date): egen maxspell = max(_spell)	
tssmooth shwinters `var'_sa_gen = `var' if max_t>tmin & maxspell <= 1, iterate(20)
qui drop max_t maxspell _seq _spell _end
qui replace `var' = `var'_sa_gen
qui drop `var'_sa_gen

}
*

bysort ISO (date): egen max_t = count(ifs_nxy)
tsspell ifs_nxy, c(ifs_nxy ~= .)
bysort ISO (date): egen maxspell = max(_spell)	
tssmooth shwinters ifs_nxy_sa_gen = ifs_nxy if max_t>tmin & maxspell <= 1, add iterate(20)
qui drop max_t maxspell _seq _spell _end
qui replace ifs_nxy = ifs_nxy_sa_gen
qui drop ifs_nxy_sa_gen



drop id
qui cd `main_path'
qui cd emrers\data
qui save ifs_data.dta, replace

******************************************************************************************************************************************************
******************************************************************************************************************************************************

*/



/*


*****************************************************************************************************
* ----------------------------- IMF BALANCE OF PAYMENTS DATA ---------------------------------------- * 
*****************************************************************************************************
clear

* change path
qui cd `main_path'
qui cd data\IMF\bop

* import from .csv file
qui import delimited BOP_data.csv


qui drop  q1-q4
qui drop v10-v145
qui drop v294-v296
qui sort indicatorname
qui order indicatorcode indicatorname 
qui keep if attribute == "Value"
qui drop attribute

qui tostring countrycode, replace
qui egen country_indicator = concat(indicatorcode countrycode)
qui destring countrycode, replace

foreach num of numlist 146/293 {
qui rename v`num' yy`num'
}

foreach num of numlist 146 / 293 {
qui destring yy`num', replace
}


* ----------------------------------------------------------------------------------------

qui keep if indicatorcode == "BXGS_BP6_USD" ||  /// /*	Current Account, Goods and Services, Credit, US Dollars	*/ 
indicatorcode   == "BMGS_BP6_USD" || 			/// /*	Current Account, Goods and Services, Debit, US Dollars	*/
indicatorcode   == "BXIPCE_BP6_USD" || 			/// /*	Current Account, Primary Income, Compensation of Employees, Credit, US Dollars	*/
indicatorcode   == "BMIPCE_BP6_USD" || 			/// /*	Current Account, Primary Income, Compensation of Employees, Debit, US Dollars	*/
indicatorcode   == "BXIP_BP6_USD" || 			/// /*	Current Account, Primary Income, Credit, US Dollars	*/
indicatorcode   == "BMIP_BP6_USD" || 			/// /*	Current Account, Primary Income, Debit, US Dollars	*/
indicatorcode   == "BXIPI_BP6_USD" || 			/// /*	Current Account, Primary Income, Investment Income, Credit, US Dollars	*/
indicatorcode   == "BMIPI_BP6_USD" || 			/// /*	Current Account, Primary Income, Investment Income, Debit, US Dollars	*/
indicatorcode   == "BXIPIP_BP6_USD" || 			/// /*	Current Account, Primary Income, Investment Income, Portfolio Investment, Credit, US Dollars	*/
indicatorcode   == "BMIPIP_BP6_USD" || 			/// /*	Current Account, Primary Income, Investment Income, Portfolio Investment, Debit, US Dollars	*/
indicatorcode   == "BXIPID_BP6_USD" || 			/// /*	Current Account, Primary Income, Investment Income, Direct Investment, Credit, US Dollars	*/
indicatorcode   == "BMIPID_BP6_USD" || 			/// /*	Current Account, Primary Income, Investment Income, Direct Investment, Debit, US Dollars	*/
indicatorcode   == "BXIS_BP6_USD" || 			/// /*	Current Account, Secondary Income, Credit, US Dollars	*/
indicatorcode   == "BMIS_BP6_USD" || 			/// /*	Current Account, Secondary Income, Debit, US Dollars	*/
indicatorcode   == "BXCA_BP6_USD" || 			/// /*	Current Account, Total, Credit, US Dollars	*/
indicatorcode   == "BMCA_BP6_USD" || 			/// /*	Current Account, Total, Debit, US Dollars	*/
indicatorcode   == "BOP_BP6_USD" || 			/// /*	Net Errors and Omissions, US Dollars	*/
indicatorcode   == "BF_BP6_USD" || 				/// /*	Financial Account, Net Lending (+) / Net Borrowing (-) (Balance from Financial Account), US Dollars	*/
indicatorcode   == "BKT_CD_BP6_USD" || 			/// /*	Capital Account, Capital Transfers, Credit, US Dollars	*/
indicatorcode   == "BKT_DB_BP6_USD"  				/*	Capital Account, Capital Transfers, Debit, US Dollars	*/

qui reshape long yy, i(country_indicator) j(date)

qui replace date = date - 66

qui gen bop_ca_gs_cr 	 = yy if indicatorcode == "BXGS_BP6_USD"    /*	Current Account, Goods and Services, Credit, US Dollars	*/ 
qui gen bop_ca_gs_db 	 = yy if indicatorcode == "BMGS_BP6_USD"    /*	Current Account, Goods and Services, Debit, US Dollars	*/
qui gen bop_ca_pi_cr 	 = yy if indicatorcode == "BXIP_BP6_USD"    /*	Current Account, Primary Income, Credit, US Dollars	*/
qui gen bop_ca_pi_db 	 = yy if indicatorcode == "BMIP_BP6_USD"    /*	Current Account, Primary Income, Debit, US Dollars	*/
qui gen bop_ca_pi_wg_cr  = yy if indicatorcode == "BXIPCE_BP6_USD"  /*	Current Account, Primary Income, Compensation of Employees, Credit, US Dollars	*/
qui gen bop_ca_pi_wg_db  = yy if indicatorcode == "BMIPCE_BP6_USD"  /*	Current Account, Primary Income, Compensation of Employees, Debit, US Dollars	*/
qui gen bop_ca_pi_inv_cr = yy if indicatorcode == "BXIPI_BP6_USD"   /*	Current Account, Primary Income, Investment Income, Credit, US Dollars	*/
qui gen bop_ca_pi_inv_db = yy if indicatorcode == "BMIPI_BP6_USD"   /*	Current Account, Primary Income, Investment Income, Debit, US Dollars	*/
qui gen bop_ca_pi_prt_cr = yy if indicatorcode == "BXIPIP_BP6_USD"  /*	Current Account, Primary Income, Investment Income, Portfolio Investment, Credit, US Dollars	*/
qui gen bop_ca_pi_prt_db = yy if indicatorcode == "BMIPIP_BP6_USD"  /*	Current Account, Primary Income, Investment Income, Portfolio Investment, Debit, US Dollars	*/
qui gen bop_ca_fdi_cr 	 = yy if indicatorcode == "BXIPID_BP6_USD"  /*	Current Account, Primary Income, Investment Income, Direct Investment, Credit, US Dollars	*/
qui gen bop_ca_fdi_db 	 = yy if indicatorcode == "BMIPID_BP6_USD"  /*	Current Account, Primary Income, Investment Income, Direct Investment, Debit, US Dollars	*/
qui gen bop_ca_si_cr 	 = yy if indicatorcode == "BXIS_BP6_USD"    /*	Current Account, Secondary Income, Credit, US Dollars	*/
qui gen bop_ca_si_db 	 = yy if indicatorcode == "BMIS_BP6_USD"    /*	Current Account, Secondary Income, Debit, US Dollars	*/
qui gen bop_ca_cr   	 = yy if indicatorcode == "BXCA_BP6_USD"    /*	Current Account, Total, Credit, US Dollars	*/
qui gen bop_ca_db   	 = yy if indicatorcode == "BMCA_BP6_USD"    /*	Current Account, Total, Debit, US Dollars	*/
qui gen bop_neo     	 = yy if indicatorcode == "BOP_BP6_USD"     /*	Net Errors and Omissions, US Dollars	*/
qui gen bop_fin_net 	 = yy if indicatorcode == "BF_BP6_USD"      /*	Financial Account, Net Lending (+) / Net Borrowing (-) (Balance from Financial Account), US Dollars	*/
qui gen bop_cap_cr  	 = yy if indicatorcode == "BKT_CD_BP6_USD"  /*	Capital Account, Capital Transfers, Credit, US Dollars	*/
qui gen bop_cap_db  	 = yy if indicatorcode == "BKT_DB_BP6_USD"  /*	Capital Account, Capital Transfers, Debit, US Dollars	*/





/* __________________ collapse the dataset to country-date level ___________________ */

qui drop yy
qui collapse (firstnm) bop_ca_gs_cr-bop_cap_db countrycode, by(countryname date)
qui rename countrycode IFScode

* ----------------------------------------------------------------------------------- *





/* ____________________ load mapping between IFS and ISO codes _____________________ */

qui cd `main_path'
qui cd data\CountryCodes
qui joinby IFScode using CountryCodes.dta, unmatched(none)
qui drop IFS_country_name

* ----------------------------------------------------------------------------------- *





/* ____________________ create a unique country-date identifier _____________________ */

qui tostring date, replace
qui egen ISOdate = concat(ISO date)
qui destring date, replace
qui sort ISO date
isid ISOdate
qui order ISOdate IFScode ISO Country date 

* ----------------------------------------------------------------------------------- *





/* _______________________________________ label the BoP variables _______________________________________________________ */

qui lab var	bop_ca_gs_cr		"Current Account, Goods and Services, Credit, US Dollars"
qui lab var	bop_ca_gs_db		"Current Account, Goods and Services, Debit, US Dollars"
qui lab var	bop_ca_pi_cr		"Current Account, Primary Income, Credit, US Dollars"
qui lab var	bop_ca_pi_db		"Current Account, Primary Income, Debit, US Dollars"
qui lab var	bop_ca_pi_wg_cr		"Current Account, Primary Income, Compensation of Employees, Credit, US Dollars"
qui lab var	bop_ca_pi_wg_db		"Current Account, Primary Income, Compensation of Employees, Debit, US Dollars"
qui lab var	bop_ca_pi_inv_cr	"Current Account, Primary Income, Investment Income, Credit, US Dollars"
qui lab var	bop_ca_pi_inv_db	"Current Account, Primary Income, Investment Income, Debit, US Dollars"
qui lab var	bop_ca_pi_prt_cr	"Current Account, Primary Income, Investment Income, Portfolio Investment, Credit, US Dollars"
qui lab var	bop_ca_pi_prt_db	"Current Account, Primary Income, Investment Income, Portfolio Investment, Debit, US Dollars"
qui lab var	bop_ca_fdi_cr		"Current Account, Primary Income, Investment Income, Direct Investment, Credit, US Dollars"
qui lab var	bop_ca_fdi_db		"Current Account, Primary Income, Investment Income, Direct Investment, Debit, US Dollars"
qui lab var	bop_ca_si_cr		"Current Account, Secondary Income, Credit, US Dollars"
qui lab var	bop_ca_si_db		"Current Account, Secondary Income, Debit, US Dollars"
qui lab var	bop_ca_cr			"Current Account, Total, Credit, US Dollars"
qui lab var	bop_ca_db			"Current Account, Total, Debit, US Dollars"
qui lab var	bop_neo				"Net Errors and Omissions, US Dollars"
qui lab var	bop_fin_net			"Financial Account, Net Lending (+) / Net Borrowing (-) (Balance from Financial Account), US Dollars"
qui lab var	bop_cap_cr			"Capital Account, Capital Transfers, Credit, US Dollars"
qui lab var	bop_cap_db			"Capital Account, Capital Transfers, Debit, US Dollars"

qui lab var IFScode "IMF country code"
qui lab var countryname "IMF country name"
qui lab var date "time variable, numeric"
qui lab var ISOdate "country-time string, unique observation identifier"

* ------------------------------------------------------------------------------------------------------------------------- *







/* ______________ save the temporary BoP data file _________________ */

qui cd `main_path'
qui cd emrers\data
save bop_data.dta, replace

* ------------------------------------------------------------------- *


******************************************************************************************************************************************************
******************************************************************************************************************************************************







*****************************************************************************************************
* -------------------------------------- OECD DATA ------------------------------------------------ * 
*****************************************************************************************************
clear


* change path
qui cd `main_path'
qui cd data\oecd




/* ________________________ import OECD data from .csv file ________________________ */

qui import delimited nipa_feb23.csv
qui drop flagcodes flags frequency v8 			/* drop extraneous variables */
qui replace value = value *10^powercodecode		/* e.g., replace millions of EUR, 
											with EUR; billions of rupias, with rupias */
* ----------------------------------------------------------------------------------- *




/* ________________________ construct a proper Date variable ________________________ */

qui gen year  = substr(time,1,4)
qui gen quart = substr(time,7,1)
qui destring year, replace
qui destring quart, replace
qui gen date = (year-1960)*4 + quart - 1

* ----------------------------------------------------------------------------------- *





/* ________________________ construct new variables ________________________ */
qui egen subject_measure = concat(subject measure)

qui gen	invent_chn_a_sa	 	= value if subject_measure == "P52_P53LNBARSA"
qui gen	ex_chn_a_sa	 		= value if subject_measure == "P6LNBARSA"
qui gen	c_chn_a_sa	 		= value if subject_measure == "P3LNBARSA"
qui gen	gov_chn_a_sa	 	= value if subject_measure == "P3S13LNBARSA"
qui gen	gcf_chn_a_sa	 	= value if subject_measure == "P5LNBARSA"
qui gen	y_chn_a_sa	 		= value if subject_measure == "B1_GELNBARSA"
qui gen	gfcf_chn_a_sa	 	= value if subject_measure == "P51LNBARSA"
qui gen	im_chn_a_sa	 		= value if subject_measure == "P7LNBARSA"	
qui gen	cpriv_chn_a_sa	 	= value if subject_measure == "P31S14_S15LNBARSA"
qui gen	res_chn_a_sa	 	= value if subject_measure == "RB1_GELNBARSA"
qui gen	disc_chn_a_sa	 	= value if subject_measure == "DB1_GELNBARSA"
qui gen	invent_chn_q_sa	 	= value if subject_measure == "P52_P53LNBQRSA"
qui gen	ex_chn_q_sa	 		= value if subject_measure == "P6LNBQRSA"
qui gen	c_chn_q_sa	 		= value if subject_measure == "P3LNBQRSA"
qui gen	gov_chn_q_sa	 	= value if subject_measure == "P3S13LNBQRSA"
qui gen	gcf_chn_q_sa	 	= value if subject_measure == "P5LNBQRSA"
qui gen	y_chn_q_sa	 		= value if subject_measure == "B1_GELNBQRSA"
qui gen	gfcf_chn_q_sa	 	= value if subject_measure == "P51LNBQRSA"
qui gen	im_chn_q_sa	 		= value if subject_measure == "P7LNBQRSA"
qui gen	cpriv_chn_q_sa	 	= value if subject_measure == "P31S14_S15LNBQRSA"
qui gen	res_chn_q_sa	 	= value if subject_measure == "RB1_GELNBQRSA"
qui gen	disc_chn_q_sa	 	= value if subject_measure == "DB1_GELNBQRSA"
qui gen	invent_nom_a	 	= value if subject_measure == "P52_P53CAR"
qui gen	ex_nom_a	 		= value if subject_measure == "P6CAR"
qui gen	c_nom_a	 			= value if subject_measure == "P3CAR"
qui gen	gov_nom_a	 		= value if subject_measure == "P3S13CAR"
qui gen	gcf_nom_a	 		= value if subject_measure == "P5CAR"
qui gen	y_nom_a	 			= value if subject_measure == "B1_GECAR"
qui gen	gfcf_nom_a	 		= value if subject_measure == "P51CAR"
qui gen	im_nom_a	 		= value if subject_measure == "P7CAR"
qui gen	cpriv_nom_a	 		= value if subject_measure == "P31S14_S15CAR"
qui gen	disc_nom_a	 		= value if subject_measure == "DB1_GECAR"
qui gen	invent_nom_a_sa	 	= value if subject_measure == "P52_P53CARSA"
qui gen	ex_nom_a_sa	 		= value if subject_measure == "P6CARSA"
qui gen	c_nom_a_sa	 		= value if subject_measure == "P3CARSA"
qui gen	gov_nom_a_sa	 	= value if subject_measure == "P3S13CARSA"
qui gen	gcf_nom_a_sa	 	= value if subject_measure == "P5CARSA"
qui gen	y_nom_a_sa	 		= value if subject_measure == "B1_GECARSA"
qui gen	gfcf_nom_a_sa	 	= value if subject_measure == "P51CARSA"
qui gen	im_nom_a_sa	 		= value if subject_measure == "P7CARSA"
qui gen	cpriv_nom_a_sa	 	= value if subject_measure == "P31S14_S15CARSA"
qui gen	res_nom_a_sa	 	= value if subject_measure == "RB1_GECARSA"
qui gen	disc_nom_a_sa	 	= value if subject_measure == "DB1_GECARSA"
qui gen	invent_nom_q	 	= value if subject_measure == "P52_P53CQR"
qui gen	ex_nom_q	 		= value if subject_measure == "P6CQR"
qui gen	c_nom_q	 			= value if subject_measure == "P3CQR"
qui gen	gov_nom_q	 		= value if subject_measure == "P3S13CQR"
qui gen	gcf_nom_q	 		= value if subject_measure == "P5CQR"
qui gen	y_nom_q	 			= value if subject_measure == "B1_GECQR"
qui gen	gfcf_nom_q	 		= value if subject_measure == "P51CQR"
qui gen	im_nom_q	 		= value if subject_measure == "P7CQR"
qui gen	cpriv_nom_q	 		= value if subject_measure == "P31S14_S15CQR"
qui gen	disc_nom_q	 		= value if subject_measure == "DB1_GECQR"
qui gen	invent_nom_q_sa	 	= value if subject_measure == "P52_P53CQRSA"
qui gen	ex_nom_q_sa	 		= value if subject_measure == "P6CQRSA"
qui gen	c_nom_q_sa	 		= value if subject_measure == "P3CQRSA"
qui gen	gov_nom_q_sa	 	= value if subject_measure == "P3S13CQRSA"
qui gen	gcf_nom_q_sa	 	= value if subject_measure == "P5CQRSA"
qui gen	y_nom_q_sa	 		= value if subject_measure == "B1_GECQRSA"
qui gen	gfcf_nom_q_sa	 	= value if subject_measure == "P51CQRSA"
qui gen	im_nom_q_sa	 		= value if subject_measure == "P7CQRSA"	
qui gen	cpriv_nom_q_sa	 	= value if subject_measure == "P31S14_S15CQRSA"
qui gen	res_nom_q_sa	 	= value if subject_measure == "RB1_GECQRSA"
qui gen	disc_nom_q_sa	 	= value if subject_measure == "DB1_GECQRSA"
qui gen	ex_vol_a_sa	 		= value if subject_measure == "P6VOBARSA"
qui gen	gov_vol_a_sa	 	= value if subject_measure == "P3S13VOBARSA"
qui gen	y_vol_a_sa	 		= value if subject_measure == "B1_GEVOBARSA"
qui gen	gfcf_vol_a_sa	 	= value if subject_measure == "P51VOBARSA"
qui gen	im_vol_a_sa	 		= value if subject_measure == "P7VOBARSA"
qui gen	cpriv_vol_a_sa	 	= value if subject_measure == "P31S14_S15VOBARSA"
qui gen	res_vol_a_sa	 	= value if subject_measure == "RB1_GEVOBARSA"

* ----------------------------------------------------------------------------------- *






/* _____________________ collapse the dataset by country - date ______________________*/

qui collapse (mean) invent_chn_a_sa-res_vol_a_sa, by(location date)
qui rename location ISO
qui lab var ISO "country code"

* ----------------------------------------------------------------------------------- *





/* ____________________________ label all new variables ____________________________ */

qui lab var	invent_chn_a_sa		"CHNG INVENT, chain local, annual level, sa"
qui lab var	ex_chn_a_sa			"EXP, chain local, annual level, sa"
qui lab var	c_chn_a_sa			"C, chain local, annual level, sa"
qui lab var	gov_chn_a_sa		"GOV, chain local, annual level, sa"
qui lab var	gcf_chn_a_sa		"GCF, chain local, annual level, sa"
qui lab var	y_chn_a_sa			"GDP, chain local, annual level, sa"
qui lab var	gfcf_chn_a_sa		"GFCF, chain local, annual level, sa"
qui lab var	im_chn_a_sa			"IMP, chain local, annual level, sa"
qui lab var	cpriv_chn_a_sa		"C PRIV, chain local, annual level, sa"
qui lab var	res_chn_a_sa		"RESIDUAL, chain local, annual level, sa"
qui lab var	disc_chn_a_sa		"STAT DISCR, chain local, annual level, sa"
qui lab var	invent_chn_q_sa		"CHNG INVENT, chain local, quart level, sa"
qui lab var	ex_chn_q_sa			"EXP, chain local, quart level, sa"
qui lab var	c_chn_q_sa			"C, chain local, quart level, sa"
qui lab var	gov_chn_q_sa		"GOV, chain local, quart level, sa"
qui lab var	gcf_chn_q_sa		"GCF, chain local, quart level, sa"
qui lab var	y_chn_q_sa			"GDP, chain local, quart level, sa"
qui lab var	gfcf_chn_q_sa		"GFCF, chain local, quart level, sa"
qui lab var	im_chn_q_sa			"IMP, chain local, quart level, sa"
qui lab var	cpriv_chn_q_sa		"C PRIV, chain local, quart level, sa"
qui lab var	res_chn_q_sa		"RESIDUAL, chain local, quart level, sa"
qui lab var	disc_chn_q_sa		"STAT DISCR, chain local, quart level, sa"
qui lab var	invent_nom_a		"CHNG INVENT, nominal, annual levels, nsa"
qui lab var	ex_nom_a			"EXP, nominal, annual levels, nsa"
qui lab var	c_nom_a				"C, nominal, annual levels, nsa"
qui lab var	gov_nom_a			"GOV, nominal, annual levels, nsa"
qui lab var	gcf_nom_a			"GCF, nominal, annual levels, nsa"
qui lab var	y_nom_a				"GDP, nominal, annual levels, nsa"
qui lab var	gfcf_nom_a			"GFCF, nominal, annual levels, nsa"
qui lab var	im_nom_a			"IMP, nominal, annual levels, nsa"
qui lab var	cpriv_nom_a			"C PRIV, nominal, annual levels, nsa"
qui lab var	disc_nom_a			"STAT DISCR, nominal, annual levels, nsa"
qui lab var	invent_nom_a_sa		"CHNG INVENT, nominal, annual levels, sa"
qui lab var	ex_nom_a_sa			"EXP, nominal, annual levels, sa"
qui lab var	c_nom_a_sa			"C, nominal, annual levels, sa"
qui lab var	gov_nom_a_sa		"GOV, nominal, annual levels, sa"
qui lab var	gcf_nom_a_sa		"GCF, nominal, annual levels, sa"
qui lab var	y_nom_a_sa			"GDP, nominal, annual levels, sa"
qui lab var	gfcf_nom_a_sa		"GFCF, nominal, annual levels, sa"
qui lab var	im_nom_a_sa			"IMP, nominal, annual levels, sa"
qui lab var	cpriv_nom_a_sa		"C PRIV, nominal, annual levels, sa"
qui lab var	res_nom_a_sa		"RESIDUAL, nominal, annual levels, sa"
qui lab var	disc_nom_a_sa		"STAT DISCR, nominal, annual levels, sa"
qui lab var	invent_nom_q		"CHNG INVENT, nominal, quart levels, nsa"
qui lab var	ex_nom_q			"EXP, nominal, quart levels, nsa"
qui lab var	c_nom_q				"C, nominal, quart levels, nsa"
qui lab var	gov_nom_q			"GOV, nominal, quart levels, nsa"
qui lab var	gcf_nom_q			"GCF, nominal, quart levels, nsa"
qui lab var	y_nom_q				"GDP, nominal, quart levels, nsa"
qui lab var	gfcf_nom_q			"GFCF, nominal, quart levels, nsa"
qui lab var	im_nom_q			"IMP, nominal, quart levels, nsa"
qui lab var	cpriv_nom_q			"C PRIV, nominal, quart levels, nsa"
qui lab var	disc_nom_q			"STAT DISCR, nominal, quart levels, nsa"
qui lab var	invent_nom_q_sa		"CHNG INVENT, nominal, quart levels, sa"
qui lab var	ex_nom_q_sa			"EXP, nominal, quart levels, sa"
qui lab var	c_nom_q_sa			"C, nominal, quart levels, sa"
qui lab var	gov_nom_q_sa		"GOV, nominal, quart levels, sa"
qui lab var	gcf_nom_q_sa		"GCF, nominal, quart levels, sa"
qui lab var	y_nom_q_sa			"GDP, nominal, quart levels, sa"
qui lab var	gfcf_nom_q_sa		"GFCF, nominal, quart levels, sa"
qui lab var	im_nom_q_sa			"IMP, nominal, quart levels, sa"
qui lab var	cpriv_nom_q_sa		"C PRIV, nominal, quart levels, sa"
qui lab var	res_nom_q_sa		"RESIDUAL, nominal, quart levels, sa"
qui lab var	disc_nom_q_sa		"STAT DISCR, nominal, quart levels, sa"
qui lab var	ex_vol_a_sa			"EXP, chain OECD, annual level, sa"
qui lab var	gov_vol_a_sa		"GOV, chain OECD, annual level, sa"
qui lab var	y_vol_a_sa			"GDP, chain OECD, annual level, sa"
qui lab var	gfcf_vol_a_sa		"GFCF, chain OECD, annual level, sa"
qui lab var	im_vol_a_sa			"IMP, chain OECD, annual level, sa"
qui lab var	cpriv_vol_a_sa		"C PRIV, chain OECD, annual level, sa"
qui lab var	res_vol_a_sa		"RESIDUAL, chain OECD, annual level, sa"

* ----------------------------------------------------------------------------------- *





/* _______________________ create country-date unique identifier ____________________ */

tostring date, replace
egen ISOdate = concat(ISO date)
destring date, replace
sort ISOdate
order ISOdate ISO date
isid ISOdate

* ----------------------------------------------------------------------------------- *







/* ____________________________ save oecd.dta temp data file ________________________ */

qui cd `main_path'
qui cd emrers\data
save oecd_data.dta, replace

* ----------------------------------------------------------------------------------- *


******************************************************************************************************************************************************
******************************************************************************************************************************************************


*/









******************************************************************************************************************************************************
* ----------------------------------	C R E A T E   M A I N   Q U A R T E R L Y   D A T A S E T   ------------------------------------------------ *
******************************************************************************************************************************************************
clear
qui cd `main_path'
qui cd emrers\data


* open OECD data
use oecd_data.dta

* merge with AG data
qui merge 1:1 ISO date using AG_data.dta, generate(_mrgeAG)
qui egen temp = concat(ISO date)
qui replace ISOdate = temp if ISOdate == ""
qui drop temp
sort ISO date 

* merge with Balance of Payments data
qui merge 1:1 ISOdate using bop_data.dta

* merge with International Financial Statistics 
qui merge 1:1 ISOdate using ifs_data.dta, generate(_merge2)

* merge with L-MF net foreign asset statistics (debt/gdp ratio)
joinby IFScode using lmf_debt_data.dta, unmatched(both) _merge(_merge3)

* merge WDI NN 
joinby ISO using wdi_data.dta, unmatched(both) _merge(_merge4)




* save the main data file
qui save ier2018_dataset.dta, replace

******************************************************************************************************************************************************
******************************************************************************************************************************************************

