clear all
set more off

*local main_path "C:\Users\R2D2\Dropbox\work\research\"
local main_path "C:\Users\rothert\Dropbox\work\research\"


qui cd `main_path'
qui cd data\IMF\ifs

/*
import delimited IFS_data.csv

qui drop  q1-q4
qui drop v298-v307
qui drop v10-v149

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
qui keep if attribute == "Value"

/*

qui keep if 							///
indicatorcode == "FITB_PA" || 			///
indicatorcode == "FIGB_PA" || 			///
indicatorcode == "NINV_SA_XDC" || 		///
indicatorcode == "NFI_SA_XDC" || 		///
indicatorcode == "NGDP_SA_XDC" || 		///
indicatorcode == "NGDP_R_SA_XDC" || 	///
indicatorcode == "NGDP_R_K_SA_XDC" || 	///
indicatorcode == "NCP_SA_XDC" || 		///
indicatorcode == "PXP_IX" || 			///
indicatorcode == "PMP_IX" || 			///
indicatorcode == "EDNA_USD_XDC_RATE" || ///
indicatorcode == "EREER_IX" || 			///
indicatorcode == "PCPI_IX"

	*/	

qui tostring countrycode, replace
qui egen country_indicator = concat(indicatorcode countrycode)
qui destring countrycode, replace

foreach num of numlist 150/297 {
qui rename v`num' yy`num'
}

foreach num of numlist 150 / 297 {
qui destring yy`num', replace
}




reshape long yy, i(country_indicator) j(time)



gen = yy if indicatorcode == "NGDP_XDC"
gen = yy if indicatorcode == "HPL_XDR"
drop yy
destring countrycode, replace

collapse (firstnm) gdp dupa countrycode, by(countryname time)



*/


qui cd `main_path'
qui cd emrers\data



* ----------------------------------------------------------------------------------------
* 							load the BALANCE OF PAYMENTS data
* ----------------------------------------------------------------------------------------
/*
qui cd `main_path'
qui cd data\IMF\bop
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
indicatorcode   == "BMGS_BP6_USD" || 		/// /*	Current Account, Goods and Services, Debit, US Dollars	*/
indicatorcode   == "BXIPCE_BP6_USD" || 		/// /*	Current Account, Primary Income, Compensation of Employees, Credit, US Dollars	*/
indicatorcode   == "BMIPCE_BP6_USD" || /// /*	Current Account, Primary Income, Compensation of Employees, Debit, US Dollars	*/
indicatorcode   == "BXIP_BP6_USD" || /// /*	Current Account, Primary Income, Credit, US Dollars	*/
indicatorcode   == "BMIP_BP6_USD" || /// /*	Current Account, Primary Income, Debit, US Dollars	*/
indicatorcode   == "BXIPI_BP6_USD" || /// /*	Current Account, Primary Income, Investment Income, Credit, US Dollars	*/
indicatorcode   == "BMIPI_BP6_USD" || /// /*	Current Account, Primary Income, Investment Income, Debit, US Dollars	*/
indicatorcode   == "BXIPIP_BP6_USD" || /// /*	Current Account, Primary Income, Investment Income, Portfolio Investment, Credit, US Dollars	*/
indicatorcode   == "BMIPIP_BP6_USD" || /// /*	Current Account, Primary Income, Investment Income, Portfolio Investment, Debit, US Dollars	*/
indicatorcode   == "BXIPID_BP6_USD" || /// /*	Current Account, Primary Income, Investment Income, Direct Investment, Credit, US Dollars	*/
indicatorcode   == "BMIPID_BP6_USD" || /// /*	Current Account, Primary Income, Investment Income, Direct Investment, Debit, US Dollars	*/
indicatorcode   == "BXIS_BP6_USD" || /// /*	Current Account, Secondary Income, Credit, US Dollars	*/
indicatorcode   == "BMIS_BP6_USD" || /// /*	Current Account, Secondary Income, Debit, US Dollars	*/
indicatorcode   == "BXCA_BP6_USD" || /// /*	Current Account, Total, Credit, US Dollars	*/
indicatorcode   == "BMCA_BP6_USD" || /// /*	Current Account, Total, Debit, US Dollars	*/
indicatorcode   == "BOP_BP6_USD" || /// /*	Net Errors and Omissions, US Dollars	*/
indicatorcode   == "BF_BP6_USD" || /// /*	Financial Account, Net Lending (+) / Net Borrowing (-) (Balance from Financial Account), US Dollars	*/
indicatorcode   == "BKT_CD_BP6_USD" || /// /*	Capital Account, Capital Transfers, Credit, US Dollars	*/
indicatorcode   == "BKT_DB_BP6_USD"  /*	Capital Account, Capital Transfers, Debit, US Dollars	*/

qui reshape long yy, i(country_indicator) j(time)

qui replace time = time - 66

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

qui drop yy

qui collapse (firstnm) bop_ca_gs_cr-bop_cap_db countrycode, by(countryname time)

qui gen date = string(time, "%tq")
qui tostring countrycode, replace
qui egen cdate = concat(countrycode date)
qui destring countrycode, replace

qui order countryname countrycode date cdate time

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

qui lab var countrycode "IMF country code"
qui lab var countryname "IMF country name"
qui lab var time "time variable, numeric"
qui lab var date "time variable, string"
qui lab var cdate "country-time string, unique observation identifier"

qui cd `main_path'
qui cd emrers\data
save bop_data.dta, replace
*/


qui cd `main_path'
qui cd data\oecd

import delimited nipa_feb23.csv

drop flagcodes flags frequency v8 			/* drop extraneous variables */

replace value = value *10^powercodecode		/* e.g., replace millions of EUR, with EUR; billions of rupias, with rupias */




/* ________________________ construct a proper Date variable ________________________ */

gen year  = substr(time,1,4)
gen quart = substr(time,7,1)
destring year, replace
destring quart, replace
gen date = (year-1960)*4 + quart - 1

* ----------------------------------------------------------------------------------- *





















