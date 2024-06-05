clear
set more off
set scheme s1mono

* Fijar globals necesarios al cambiar de directorio.
global path "/Users/upar/Library/CloudStorage/OneDrive-UniversidaddelosAndes/03 MONEY/CESED/Cuanti-PNIS" 
global output_path "/Users/upar/Library/CloudStorage/OneDrive-UniversidaddelosAndes/03 MONEY/CESED/Cuanti-PNIS/Output/Estimación_modelos"
use "${path}/Datos/db_sisben_pnis_panel_VF.dta", clear


drop if u1 == 2 // PNIS que no están en Sisbén o que no tienen información del Sisbén desde 2013

/// Quedarnos solo con cub con información desde 2013 

bysort cub: egen num_total = count(activo)
keep if num_total >= 10

/// Estadísticas descriptivas del IPM por grupo de ejecución del PNIS 

keep if activo == 1
keep if year > 2012

bysort cub: ereplace cod_mpio = mean(cod_mpio)

/// Crear tendencia lineal por departamento 

egen trend= group(depto year)
//                         _        _              
//                        | |      | |             
//   _ __ ___    ___    __| |  ___ | |  ___   ___  
//  | '_ ` _ \  / _ \  / _` | / _ \| | / _ \ / __| 
//  | | | | | || (_) || (_| ||  __/| || (_) |\__ \ 
//  |_| |_| |_| \___/  \__,_| \___||_| \___/ |___/ 
//                               _______  _____ 
//                           /\ |__   __||_   _|
//   _ __    ___   _ __     /  \   | |     | |  
//  | '_ \  / _ \ | '__|   / /\ \  | |     | |  
//  | |_) || (_) || |     / ____ \ | |    _| |_ 
//  | .__/  \___/ |_|    /_/    \_\|_|   |_____|
//  | |                                         
//  |_|                                         
//
/// Estimaciones entre grupos - Callaway & Sant'Anna  

foreach i in 2 1{	
	capture drop t_* year_t_*
	//  .----------------. 
	// | .--------------. |
	// | |     __       | |
	// | |    /  |      | |
	// | |    `| |      | |
	// | |     | |      | |
	// | |    _| |_     | |
	// | |   |_____|    | |
	// | |              | |
	// | '--------------' |
	//  '----------------' 
	****************************
	** AAI vs No recibió nada **
	****************************

	* PREVIO A ESTIMACIÓN:

	* A continuación prepararemos los globals que se usarán para la definición de
	* las variables de tratamiento, de año de tratamiento, grupos de control y 
	* tratamiento, y demás. Esto recude la probabilidad de error humano en la 
	* creación de las variables y facilita encontrar errores.

	global grupo_comparacion "AAI vs No recibió nada" 		// Global para títulos
	global modelo "model1" 						// Global para nombre de archivos 
	global treatment_variable "t_AAI_Nada"		// Global para var de tratamiento
	global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
	global grupo_control 0						// Global para grupo control regresión
	global grupo_tratamiento 1					// Global para grupo tratamiento regresión
	global var_umbral "c_aai_total"				// Global para crear tratamiento dummy
	global umbral_monto_tratado=2000000			// Global de umbral para crear var trat dummy

	* PREVIO A ESTIMACIÓN:

	// 1. Crear tratamiento dummy

	capture gen ${treatment_variable} = . 
	capture bysort cub: replace ${treatment_variable} = 1 if ///
		(${var_umbral} >= ${umbral_monto_tratado}) & (${var_umbral}[_n-1] < ${umbral_monto_tratado})
	capture bysort cub: replace ${treatment_variable} = ${treatment_variable}[_n-1] if  ///
		${treatment_variable} == . 
	capture replace ${treatment_variable} = 0 if ${treatment_variable} == . & ejecucion_PNIS != .

	// 2. Crear año tratamiento
	sort cub year
	capture gen ${year_treatment_var} = .
	capture bysort cub: replace ${year_treatment_var} = year if ///
		${treatment_variable} == 1 & ${treatment_variable}[_n-1] == 0
	capture bys cub: ereplace ${year_treatment_var} = mean(${year_treatment_var})
	capture replace ${year_treatment_var} = 0 if ${year_treatment_var} == . & ejecucion_PNIS != .

	// 3. Revisar que pasos anteriores hayan quedado bien
	br cub year ${treatment_variable} ${var_umbral} ${year_treatment_var}


	* ESTIMACIÓN:

	/// Estimación C&S - AAI vs Nada
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace


	//  .----------------. 
	// | .--------------. |
	// | |    _____     | |
	// | |   / ___ `.   | |
	// | |  |_/___) |   | |
	// | |   .'____.'   | |
	// | |  / /____     | |
	// | |  |_______|   | |
	// | |              | |
	// | '--------------' |
	//  '----------------' 
	****************************
	**	 	 SA vs AAI   	  **
	**************************** 

	* PREVIO A ESTIMACIÓN:

	* A continuación prepararemos los globals que se usarán para la definición de
	* las variables de tratamiento, de año de tratamiento, grupos de control y 
	* tratamiento, y demás. Esto recude la probabilidad de error humano en la 
	* creación de las variables y facilita encontrar errores.

	global grupo_comparacion "SA vs AAI" 		// Global para títulos
	global modelo "model2" 						// Global para nombre de archivos 
	global treatment_variable "t_SA_AAI"		// Global para var de tratamiento
	global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
	global grupo_control 1						// Global para grupo control regresión
	global grupo_tratamiento 2					// Global para grupo tratamiento regresión
	global var_umbral "c_sa_total"				// Global para crear tratamiento dummy
	global umbral_monto_tratado=1620000			// Global de umbral para crear var trat dummy

	// 1. Crear tratamiento dummy

	capture gen ${treatment_variable} = . 
	capture bysort cub: replace ${treatment_variable} = 1 if ///
		(${var_umbral} >= ${umbral_monto_tratado}) & (${var_umbral}[_n-1] < ${umbral_monto_tratado})
	capture bysort cub: replace ${treatment_variable} = ${treatment_variable}[_n-1] if  ///
		${treatment_variable} == . 
	capture replace ${treatment_variable} = 0 if ${treatment_variable} == . & ejecucion_PNIS != .

	// 2. Crear año tratamiento
	sort cub year
	capture gen ${year_treatment_var} = .
	capture bysort cub: replace ${year_treatment_var} = year if ///
		${treatment_variable} == 1 & ${treatment_variable}[_n-1] == 0
	capture bys cub: ereplace ${year_treatment_var} = mean(${year_treatment_var})
**# Bookmark #1: En este último replace se putió el program, justo después no pudo seguir
	capture replace ${year_treatment_var} = 0 if ${year_treatment_var} == . & ejecucion_PNIS != .

	// 3. Revisar que pasos anteriores hayan quedado bien
	br cub year ${treatment_variable} ${var_umbral} ${year_treatment_var}


	* ESTIMACIÓN:

	/// Estimación C&S - SA vs AAI

		* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace


	//
	//  .----------------. 
	// | .--------------. |
	// | |    ______    | |
	// | |   / ____ `.  | |
	// | |   `'  __) |  | |
	// | |   _  |__ '.  | |
	// | |  | \____) |  | |
	// | |   \______.'  | |
	// | |              | |
	// | '--------------' |
	//  '----------------' 
	****************************
	**	 	 PPCC vs AAI   	  **
	**************************** 

	* PREVIO A ESTIMACIÓN:

	global grupo_comparacion "PPCC vs AAI" 		// Global para títulos
	global modelo "model3" 						// Global para nombre de archivos 
	global treatment_variable "t_PPCC_AAI"		// Global para var de tratamiento
	global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
	global grupo_control 1						// Global para grupo control regresión
	global grupo_tratamiento 3					// Global para grupo tratamiento regresión
	global var_umbral "c_pp_total_cc"				// Global para crear tratamiento dummy
	global umbral_monto_tratado=8100000			// Global de umbral para crear var trat dummy

	// 1. Crear tratamiento dummy

	gen ${treatment_variable} = . 
	bysort cub: replace ${treatment_variable} = 1 if ///
		(${var_umbral} >= ${umbral_monto_tratado}) & (${var_umbral}[_n-1] < ${umbral_monto_tratado})
	bysort cub: replace ${treatment_variable} = ${treatment_variable}[_n-1] if  ///
		${treatment_variable} == . 
	replace ${treatment_variable} = 0 if ${treatment_variable} == . & ejecucion_PNIS != .

	// 2. Crear año tratamiento
	sort cub year
	gen ${year_treatment_var} = .
	bysort cub: replace ${year_treatment_var} = year if ///
		${treatment_variable} == 1 & ${treatment_variable}[_n-1] == 0
	bys cub: ereplace ${year_treatment_var} = mean(${year_treatment_var})
	replace ${year_treatment_var} = 0 if ${year_treatment_var} == . & ejecucion_PNIS != .

	// 3. Revisar que pasos anteriores hayan quedado bien
	br cub year ${treatment_variable} ${var_umbral} ${year_treatment_var}


	* ESTIMACIÓN:

	/// Estimación C&S - PPCC vs AAI

	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace




	//  .----------------. 
	// | .--------------. |
	// | |   _    _     | |
	// | |  | |  | |    | |
	// | |  | |__| |_   | |
	// | |  |____   _|  | |
	// | |      _| |_   | |
	// | |     |_____|  | |
	// | |              | |
	// | '--------------' |
	//  '----------------' 
	****************************
	**	 PPCC + SA vs AAI  	  **
	**************************** 

	* PREVIO A ESTIMACIÓN:

	global grupo_comparacion "PPCC + SA vs AAI" // Global para títulos
	global modelo "model4" 						// Global para nombre de archivos 
	global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
	global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
	global grupo_control 1						// Global para grupo control regresión
	global grupo_tratamiento 4					// Global para grupo tratamiento regresión

	// 1. Crear tratamiento dummy

	gen ${treatment_variable} = . 
	bysort cub: replace ${treatment_variable} = 1 if ///
		(t_SA_AAI==1) & (t_PPCC_AAI==1)
	bysort cub: replace ${treatment_variable} = ${treatment_variable}[_n-1] if  ///
		${treatment_variable} == . 
	replace ${treatment_variable} = 0 if ${treatment_variable} == . & ejecucion_PNIS != .

	// 2. Crear año tratamiento
	sort cub year
	gen ${year_treatment_var} = .
	bysort cub: replace ${year_treatment_var} = year if ///
		${treatment_variable} == 1 & ${treatment_variable}[_n-1] == 0
	bys cub: ereplace ${year_treatment_var} = mean(${year_treatment_var})
	replace ${year_treatment_var} = 0 if ${year_treatment_var} == . & ejecucion_PNIS != .

	// 3. Revisar que pasos anteriores hayan quedado bien
	br cub year ${treatment_variable} sa_montos c_pp_total_cc ${year_treatment_var}


	* ESTIMACIÓN:

	/// Estimación C&S - PPCC vs AAI

	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace



	//  .----------------. 
	// | .--------------. |
	// | |   _______    | |
	// | |  |  _____|   | |
	// | |  | |____     | |
	// | |  '_.____''.  | |
	// | |  | \____) |  | |
	// | |   \______.'  | |
	// | |              | |
	// | '--------------' |
	//  '----------------' 
	****************************
	**	 PPCC + SA vs SA   	  **
	**************************** 

	* PREVIO A ESTIMACIÓN:

	global grupo_comparacion "PPCC + SA vs SA" // Global para títulos
	global modelo "model5" 						// Global para nombre de archivos 
	global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
	global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
	global grupo_control 2						// Global para grupo control regresión
	global grupo_tratamiento 4					// Global para grupo tratamiento regresión

	// 1. Crear tratamiento dummy
	* ACLARACIÓN: 
	* La variable t_PPCCySA ya fue creada para la comparación número 4, por lo que 
	* no se creará de nuevo la variable sino que se hará uso de la misma que ya se 
	* creó previamente, tanto la variable de tratamiento t_PPCCySA así como la de año
	* de tratamiento year_t_PPCCySA.

	// 2. Crear año tratamiento
	* ACLARACIÓN:
	* LA variable year_t_PPCCySA ya se creó para la comparación número 4 por lo que
	* no se creará de nuevo, se usará la previamente creada.

	// 3. Revisar que pasos anteriores hayan quedado bien
	br cub year ${treatment_variable} c_sa_total c_pp_total_cc ${year_treatment_var}


	* ESTIMACIÓN:

	/// Estimación C&S - PPCC vs AAI

	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace



	//  .----------------. 
	// | .--------------. |
	// | |    ______    | |
	// | |  .' ____ \   | |
	// | |  | |____\_|  | |
	// | |  | '____`'.  | |
	// | |  | (____) |  | |
	// | |  '.______.'  | |
	// | |              | |
	// | '--------------' |
	//  '----------------' 
	****************************
	**	 SA + PPCC vs PPCC 	  **
	**************************** 

	* PREVIO A ESTIMACIÓN:

	global grupo_comparacion "SA + PPCC vs PPCC" // Global para títulos
	global modelo "model6" 						// Global para nombre de archivos 
	global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
	global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
	global grupo_control 3						// Global para grupo control regresión
	global grupo_tratamiento 4					// Global para grupo tratamiento regresión

	// 1. Crear tratamiento dummy
	* ACLARACIÓN: 
	* La variable t_PPCCySA ya fue creada para la comparación número 4, por lo que 
	* no se creará de nuevo la variable sino que se hará uso de la misma que ya se 
	* creó previamente, tanto la variable de tratamiento t_PPCCySA así como la de año
	* de tratamiento year_t_PPCCySA.

	// 2. Crear año tratamiento
	* ACLARACIÓN:
	* LA variable year_t_PPCCySA ya se creó para la comparación número 4 por lo que
	* no se creará de nuevo, se usará la previamente creada.

	// 3. Revisar que pasos anteriores hayan quedado bien
	br cub year ${treatment_variable} sa_montos c_pp_total_cc ${year_treatment_var}


	* ESTIMACIÓN:

	/// Estimación C&S - PPCC vs AAI

	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace


	//  .----------------. 
	// | .--------------. |
	// | |   _______    | |
	// | |  |  ___  |   | |
	// | |  |_/  / /    | |
	// | |      / /     | |
	// | |     / /      | |
	// | |    /_/       | |
	// | |              | |
	// | '--------------' |
	//  '----------------' 
	****************************
	**PPCL vs AAI + SA + PPCC **
	**************************** 
	* PREVIO A ESTIMACIÓN:

	global grupo_comparacion "PPCL vs AAI + SA + PPCC" // Global para títulos
	global modelo "model7" 						// Global para nombre de archivos 
	global treatment_variable "t_PPCL_PPCCySA"	// Global para var de tratamiento
	global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
	global grupo_control 4						// Global para grupo control regresión
	global grupo_tratamiento 5					// Global para grupo tratamiento regresión
	global var_umbral "c_pp_total_cl"			// Global para crear tratamiento dummy
	global umbral_monto_tratado=9000000			// Global de umbral para crear var trat dummy

	// 1. Crear tratamiento dummy
	gen ${treatment_variable} = . 
	// Crear tratamiento dummy
	bysort cub: replace ${treatment_variable} = 1 if ///
		(${var_umbral} >= ${umbral_monto_tratado}) & (${var_umbral}[_n-1] < ${umbral_monto_tratado})
	bysort cub: replace ${treatment_variable} = ${treatment_variable}[_n-1] if  ///
		${treatment_variable} == . 
	replace ${treatment_variable} = 0 if ${treatment_variable} == . & ejecucion_PNIS != .

	// 2. Crear año tratamiento
	sort cub year
	gen ${year_treatment_var} = .
	bysort cub: replace ${year_treatment_var} = year if ///
		${treatment_variable} == 1 & ${treatment_variable}[_n-1] == 0
	bys cub: ereplace ${year_treatment_var} = mean(${year_treatment_var})
	replace ${year_treatment_var} = 0 if ${year_treatment_var} == . & ejecucion_PNIS != .

	// 3. Revisar que pasos anteriores hayan quedado bien
	br cub year ${treatment_variable} ${var_umbral} ${year_treatment_var}

	* ESTIMACIÓN:

	/// Estimación C&S - PPCL vs AAI + SA + PPCC 

	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if (d_ati==`i') & ///
			(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/ati`i'-${modelo}-${ipm}.ster", replace
}








* Para d_ati==0:
global n_ati 0
keep if d_ati==${n_ati}
//  .----------------. 
// | .--------------. |
// | |     __       | |
// | |    /  |      | |
// | |    `| |      | |
// | |     | |      | |
// | |    _| |_     | |
// | |   |_____|    | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
** AAI vs No recibió nada **
****************************

global grupo_comparacion "AAI vs No recibió nada" 		// Global para títulos
global modelo "model1" 						// Global para nombre de archivos 
global treatment_variable "t_AAI_Nada"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 0						// Global para grupo control regresión
global grupo_tratamiento 1					// Global para grupo tratamiento regresión
global var_umbral "c_aai_total"				// Global para crear tratamiento dummy
global umbral_monto_tratado=2000000			// Global de umbral para crear var trat dummy

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
* IPM 1
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace

* IPM 2
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace


//  .----------------. 
// | .--------------. |
// | |    _____     | |
// | |   / ___ `.   | |
// | |  |_/___) |   | |
// | |   .'____.'   | |
// | |  / /____     | |
// | |  |_______|   | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
**	 	 SA vs AAI   	  **
**************************** 

* PREVIO A ESTIMACIÓN:

global grupo_comparacion "SA vs AAI" 		// Global para títulos
global modelo "model2" 						// Global para nombre de archivos 
global treatment_variable "t_SA_AAI"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 2					// Global para grupo tratamiento regresión
global var_umbral "c_sa_total"				// Global para crear tratamiento dummy
global umbral_monto_tratado=1620000			// Global de umbral para crear var trat dummy

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
* IPM 1
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace

* IPM 2
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace


//
//  .----------------. 
// | .--------------. |
// | |    ______    | |
// | |   / ____ `.  | |
// | |   `'  __) |  | |
// | |   _  |__ '.  | |
// | |  | \____) |  | |
// | |   \______.'  | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
**	 	 PPCC vs AAI   	  **
**************************** 

* PREVIO A ESTIMACIÓN:

global grupo_comparacion "PPCC vs AAI" 		// Global para títulos
global modelo "model3" 						// Global para nombre de archivos 
global treatment_variable "t_PPCC_AAI"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 3					// Global para grupo tratamiento regresión
global var_umbral "c_pp_total_cc"				// Global para crear tratamiento dummy
global umbral_monto_tratado=8100000			// Global de umbral para crear var trat dummy

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
* IPM 1
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace

* IPM 2
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace




//  .----------------. 
// | .--------------. |
// | |   _    _     | |
// | |  | |  | |    | |
// | |  | |__| |_   | |
// | |  |____   _|  | |
// | |      _| |_   | |
// | |     |_____|  | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
**	 PPCC + SA vs AAI  	  **
**************************** 

* PREVIO A ESTIMACIÓN:

global grupo_comparacion "PPCC + SA vs AAI" // Global para títulos
global modelo "model4" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
* IPM 1
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace

* IPM 2
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace



//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  _____|   | |
// | |  | |____     | |
// | |  '_.____''.  | |
// | |  | \____) |  | |
// | |   \______.'  | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
**	 PPCC + SA vs SA   	  **
**************************** 

* PREVIO A ESTIMACIÓN:

global grupo_comparacion "PPCC + SA vs SA" // Global para títulos
global modelo "model5" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 2						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
* IPM 1
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace

* IPM 2
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace



//  .----------------. 
// | .--------------. |
// | |    ______    | |
// | |  .' ____ \   | |
// | |  | |____\_|  | |
// | |  | '____`'.  | |
// | |  | (____) |  | |
// | |  '.______.'  | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
**	 SA + PPCC vs PPCC 	  **
**************************** 

* PREVIO A ESTIMACIÓN:

global grupo_comparacion "SA + PPCC vs PPCC" // Global para títulos
global modelo "model6" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 3						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
* IPM 1
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace

* IPM 2
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace


//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  ___  |   | |
// | |  |_/  / /    | |
// | |      / /     | |
// | |     / /      | |
// | |    /_/       | |
// | |              | |
// | '--------------' |
//  '----------------' 
****************************
**PPCL vs AAI + SA + PPCC **
**************************** 
* PREVIO A ESTIMACIÓN:

global grupo_comparacion "PPCL vs AAI + SA + PPCC" // Global para títulos
global modelo "model7" 						// Global para nombre de archivos 
global treatment_variable "t_PPCL_PPCCySA"	// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 4						// Global para grupo control regresión
global grupo_tratamiento 5					// Global para grupo tratamiento regresión
global var_umbral "c_pp_total_cl"			// Global para crear tratamiento dummy
global umbral_monto_tratado=9000000			// Global de umbral para crear var trat dummy

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
* IPM 1
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace

* IPM 2
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
set rmsg on
	csdid d_IPM_1 trend if ///
		(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
		cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
set rmsg off
estimates save "${output_path}/estimaciones/ati${n_ati}-${modelo}-${ipm}.ster", replace


* End of file

