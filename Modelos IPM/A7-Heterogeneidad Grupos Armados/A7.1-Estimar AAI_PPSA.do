/*
AUTOR:
	Gustavo Castillo

FECHA:
	5/oct/2023

DESCRIPCIÓN
	En este script se estima el modelo de IPM de PP&SA con AAI como control revisando
	la heterogeneidad de beneficiarios que se encuentran en uno de los siguientes
	3 grupos de municipios:
		- Sin grupos armados
		- Con un grupo armado
		- Con más de 1 grupo armado

*/

* Preámbulo luego de ejecutar _master.do
global output_path "${output}/Modelos IPM/_heterogeneidad proyectos rural/estimaciones" 

*-------------------------------------------------------------------------------
**# 1. Crear variables para estimación: ejecución con PP y cohortes de tratamiento
*-------------------------------------------------------------------------------
// Crear variable con PP agrupado
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

tab ejecucion_PNIS ejecucion_PNIS_prima


// 1. Crear tratamiento dummy
gen t_PP_AAI = . 
bysort cub: replace t_PP_AAI = 1 if ///
	(t_PPCC_AAI==1 | t_PPCL_PPCCySA==1)
replace t_PP_AAI = 0 if t_PP_AAI == . & ejecucion_PNIS_prima != .

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










*-------------------------------------------------------------------------------
**# 2. Estimar modelo para beneficiarios en municipios grupos_armados==0
*-------------------------------------------------------------------------------
// Mantener solo observaciones en municipios sin presencia de grupos armados
global n_grupoarmado 0

preserve 
keep if grupos_armados==${n_grupoarmado}
tab year ejecucion_PNIS_prima
tab year_t_PPySA ejecucion_PNIS_prima if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4

* Definir macros para archivo
global ESP "esp4"
global modelo "AAI_PPSA"
global PARMED "grupos_armados${n_grupoarmado}"


  * Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
    forvalues ipm=1/2{
      global tipm="IPM `ipm'"
      di "> IPM `ipm'"
     
      global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${PARMED}"
     
      csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 4, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPySA)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	

restore	
di _newline(9)


*-------------------------------------------------------------------------------
**# 3. Estimar modelo para beneficiarios en municipios grupos_armados==1
*-------------------------------------------------------------------------------
// Mantener solo observaciones en municipios con presencia de 1 solo grupo 
global n_grupoarmado 1

preserve 
keep if grupos_armados==${n_grupoarmado}
tab year ejecucion_PNIS_prima
tab year_t_PPySA ejecucion_PNIS_prima if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4

* Definir macros para archivo
global ESP "esp4"
global modelo "AAI_PPSA"
global PARMED "grupos_armados${n_grupoarmado}"


  * Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
    forvalues ipm=1/2{
      global tipm="IPM `ipm'"
      di "> IPM `ipm'"
     
      global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${PARMED}"
     
      csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 4, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPySA)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	

restore	
di _newline(9)


*-------------------------------------------------------------------------------
**# 4. Estimar modelo para beneficiarios en municipios grupos_armados==2
*-------------------------------------------------------------------------------
// Mantener solo observaciones en municipios con presencia de >1 grupo
global n_grupoarmado 2

preserve 
keep if grupos_armados==${n_grupoarmado}
tab year ejecucion_PNIS_prima
tab year_t_PPySA ejecucion_PNIS_prima if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4

* Definir macros para archivo
global ESP "esp4"
global modelo "AAI_PPSA"
global PARMED "grupos_armados${n_grupoarmado}"


  * Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
    forvalues ipm=1/2{
      global tipm="IPM `ipm'"
      di "> IPM `ipm'"
     
      global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${PARMED}"
     
      csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 4, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPySA)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	

restore	
di _newline(9)
