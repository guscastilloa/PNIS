/*
AUTOR: Gustavo Castillo

DESCRIPCIÓN:
	En este script se realizan las modificaciones al tratamiento de PP a partir 
	de lo discutido en la reunión conjunta IPSOS-CESED del 1ro de septiembre en 
	la que se puso en tela de juicio si tal vez era mejor incluir PPCL y PPCC bajo
	un mismo tratamiento, dado que en la práctica, según el equipo Caulitativo,
	estos dos eran casi indistinguibles para los beneficiarios. Por esta razón
	el siguiente script hace dos cosas:
	
	1. Crear nueva variable ejecucion_PNIS_prima que incluya estas modificaciones
	2. Crear variables de cohorte de tratamiento
	3. Preparar estimación de modelos 3' a 6' como se describe a continuación:
	
+----+----+----+---------------+-------------------+-----------------+
| id | C  | T  | Grupo Control | Grupo Tratamiento | título          |
+====+====+====+===============+===================+=================+
| 3' | 1  | 3' | AAI           | AAI y PP          | PP vs AAI       |
+----+----+----+---------------+-------------------+-----------------+
| 4' | 1  | 4' | AAI           | AAI, PP y SA      | PP + SA vs AAI  |
+----+----+----+---------------+-------------------+-----------------+
| 5' | 2  | 4' | AAI y SA      | AAI, PP y SA      | PP + SA vs SA   |
+----+----+----+---------------+-------------------+-----------------+
| 6' | 3' | 4' | AAI y PP      | AAI, PP, y SA     | PP + SA vs PP   |
+----+----+----+---------------+-------------------+-----------------+	

*/

*-------------------------------------------------------------------------------
**# 1. Crear tratamientos
*-------------------------------------------------------------------------------
capture log close
// log using "${projectfolder}/tratamientoPPesp4", replace
* Preámbulo después de correr _master.do
use "${projectfolder}/Datos/base_estimaciones_gus.dta", clear

// Crear una variable que identifique nivel de ejecución para cada cub donde las categorías son excluyentes 
gen ejecucion_PNIS_prima = 0 if d_aai == 0 & d_sa == 0 & d_ppcc == 0 & d_ppcl == 0
replace ejecucion_PNIS_prima = 1 if d_aai == 1
replace ejecucion_PNIS_prima = 2 if d_sa == 1 // AAI + SA
replace ejecucion_PNIS_prima = 3 if (d_ppcc == 1 | d_ppcl == 1  ) // AAI + PPCC|PPCL
replace ejecucion_PNIS_prima = 4 if d_sa == 1 & (d_ppcc == 1 | d_ppcl == 1  ) // AAI + SA + PPCC|PPCL
label define ejecucion_prima 0 "No ha recibido nada" ///
					   1 "Recibió solo AAI" ///
					   2 "Recibió SA" ///
					   3 "Recibió PP" ///
					   4 "Recibió SA y PP"
label values ejecucion_PNIS_prima ejecucion_prima

replace ejecucion_PNIS_prima = . if activo == 0 | actividad == "Recolector" // Nos quedamos solo con activos y que no sean recolectores

sort cub year
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

// 1. Crear tratamiento dummy
gen ${treatment_variable} = . 
bysort cub: replace ${treatment_variable} = 1 if ///
	(t_PPCC_AAI==1 | t_PPCL_PPCCySA==1)
replace ${treatment_variable} = 0 if ${treatment_variable} == . & ejecucion_PNIS_prima != .

// 2. Crear año tratamiento
sort cub year
gen ${year_treatment_var} = .
bysort cub: replace ${year_treatment_var} = year if ///
	${treatment_variable} == 1 & ${treatment_variable}[_n-1] == 0
bys cub: ereplace ${year_treatment_var} = mean(${year_treatment_var})
replace ${year_treatment_var} = 0 if ${year_treatment_var} == . & ejecucion_PNIS_prima != .

// 3. Revisar que pasos anteriores hayan quedado bien
tab ${year_treatment_var}
br cub year ${treatment_variable} ${var_umbral} ${year_treatment_var}
br cub year t_PPCC_AAI t_PPCL_PPCCySA year_t_PPCC_AAI year_t_PPCL_PPCCySA c_pp_total c_pp_total_cc c_pp_total_cl



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

// 1. Crear tratamiento dummy

gen ${treatment_variable} = . 
bysort cub: replace ${treatment_variable} = 1 if ///
	(t_SA_AAI==1) & (t_PP_AAI==1)
bysort cub: replace ${treatment_variable} = ${treatment_variable}[_n-1] if  ///
	${treatment_variable} == . 
replace ${treatment_variable} = 0 if ${treatment_variable} == . & ejecucion_PNIS_prima != .

// 2. Crear año tratamiento
sort cub year
gen ${year_treatment_var} = .
bysort cub: replace ${year_treatment_var} = year if ///
	${treatment_variable} == 1 & ${treatment_variable}[_n-1] == 0
bys cub: ereplace ${year_treatment_var} = mean(${year_treatment_var})
replace ${year_treatment_var} = 0 if ${year_treatment_var} == . & ejecucion_PNIS_prima != .

// 3. Revisar que pasos anteriores hayan quedado bien
tab ${year_treatment_var}
br cub year ${treatment_variable} sa_montos c_pp_total_cc ${year_treatment_var}



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

// 1. Crear tratamiento dummy
* ACLARACIÓN: 
* La variable t_PPySA ya fue creada para la comparación número 4', por lo que 
* no se creará de nuevo la variable sino que se hará uso de la misma que ya se 
* creó previamente, tanto la variable de tratamiento t_PPySA así como la de año
* de tratamiento year_t_PPySA.

// 2. Crear año tratamiento
* ACLARACIÓN:
* LA variable year_t_PPySA ya se creó para la comparación número 4' por lo que
* no se creará de nuevo, se usará la previamente creada.

// 3. Revisar que pasos anteriores hayan quedado bien
br cub year ${treatment_variable} c_sa_total c_pp_total_cc ${year_treatment_var}


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

global grupo_comparacion "SA + PP vs PP" // Global para títulos
global n_modelo 6
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 3						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

// 1. Crear tratamiento dummy
* ACLARACIÓN: 
* La variable t_PPySA ya fue creada para la comparación número 4', por lo que 
* no se creará de nuevo la variable sino que se hará uso de la misma que ya se 
* creó previamente, tanto la variable de tratamiento t_PPySA así como la de año
* de tratamiento year_t_PPySA.

// 2. Crear año tratamiento
* ACLARACIÓN:
* LA variable year_t_PPySA ya se creó para la comparación número 4' por lo que
* no se creará de nuevo, se usará la previamente creada.


// 3. Revisar que pasos anteriores hayan quedado bien
br cub year ${treatment_variable} sa_montos c_pp_total_cc ${year_treatment_var}







*-------------------------------------------------------------------------------
**# 2. Estimar modelos 3', 4', 5', 6' para especificaciones 4
*-------------------------------------------------------------------------------
//   ______                 _  _   
//  |  ____|               | || |  
//  | |__    ___  _ __     | || |_ 
//  |  __|  / __|| '_ \    |__   _|
//  | |____ \__ \| |_) |_     | |  
//  |______||___/| .__/(_)    |_|  
//               | |               
//               |_|               
//
global n_esp 4
global especificacion "esp${n_esp}"
global switch_estimation_on 0 // Fijar global como 1 para estimar los modelos.
**# Esp 4 con outliers

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

* ESTIMACIÓN:

if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS_prima == ${grupo_control} | ejecucion_PNIS_prima == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
// 	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS_prima == ${grupo_control} | ejecucion_PNIS_prima == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
// 	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
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

global grupo_comparacion "PP + SA vs AAI" // Global para títulos
global n_modelo 4
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

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

//          _                     _   _ _                  
//         (_)                   | | | (_)                 
//      ___ _ _ __     ___  _   _| |_| |_  ___ _ __ ___    
//     / __| | '_ \   / _ \| | | | __| | |/ _ \ '__/ __|   
//     \__ \ | | | | | (_) | |_| | |_| | |  __/ |  \__ \   
//     |___/_|_| |_|  \___/ \__,_|\__|_|_|\___|_|  |___/   
**# Esp 4 sin outliers
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

global grupo_comparacion "PP + SA vs AAI" // Global para títulos
global n_modelo 4
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

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

global grupo_comparacion "PPCC + SA vs SA" // Global para títulos
global n_modelo 5
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 2						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

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

global grupo_comparacion "SA + PPCC vs PPCC" // Global para títulos
global n_modelo 6
global modelo "model${n_modelo}prima" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 3						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

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

log close 

* Correr siguiente dofile de estimación Especificación 5
do "${projectfolder}/Do/Modificacion PP Esp 5.do"

* End
