// ███████████████████████████
// ███████▀▀▀░░░░░░░▀▀▀███████
// ████▀░░░░░░░░░░░░░░░░░▀████
// ███│░░░░░░░░░░░░░░░░░░░│███
// ██▌│░░░░░░░░░░░░░░░░░░░│▐██
// ██░└┐░░░░░░░░░░░░░░░░░┌┘░██
// ██░░└┐░░░░░░░░░░░░░░░┌┘░░██
// ██░░┌┘▄▄▄▄▄░░░░░▄▄▄▄▄└┐░░██
// ██▌░│██████▌░░░▐██████│░▐██
// ███░│▐███▀▀░░▄░░▀▀███▌│░███
// ██▀─┘░░░░░░░▐█▌░░░░░░░└─▀██
// ██▄░░░▄▄▄▓░░▀█▀░░▓▄▄▄░░░▄██
// ████▄─┘██▌░░░░░░░▐██└─▄████
// █████░░▐█─┬┬┬┬┬┬┬─█▌░░█████
// ████▌░░░▀┬┼┼┼┼┼┼┼┬▀░░░▐████
// █████▄░░░└┴┴┴┴┴┴┴┘░░░▄█████
// ███████▄░░░░░░░░░░░▄███████
// ██████████▄▄▄▄▄▄▄██████████
// ███████████████████████████
/*
AUTOR:
	Gustavo Castillo

FECHA:
	7/oct/2023
	
DESCRIPCIÓN.
	En este script se realizan las estimaciones del modelo 4 par la especificación
	4 dividiando las muestras sobre las que se estima en aquellos CUBs 
	en zonas de manejo especial (ZME) y en aquellos que no estan en una ZME. 
	
	En este ejercicio agrupamos los proyectos productivos en la ejecución PP.
*/

//   ______                 _  _   
//  |  ____|               | || |  
//  | |__    ___  _ __     | || |_ 
//  |  __|  / __|| '_ \    |__   _|
//  | |____ \__ \| |_) |_     | |  
//  |______||___/| .__/(_)    |_|  
//               | |               
//               |_|               

* With trend
* Cluster por municipio


* Preámbulo después de correr _master.do
capture log close
log using "${projectfolder}/Log/A3-Especificacion4-ZMEtoda-PP.smcl", replace

global output_path "${output}/Modelos IPM/_heterogeneidad zme/estimaciones" 

global n_esp 4
global ESP "esp${n_esp}"
use "${datafolder}/base_estimaciones_simci_pp.dta", clear


*-------------------------------------------------------------------------------
**# Estimar modelos 3' y 4' para beneficiarios en municipios no-ZME (0)
*-------------------------------------------------------------------------------
global Z=0
global ZME = "zme${Z}"
preserve
* Mantener solo observaciones para beneficiarios en no-ZME (0)
	keep if zme ==${Z}
	
*************************************
* Modelo 3: PP vs AAI
*************************************

	global n_modelo 3
	global modelo "model${n_modelo}"
	
	* Revisar cohortes de tratamiento 
	qui tab year_t_PP_AAI if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3
	if r(r)>1{
		* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-${ZME}-PP"
			di "$estimate_file_name"
			
			csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 3, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PP_AAI)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	}
	else{
		di "No hay suficientes observaciones" 
		tab year_t_PP_AAI if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3
	}
	

	

*************************************
* Modelo 4: PP&SA vs AAI
*************************************	
	tab year ejecucion_PNIS_prima
	global n_modelo 4
	global modelo "model${n_modelo}"
	qui tab year_t_PPySA if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4
	if r(r)>1{
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-${ZME}-PP"
			di "$estimate_file_name"
			csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 4, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPySA)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	}
	else{
		di "No hay suficientes observaciones"
		tab year_t_PPySA if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4
	}

restore		
	
	

	
	
*-------------------------------------------------------------------------------
**# Estimar modelos 3' y 4' para beneficiarios en municipios ZME (1)
*-------------------------------------------------------------------------------
global Z=1
global ZME = "zme${Z}"
preserve
* Mantener solo observaciones para beneficiarios en no-ZME (1)
	keep if zme ==${Z}
	
	


*************************************
* Modelo 3: PP vs AAI
*************************************

	global n_modelo 3
	global modelo "model${n_modelo}"
	
	* Revisar cohortes de tratamiento 
	qui tab year_t_PP_AAI if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3
	if r(r)>1{
		* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-${ZME}-PP"
			di "$estimate_file_name"
			csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 3, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PP_AAI)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	}
	else{
		di "No hay suficientes observaciones"
		tab year_t_PP_AAI if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3
	}
	

	

*************************************
* Modelo 4: PP&SA vs AAI
*************************************	
	tab year ejecucion_PNIS_prima
	global n_modelo 4
	global modelo "model${n_modelo}"
	qui tab year_t_PPySA if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4
	if r(r)>1{
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-${ZME}-PP"
			di "$estimate_file_name"
			csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 4, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPySA)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	}
	else{
		di "No hay suficientes observaciones"
		tab year_t_PPySA if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4
	}

restore	
