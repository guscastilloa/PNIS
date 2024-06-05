/*
AUTOR: 
	Gustavo Castillo
	
FECHA:
	28/sept/2023

DESCRIPCIÓN:
	También se obtiene la distribución de cohortes de tratamiento para cada 
	modelo para los beneficarios en ZME (i.e. ZME==1).
*/


* Preámbulo luego de correr _main.do
	* Cargar base con la que se realizarán las estimaciones
	use "${datafolder}/base_estimaciones_simci.dta", replace


*------------------------------------------------------------------------------
**# Distribución de cohortes de tratamiento para cada modelo para ZME==1
*------------------------------------------------------------------------------
keep if zme==1
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
global n_model 1
global modelo "model${n_model}" 		
global grupo_control 0						// Global para grupo control regresión
global grupo_tratamiento 1					// Global para grupo tratamiento regresión

estpost tab year_t_AAI_Nada ejecucion_PNIS if ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}) & year==2017

global control: label ejecucion_master ${grupo_control}
global tratamiento: label ejecucion_master ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}-ZME.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}: ${grupo_comparacion}") nonote noobs



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
global n_model 2
global modelo "model${n_model}" 		
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 2					// Global para grupo tratamiento regresión

estpost tab year_t_SA_AAI ejecucion_PNIS ///
	if (ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}) & year==2017
 
global control: label ejecucion_master ${grupo_control}
global tratamiento: label ejecucion_master ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}-ZME.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}: ${grupo_comparacion}") nonote noobs
 
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
global grupo_comparacion "PPCC vs AAI" 		// Global para títulos
global n_model 3
global modelo "model${n_model}" 		
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 3					// Global para grupo tratamiento regresión

estpost tab year_t_PPCC_AAI ejecucion_PNIS ///
	if (ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}) & year==2017

global control: label ejecucion_master ${grupo_control}
global tratamiento: label ejecucion_master ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}-ZME.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}: ${grupo_comparacion}") nonote noobs
	
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
global grupo_comparacion "PPCC + SA vs AAI" // Global para títulos
global n_model 4
global modelo "model${n_model}" 		
global grupo_control 1						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión


estpost tab year_t_PPCCySA ejecucion_PNIS ///
	if (ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}) & year==2017

global control: label ejecucion_master ${grupo_control}
global tratamiento: label ejecucion_master ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}-ZME.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}: ${grupo_comparacion}") nonote noobs
	
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
global grupo_comparacion "PPCC + SA vs SA" // Global para títulos
global n_model 5
global modelo "model${n_model}" 		
global grupo_control 2						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión

estpost tab year_t_PPCCySA ejecucion_PNIS ///
	if (ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}) & year==2018

global control: label ejecucion_master ${grupo_control}
global tratamiento: label ejecucion_master ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}-ZME.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}: ${grupo_comparacion}") nonote noobs
	
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
global grupo_comparacion "SA + PPCC vs PPCC" // Global para títulos
global n_model 6
global modelo "model${n_model}" 		
global grupo_control 3						// Global para grupo control regresión
global grupo_tratamiento 4					// Global para grupo tratamiento regresión


estpost tab year_t_PPCCySA ejecucion_PNIS ///
	if (ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}) & year==2017

global control: label ejecucion_master ${grupo_control}
global tratamiento: label ejecucion_master ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}-ZME.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}: ${grupo_comparacion}") nonote noobs	

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
global n_model 7
global modelo "model${n_model}" 		
global grupo_control 4						// Global para grupo control regresión
global grupo_tratamiento 5					// Global para grupo tratamiento regresión

estpost tab year_t_PPCL_PPCCySA  ejecucion_PNIS ///
	if (ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}) & year==2017

global control: label ejecucion_master ${grupo_control}
global tratamiento: label ejecucion_master ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}-ZME.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}: ${grupo_comparacion}") nonote noobs
