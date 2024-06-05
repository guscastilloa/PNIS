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
	6/oct/2023
	
DESCRIPCIÓN.
	En este script se realizan las estimaciones de los modelos 3' y 4' de IPM
	para la especificacioón 4 dividiando las muestras sobre las que se 
	estima por el sexo del CUB.
	
	Deben resultar 8 archivos de estimaciones.
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
log using "${projectfolder}/Log/A4-Especificacion4-sexo-PP.smcl", replace

global output_path "${output}/Modelos IPM/_heterogeneidad sexo/estimaciones" 
global n_esp 4
global ESP "esp${n_esp}"
use "${datafolder}/base_estimaciones_pp.dta", clear


*-------------------------------------------------------------------------------
**# Estimar modelos 3' y 4' para hombres
*-------------------------------------------------------------------------------
global S=0
global SEX = "sexo${S}"
preserve
* Mantener solo observaciones para hombres (0)
	keep if sexo_titular ==${S}


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
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-${SEX}-PP"
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
		di "No hay suficientes observaciones
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
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-${SEXO}-PP"
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
**# Estimar modelos 3' y 4' para mujeres
*-------------------------------------------------------------------------------
global S=1
global SEX = "sexo${S}"
preserve
* Mantener solo observaciones para mujeres (1)
	keep if sexo_titular ==${S}


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
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-${SEXO}-PP"
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
		di "No hay suficientes observaciones
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
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-${SEXO}-PP"
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
		
capture log close
