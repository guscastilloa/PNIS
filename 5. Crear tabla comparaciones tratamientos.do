

use "${projectfolder}/Datos/base_estimaciones_gus.dta", clear
*******************************************************************************
* CONNTROL MEAN
*******************************************************************************
*esp2-model1-IPM 2-continua.ster
global grupo_de_control 0
sum d_IPM_1 if (ejecucion_PNIS==${grupo_de_control}) & (year <2017)
di r(mean)



*******************************************************************************
* CUBS 
*******************************************************************************


matrix define A=J(7,4,.)
matrix colnames A = "cub_Control" "cub_Trat." "Prop Control" "Prop Trat"
matrix rownames A= "Modelo 1" "Modelo 2" "Modelo 3" ///
				   "Modelo 4" "Modelo 5" "Modelo 6" ///
				   "Modelo 7"
				   
				 
				   
				   
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
global modelo "model${n_modelo}" 						// Global para nombre de archivos 
global treatment_variable "t_AAI_Nada"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 0						// Global para grupo control regresión
global grupo_tratamiento 1					// Global para grupo tratamiento regresión

* Llenar CUBs tratamiento y control
preserve
keep if ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}
qui xtdescribe if ejecucion_PNIS == ${grupo_control}
scalar n_control=r(N)
matrix A[${n_modelo},1]=n_control

qui xtdescribe if ejecucion_PNIS == ${grupo_tratamiento}
scalar n_tratamiento=r(N)
matrix A[${n_modelo},2]=n_tratamiento
restore 

matlist A


* Llenar proporción sobre muestra  ( cultivadores y no cultivadores)
qui xtdescribe if actividad=="Cultivador" | actividad=="No Cultivador"
di "denom: `r(N)'"
scalar denom=r(N)
matrix A[${n_modelo},3]= round((n_control/denom)*100, 0.01)
matrix A[${n_modelo},4]= round((n_tratamiento/denom)*100, 0.01)


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


global grupo_comparacion "SA vs AAI" 		// Global para títulos
global n_modelo 2
global modelo "model2" 						// Global para nombre de archivos 
global treatment_variable "t_SA_AAI"		// Global para var de tratamiento
global year_treatment_var "year_${treatment_variable}"	// Global para variable en regresión
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 2					// Global para grupo tratamiento regresión

* Llenar CUBs tratamiento y control
preserve
keep if ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}
qui xtdescribe if ejecucion_PNIS == ${grupo_control}
scalar n_control=r(N)
matrix A[${n_modelo},1]=n_control

qui xtdescribe if ejecucion_PNIS == ${grupo_tratamiento}
scalar n_tratamiento=r(N)
matrix A[${n_modelo},2]=n_tratamiento
restore 

* Llenar proporción sobre muestra  ( cultivadores y no cultivadores)
qui xtdescribe if actividad=="Cultivador" | actividad=="No Cultivador"
di "denom: `r(N)'"
scalar denom=r(N)
matrix A[${n_modelo},3]= round((n_control/denom)*100, 0.01)
matrix A[${n_modelo},4]= round((n_tratamiento/denom)*100, 0.01)



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

* Llenar CUBs tratamiento y control
preserve
keep if ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}
qui xtdescribe if ejecucion_PNIS == ${grupo_control}
scalar n_control=r(N)
matrix A[${n_modelo},1]=n_control

qui xtdescribe if ejecucion_PNIS == ${grupo_tratamiento}
scalar n_tratamiento=r(N)
matrix A[${n_modelo},2]=n_tratamiento
restore 

* Llenar proporción sobre muestra  ( cultivadores y no cultivadores)
qui xtdescribe if actividad=="Cultivador" | actividad=="No Cultivador"
di "denom: `r(N)'"
scalar denom=r(N)
matrix A[${n_modelo},3]= round((n_control/denom)*100, 0.01)
matrix A[${n_modelo},4]= round((n_tratamiento/denom)*100, 0.01)




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

* Llenar CUBs tratamiento y control
preserve
keep if ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}
qui xtdescribe if ejecucion_PNIS == ${grupo_control}
scalar n_control=r(N)
matrix A[${n_modelo},1]=n_control

qui xtdescribe if ejecucion_PNIS == ${grupo_tratamiento}
scalar n_tratamiento=r(N)
matrix A[${n_modelo},2]=n_tratamiento
restore 



* Llenar proporción sobre muestra  ( cultivadores y no cultivadores)
qui xtdescribe if actividad=="Cultivador" | actividad=="No Cultivador"
di "denom: `r(N)'"
scalar denom=r(N)
matrix A[${n_modelo},3]= round((n_control/denom)*100, 0.01)
matrix A[${n_modelo},4]= round((n_tratamiento/denom)*100, 0.01)



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

* Llenar CUBs tratamiento y control
preserve
keep if ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}
qui xtdescribe if ejecucion_PNIS == ${grupo_control}
scalar n_control=r(N)
matrix A[${n_modelo},1]=n_control

qui xtdescribe if ejecucion_PNIS == ${grupo_tratamiento}
scalar n_tratamiento=r(N)
matrix A[${n_modelo},2]=n_tratamiento
restore 



* Llenar proporción sobre muestra  ( cultivadores y no cultivadores)
qui xtdescribe if actividad=="Cultivador" | actividad=="No Cultivador"
di "denom: `r(N)'"
scalar denom=r(N)
matrix A[${n_modelo},3]= round((n_control/denom)*100, 0.01)
matrix A[${n_modelo},4]= round((n_tratamiento/denom)*100, 0.01)



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

* Llenar CUBs tratamiento y control
preserve
keep if ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}
qui xtdescribe if ejecucion_PNIS == ${grupo_control}
scalar n_control=r(N)
matrix A[${n_modelo},1]=n_control

qui xtdescribe if ejecucion_PNIS == ${grupo_tratamiento}
scalar n_tratamiento=r(N)
matrix A[${n_modelo},2]=n_tratamiento
restore 

* Llenar proporción sobre muestra  ( cultivadores y no cultivadores)
qui xtdescribe if actividad=="Cultivador" | actividad=="No Cultivador"
di "denom: `r(N)'"
scalar denom=r(N)
matrix A[${n_modelo},3]= round((n_control/denom)*100, 0.01)
matrix A[${n_modelo},4]= round((n_tratamiento/denom)*100, 0.01)

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

* Llenar CUBs tratamiento y control
preserve
keep if ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}
qui xtdescribe if ejecucion_PNIS == ${grupo_control}
scalar n_control=r(N)
matrix A[${n_modelo},1]=n_control

qui xtdescribe if ejecucion_PNIS == ${grupo_tratamiento}
scalar n_tratamiento=r(N)
matrix A[${n_modelo},2]=n_tratamiento
restore 

* Llenar proporción sobre muestra  ( cultivadores y no cultivadores)
qui xtdescribe if actividad=="Cultivador" | actividad=="No Cultivador"
di "denom: `r(N)'"
scalar denom=r(N)
matrix A[${n_modelo},3]= round((n_control/denom)*100, 0.01)
matrix A[${n_modelo},4]= round((n_tratamiento/denom)*100, 0.01)

matlist A

putexcel set "~/Downloads/tabla_terceras_estimaciones.xlsx", sheet("import") modify
putexcel A1=matrix(A), names 
