/*
AUTOR:
	Gustavo Castillo

DESCRIPCIÓN
	En este script se exportan los resultados del ejercicio de reestimación de 
	los modelos (esp. 4 y 5) haciendo uso del tratamiento PP que incluía PPCC
	y PPCL que se estiman en los scripts:
		- "A2-Modificación PP Esp 4.do"
		- "A2-Modificación PP Esp 5.do"
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Modelos IPM/estimaciones"
global output_path "${output}/Modelos IPM/graficos"

*-------------------------------------------------------------------------------
**# 1. Distribución de cohortes
*-------------------------------------------------------------------------------
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


estpost tab year_t_PP_AAI ejecucion_PNIS_prima if ///
	(ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}) & year==2017

global control: label ejecucion_prima ${grupo_control}
global tratamiento: label ejecucion_prima ${grupo_tratamiento}

esttab using "${output}/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	nonote noobs

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
	
estpost tab year_t_PPySA ejecucion_PNIS_prima ///
	if (ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}) & year==2017

global control: label ejecucion_prima ${grupo_control}
global tratamiento: label ejecucion_prima ${grupo_tratamiento}

esttab using "${output}/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	nonote noobs

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

estpost tab year_t_PPySA ejecucion_PNIS_prima ///
	if (ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}) & year==2017
	
global control: label ejecucion_prima ${grupo_control}
global tratamiento: label ejecucion_prima ${grupo_tratamiento}

esttab using "${output}/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	nonote noobs

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


estpost tab year_t_PPySA ejecucion_PNIS_prima ///
	if (ejecucion_PNIS_prima== ${grupo_control} | ejecucion_PNIS_prima== ${grupo_tratamiento}) & year==2017

global control: label ejecucion_prima ${grupo_control}
global tratamiento: label ejecucion_prima ${grupo_tratamiento}

esttab using "${output}/Construccion Tratamientos/revision_cohortes-${modelo}.tex", replace ///
	wide unstack compress eqlabels("$control " "$tratamiento") nonum ///
	nonote noobs	

*-------------------------------------------------------------------------------
**# Obtener media de control de cada modelo
*-------------------------------------------------------------------------------
* Continua CON OUTLIERS

* Matriz que identifica modelo con sus grupos de control y tratamiento
matrix define N=J(7,2,.)
matrix colnames N = "Control"  "Tratamiento"
matrix N[1,1] = 0
matrix N[2,1] = 1
matrix N[3,1] = 1
matrix N[4,1] = 1
matrix N[5,1] = 2
matrix N[6,1] = 3
matrix N[7,1] = 4
matrix N[1,2] = 1
matrix N[2,2] = 2
matrix N[3,2] = 3
matrix N[4,2] = 4
matrix N[5,2] = 4
matrix N[6,2] = 4
matrix N[7,2] = 5
matlist N


matrix define C=J(7,2,.)
matrix colnames C = "IPM 1" "IPM 2"
matrix rownames C = "Modelo 1" "Modelo 2" "Modelo 3'" "Modelo 4'" "Modelo 5'" ///
					"Modelo 6'" "Modelo 7"
// matlist C

forvalues M=3/6{
	local grupo_control=N[`M',1]
	qui mean IPM_1 IPM_2 if ejecucion_PNIS_prima ==`grupo_control' & year==2015
	matrix C[`M',1]=round(r(table)[1,1], 0.0001)
	matrix C[`M',2]=round(r(table)[1,2], 0.0001)
// 	di "Media paraa modelo `M' y el grupo de control es `grupo_control'"
}

matlist C

*-------------------------------------------------------------------------------
**# Exportar tablas con resultados variable con outliers
*-------------------------------------------------------------------------------
//    _____ ____  _   _ _______ _____ _   _ _    _         
//   / ____/ __ \| \ | |__   __|_   _| \ | | |  | |  /\    
//  | |   | |  | |  \| |  | |    | | |  \| | |  | | /  \   
//  | |   | |  | | . ` |  | |    | | | . ` | |  | |/ /\ \  
//  | |___| |__| | |\  |  | |   _| |_| |\  | |__| / ____ \ 
//   \_____\____/|_| \_|  |_|  |_____|_| \_|\____/_/    \_\ 
* Iterar sobre los modelos 3' a 6'
forvalues M=3/6{
	di "**************************************"
	di ">>> MODELO `M' **************************************"
	
	* Iterar sobrelas IPMs: IPM 1 e IPM 2
	forvalues I=1/2{
		di ">> IPM `I'"
		
		* Cargar Estimación de Especificación 4
		local E=4
		di "> Estimacion `E'"
		di "Iteración `counter'"
		di "esp`E'-model`M'prima-IPM `I'-continua.ster"
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'prima-IPM `I'-continua.ster"
		qui estat simple, estore(eesp`E'_`I')
		scalar N_OBS_`E'= e(N)
		
		qui eststo con_eststo`E'
		
		* Cargar Estimación de Especificación 5
		local E=5
		di "> Estimacion `E'"
		di "Iteración `counter'"
		di "esp`E'-model`M'prima-IPM `I'-continua.ster"
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'prima-IPM `I'-continua.ster"
		qui estat simple, estore(eesp`E'_`I')
		scalar N_OBS_`E'= e(N)
		
		qui eststo con_eststo`E'
		
		
		*-- Scalars Especificación 4'
		est restore eesp4_`I'
		di "antes "
		local controlmean=C[`M',`I']
		di "desp"
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_4, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC " "
		*-- Scalars Especificación 5 truncando 2018-2020
		est restore eesp5_`I'
		local controlmean=C[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "2018-2020"

	}
	esttab eesp4_1 eesp5_1 eesp4_2 eesp5_2 using "${table_output}/_modelo`M'-continua-modPP.tex", ///
			mtitles("Esp. 4" "Esp. 5" "Esp. 4" "Esp. 5") ///
			mgroups("IPM 1" "IPM 2", pattern(1 0 1 0) ///
				prefix(\multicolumn{@span}{c}{) suffix(})   ///
				span erepeat(\cmidrule(lr){@span})) ///
			nonum ///
			replace main(b %6.4f) aux(se %6.4f) ///
			star(* 0.10 ** 0.05 *** 0.01) compress ///
			gap nonotes noobs ///
			scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFU EF CUB" "TREND Tendencia" "CLDEPT Cluster Dep." "CLMUN Cluster Mun." "TRUNC Truncado") ///
			note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")		
}


*-------------------------------------------------------------------------------
**# Exportar tablas con resultados variable SIN outliers
*-------------------------------------------------------------------------------
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

* Iterar sobre los modelos 3' a 6'
forvalues M=3/6{
	di "**************************************"
	di ">>> MODELO `M' **************************************"
	
	* Iterar sobrelas IPMs: IPM 1 e IPM 2
	forvalues I=1/2{
		di ">> IPM `I'"
		* Cargar Estimación de Especificación 4
		local E=4
		di "> Estimacion `E'"
		di "Iteración `counter'"
		di "esp`E'-model`M'prima-IPM `I'-continua.ster"
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'prima-IPM `I'-continua-no_outliers.ster"
		qui estat simple, estore(eesp`E'_`I')
		scalar N_OBS_`E'= e(N)
		
		qui eststo con_eststo`E'
		
		* Cargar Estimación de Especificación 5
		local E=5
		di "> Estimacion `E'"
		di "Iteración `counter'"
		di "esp`E'-model`M'prima-IPM `I'-continua.ster"
		qui estimates use "${dir_estimaciones}/esp`E'-model`M'prima-IPM `I'-continua-no_outliers.ster"
		qui estat simple, estore(eesp`E'_`I')
		scalar N_OBS_`E'= e(N)
		
		qui eststo con_eststo`E'
		
		
		*-- Scalars Especificación 4'
		est restore eesp4_`I'
		di "antes "
		local controlmean=C[`M',`I']
		di "desp"
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_4, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC " "
		*-- Scalars Especificación 5 truncando 2018-2020
		est restore eesp5_`I'
		local controlmean=C[`M',`I']
		qui estadd local CM "`controlmean'" // Añadir promedio de grupo de control
		estadd scalar OBS=N_OBS_5, replace
		qui estadd local EFT "\checkmark"
		qui estadd local EFU "\checkmark"
		qui estadd local TREND "\checkmark"
		qui estadd local CLDEPT " "
		qui estadd local CLMUN "\checkmark"
		qui estadd local TRUNC "2018-2020"

		
// 		esttab eesp4 eesp5 using "${table_output}/_modelo`M'-ipm`I'-continua-no_outl-modPP-modPP.tex", ///
// 			mtitles("Esp. 4" "Esp. 5") ///
// 			nonum ///
// 			replace main(b %6.4f) aux(se %6.4f) ///
// 			star(* 0.10 ** 0.05 *** 0.01) compress ///
// 			gap nonotes noobs ///
// 			scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFU EF CUB" "TREND Tendencia" "CLDEPT Cluster Dep." "CLMUN Cluster Mun." "TRUNC Truncado") ///
// 			note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
	}
	esttab eesp4_1 eesp5_1 eesp4_2 eesp5_2 using "${table_output}/_modelo`M'-continua-no_outl-modPP.tex", ///
			mtitles("Esp. 4" "Esp. 5" "Esp. 4" "Esp. 5") ///
			mgroups("IPM 1" "IPM 2", pattern(1 0 1 0) ///
				prefix(\multicolumn{@span}{c}{) suffix(})   ///
				span erepeat(\cmidrule(lr){@span})) ///
			nonum ///
			replace main(b %6.4f) aux(se %6.4f) ///
			star(* 0.10 ** 0.05 *** 0.01) compress ///
			gap nonotes noobs ///
			scalars("CM Media Control" "OBS Obs." "EFT EF Año" "EFU EF CUB" "TREND Tendencia" "CLDEPT Cluster Dep." "CLMUN Cluster Mun." "TRUNC Truncado") ///
			note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")		
	//est clear
}







*-------------------------------------------------------------------------------
**# Exportar gráfica de efectos dinámicos para modelo 1: AAI vs Nada
*-------------------------------------------------------------------------------
* IPM 1
	estimates use "${dir_estimaciones}/esp4-model1-IPM 1-continua.ster"
	estat event, window(-6 6)
	csdid_plot, title("Sin truncar") aspect(1.3) name(a, replace)

	estimates use "${dir_estimaciones}/esp5-model1-IPM 1-continua.ster"
	estat event, window(-6 6)
	csdid_plot, title("Truncado") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("IPM 1") name(One, replace)

* IPM 2
	estimates use "${dir_estimaciones}/esp4-model1-IPM 2-continua.ster"
	estat event, window(-6 6)
	csdid_plot, title("Sin truncar") aspect(1.3) name(c, replace)

	estimates use "${dir_estimaciones}/esp5-model1-IPM 2-continua.ster"
	estat event, window(-6 6)
	csdid_plot, title("Truncado") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("IPM 2") name(Two, replace)
	
	grc1leg One Two, ycommon title("AAI vs No recibió ningún beneficio") ///
		caption("AAI vs Nada", color(gs15%50))
	graph export "${output_path}/efectos dinamicos/efectos_dinamicos-model1.jpg", replace
	
	
*-------------------------------------------------------------------------------
**# Exportar gráfica de efectos dinámicos para modelo 2: SA vs AAI
*-------------------------------------------------------------------------------
* IPM 1
	estimates use "${dir_estimaciones}/esp4-model2-IPM 1-continua.ster"
	estat event, window(-6 6)
	csdid_plot, title("Sin truncar") aspect(1.3) name(a, replace) ///
	ylabel(-0.15(0.05)0.05) yscale(range(-0.15(0.05)0.05))

	estimates use "${dir_estimaciones}/esp5-model2-IPM 1-continua.ster"
	estat event, window(-6 6)
	csdid_plot, title("Truncado") aspect(1.3) name(b, replace) ///
	ylabel(-0.15(0.05)0.05) yscale(range(-0.15(0.05)0.05))
	
	grc1leg a b, ycommon row(1) title("IPM 1") name(One, replace)

* IPM 2
	estimates use "${dir_estimaciones}/esp4-model2-IPM 2-continua.ster"
	estat event, window(-6 6)
	csdid_plot, title("Sin truncar") aspect(1.3) name(c, replace) ///
	ylabel(-0.15(0.05)0.05) yscale(range(-0.15(0.05)0.05))

	estimates use "${dir_estimaciones}/esp5-model2-IPM 2-continua.ster"
	estat event, window(-6 6)
	csdid_plot, title("Truncado") aspect(1.3) name(d, replace) ///
	ylabel(-0.15(0.05)0.05) yscale(range(-0.15(0.05)0.05))
	
	grc1leg c d, ycommon row(1) title("IPM 2") name(Two, replace)
	
	grc1leg One Two, ycommon title("SA vs AAI") caption("SA vs AAI", color(gs15%50))
	graph export "${output_path}/efectos dinamicos/efectos_dinamicos-model2.jpg", replace



*-------------------------------------------------------------------------------
**# Exportar gráfica de efectos dinámicos para modelo 3': PP
*-------------------------------------------------------------------------------
* IPM 1
	estimates use "${dir_estimaciones}/esp4-model3prima-IPM 1-continua.ster"
	estat event, window(-5 5)
	csdid_plot, title("Sin truncar") aspect(1.3) name(a, replace)

	estimates use "${dir_estimaciones}/esp5-model3prima-IPM 1-continua.ster"
	estat event, window(-3 3)
	csdid_plot, title("Truncado") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("IPM 1") name(One, replace)

* IPM 2
	estimates use "${dir_estimaciones}/esp4-model3prima-IPM 2-continua.ster"
	estat event, window(-5 5)
	csdid_plot, title("Sin truncar") aspect(1.3) name(c, replace)

	estimates use "${dir_estimaciones}/esp5-model3prima-IPM 2-continua.ster"
	estat event, window(-3 3)
	csdid_plot, title("Truncado") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("IPM 2") name(Two, replace)
	
	grc1leg One Two, ycommon title("PP&AAI vs AAI") caption("PP", color(gs15%50))
	graph export "${output_path}/efectos dinamicos/efectos_dinamicos-model3prima.jpg", replace

*-------------------------------------------------------------------------------
**# Exportar gráfica de efectos dinámicos para modelo 4': PPSA
*-------------------------------------------------------------------------------
* IPM 1
	estimates use "${dir_estimaciones}/esp4-model4prima-IPM 1-continua.ster"
	estat event, window(-5 5)
	csdid_plot, title("Sin truncar") aspect(1.3) name(a, replace)

	estimates use "${dir_estimaciones}/esp5-model4prima-IPM 1-continua.ster"
	estat event, window(-3 3)
	csdid_plot, title("Truncado") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("IPM 1") name(One, replace)

* IPM 2
	estimates use "${dir_estimaciones}/esp4-model4prima-IPM 2-continua.ster"
	estat event, window(-5 5)
	csdid_plot, title("Sin truncar") aspect(1.3) name(c, replace)

	estimates use "${dir_estimaciones}/esp5-model4prima-IPM 2-continua.ster"
	estat event, window(-3 3)
	csdid_plot, title("Truncado") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("IPM 2") name(Two, replace)
	
	grc1leg One Two, ycommon title("PP&SA+AAI vs AAI") caption("PPSA", color(gs15%50))
	graph export "${output_path}/efectos dinamicos/efectos_dinamicos-model4prima.jpg", replace

*-------------------------------------------------------------------------------
**# Exportar gráfica de efectos dinámicos para modelo 5': PPSA
*-------------------------------------------------------------------------------
* IPM 1
	estimates use "${dir_estimaciones}/esp4-model5prima-IPM 1-continua.ster"
	estat event, window(-5 5)
	csdid_plot, title("Sin truncar") aspect(1.3) name(a, replace)

	estimates use "${dir_estimaciones}/esp5-model5prima-IPM 1-continua.ster"
	estat event, window(-3 3)
	csdid_plot, title("Truncado") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("IPM 1") name(One, replace)

* IPM 2
	estimates use "${dir_estimaciones}/esp4-model5prima-IPM 2-continua.ster"
	estat event, window(-5 5)
	csdid_plot, title("Sin truncar") aspect(1.3) name(c, replace)

	estimates use "${dir_estimaciones}/esp5-model5prima-IPM 2-continua.ster"
	estat event, window(-3 3)
	csdid_plot, title("Truncado") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("IPM 2") name(Two, replace)
	
	grc1leg One Two, ycommon title("PP&SA+AAI vs AAI+SA") caption("PPSA v SA", color(gs15%50))
	graph export "${output_path}/efectos dinamicos/efectos_dinamicos-model5prima.jpg", replace	

*-------------------------------------------------------------------------------
**# Exportar gráfica de efectos dinámicos para modelo 6': PPSA
*-------------------------------------------------------------------------------
* IPM 1
	estimates use "${dir_estimaciones}/esp4-model6prima-IPM 1-continua.ster"
	estat event, window(-5 5)
	csdid_plot, title("Sin truncar") aspect(1.3) name(a, replace)

	estimates use "${dir_estimaciones}/esp5-model6prima-IPM 1-continua.ster"
	estat event, window(-3 3)
	csdid_plot, title("Truncado") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("IPM 1") name(One, replace)

* IPM 2
	estimates use "${dir_estimaciones}/esp4-model6prima-IPM 2-continua.ster"
	estat event, window(-5 5)
	csdid_plot, title("Sin truncar") aspect(1.3) name(c, replace)

	estimates use "${dir_estimaciones}/esp5-model6prima-IPM 2-continua.ster"
	estat event, window(-3 3)
	csdid_plot, title("Truncado") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("IPM 2") name(Two, replace)
	
	grc1leg One Two, ycommon title("PP&SA+AAI vs AAI+PP") caption("PPSA v PP", color(gs15%50))
	graph export "${output_path}/efectos dinamicos/efectos_dinamicos-model6prima.jpg", replace	

	
local M=4
* CON OUTLIERS
forvalues E=4/5{
	forvalues I=1/2{
		estimates use "${dir_estimaciones}/esp`E'-model`M'prima-IPM `I'-continua-no_outliers.ster"
		estat simple, estore (esp`E'_modelo`M'_ipm`I')
		estat event, window(-5 5)
		csdid_plot, title("Especificación `E'-Modelo `M'" "IPM `I'") ///
			name(I`I', replace) //legend(pos(6))
	}
	grc1leg I1 I2, ycommon name(S`E'M`M'common, replace) ///
			note("Variable IPM continua sin outliers")
	graph export "${output}/Estimación_modelos/graficos/esp`E'-modelo`M'prima-continua-no_outliers.jpg", replace
}
