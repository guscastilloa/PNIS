/*
AUTOR: 
	Gustavo Castillo
	
DESCRIPCIÓN:
	En este script se explora si niveles de pobreza promedio pre-PNIS entre hombres
	y mujeres titulares son iguales o no. 

*/

* Preámbulo luego de ejecutar _master.do
use "${datafolder}/base_estimaciones_gus.dta", clear
global grupo1: label sexo 0
global grupo2: label sexo 1

label var IPM_1 "IPM 1"
label var IPM_2 "IPM 2"


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

estpost ttest IPM_1 IPM_2 if ///
	year==2015 & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
	by(sexo_titular)
	
esttab using "${projectfolder}/Output/Tablas/ttest-IPM-${modelo}-SEXO.tex", ///
	cells("mu_1(fmt(2)) mu_2 b(star) p count(fmt(0))") ///
	collabels("$grupo1" "$grupo2" "Dif. ($grupo1-$grupo2)" "P-valor" "obs.") ///
	gaps noobs compress nonum star(* 0.1 ** 0.05 *** 0.01) label replace ///
	note("* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

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

estpost ttest IPM_1 IPM_2 if ///
	year==2015 & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
	by(sexo_titular)
	
esttab using "${projectfolder}/Output/Tablas/ttest-IPM-${modelo}-SEXO.tex", ///
	cells("mu_1(fmt(2)) mu_2 b(star) p count(fmt(0))") ///
	collabels("$grupo1" "$grupo2" "Dif. ($grupo1-$grupo2)" "P-valor" "obs.") ///
	gaps noobs compress nonum star(* 0.1 ** 0.05 *** 0.01) label replace ///
	note("* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
	
 
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

estpost ttest IPM_1 IPM_2 if ///
	year==2015 & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
	by(sexo_titular)
	
esttab using "${projectfolder}/Output/Tablas/ttest-IPM-${modelo}-SEXO.tex", ///
	cells("mu_1(fmt(2)) mu_2 b(star) p count(fmt(0))") ///
	collabels("$grupo1" "$grupo2" "Dif. ($grupo1-$grupo2)" "P-valor" "obs.") ///
	gaps noobs compress nonum star(* 0.1 ** 0.05 *** 0.01) label replace ///
	note("* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
	
	
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

estpost ttest IPM_1 IPM_2 if ///
	year==2015 & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
	by(sexo_titular)
	
esttab using "${projectfolder}/Output/Tablas/ttest-IPM-${modelo}-SEXO.tex", ///
	cells("mu_1(fmt(2)) mu_2 b(star) p count(fmt(0))") ///
	collabels("$grupo1" "$grupo2" "Dif. ($grupo1-$grupo2)" "P-valor" "obs.") ///
	gaps noobs compress nonum star(* 0.1 ** 0.05 *** 0.01) label replace ///
	note("* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
	
	
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

estpost ttest IPM_1 IPM_2 if ///
	year==2015 & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
	by(sexo_titular)
	
esttab using "${projectfolder}/Output/Tablas/ttest-IPM-${modelo}-SEXO.tex", ///
	cells("mu_1(fmt(2)) mu_2 b(star) p count(fmt(0))") ///
	collabels("$grupo1" "$grupo2" "Dif. ($grupo1-$grupo2)" "P-valor" "obs.") ///
	gaps noobs compress nonum star(* 0.1 ** 0.05 *** 0.01) label replace ///
	note("* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
	
	
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

estpost ttest IPM_1 IPM_2 if ///
	year==2015 & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
	by(sexo_titular)
	
esttab using "${projectfolder}/Output/Tablas/ttest-IPM-${modelo}-SEXO.tex", ///
	cells("mu_1(fmt(2)) mu_2 b(star) p count(fmt(0))") ///
	collabels("$grupo1" "$grupo2" "Dif. ($grupo1-$grupo2)" "P-valor" "obs.") ///
	gaps noobs compress nonum star(* 0.1 ** 0.05 *** 0.01) label replace ///
	note("* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
	

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

estpost ttest IPM_1 IPM_2 if ///
	year==2015 & ///
	(ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}), ///
	by(sexo_titular)
	
esttab using "${projectfolder}/Output/Tablas/ttest-IPM-${modelo}-SEXO.tex", ///
	cells("mu_1(fmt(2)) mu_2 b(star) p count(fmt(0))") ///
	collabels("$grupo1" "$grupo2" "Dif. ($grupo1-$grupo2)" "P-valor" "obs.") ///
	gaps noobs compress nonum star(* 0.1 ** 0.05 *** 0.01) label replace ///
	note("* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

* End
