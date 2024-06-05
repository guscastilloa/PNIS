/*
DESCRIPCIÓN:

	En este script se revisa que la creación de las variables de tratamiento por cohorte
	así como la variable de ejecución de cada componente "ejecucion_PNIS" se hayan 
	creado bien. Para revisar si quedaron bien creadas se debería observar que para
	cada pareja de grupos de comparación, i.e. cada modelo, en la columna del grupo
	de control la variable de cohorte de tratamiento debe tener observaciones 
	únicamente cuando es 0, de en los demás años debe ser 0 dado que el grupo es
	de control, y viceversa para la columna del grupo de tratamiento. Ver el siguiente
	ejemplo:

year_t_AAI |    ejecucion_PNIS
     _Nada | G CONTROL  G TRATAMI. |     Total
-----------+----------------------+----------
         0 |        45          0 |        45 
      2017 |         0         48 |        48 
      2018 |         0         15 |        15 
      2019 |         0         16 |        16 
      2020 |         0         18 |        18 
      2021 |         0         24 |        24 
      2022 |         0          1 |         1 
-----------+----------------------+----------
     Total |        45        122 |       167 
	
	En la Sección 2 del script (es un bookmark) se hace la revisión de la proporción
	de municipios en las cohortes de tratamiento en el modelo 7.
		
	
*/


* Preámbulo luego de correr _master.do
clear all
use "${projectfolder}/Datos/base_estimaciones_gus.dta", clear


**# Sección 1: Exportar tabulación cruzada

* Fijar global

global tvars "year_t_AAI_Nada year_t_SA_AAI year_t_PPCC_AAI year_t_PPCCySA year_t_PPCL_PPCCySA"

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

global control: label ejecucion ${grupo_control}
global tratamiento: label ejecucion ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	nonote noobs



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
 
global control: label ejecucion ${grupo_control}
global tratamiento: label ejecucion ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}:${grupo_comparacion}") nonote noobs
 
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

global control: label ejecucion ${grupo_control}
global tratamiento: label ejecucion ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}:${grupo_comparacion}") nonote noobs
	
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

global control: label ejecucion ${grupo_control}
global tratamiento: label ejecucion ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}:${grupo_comparacion}") nonote noobs
	
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

global control: label ejecucion ${grupo_control}
global tratamiento: label ejecucion ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}:${grupo_comparacion}") nonote noobs
	
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

global control: label ejecucion ${grupo_control}
global tratamiento: label ejecucion ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}:${grupo_comparacion}") nonote noobs	

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

global control: label ejecucion ${grupo_control}
global tratamiento: label ejecucion ${grupo_tratamiento}

esttab using "${projectfolder}/Output/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	title("Modelo ${n_model}:${grupo_comparacion}") nonote noobs
	


**# Sección 2: Revisión de modelo 7
drop if actividad=="Recolector"

tab year_t_PPCL_PPCCySA  ejecucion_PNIS ///
	if (ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}) & year==2017
	
* Generar variables que identifiquen a estas personas
tab year_t_PPCL_PPCCySA ejecucion_PNIS if ejecucion_PNIS == ${grupo_tratamiento} & year==2017, gen(f_2017_)

//            | ejecucion_
// year_t_PPC |    PNIS
//  L_PPCCySA | Recibió P |     Total
// -----------+-----------+----------
//       2017 |         1 |         1 
//       2018 |        55 |        55 
//       2019 |       193 |       193 
//       2020 |        19 |        19 
//       2021 |       687 |       687 
//       2022 |       339 |       339 
// -----------+-----------+----------
//      Total |     1,294 |     1,294 
	
forvalues x=2018/2022{
	di "`x'"
	* Variable para identificar obsevaciones (no solo CUBs) en ese cohorte
	gen f_`x'=1 if ( ejecucion_PNIS ==5) & year_t_PPCL_PPCCySA==`x'
	recode f_`x' .=0
	
	* Variable para identificar CUBs en esa cohorte
	gen f_`x'_cub2017=1 if ( ejecucion_PNIS ==5) & year_t_PPCL_PPCCySA==`x' & year==2017
	recode f_`x'_cub2017 .=0
}

* Usando las siguientes 	

tab mpio_cnmbr if f_2018_cub2017 ==1
tab mpio_cnmbr if f_2019_cub2017 ==1
tab mpio_cnmbr if f_2020_cub2017 ==1
tab mpio_cnmbr if f_2021_cub2017 ==1
tab mpio_cnmbr if f_2022_cub2017 ==1

tab dpto_cnmbr if (f_2018_cub2017 ==1) | (f_2019_cub2017 ==1) | (f_2020_cub2017 ==1)

	
* END
