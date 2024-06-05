//   ______                 ____  
//  |  ____|               |___ \ 
//  | |__    ___  _ __       __) |
//  |  __|  / __|| '_ \     |__ < 
//  | |____ \__ \| |_) |_   ___) |
//  |______||___/| .__/(_) |____/ 
//               | |              
//               |_|              

* With trend
* Cluster por departamento
/// Estimaciones entre grupos - Callaway & Sant'Anna  


* Preámbulo después de correr _master.do
// global output_path "${output}/Estimación_modelos" //"C:\Users\ga.castillo\Documents\Output"
global n_esp 3
global especificacion "esp${n_esp}"



* Problema: Hay CUBs que cambian de departamento a través del tiempo:
// by cub (dpto_ccdgo), sort: gen byte moved = (dpto_ccdgo[1]!=dpto_ccdgo[_N])
// codebook cub if moved==1

//   _____  _    _ __  __ __  ____     __
//  |  __ \| |  | |  \/  |  \/  \ \   / /
//  | |  | | |  | | \  / | \  / |\ \_/ / 
//  | |  | | |  | | |\/| | |\/| | \   /  
//  | |__| | |__| | |  | | |  | |  | |   
//  |_____/ \____/|_|  |_|_|  |_|  |_|   
**# IPM Dummy
                       
					  
global switch_estimation_on 0

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

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off

	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
}



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

* ESTIMACIÓN:

/// Estimación C&S - SA vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace
}
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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
		
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace

}


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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
		
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace
}

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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off

	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace
}

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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
		
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace
}

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

global grupo_comparacion "PPCL vs AAI + SA + PPCC" // Global para títulos
global modelo "model7" 						// Global para nombre de archivos 
global treatment_variable "t_PPCL_PPCCySA"	// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 4						// Global para grupo control regresión
global grupo_tratamiento 5					// Global para grupo tratamiento regresión
global var_umbral "c_pp_total_cl"			// Global para crear tratamiento dummy
global umbral_monto_tratado=9000000			// Global de umbral para crear var trat dummy

* ESTIMACIÓN:

/// Estimación C&S - PPCL vs AAI + SA + PPCC 
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
		
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}")
// 	graph export "${output_path}/graficos/${especificacion}-${modelo}-${ipm}.jpg", replace
}


********************************************************************************
********************************************************************************
//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\ 
**# IPM Continua con outliers
                                                       
global switch_estimation_on 0

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

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}


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

* ESTIMACIÓN:

/// Estimación C&S - SA vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}

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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}


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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}

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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}

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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}

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

global grupo_comparacion "PPCL vs AAI + SA + PPCC" // Global para títulos
global modelo "model7" 						// Global para nombre de archivos 
global treatment_variable "t_PPCL_PPCCySA"	// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 4						// Global para grupo control regresión
global grupo_tratamiento 5					// Global para grupo tratamiento regresión
global var_umbral "c_pp_total_cl"			// Global para crear tratamiento dummy
global umbral_monto_tratado=9000000			// Global de umbral para crear var trat dummy

* ESTIMACIÓN:

/// Estimación C&S - PPCL vs AAI + SA + PPCC 
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}

//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\
//          _                     _   _ _                  
//         (_)                   | | | (_)                 
//      ___ _ _ __     ___  _   _| |_| |_  ___ _ __ ___    
//     / __| | '_ \   / _ \| | | | __| | |/ _ \ '__/ __|   
//     \__ \ | | | | | (_) | |_| | |_| | |  __/ |  \__ \   
//     |___/_|_| |_|  \___/ \__,_|\__|_|_|\___|_|  |___/   
**# IPM continua sin outliers
global switch_estimation_on 1

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

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}


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

* ESTIMACIÓN:

/// Estimación C&S - SA vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}

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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}


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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}

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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}

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

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}

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

global grupo_comparacion "PPCL vs AAI + SA + PPCC" // Global para títulos
global modelo "model7" 						// Global para nombre de archivos 
global treatment_variable "t_PPCL_PPCCySA"	// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 4						// Global para grupo control regresión
global grupo_tratamiento 5					// Global para grupo tratamiento regresión
global var_umbral "c_pp_total_cl"			// Global para crear tratamiento dummy
global umbral_monto_tratado=9000000			// Global de umbral para crear var trat dummy

* ESTIMACIÓN:

/// Estimación C&S - PPCL vs AAI + SA + PPCC 
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_1==1
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	preserve
	drop if es_outlier_IPM_2==1
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(dpto_ccdgo) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}


* End
do "${projectfolder}/Do/9-Especificacion4.do"
