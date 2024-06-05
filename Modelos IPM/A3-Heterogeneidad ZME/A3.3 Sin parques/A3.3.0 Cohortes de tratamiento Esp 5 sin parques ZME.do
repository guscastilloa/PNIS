/*
AUTOR: 
	Gustavo Castillo
	
FECHA:
	27/sept/2023

DESCRIPCIÓN:
	En este script se realiza la revisión de cohortes de tratamiento
	de los modelos IPM revisando la heterogeneidad por ZME al excluir
	de la muestra los beneficiarios en parques ZME para la 
	especificación 5.

*/


// drop if `MODELO'==1 & year_t_AAI_Nada==2022
// drop if `MODELO'==2 & ((year_t_SA_AAI==2021) | ///
// 					   (year_t_SA_AAI==2022))
// drop if `MODELO'==3 & ((year_t_PPCC_AAI==2018) | ///
// 					   (year_t_PPCC_AAI==2019) | ///
// 					   (year_t_PPCC_AAI==2020))
// drop if (`MODELO'==4 | `MODELO'==5 |`MODELO'==6)  & ///
// 	((year_t_PPCCySA==2018) | ///
// 	 (year_t_PPCCySA==2019) | ///
// 	 (year_t_PPCCySA==2020))
// drop if `MODELO'==7 & ((year_t_PPCL_PPCCySA==2017) | ///
// 					   (year_t_PPCL_PPCCySA==2018) | ///
// 					   (year_t_PPCL_PPCCySA==2019) | ///
// 					   (year_t_PPCL_PPCCySA==2020))

log using "${projectfolder}/Log/Heterogeneidad ZME sin parques Esp. 5 revision cohortes", replace


use "${datafolder}/base_estimaciones_simci.dta", clear
tab zona_zme
drop if zona_zme ==1


*-----------------------------------------------
* ZME == 0
*-----------------------------------------------
keep if zme==0					   
// * Modelo 1: AAI vs Nada 
// preserve
// 	drop if year_t_AAI_Nada==2022
// 	tab year_t_AAI_Nada ejecucion_PNIS if ///
// 		ejecucion_PNIS==0 | ejecucion_PNIS==1
// restore
	
* Modelo 2: SA vs AAI
preserve
	drop if ((year_t_SA_AAI==2021) | (year_t_SA_AAI==2022))
	tab year_t_SA_AAI ejecucion_PNIS if ///
		ejecucion_PNIS==1 | ejecucion_PNIS==2
restore

// * Modelo 3: PPCC vs AAI
// preserve
// 	drop if ((year_t_PPCC_AAI==2018) | ///
// 			(year_t_PPCC_AAI==2019) | ///
// 			(year_t_PPCC_AAI==2020))
// 	tab year_t_PPCC_AAI ejecucion_PNIS if ///
// 		ejecucion_PNIS==1 | ejecucion_PNIS==3
// restore	
//
// * Modelo 4: PPCC&SA vs AAI
// preserve
// 	drop if ((year_t_PPCCySA==2018) | ///
// 			(year_t_PPCCySA==2019) | ///
// 			(year_t_PPCCySA==2020))
// 	tab year_t_PPCCySA ejecucion_PNIS if ///
// 		ejecucion_PNIS==1 | ejecucion_PNIS==4
// restore
//
// * Modelo 5: PPCC&SA vs SA
// preserve
// 	drop if ((year_t_PPCCySA==2018) | ///
// 			(year_t_PPCCySA==2019) | ///
// 			(year_t_PPCCySA==2020))
// 	tab year_t_PPCCySA ejecucion_PNIS if ///
// 		ejecucion_PNIS==2 | ejecucion_PNIS==4
// restore
//
// * Modelo 6: PPCC&SA vs PPCC
// preserve
// 	drop if ((year_t_PPCCySA==2018) | ///
// 			(year_t_PPCCySA==2019) | ///
// 			(year_t_PPCCySA==2020))
// 	tab year_t_PPCCySA ejecucion_PNIS if ///
// 		ejecucion_PNIS==3 | ejecucion_PNIS==4
// restore
//
// * Modelo 7: PPCL vs PPCC&SA	
// preserve
// 	drop if ((year_t_PPCL_PPCCySA==2017) | ///
// 			(year_t_PPCL_PPCCySA==2018) | ///
// 			(year_t_PPCL_PPCCySA==2019) | ///
// 			(year_t_PPCL_PPCCySA==2020))
// 	tab year_t_PPCL_PPCCySA ejecucion_PNIS if ///
// 		ejecucion_PNIS==4 | ejecucion_PNIS==5
// restore

use "${datafolder}/base_estimaciones_simci.dta", clear
drop if zona_zme ==1
*-----------------------------------------------
* ZME == 1
*-----------------------------------------------
keep if zme==1	

// * Modelo 1: AAI vs Nada 
// preserve
// 	drop if year_t_AAI_Nada==2022
// 	tab year_t_AAI_Nada ejecucion_PNIS ///
// 		if ejecucion_PNIS==0 | ejecucion_PNIS==1
// restore
	
* Modelo 2: SA vs AAI
preserve
	drop if ((year_t_SA_AAI==2021) | (year_t_SA_AAI==2022))
	tab year_t_SA_AAI ejecucion_PNIS if ///
		ejecucion_PNIS==1 | ejecucion_PNIS==2
restore

// * Modelo 3: PPCC vs AAI
// preserve
// 	drop if ((year_t_PPCC_AAI==2018) | ///
// 			(year_t_PPCC_AAI==2019) | ///
// 			(year_t_PPCC_AAI==2020))
// 	tab year_t_PPCC_AAI ejecucion_PNIS if ///
// 		ejecucion_PNIS==1 | ejecucion_PNIS==3
// restore	
//
// * Modelo 4: PPCC&SA vs AAI
// preserve
// 	drop if ((year_t_PPCCySA==2018) | ///
// 			(year_t_PPCCySA==2019) | ///
// 			(year_t_PPCCySA==2020))
// 	tab year_t_PPCCySA ejecucion_PNIS if ///
// 		ejecucion_PNIS==1 | ejecucion_PNIS==4
// restore
//
// * Modelo 5: PPCC&SA vs SA
// preserve
// 	drop if ((year_t_PPCCySA==2018) | ///
// 			(year_t_PPCCySA==2019) | ///
// 			(year_t_PPCCySA==2020))
// 	tab year_t_PPCCySA ejecucion_PNIS if ///
// 		ejecucion_PNIS==2 | ejecucion_PNIS==4
// restore
//
// * Modelo 6: PPCC&SA vs PPCC
// preserve
// 	drop if ((year_t_PPCCySA==2018) | ///
// 			(year_t_PPCCySA==2019) | ///
// 			(year_t_PPCCySA==2020))
// 	tab year_t_PPCCySA ejecucion_PNIS if ///
// 		ejecucion_PNIS==3 | ejecucion_PNIS==4
// restore
//
// * Modelo 7: PPCL vs PPCC&SA	
// preserve
// 	drop if ((year_t_PPCL_PPCCySA==2017) | ///
// 			(year_t_PPCL_PPCCySA==2018) | ///
// 			(year_t_PPCL_PPCCySA==2019) | ///
// 			(year_t_PPCL_PPCCySA==2020))
// 	tab year_t_PPCL_PPCCySA ejecucion_PNIS if ///
// 		ejecucion_PNIS==4 | ejecucion_PNIS==5
// restore

capture log close
