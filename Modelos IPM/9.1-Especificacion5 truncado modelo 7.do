* En este


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

matrix define A=J(8,3,.)
matrix colnames A = "Total" "Por Modelo" "CUBs"
matrix rownames A = "Modelo 1" "Modelo 2" "Modelo 3" "Modelo 4" "Modelo 5" ///
					"Modelo 6" "Modelo 7 t" "Modelo 7 t2"
matlist A

**# Guardando observaciones truncadas en cada modelo
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

* TRUNCAR 2017 y 2018:
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
	
* TRUNCAR 2019 y 2020 también:
qui xtdescribe if ((year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018) | ///
				   (year_t_PPCL_PPCCySA==2019) | (year_t_PPCL_PPCCySA==2020)) & ///
	(ejecucion_PNIS ==${grupo_control} | ejecucion_PNIS ==${grupo_tratamiento})
	// Guardar número de CUBs perdidos en Matriz
	matrix A[${n_modelo}+1,3]=r(N)
preserve
count if ((year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018) | ///
		  (year_t_PPCL_PPCCySA==2019) | (year_t_PPCL_PPCCySA==2020)) & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento})
	matrix A[${n_modelo}+1,2]=r(N)
drop if ((year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018) | ///
		  (year_t_PPCL_PPCCySA==2019) | (year_t_PPCL_PPCCySA==2020))
	matrix A[${n_modelo}+1,1]=r(N_drop)
restore


matlist A


********************************************************************************
********************************************************************************
********************************************************************************

/* ANOTACIÓN:

	En adelante se realiza la estimación del Modelo 7 truncando diferentes cohortes.
	1. En primer lugar se truncaron la cohorte del 2017 y 2018
	2. Luego se truncan las cohortes desde el 2017 al 2020.
	3. Finalmente se estima el modelo 7 truncando una a una las cohortes de 2017-2018
		de tal forma que se pueda observar qué cohorte es la que se lleva el efecto
		significativo del modelo.

*/

*-----------------------------------------------------------------------------*
* En adelante se truncan solo las cohortes del 2017 y 2018. El resutado
* de las estimaciones se guardan en una archivo de nombre
*	${especificacion}-${modelo}-${ipm}-continua-t.ster"
* que permite identificarlo como "primer truncamiento" gracias al "-t" al final.
*-----------------------------------------------------------------------------*

//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\ 
**# 1.2 IPM Continua con outliers truncando 2017 y 2018
global switch_estimation_on 0

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

* TRUNCAR 2017 y 2018:
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
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-t.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-t.ster", replace
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

**# 1.2 IPM continua sin outliers truncando 2017 y 2018
global switch_estimation_on 0
tempfile mod0 mod1 mod2 mod3 mod4 mod5 mod6 mod7 mod7_2
save `mod0' // Guardar odelo con todas las observaciones

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

* TRUNCAR 2017 y 2018:
drop if (year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018)
save `mod7'
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
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers-t.ster", replace
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
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers-t.ster", replace
	restore
}


*-----------------------------------------------------------------------------*
* En adelante se truncan también las cohortes 2019 y 2020. El resultado de
* de las estimaciones se guardan en una archivo de nombre
*	${especificacion}-${modelo}-${ipm}-continua-t2.ster"
* que permite identificarlo como "segundo truncamiento" gracias al "-t2" al final.
*-----------------------------------------------------------------------------*

//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\ 
**# 2.1 IPM Continua con outliers truncando además 2019 y 2020
global switch_estimation_on 0

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

* TRUNCAR 2017-2020:
preserve
drop if (year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018) | ///
		(year_t_PPCL_PPCCySA==2019) | (year_t_PPCL_PPCCySA==2020)

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
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-t2.ster", replace

	* IPM 2
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	set rmsg on
		csdid IPM_2 trend if ///
			ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
			cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
	set rmsg off
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-t2.ster", replace
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

**# 2.2 IPM continua sin outliers truncando además 2019 y 2020
global switch_estimation_on 1

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
tempfile mod0 mod1 mod2 mod3 mod4 mod5 mod6 mod7 mod7_2
save `mod0' // Guardar odelo con todas las observaciones
use `mod0' // Cargar modelo con todas las observaciones 

global grupo_comparacion "PPCL vs AAI + SA + PPCC" // Global para títulos
global modelo "model7" 						// Global para nombre de archivos 
global treatment_variable "t_PPCL_PPCCySA"	// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 4						// Global para grupo control regresión
global grupo_tratamiento 5					// Global para grupo tratamiento regresión
global var_umbral "c_pp_total_cl"			// Global para crear tratamiento dummy
global umbral_monto_tratado=9000000			// Global de umbral para crear var trat dummy

* TRUNCAR 2017-2020:
drop if (year_t_PPCL_PPCCySA==2017) | (year_t_PPCL_PPCCySA==2018) | ///
		(year_t_PPCL_PPCCySA==2019) | (year_t_PPCL_PPCCySA==2020)
save `mod7_2'
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
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers-t2.ster", replace
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
	estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers-t2.ster", replace
	restore
}


**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**




**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**--**
*-----------------------------------------------------------------------------*
* En adelante se truncan una a una las cohortes de 2017-2020. El resultado de
* de las estimaciones se guardan en una archivo de nombre
*	${especificacion}-${modelo}-${ipm}-continua-t${t_year}.ster
* que permite identificarlo como "segundo truncamiento" gracias al "-t2" al final.
log using "${projectfolder}/mod7_t_by_cohort", replace
*-----------------------------------------------------------------------------*

//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\ 
**# 3.1 IPM con outliers truncando uno a uno las cohortes 2017-2020

global switch_estimation_on 1

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

* Itero sobre cada cohorte a truncar
forvalues cohorte=2017/2020{
	preserve
	di "Eliminando cohorte `cohorte'"
	drop if year_t_PPCL_PPCCySA==`cohorte'
	if ${switch_estimation_on}==1{
		* IPM 1
		global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
		set rmsg on
			csdid IPM_1 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-t`cohorte'.ster", replace

		* IPM 2
		global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
		set rmsg on
			csdid IPM_2 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-t`cohorte'.ster", replace
	}
	restore
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
**# 3.2 IPM sin outliers truncando uno a uno las cohortes 2017-2020

global switch_estimation_on 1

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

tempfile mod0 trunc_2017 trunc_2018 trunc_2019 trunc_2020
save `mod0' // Guardar odelo con todas las observaciones
use `mod0' // Cargar modelo con todas las observaciones 

* Itero sobre cada cohorte a truncar
forvalues cohorte=2017/2020{
	
	* PREVIO A ESTIMACIÓN
	//save `mod0' // Guardar modelo previo para 
	use `mod0', clear // Cargar modelo con todas las cohortes
	di "Eliminando cohorte `cohorte'"
	drop if year_t_PPCL_PPCCySA==`cohorte'
	
	* ESTIMACIÓN
	if ${switch_estimation_on}==1{
		* IPM 1
		global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
		preserve
		di "pre drop"
		drop if es_outlier_IPM_1==1
		di "pre est"
		set rmsg on
			csdid IPM_1 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers-t`cohorte'.ster", replace
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
		estimates save "${output_path}/estimaciones/${especificacion}-${modelo}-${ipm}-continua-no_outliers-t`cohorte'.ster", replace
		restore
	}
}


log close

* END
