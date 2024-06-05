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
	5 dividiando las muestras sobre las que se estima en aquellos CUBs 
	cuyo nivel de IPM (1 y 2) están por encima (h_IPM_X==1) o por debajo 
	(h_IPM_X==0) de la mediana para el 2015. 
	
	En este ejercicio agrupamos los proyectos productivos en la ejecución PP.
	
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

global output_path "${output}/Modelos IPM/_heterogeneidad vulnerabilidad/estimaciones" 


* Preparar base creando variable que define si el CUB tiene nivel de IPM 1 y 2 
* mayor a la mediana del IPM en el 2015.
global n_esp 5
global ESP "esp${n_esp}"
use "${datafolder}/base_estimaciones_pp.dta", clear

capture drop h_IPM_1 h_IPM_2
forvalues I=1/2{
	sum IPM_`I' if year==2015, d
	di r(p50)
	gen h_IPM_`I' = 1 if IPM_`I' >=r(p50) & year==2015
	bysort cub: ereplace h_IPM_`I'=mean(h_IPM_`I')
	bysort cub: replace h_IPM_`I' = 0 if h_IPM_`I'==.
}

tab year h_IPM_1, miss
tab year h_IPM_2, miss

tempfile completo vulnerabilidad0 vulnerabilidad1
save `completo'

*-------------------------------------------------------------------------------
**# Estimar modelos 3' y 4' para beneficiarios "más pobres": h_IPM_X == 1
*-------------------------------------------------------------------------------

global V=1
global VULN = "vuln${V}"

*************************************
* Modelo 3: PP vs AAI
*************************************
	use `completo'
	global n_modelo 3
	global modelo "model${n_modelo}"
	
	* Revisar cohortes de tratamiento y truncar 2018-2020
	tab year_t_PP_AAI ejecucion_PNIS_prima if year==2017 & ///
		(ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3), cell
	drop if ((year_t_PP_AAI==2018) | (year_t_PP_AAI==2019) | (year_t_PP_AAI==2020))
	
	
	if r(r)>1{
		* IPM 1 - - - - - - - - - - - - - - - - - - - -
		preserve
		keep if h_IPM_1 == 1
		global tipm="IPM 1"
		di "> IPM 1"
		
		global estimate_file_name "${ESP}-${modelo}-${tipm}-${VULN}-PP"
		di "$estimate_file_name"
		
		csdid IPM_1 if ///
			ejecucion_PNIS_prima == 1 | ///
			ejecucion_PNIS_prima == 3, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PP_AAI)
		estimates save "${output_path}/${estimate_file_name}.ster", replace
		restore
		
		* IPM 2 - - - - - - - - - - - - - - - - - - - -
		preserve
		keep if h_IPM_2 == 1
		global tipm="IPM 2"
		di "> IPM 2"
		
		global estimate_file_name "${ESP}-${modelo}-${tipm}-${VULN}-PP"
		di "$estimate_file_name"
		
		csdid IPM_2 if ///
			ejecucion_PNIS_prima == 1 | ///
			ejecucion_PNIS_prima == 3, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PP_AAI)
		estimates save "${output_path}/${estimate_file_name}.ster", replace
		restore
		}
	
	else{
		di "No hay suficientes observaciones" 
		tab year_t_PP_AAI if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3
	}

*************************************
* Modelo 4: PP&SA vs AAI
*************************************	
	use `completo', clear
	global n_modelo 4
	global modelo "model${n_modelo}"
	
	* Revisar cohortes de tratamiento y truncar 2018-2020
	tab year_t_PPySA ejecucion_PNIS_prima if year==2017 & ///
		(ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4), cell
	drop if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020))
	
	if r(r)>1{
		* IPM 1 - - - - - - - - - - - - - - - - - - - -
		preserve
		keep if h_IPM_1 == 1
		global tipm="IPM 1"
		di "> IPM 1"
		
		global estimate_file_name "${ESP}-${modelo}-${tipm}-${VULN}-PP"
		di "$estimate_file_name"
		
		csdid IPM_1 if ///
			ejecucion_PNIS_prima == 1 | ///
			ejecucion_PNIS_prima == 4, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PPySA)
		estimates save "${output_path}/${estimate_file_name}.ster", replace
		restore
		
		* IPM 2 - - - - - - - - - - - - - - - - - - - -
		preserve
		keep if h_IPM_2 == 1
		global tipm="IPM 2"
		di "> IPM 2"
		
		global estimate_file_name "${ESP}-${modelo}-${tipm}-${VULN}-PP"
		di "$estimate_file_name"
		
		csdid IPM_2 if ///
			ejecucion_PNIS_prima == 1 | ///
			ejecucion_PNIS_prima == 4, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PPySA)
		estimates save "${output_path}/${estimate_file_name}.ster", replace
		restore
		}
	
	else{
		di "No hay suficientes observaciones" 
		tab year_t_PPySA if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4
	}
		
	
	
	
	
	
	
	
*-------------------------------------------------------------------------------
**# Estimar modelos 3' y 4' para beneficiarios "menos pobres": h_IPM_X == 0
*-------------------------------------------------------------------------------

global V=0
global VULN = "vuln${V}"

*************************************
* Modelo 3: PP vs AAI
*************************************
	use `completo', clear
	global n_modelo 3
	global modelo "model${n_modelo}"
	
	* Revisar cohortes de tratamiento y truncar 2018-2020
	tab year_t_PP_AAI ejecucion_PNIS_prima if year==2017 & ///
		(ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3), cell
	drop if ((year_t_PP_AAI==2018) | (year_t_PP_AAI==2019) | (year_t_PP_AAI==2020))
	
	if r(r)>1{
		* IPM 1 - - - - - - - - - - - - - - - - - - - -
		preserve
		keep if h_IPM_1 == 0
		global tipm="IPM 1"
		di "> IPM 1"
		
		global estimate_file_name "${ESP}-${modelo}-${tipm}-${VULN}-PP"
		di "$estimate_file_name"
		
		csdid IPM_1 if ///
			ejecucion_PNIS_prima == 1 | ///
			ejecucion_PNIS_prima == 3, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PP_AAI)
		estimates save "${output_path}/${estimate_file_name}.ster", replace
		restore
		
		* IPM 2 - - - - - - - - - - - - - - - - - - - -
		preserve
		keep if h_IPM_2 == 0
		global tipm="IPM 2"
		di "> IPM 2"
		
		global estimate_file_name "${ESP}-${modelo}-${tipm}-${VULN}-PP"
		di "$estimate_file_name"
		
		csdid IPM_2 if ///
			ejecucion_PNIS_prima == 1 | ///
			ejecucion_PNIS_prima == 3, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PP_AAI)
		estimates save "${output_path}/${estimate_file_name}.ster", replace
		restore
		}
	
	else{
		di "No hay suficientes observaciones" 
		tab year_t_PP_AAI if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3
	}

*************************************
* Modelo 4: PP&SA vs AAI
*************************************	
	use `completo', clear
	
	global n_modelo 4
	global modelo "model${n_modelo}"
	
	* Revisar cohortes de tratamiento y truncar 2018-2020
	tab year_t_PPySA ejecucion_PNIS_prima if year==2017 & ///
		(ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4), cell
	drop if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020))
	
	if r(r)>1{
		* IPM 1 - - - - - - - - - - - - - - - - - - - -
		preserve
		keep if h_IPM_1 == 0
		global tipm="IPM 1"	
		di "> IPM 1"
		
		global estimate_file_name "${ESP}-${modelo}-${tipm}-${VULN}-PP"
		di "$estimate_file_name"
		
		csdid IPM_1 if ///
			ejecucion_PNIS_prima == 1 | ///
			ejecucion_PNIS_prima == 4, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PPySA)
		estimates save "${output_path}/${estimate_file_name}.ster", replace
		restore
		
		* IPM 2 - - - - - - - - - - - - - - - - - - - -
		preserve
		keep if h_IPM_2 == 0
		global tipm="IPM 2"
		di "> IPM 2"
		
		global estimate_file_name "${ESP}-${modelo}-${tipm}-${VULN}-PP"
		di "$estimate_file_name"
		
		csdid IPM_2 if ///
			ejecucion_PNIS_prima == 1 | ///
			ejecucion_PNIS_prima == 4, ///
			cluster(cod_mpio) ivar(cub) time(year) ///
			gvar(year_t_PPySA)
		estimates save "${output_path}/${estimate_file_name}.ster", replace
		restore
		}
	
	else{
		di "No hay suficientes observaciones" 
		tab year_t_PPySA if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4
	}
	
