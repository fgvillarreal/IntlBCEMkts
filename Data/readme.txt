Replication files for Section 2: Empirical motivation - RERs in emerging economies
---------------------------------------------------------------------------------------------------------------------------------
1) "ier2018_dataset.dta" - quarterly national accounts, exchange rates, real exchange rates, interest rates data
sources: OECD, IFS, BoP
created from bulk downloads in 2018 using "ier_makedata.do"

2) "ier_makedata.do" - uses bulk downloads from OECD, IFS, BoP to create "ier2018_dataset.dta"

3) "ier_mainfile.do" - do-file for the computation of business cycles statistics for individual countries and group averages

4) "ier_maketablesgraphs.do" - do-file for creating tables and graphs; saves tables with results to "data_results_hp.xlsx"

5) "data_results_hp.xlsx" - Excel file with results

6) "create_cross_correlation_graphs.m" - Matlab file that reads "data_results_hp.xlsx" to create Figure 3 (cross-correlograms)
---------------------------------------------------------------------------------------------------------------------------------
