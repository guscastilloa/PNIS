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

/// Estimaciones entre grupos - Callaway & Sant'Anna  

* Preámbulo después de correr _master.do
global output_path "${output}/Estimación_modelos" //"C:\Users\ga.castillo\Documents\Output"
global n_esp 5
global especificacion "esp${n_esp}"
use "${projectfolder}/Datos/base_estimaciones_gus.dta", clear

matrix define A=J(7,3,.)
matrix colnames A = "Total" "Por Modelo" "CUBs"
matrix rownames A = "Modelo 1" "Modelo 2" "Modelo 3" "Modelo 4" "Modelo 5" ///
					"Modelo 6" "Modelo 7"


//   _____  _    _ __  __ __  ____     __
//  |  __ \| |  | |  \/  |  \/  \ \   / /
//  | |  | | |  | | \  / | \  / |\ \_/ / 
//  | |  | | |  | | |\/| | |\/| | \   /  
//  | |__| | |__| | |  | | |  | |  | |   
//  |_____/ \____/|_|  |_|_|  |_|  |_|   
**# IPM Dummy                       
{global switch_estimation_on 0

* Problema: Hay CUBs que cambian de departamento a través del tiempo:
// capture by cub (depto), sort: gen byte moved = (depto[1]!=depto[_N])
// codebook cub if moved==1


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
global n_modelo 1
global modelo "model1" 						// Global para nombre de archivos 
global treatment_variable "t_AAI_Nada"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 0						// Global para grupo control regresión
global grupo_tratamiento 1					// Global para grupo tratamiento regresión
global var_umbral "c_aai_total"				// Global para crear tratamiento dummy
global umbral_monto_tratado=2000000			// Global de umbral para crear var trat dummy

* TRUNCAR:
qui xtdescribe if year_t_AAI_Nada ==2022 & ///
	(ejecucion_PNIS ==${grupo_control} | ejecucion_PNIS ==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)

preserve
count if year_t_AAI_Nada==2022 & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)
drop if year_t_AAI_Nada==2022
	matrix A[${n_modelo},1]=r(N_drop)
cls
tab year_t_AAI_Nada if ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
if ${switch_estimation_on}==99{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off

	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid d_IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}.ster", replace
}
restore


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
global n_modelo 2
global modelo "model2" 						// Global para nombre de archivos 
global treatment_variable "t_SA_AAI"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 2					// Global para grupo tratamiento regresión
global var_umbral "c_sa_total"				// Global para crear tratamiento dummy
global umbral_monto_tratado=1620000			// Global de umbral para crear var trat dummy

* TRUNCAR:
qui xtdescribe if ((year_t_SA_AAI==2021) | (year_t_SA_AAI==2022)) & ///
	(ejecucion_PNIS ==${grupo_control} | ejecucion_PNIS ==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)

preserve
count if ((year_t_SA_AAI==2021) | (year_t_SA_AAI==2022)) & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)

drop if ((year_t_SA_AAI==2021) | (year_t_SA_AAI==2022))
	matrix A[${n_modelo},1]=r(N_drop)
restore
	
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
global n_modelo 3
global modelo "model3" 						// Global para nombre de archivos 
global treatment_variable "t_PPCC_AAI"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 3					// Global para grupo tratamiento regresión
global var_umbral "c_pp_total_cc"				// Global para crear tratamiento dummy
global umbral_monto_tratado=8100000			// Global de umbral para crear var trat dummy

* TRUNCAR:

xtdescribe if ((year_t_PPCC_AAI==2018) | (year_t_PPCC_AAI==2019) | (year_t_PPCC_AAI==2020)) & ///
	(ejecucion_PNIS ==${grupo_control} | ejecucion_PNIS ==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)

preserve
count if ((year_t_PPCC_AAI==2018) | (year_t_PPCC_AAI==2019) | (year_t_PPCC_AAI==2020)) & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)
drop if ((year_t_PPCC_AAI==2018) | (year_t_PPCC_AAI==2019) | (year_t_PPCC_AAI==2020))
	matrix A[${n_modelo},1]=r(N_drop)
restore

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
global n_modelo 4
global modelo "model4" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión
 

* TRUNCAR:

qui xtdescribe if ((year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)) & ///
	(ejecucion_PNIS ==${grupo_control} | ejecucion_PNIS ==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)

preserve
count if  ((year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)) & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)
drop if ((year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020))
	matrix A[${n_modelo},1]=r(N_drop)
restore

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
global n_modelo 5
global modelo "model5" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 2						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* TRUNCAR:

qui xtdescribe if ((year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)) & ///
	(ejecucion_PNIS ==${grupo_control} | ejecucion_PNIS ==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)

preserve
count if ((year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)) & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)
drop if ((year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020))
	matrix A[${n_modelo},1]=r(N_drop)
restore
	
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
global n_modelo 6
global modelo "model6" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 3						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* TRUNCAR:
qui xtdescribe if ((year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)) & ///
	(ejecucion_PNIS ==${grupo_control} | ejecucion_PNIS ==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)

preserve
count if ((year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)) & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)
drop if ((year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020))
	matrix A[${n_modelo},1]=r(N_drop)
restore
	
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
global n_modelo 7
global modelo "model7" 						// Global para nombre de archivos 
global treatment_variable "t_PPCL_PPCCySA"	// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 4						// Global para grupo control regresión
global grupo_tratamiento 5					// Global para grupo tratamiento regresión
global var_umbral "c_pp_total_cl"			// Global para crear tratamiento dummy
global umbral_monto_tratado=9000000			// Global de umbral para crear var trat dummy

* TRUNCAR:
qui xtdescribe if ((year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018)) & ///
	(ejecucion_PNIS ==${grupo_control} | ejecucion_PNIS ==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo},3]=r(N)
preserve
count if ((year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018)) & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento})
	matrix A[${n_modelo},2]=r(N)
drop if (year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018)
	matrix A[${n_modelo},1]=r(N_drop)

restore
}
matlist A
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
global n_modelo 1
global modelo "model1" 						// Global para nombre de archivos 
global treatment_variable "t_AAI_Nada"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 0						// Global para grupo control regresión
global grupo_tratamiento 1					// Global para grupo tratamiento regresión
global var_umbral "c_aai_total"				// Global para crear tratamiento dummy
global umbral_monto_tratado=2000000			// Global de umbral para crear var trat dummy

* TRUNCAR:
preserve
drop if year_t_AAI_Nada==2022

* ESTIMACIÓN:

/// Estimación C&S - AAI vs Nada
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore


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
global n_modelo 2
global modelo "model2" 						// Global para nombre de archivos 
global treatment_variable "t_SA_AAI"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 2					// Global para grupo tratamiento regresión
global var_umbral "c_sa_total"				// Global para crear tratamiento dummy
global umbral_monto_tratado=1620000			// Global de umbral para crear var trat dummy

* TRUNCAR:
preserve
drop if (year_t_SA_AAI==2021) | (year_t_SA_AAI==2022)



* ESTIMACIÓN:

/// Estimación C&S - SA vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore

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

* TRUNCAR:
preserve
drop if (year_t_PPCC_AAI==2018) | (year_t_PPCC_AAI==2019) | (year_t_PPCC_AAI==2020)


* ESTIMACIÓN:

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore

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
 

* TRUNCAR:
preserve
drop if (year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)


* ESTIMACIÓN:

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore

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

* TRUNCAR:
preserve
drop if (year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)


* ESTIMACIÓN:

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore

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

* TRUNCAR:
preserve
drop if (year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)

* ESTIMACIÓN:

/// Estimación C&S - PPCC vs AAI
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore

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

* TRUNCAR:
preserve
drop if (year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018)

* ESTIMACIÓN:

/// Estimación C&S - PPCL vs AAI + SA + PPCC 
if ${switch_estimation_on}==1{
	* IPM 1
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_1 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua.ster", replace
}
restore

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
global switch_estimation_on 0
tempfile mod0 mod1 mod2 mod3 mod4 mod5 mod6 mod7
save `mod0' // Guardar odelo con todas las observaciones
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

* TRUNCAR:
drop if year_t_AAI_Nada==2022
save `mod1'
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
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
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

use `mod0' // Cargar modelo con todas las observaciones 

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

* TRUNCAR:
drop if (year_t_SA_AAI==2021) | (year_t_SA_AAI==2022)
save `mod2'

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
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
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

use `mod0' // Cargar modelo con todas las observaciones 

global grupo_comparacion "PPCC vs AAI" 		// Global para títulos
global modelo "model3" 						// Global para nombre de archivos 
global treatment_variable "t_PPCC_AAI"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 3					// Global para grupo tratamiento regresión
global var_umbral "c_pp_total_cc"				// Global para crear tratamiento dummy
global umbral_monto_tratado=8100000			// Global de umbral para crear var trat dummy

* TRUNCAR:
drop if (year_t_PPCC_AAI==2018) | (year_t_PPCC_AAI==2019) | (year_t_PPCC_AAI==2020)
save `mod3'

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
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
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

use `mod0' // Cargar modelo con todas las observaciones 

global grupo_comparacion "PPCC + SA vs AAI" // Global para títulos
global modelo "model4" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión
 

* TRUNCAR:
drop if (year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)
save `mod4'

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
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
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

use `mod0' // Cargar modelo con todas las observaciones 

global grupo_comparacion "PPCC + SA vs SA" // Global para títulos
global modelo "model5" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 2						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* TRUNCAR:
drop if (year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)
save `mod5'

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
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
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

use `mod0' // Cargar modelo con todas las observaciones 

global grupo_comparacion "SA + PPCC vs PPCC" // Global para títulos
global modelo "model6" 						// Global para nombre de archivos 
global treatment_variable "t_PPCCySA"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 3						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

* TRUNCAR:
drop if (year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)
save `mod6'
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
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
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

use `mod0' // Cargar modelo con todas las observaciones 

global grupo_comparacion "PPCL vs AAI + SA + PPCC" // Global para títulos
global modelo "model7" 						// Global para nombre de archivos 
global treatment_variable "t_PPCL_PPCCySA"	// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 4						// Global para grupo control regresión
global grupo_tratamiento 5					// Global para grupo tratamiento regresión
global var_umbral "c_pp_total_cl"			// Global para crear tratamiento dummy
global umbral_monto_tratado=9000000			// Global de umbral para crear var trat dummy

* TRUNCAR:
preserve
drop if (year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018)

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
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers.ster", replace
	restore
}
restore

* End
