

* Preámbulo luego de ejecutar _master.do
global output_path "${output}/Modelos IPM/_heterogeneidad proyectos rural/estimaciones" 

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
  
*-------------------------------------------------------------------------------
**# Estimar modelo para beneficiarios que recibieron 1 o más proyectos rurales.
*-------------------------------------------------------------------------------
// Mantener solo observaciones con 1 o más proyectos de desarrollo rural.
global n_prural 1

preserve 
keep if proyectos_rural==${n_prural}
tab year ejecucion_PNIS_prima
tab year_t_PP_AAI ejecucion_PNIS_prima if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3

* Definir macros para archivo
global ESP "esp4"
global modelo "AAI_PP"
global PRURAL "prural${n_prural}"


  * Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
    forvalues ipm=1/2{
      global tipm="IPM `ipm'"
      di "> IPM `ipm'"
      
      global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${PRURAL}"
      
      csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 3, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PP_AAI)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	

restore	
di _newline(9)


*-------------------------------------------------------------------------------
**# Estimar modelo para beneficiarios que no recibieron proyectos rurales
*-------------------------------------------------------------------------------
* 2. Mantener solo observaciones sin proyectos de desarrollo rural.
global n_prural 0

preserve 
keep if proyectos_rural==${n_prural}
tab year ejecucion_PNIS_prima
tab year_t_PP_AAI  ejecucion_PNIS_prima if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3

* Definir macros para archivo
global ESP "esp4"
global modelo "AAI_PP"
global PRURAL "prural${n_prural}"


  * Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
    forvalues ipm=1/2{
      global tipm="IPM `ipm'"
      di "> IPM `ipm'"
      
      global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${PRURAL}"
      
      csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 3, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PP_AAI)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	

restore	
di _newline(9)
