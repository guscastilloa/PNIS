/*
AUTOR: Gustavo Castillo

DESCRIPCIÓN:
	En el siguiente script se crean las variables de cohorte de tratamiento
	para cada uno de los modelos (parejas de comparación). Por ejemplo, para el
	Modelo 1 que compara no recibir nada contra recibir únicamente AAI se crea
	una variable dummy t_AAI_Nada que es 1 cuando un CUB en un año respectivo
	supera el umbral del monto de tratamiento de $2.000.000 (con >=) y si en 
	el período inmediatamente anterior ha recibido estrictamente menor al umbral.
	Luego a partir de esta variable se crea year_t_AAI_Nada que indica el año 
	a partir del cual t_AAI_Nada es 1 y en el año anterior t_AAI_Nada==0. Esta
	variable nos indica la cohorte de tratamiento a la que pertenece ese CUB,
	es decir, a partir de qué año un CUB se considera tratado (para el componente
	respectivo que se está observando).
	
	Al final se guarda la base de datos resultante pues con esta base es que
	se realizarán las estimaciones de los modelos. 
*/


clear
set more off
set scheme s1mono

* Fijar globals necesarios al cambiar de directorio.
global output_path "${projectfolder}/Output/Estimación_modelos"
use "${projectfolder}/Datos/db_sisben_pnis_panel_VF.dta", clear


drop if u1 == 2 // PNIS que no están en Sisbén o que no tienen información del Sisbén desde 2013

/// Quedarnos solo con cub con información desde 2013 

bysort cub: egen num_total = count(activo)
keep if num_total >= 10

/// Estadísticas descriptivas del IPM por grupo de ejecución del PNIS 

keep if activo == 1
keep if year > 2012

/// Arreglar municipios y departamentos cuya información falta pre 2016
bysort cub: ereplace cod_mpio = mean(cod_mpio)
bysort cub: ereplace dpto_ccdgo=mean(dpto_ccdgo)

/// Crear tendencia lineal por departamento 

egen trend= group(dpto_ccdgo year)


//                        _        _             
//  _ __ ___    ___    __| |  ___ | |  ___   ___ 
// | '_ ` _ \  / _ \  / _` | / _ \| | / _ \ / __|
// | | | | | || (_) || (_| ||  __/| || (_) |\__ \
// |_| |_| |_| \___/  \__,_| \___||_| \___/ |___/
//                                              

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
**# Bookmark #2: A continuación hay un paso que debe discutirse y es la definición conjunta
* de la recepción de PPCC+SA. 
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

* Llenar el sexo para el 2015
sort cub year
tab year sexo_titular, miss
bysort cub: ereplace sexo_titular=mean(sexo_titular)
tab year sexo_titular, miss

save "${projectfolder}/Datos/base_estimaciones_gus.dta", replace



use "${projectfolder}/Datos/base_estimaciones_gus.dta", clear
*-------------------------------------------------------------------------------
**# Base con PP agrupado
*-------------------------------------------------------------------------------

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


save "${projectfolder}/Datos/base_estimaciones_pp.dta", replace




*------------------------------------------------------------------------------
**# Preparar base y variables para la estimación de los modelos ZME
*------------------------------------------------------------------------------
	tempfile master using 	
	
	* Cargar base SIMCI y crear variable indicadora
	use "${datafolder}/db_join_simci_&_pnis.dta", clear
	// elabel save zona_l using labels
	rename zona zona_zme
	gen zme=1 if zona_zme>0
	replace zme=0 if zme==.

	label define zme_l 0 "No ZME" 1 "En ZME"
	label values zme zme_l
	tab zme

	tab zona_zme zme
	save `using'

	* Cargar panel de estimaciones y merges
	use "${projectfolder}/Datos/base_estimaciones_pp.dta", clear
	merge m:1 cub using `using', gen(u2)
	save `master'
	tab zona_zme zme

	* Guardar base para estimaciones
	save "${datafolder}/base_estimaciones_simci_pp.dta", replace

	tab year if u2==3

	tab year zme, miss

* End of file
