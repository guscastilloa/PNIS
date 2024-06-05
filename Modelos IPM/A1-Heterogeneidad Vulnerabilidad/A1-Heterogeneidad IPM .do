/*
DESCRIPCIÓN:
	En este script se crea una variable que divide la muestra entre aquellos
	CUBs que están por encima (o igual) de la mediana del IPM (1 y 2) y aquellos
	por debajo. Usando esta variable se vuelve a estimar el modelo 4 para cada
	una de estas sub muestras por separado.
*/


* Preámbulo luego de correr _main.do
use "${projectfolder}/Datos/base_estimaciones_gus.dta", clear
capture log close
// log using "${projectfolder}/Heterogeneidad IPM", replace
tempfile mod0 uno dos tres cuatro cinco seis
* Crear variable que define si el CUB tiene nivel de IPM 1 y 2 mayor a la
* mediana del IPM (el 2015). 

capture drop h_IPM_1 h_IPM_2
forvalues I=1/2{
	sum IPM_`I' if year==2015, d
	di r(p50)
	gen h_IPM_`I' = 1 if IPM_`I' >=r(p50) & year==2015
	bysort cub: ereplace h_IPM_`I'=mean(h_IPM_`I')
	bysort cub: replace h_IPM_`I' = 0 if h_IPM_`I'==.
}

tab year h_IPM_1, miss
tab year h_IPM_2, miss

global switch_estimation_on 1 // Fijar a 1 para estimar modelos.

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
global grupo_tratamiento 4					// Global para grupo tratamiento regresió

//   ______                 _  _   
//  |  ____|               | || |  
//  | |__    ___  _ __     | || |_ 
//  |  __|  / __|| '_ \    |__   _|
//  | |____ \__ \| |_) |_     | |  
//  |______||___/| .__/(_)    |_|  
//               | |               
//               |_|               
global n_esp 4
global especificacion "esp${n_esp}"

*-------------------------------------------------------------------------------
* Estimando modelos para la submuestra que está por encima de la mediana, i.e
* para hogares "más pobres": h_IPM_X == 1
*-------------------------------------------------------------------------------
**# A1. Estimar modelo 4 Esp 4 con outliers para h_IPM_X == 1
	
	* ESTIMACIÓN:
	if ${switch_estimation_on}==1{
		* IPM 1
		preserve
		keep if h_IPM_1 ==1
		global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-h1"
		set rmsg on
			csdid IPM_1 trend if ///
				ejecucion_PNIS== ${grupo_control} | ejecucion_PNIS== ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore
		
		* IPM 2
		global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-h1"
		preserve
		keep if h_IPM_2 ==1
		set rmsg on
			csdid IPM_2 trend if ///
				ejecucion_PNIS== ${grupo_control} | ejecucion_PNIS== ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore
	}

**# A2. Estimar modelo 4 Esp 4 sin outliers para h_IPM_X == 1
	
	if ${switch_estimation_on}==1{
		* IPM 1
		global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-no_outliers-h1"
		preserve
		keep if h_IPM_1 ==1
		drop if es_outlier_IPM_1==1
		set rmsg on
			csdid IPM_1 trend if ///
				ejecucion_PNIS== ${grupo_control} | ejecucion_PNIS== ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore

		* IPM 2
		global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-no_outliers-h1"
		preserve
		keep if h_IPM_2 ==1
		drop if es_outlier_IPM_2==1
		set rmsg on
			csdid IPM_2 trend if ///
				ejecucion_PNIS== ${grupo_control} | ejecucion_PNIS== ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore
	}

*-------------------------------------------------------------------------------
* Estimando modelos para la submuestra que está estrictamente debajo de la mediana, i.e
* para hogares menos pobres, aquellos con niveles de IPM menores.
*-------------------------------------------------------------------------------

**# A3. Estimar modelo 4 Esp 4 con outliers para h_IPM_X == 0
	
	* ESTIMACIÓN:
	/// Estimación C&S - PPCC vs AAI
	if ${switch_estimation_on}==1{
		* IPM 1
		preserve
		keep if h_IPM_1 ==0
		global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-h0"
		set rmsg on
			csdid IPM_1 trend if ///
				ejecucion_PNIS== ${grupo_control} | ejecucion_PNIS== ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore
		
		* IPM 2
		global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-h0"
		preserve
		keep if h_IPM_2 ==0
		set rmsg on
			csdid IPM_2 trend if ///
				ejecucion_PNIS== ${grupo_control} | ejecucion_PNIS== ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore
	}

**# A4. Estimar modelo 4 Esp 4 sin outliers para h_IPM_X == 0
	
	if ${switch_estimation_on}==1{
		* IPM 1
		global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-no_outliers-h0"
		preserve
		keep if h_IPM_1 ==0
		drop if es_outlier_IPM_1==1
		set rmsg on
			csdid IPM_1 trend if ///
				ejecucion_PNIS== ${grupo_control} | ejecucion_PNIS== ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore

		* IPM 2
		global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-no_outliers-h0"
		preserve
		keep if h_IPM_2 ==0
		drop if es_outlier_IPM_2==1
		set rmsg on
			csdid IPM_2 trend if ///
				ejecucion_PNIS== ${grupo_control} | ejecucion_PNIS== ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore
	}



//   ______                 _____ 
//  |  ____|               | ____|
//  | |__    ___  _ __     | |__  
//  |  __|  / __|| '_ \    |___ \ 
//  | |____ \__ \| |_) |_   ___) |
//  |______||___/| .__/(_) |____/ 
//               | |              
//               |_|              
global n_esp 5
global especificacion "esp${n_esp}"
save `mod0'
*-------------------------------------------------------------------------------
* Estimando modelos para la submuestra que está por encima de la mediana, i.e
* para hogares "más pobres": h_IPM_X == 1
*-------------------------------------------------------------------------------

**# B1. Estimar modelo 4 Esp 5 con outliers para h_IPM_X == 1
	
	use `mod0'
	* TRUNCAR:
	drop if (year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)
	save `uno'
	
	* ESTIMACIÓN:
	if ${switch_estimation_on}==1{
		* IPM 1
		preserve
		global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-h1"
		keep if h_IPM_1 ==1
		set rmsg on
			csdid IPM_1 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore 
		
		* IPM 2
		preserve
		keep if h_IPM_2 ==1
		global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-h1"
		set rmsg on
			csdid IPM_2 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore
	}
	
**# B2. Estimar modelo 4 Esp 5 sin outliers para h_IPM_X == 1
	
	use `mod0'
	* TRUNCAR:
	drop if (year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)
	save `dos'
	
	* ESTIMACIÓN:
	if ${switch_estimation_on}==1{
		* IPM 1
		preserve
		global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-no_outliers-h1"
		keep if h_IPM_1 ==1
		drop if es_outlier_IPM_1==1
		set rmsg on
			csdid IPM_1 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore 
		
		* IPM 2
		preserve
		keep if h_IPM_2 ==1
		drop if es_outlier_IPM_2==1
		global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-no_outliers-h1"
		set rmsg on
			csdid IPM_2 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore
	}
*-------------------------------------------------------------------------------
* Estimando modelos para la submuestra que está estrictamente debajo de la mediana, i.e
* para hogares menos pobres, aquellos con niveles de IPM menores.
*-------------------------------------------------------------------------------
**# B3. Estimar modelo 4 Esp 5 con outliers para h_IPM_X == 0
	
	use `mod0'
	* TRUNCAR:
	drop if (year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)
	save `tres'

	* ESTIMACIÓN:
	if ${switch_estimation_on}==1{
		* IPM 1
		preserve
		global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-h0"
		keep if h_IPM_1 ==0
		set rmsg on
			csdid IPM_1 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore 
		
		* IPM 2
		preserve
		keep if h_IPM_2 ==0
		global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-h0"
		set rmsg on
			csdid IPM_2 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore
	}
	
**# B4. Estimar modelo 4 Esp 5 sin outliers para h_IPM_X == 0
	
	use `mod0'
	* TRUNCAR:
	drop if (year_t_PPCCySA==2018) | (year_t_PPCCySA==2019) | (year_t_PPCCySA==2020)
	save `cuatro'
	
	if ${switch_estimation_on}==1{
		* IPM 1
		preserve
		global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-no_outliers-h0"
		keep if h_IPM_1 ==0
		drop if es_outlier_IPM_1==1
		set rmsg on
			csdid IPM_1 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore 
		
		* IPM 2
		preserve
		keep if h_IPM_2 ==0
		drop if es_outlier_IPM_2==1
		global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
		global estimate_file_name "${especificacion}-${modelo}-${ipm}-continua-no_outliers-h0"
		set rmsg on
			csdid IPM_2 trend if ///
				ejecucion_PNIS == ${grupo_control} | ejecucion_PNIS == ${grupo_tratamiento}, ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(${year_treatment_var})
		set rmsg off
		estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
		restore
	}

// log close	
* End
