/*
AUTOR:
	Gustavo Castillo

DESCRIPCIÓN.
	En este script se realizan las estimaciones del modelo 4 par las especificaciones
	4 y 5 dividiando las muestras sobre las que se estima en aquellos CUBs 
	en zonas de manejo especial (ZME) y en aquellos que no estan en una ZME. 
*/

//   ______                 _____ 
//  |  ____|               | ____|
//  | |__    ___  _ __     | |__  
//  |  __|  / __|| '_ \    |___ \ 
//  | |____ \__ \| |_) |_   ___) |
//  |______||___/| .__/(_) |____/ 
//               | |              
//               |_|              

* With trend
* Cluster por municipio
* Truncando los años con menos del 3-4% de observaciones

* Preámbulo después de correr _master.do
log using "${projectfolder}/Log/A3.3.1-Especificacion5-sin_parquesZ0.smcl", replace
global output_path "${output}/Estimación_modelos/estimaciones/_heterogeneidad zme"
global n_esp 5
global especificacion "esp${n_esp}"

use "${datafolder}/base_estimaciones_simci.dta", clear
tab zme	zona_zme

* Eliminar parques y observaciones que no pegaron del merge base simci con panel.
drop if zona_zme ==1
keep if u2==3

* Preparar submuestra Especificación 5 Modelo 2
	global n_modelo 2
	global modelo "model${n_modelo}"
	drop if ((year_t_SA_AAI==2021) | year_t_SA_AAI==2022)
	qui tab year_t_SA_AAI if ejecucion_PNIS==1 | ejecucion_PNIS==2

* Revisar que panel esté balanceado
capture drop meanzme
bysort cub: egen meanzme = mean(zona_zme)
tab meanzme, miss // No hay ningún número decimal, todos son enteros. Quedó balanceado.	

*------------------------------------------------------------------------------
**# Estimar modelo 2 especificación 5 excluyendo parques, ZME==0
*------------------------------------------------------------------------------
keep if zme==0

	
* Con outliers + + + + + + + + + + + + + + + + + + + + 
forvalues ipm=1/2{
	global tipm="IPM `ipm'"
	di "> IPM `ipm'"
	
	global estimate_file_name "esp5-model2-${tipm}-con_outliers-Z0-sin_parques"
	
	csdid IPM_`ipm' if ///
		ejecucion_PNIS == 1 | ///
		ejecucion_PNIS == 2, ///
		cluster(cod_mpio) ivar(cub) time(year) ///
		gvar(year_t_SA_AAI)
	estimates save "${output_path}/${estimate_file_name}.ster", replace
	}	

* SIN outliers + + + + + + + + + + + + + + + + + + + + 
forvalues ipm=1/2{
	global tipm="IPM `ipm'"
	di "> IPM `ipm'"
	
	global estimate_file_name "esp5-model2-${tipm}-sin_outliers-Z0-sin_parques"
	
	preserve
	drop if es_outlier_IPM_1==1 & `ipm'==1
	drop if es_outlier_IPM_2==1 & `ipm'==2
	csdid IPM_`ipm' if ///
		ejecucion_PNIS == 1 | ///
		ejecucion_PNIS == 2, ///
		cluster(cod_mpio) ivar(cub) time(year) ///
		gvar(year_t_SA_AAI)
	estimates save "${output_path}/${estimate_file_name}.ster", replace
	restore
	}	
*------------------------------------------------------------------------------
**# Estimar modelo 2 especificación 5 excluyendo parques, ZME==1
*------------------------------------------------------------------------------
// keep if zme==1
// * Con outliers + + + + + + + + + + + + + + + + + + + + 
// forvalues ipm=1/2{
// 	global tipm="IPM `ipm'"
// 	di "> IPM `ipm'"
//	
// 	global estimate_file_name "esp5-model2-${tipm}-con_outliers-Z1-sin_parques"
//	
// 	csdid IPM_`ipm' if ///
// 		ejecucion_PNIS == 1 | ///
// 		ejecucion_PNIS == 2, ///
// 		cluster(cod_mpio) ivar(cub) time(year) ///
// 		gvar(year_t_SA_AAI)
// 	estimates save "${output_path}/${estimate_file_name}.ster", replace
// 	}	
//
// * SIN outliers + + + + + + + + + + + + + + + + + + + + 
// forvalues ipm=1/2{
// 	global tipm="IPM `ipm'"
// 	di "> IPM `ipm'"
//	
// 	global estimate_file_name "esp5-model2-${tipm}-sin_outliers-Z1-sin_parques"
//	
// 	preserve
// 	drop if es_outlier_IPM_1==1 & `ipm'==1
// 	drop if es_outlier_IPM_2==1 & `ipm'==2
// 	csdid IPM_`ipm' if ///
// 		ejecucion_PNIS == 1 | ///
// 		ejecucion_PNIS == 2, ///
// 		cluster(cod_mpio) ivar(cub) time(year) ///
// 		gvar(year_t_SA_AAI)
// 	estimates save "${output_path}/${estimate_file_name}.ster", replace
// 	restore
// 	}	


capture log close
