/*
AUTOR:
	Gustavo Castillo

DESCRIPCIÓN.
	En este script se realizan las estimaciones de los modelos 1-7 de IPM
	4 par la especificaciones 5 dividiando las muestras sobre las que se 
	estima por el sexo del CUB.
*/

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

* Preámbulo después de correr _master.do
capture log close


global output_path "${output}/Estimación_modelos/estimaciones/_heterogeneidad sexo" 
global n_esp 5
global especificacion "esp${n_esp}"
use "${datafolder}/base_estimaciones_gus.dta", clear

*-------------------------------------------------------------------------------
**# Estimar modelos 1 a 7 en un loop 
*--------------------------------------------------------------------------------
log using "${projectfolder}/Log/A4-Especificacion5.smcl", replace
* Definir matriz N que nos relacione número de modelo con grupos de comparación
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

* Iterar de modelo 1 al 7
timer clear
local timer_counter = 1
tempfile completo m1 m2 m3 m4a6 m7
save `completo'
forvalues MODELO=1/7{
	local modelo "model`MODELO'"
	* Crear locals de grupos de control y tratamiento para estimación
	local grupo_control=N[`MODELO',1]
	local grupo_tratamiento=N[`MODELO',2]
	di "M`MODELO': C: `grupo_control' TR: `grupo_tratamiento'"
	
	* Crear local de variable de cohorte de tratamiento para el loop
	if `MODELO'==1{
		local year_treatment_var="year_t_AAI_Nada"
	}
	else if `MODELO'==2{
		local year_treatment_var="year_t_SA_AAI"
	}
	else if `MODELO'==3{
		local year_treatment_var="year_t_PPCC_AAI"
	}
	else if `MODELO'==4 | `MODELO'==5 | `MODELO'==6{ 
		local year_treatment_var="year_t_PPCCySA"
	}
	else if `MODELO'==7{
		local year_treatment_var="year_t_PPCL_PPCCySA"
	}
	di " > `year_treatment_var'"
	
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
	forvalues ipm=1/2{
		global tipm="IPM `ipm'"
		di _col(2) "IPM `ipm'"
		
		* Iterar sobre Sexo - - - - - - - - - - - - - - - - - -
		forvalues SEX=0/1{
			di _col(4) "Sexo `SEX'"

			* TRUNCAR VALORES PARA CADA MODELO
			drop if `MODELO'==1 & year_t_AAI_Nada==2022
			drop if `MODELO'==2 & ((year_t_SA_AAI==2021) | ///
							       (year_t_SA_AAI==2022))
			drop if `MODELO'==3 & ((year_t_PPCC_AAI==2018) | ///
								   (year_t_PPCC_AAI==2019) | ///
								   (year_t_PPCC_AAI==2020))
			drop if (`MODELO'==4 | `MODELO'==5 |`MODELO'==6)  & ///
				((year_t_PPCCySA==2018) | ///
				 (year_t_PPCCySA==2019) | ///
				 (year_t_PPCCySA==2020))
			drop if `MODELO'==7 & ((year_t_PPCL_PPCCySA==2017) | ///
								   (year_t_PPCL_PPCCySA==2018) | ///
								   (year_t_PPCL_PPCCySA==2019) | ///
								   (year_t_PPCL_PPCCySA==2020))
			di "Keep if sex=`SEX'"
			keep if sexo_titular ==`SEX'
			save `m2', replace // Guardar base con subset de sexo y valores truncados
			
			* Con outliers + + + + + + + + + + + + + + + + + + + + 
			di _col(6) "Con outliers"
			global estimate_file_name "${especificacion}-`modelo'-${tipm}-continua-S`SEX'"
			
			qui timer on `timer_counter'
			csdid IPM_`ipm' trend if ///
				ejecucion_PNIS == `grupo_control' | ejecucion_PNIS == `grupo_tratamiento', ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(`year_treatment_var')
			estimates save "${output_path}/${estimate_file_name}.ster", replace
			timer off `timer_counter'
			di _col(7) "Iteration (`timer_counter') successful. (M,IPM,OUT,SEX)=(`MODELO',`ipm',con,`SEX')"  _newline(2)
			di _col(7) "C: `grupo_control' T: `grupo_tratamiento' gvar: `year_treatment_var'"
			di "${estimate_file_name}"
			local timer_counter=`timer_counter'+1

			
			* SIN outliers + + + + + + + + + + + + + + + + + + + + 
			preserve
			di _col(6) "Sin outliers, (drop for IPM `ipm'):'"
			global estimate_file_name "${especificacion}-`modelo'-${tipm}-continua-no_outliers-S`SEX'"
			
			drop if es_outlier_IPM_1==1 & `ipm'==1
			drop if es_outlier_IPM_2==1 & `ipm'==2
			qui timer on `timer_counter'
			csdid IPM_`ipm' trend if ///
				ejecucion_PNIS == `grupo_control' | ejecucion_PNIS == `grupo_tratamiento', ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(`year_treatment_var')
			estimates save "${output_path}/${estimate_file_name}.ster", replace
			timer off `timer_counter'
			di _col(7) "Iteration (`timer_counter') successful. (M,IPM,OUT,SEX)=(`MODELO',`ipm',con,`SEX')"  _newline(2)
			di "${estimate_file_name}"
			restore 
			local timer_counter=`timer_counter'+1
			
			qui use `completo', clear // Cargar de nuevo base completa
		}
		
	}
 di _newline(5)
}
timer list

log close
