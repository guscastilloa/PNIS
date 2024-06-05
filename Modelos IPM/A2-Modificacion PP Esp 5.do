/*
AUTOR: Gustavo Castillo

DESCRIPCIÓN:
	En este script se hacen las estimaciones de los modelos 3', 4', 5', y 6' 
	únicamente para la especificación 5. 
	
+----+----+----+---------------+-------------------+-----------------+
| id | C  | T  | Grupo Control | Grupo Tratamiento | título          |
+====+====+====+===============+===================+=================+
| 3' | 1  | 3' | AAI           | AAI y PP          | PP vs AAI       |
+----+----+----+---------------+-------------------+-----------------+
| 4' | 1  | 4' | AAI           | AAI, PP y SA      | PP + SA vs AAI  |
+----+----+----+---------------+-------------------+-----------------+
| 5' | 2  | 4' | AAI y SA      | AAI, PP y SA      | PP + SA vs SA   |
+----+----+----+---------------+-------------------+-----------------+
| 6' | 3' | 4' | AAI y PP      | AAI, PP, y SA     | PP + SA vs PPCC |
+----+----+----+---------------+-------------------+-----------------+	

*/

*-------------------------------------------------------------------------------
**# 1. Crear tratamientos
*-------------------------------------------------------------------------------
* Preámbulo después de correr _master.do
use "${projectfolder}/Datos/base_estimaciones_gus.dta", clear



*-------------------------------------------------------------------------------
**# 2. Estimar modelos 3', 4', 5', 6' para especificacion 5
*-------------------------------------------------------------------------------
global n_esp 5
global especificacion "esp${n_esp}"
log using "${projectfolder}/tratamientoPP${especificacion}", replace

* Definir matriz para guardar número de obs. y CUBs truncados
matrix define A=J(7,3,.)
matrix colnames A = "Total" "Por Modelo" "CUBs"
matrix rownames A = "Modelo 1" "Modelo 2" "Modelo 3'" "Modelo 4'" "Modelo 5'" ///
					"Modelo 6'" "Modelo 7"

//   ______                 _____ 
//  |  ____|               | ____|
//  | |__    ___  _ __     | |__  
//  |  __|  / __|| '_ \    |___ \ 
//  | |____ \__ \| |_) |_   ___) |
//  |______||___/| .__/(_) |____/ 
//               | |              
//               |_|              

**# Revisión cohortes de tratamiento
* Para saber qué años truncar debemos observar la tabla de cohortes de tratamiento y 
* eliminar aquellos años que compongan muy poquitos datos. 

* Modelo 3'
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 3					// Global para grupo tratamiento regresión
tab year_t_PP_AAI ejecucion_PNIS_prima if ///
	(ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}) & year==2017

// year_t_PP_ | ejecucion_PNIS_prima
//        AAI | Recibió s  Recibió P |     Total
// -----------+----------------------+----------
//          0 |       122        160 |       282 
//       2018 |         0          9 |         9 
//       2019 |         0         33 |        33 
//       2020 |         0          1 |         1 
//       2021 |         0        790 |       790 
//       2022 |         0        382 |       382 
// -----------+----------------------+----------
//      Total |       122      1,375 |     1,497 

* Para el modelo 3' se ve adecuado eliminar 2018-2020 que son 43 CUBs (.08% sobre
* total de CUBs). 

* Modelo 4'
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión
tab year_t_PPySA ejecucion_PNIS_prima ///
	if (ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}) & year==2017
	
// year_t_PPy | ejecucion_PNIS_prima
//         SA | Recibió s  Recibió S |     Total
// -----------+----------------------+----------
//          0 |       122          0 |       122 
//       2018 |         0        183 |       183 
//       2019 |         0        163 |       163 
//       2020 |         0        242 |       242 
//       2021 |         0     11,534 |    11,534 
//       2022 |         0     33,988 |    33,988 
// -----------+----------------------+----------
//      Total |       122     46,110 |    46,232 


* Para el modelo 4'	(y por consiguiente para el 5' y 6' que tienen el mismo grupo
* de tratamiento) se ve adecuado seguir con la misma regla de truncamiento que 
* había en las Quintas Estimaciones: 2018-2020

* Modelo 5'
global grupo_control 2						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión
tab year_t_PPySA ejecucion_PNIS_prima ///
	if (ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}) & year==2017

// year_t_PPy | ejecucion_PNIS_prima
//         SA | Recibió S  Recibió S |     Total
// -----------+----------------------+----------
//          0 |     1,308          0 |     1,308 
//       2018 |         0        183 |       183 
//       2019 |         0        163 |       163 
//       2020 |         0        242 |       242 
//       2021 |         0     11,534 |    11,534 
//       2022 |         0     33,988 |    33,988 
// -----------+----------------------+----------
//      Total |     1,308     46,110 |    47,418 
 

	
* Modelo 6'
global grupo_control 3						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión
tab year_t_PPySA ejecucion_PNIS_prima ///
	if (ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}) & year==2017
	
// year_t_PPy | ejecucion_PNIS_prima
//         SA | Recibió P  Recibió S |     Total
// -----------+----------------------+----------
//          0 |     1,573          0 |     1,573 
//       2018 |         0        183 |       183 
//       2019 |         0        163 |       163 
//       2020 |         0        242 |       242 
//       2021 |         0     11,534 |    11,534 
//       2022 |         0     33,988 |    33,988 
// -----------+----------------------+----------
//      Total |     1,573     46,110 |    47,683 


	
**# Esp 5 con outliers
global switch_estimation_on 0

//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |    ______    | || |      _       | |
// | |   / ____ `.  | || |     | |      | |
// | |   `'  __) |  | || |     \_|      | |
// | |   _  |__ '.  | || |              | |
// | |  | \____) |  | || |              | |
// | |   \______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 

****************************
**	 	 PP vs AAI   	  **
**************************** 

* PREVIO A ESTIMACIÓN:

global grupo_comparacion "PP vs AAI" 		// Global para títulos
global n_modelo 3
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PP_AAI"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 3					// Global para grupo tratamiento regresión

* TRUNCAR:

xtdescribe if ((year_t_PP_AAI==2018) | (year_t_PP_AAI==2019) | (year_t_PP_AAI==2020)) & ///
	(ejecucion_PNIS_prima ==${grupo_control} | ejecucion_PNIS_prima ==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)

preserve
count if ((year_t_PP_AAI==2018) | (year_t_PP_AAI==2019) | (year_t_PP_AAI==2020)) & ///
	(ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)
drop if ((year_t_PP_AAI==2018) | (year_t_PP_AAI==2019) | (year_t_PP_AAI==2020))
	matrix A[${n_modelo},1]=r(N_drop)

* ESTIMACIÓN:

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore


//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |   _    _     | || |      _       | |
// | |  | |  | |    | || |     | |      | |
// | |  | |__| |_   | || |     \_|      | |
// | |  |____   _|  | || |              | |
// | |      _| |_   | || |              | |
// | |     |_____|  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 PP + SA vs AAI  	  **
**************************** 

* PREVIO A ESTIMACIÓN:

global grupo_comparacion "PP + SA vs AAI" // Global para títulos
global n_modelo 4
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* TRUNCAR:

qui xtdescribe if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020)) & ///
	(ejecucion_PNIS_prima==${grupo_control} | ejecucion_PNIS_prima==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)

preserve
count if  ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020)) & ///
	(ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)
drop if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020))
	matrix A[${n_modelo},1]=r(N_drop)

* ESTIMACIÓN:

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore


//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |   _______    | || |      _       | |
// | |  |  _____|   | || |     | |      | |
// | |  | |____     | || |     \_|      | |
// | |  '_.____''.  | || |              | |
// | |  | \____) |  | || |              | |
// | |   \______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 PP + SA vs SA   	  **
**************************** 

* PREVIO A ESTIMACIÓN:

global grupo_comparacion "PPCC + SA vs SA" // Global para títulos
global n_modelo 5
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 2						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* TRUNCAR:

qui xtdescribe if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020)) & ///
	(ejecucion_PNIS_prima==${grupo_control} | ejecucion_PNIS_prima==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)

preserve
count if  ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020)) & ///
	(ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)
drop if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020))
	matrix A[${n_modelo},1]=r(N_drop)

* ESTIMACIÓN:
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore


//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |    ______    | || |      _       | |
// | |  .' ____ \   | || |     | |      | |
// | |  | |____\_|  | || |     \_|      | |
// | |  | '____`'.  | || |              | |
// | |  | (____) |  | || |              | |
// | |  '.______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 SA + PP vs PP 	  **
**************************** 

* PREVIO A ESTIMACIÓN:

global grupo_comparacion "SA + PPCC vs PPCC" // Global para títulos
global n_modelo 6
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 3						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* TRUNCAR:

qui xtdescribe if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020)) & ///
	(ejecucion_PNIS_prima==${grupo_control} | ejecucion_PNIS_prima==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)

preserve
count if  ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020)) & ///
	(ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)
drop if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020))
	matrix A[${n_modelo},1]=r(N_drop)


* ESTIMACIÓN:
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore

**# Esp 5 sin outliers
global switch_estimation_on 1
tempfile mod0 mod3 mod4 mod5 mod6 
save `mod0' // Guardar odelo con todas las observaciones
//          _                     _   _ _                  
//         (_)                   | | | (_)                 
//      ___ _ _ __     ___  _   _| |_| |_  ___ _ __ ___    
//     / __| | '_ \   / _ \| | | | __| | |/ _ \ '__/ __|   
//     \__ \ | | | | | (_) | |_| | |_| | |  __/ |  \__ \   
//     |___/_|_| |_|  \___/ \__,_|\__|_|_|\___|_|  |___/   
//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |    ______    | || |      _       | |
// | |   / ____ `.  | || |     | |      | |
// | |   `'  __) |  | || |     \_|      | |
// | |   _  |__ '.  | || |              | |
// | |  | \____) |  | || |              | |
// | |   \______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 

****************************
**	 	 PP vs AAI   	  **
**************************** 

* PREVIO A ESTIMACIÓN:
use `mod0' // Cargar modelo con todas las observaciones 

global grupo_comparacion "PP vs AAI" 		// Global para títulos
global n_modelo 3
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PP_AAI"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 3					// Global para grupo tratamiento regresión

* TRUNCAR:
drop if ((year_t_PP_AAI==2018) | (year_t_PP_AAI==2019) | (year_t_PP_AAI==2020))
save `mod3'
* ESTIMACIÓN:
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}

//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |   _    _     | || |      _       | |
// | |  | |  | |    | || |     | |      | |
// | |  | |__| |_   | || |     \_|      | |
// | |  |____   _|  | || |              | |
// | |      _| |_   | || |              | |
// | |     |_____|  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 PP + SA vs AAI  	  **
**************************** 

* PREVIO A ESTIMACIÓN:
use `mod0' // Cargar modelo con todas las observaciones 
global grupo_comparacion "PP + SA vs AAI" // Global para títulos
global n_modelo 4
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* TRUNCAR:
drop if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020))
save `mod4'

* ESTIMACIÓN:
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}

//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |   _______    | || |      _       | |
// | |  |  _____|   | || |     | |      | |
// | |  | |____     | || |     \_|      | |
// | |  '_.____''.  | || |              | |
// | |  | \____) |  | || |              | |
// | |   \______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 PP + SA vs SA   	  **
**************************** 

* PREVIO A ESTIMACIÓN:
use `mod0' // Cargar modelo con todas las observaciones 
global grupo_comparacion "PPCC + SA vs SA" // Global para títulos
global n_modelo 5
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 2						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* TRUNCAR:
drop if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020))
save `mod5'

* ESTIMACIÓN:
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}


//  .----------------.  .----------------. 
// | .--------------. || .--------------. |
// | |    ______    | || |      _       | |
// | |  .' ____ \   | || |     | |      | |
// | |  | |____\_|  | || |     \_|      | |
// | |  | '____`'.  | || |              | |
// | |  | (____) |  | || |              | |
// | |  '.______.'  | || |              | |
// | |              | || |              | |
// | '--------------' || '--------------' |
//  '----------------'  '----------------' 
****************************
**	 SA + PP vs PP 	  **
**************************** 

* PREVIO A ESTIMACIÓN:
use `mod0' // Cargar modelo con todas las observaciones 
global grupo_comparacion "SA + PPCC vs PPCC" // Global para títulos
global n_modelo 6
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 3						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* TRUNCAR:
drop if ((year_t_PPySA==2018) | (year_t_PPySA==2019) | (year_t_PPySA==2020))
save `mod6'

* ESTIMACIÓN:
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}
