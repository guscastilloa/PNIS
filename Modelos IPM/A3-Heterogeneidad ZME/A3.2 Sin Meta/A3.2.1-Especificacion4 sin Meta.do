/*
AUTOR:
	Gustavo Castillo

DESCRIPCIÓN.
	En este script se realizan las estimaciones del modelo 2 par la estimación
	4 dividiando las muestras sobre las que se estima en aquellos CUBs 
	en zonas de manejo especial (ZME) y en aquellos que no estan en una ZME pero
	excluyendo todos los CUBs que están en el departamento del Meta.
*/

//   ______                 _  _   
//  |  ____|               | || |  
//  | |__    ___  _ __     | || |_ 
//  |  __|  / __|| '_ \    |__   _|
//  | |____ \__ \| |_) |_     | |  
//  |______||___/| .__/(_)    |_|  
//               | |               
//               |_|               

* With trend
* Cluster por municipio

* Preámbulo después de correr _master.do
global output_path "${output}/Estimación_modelos" 
global n_esp 4
global especificacion "esp${n_esp}"
use "${datafolder}/base_estimaciones_simci.dta", clear
tab zme	zona_zme
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

*------------------------------------------------------------------------------
**# Estimar modelo 2 especificación 4 excluyendo el departamento del Meta, cuyo
	* código del DANE es el 50.
*------------------------------------------------------------------------------
tab dpto_cnmbr zona_zme if year==2017 & (ejecucion_PNIS==1 | ejecucion_PNIS==2)
	// 238 CUBs que estan actualmente en ZME son del META


* Preparar base completa por si es necesesario recuperarla 
tempfile completo sin_meta
save `completo'

* Quitar todas las obsevaciones del Meta
// tab year dpto_ccdgo if dpto_ccdgo ==50
//            | dpto_cnmbr
//       year |      META |     Total
// -----------+-----------+----------
//       2016 |     5,788 |     5,788 
//       2017 |     5,788 |     5,788 
//       2018 |     5,788 |     5,788 
//       2019 |     5,788 |     5,788 
//       2020 |     5,788 |     5,788 
//       2021 |     5,788 |     5,788 
//       2022 |     5,788 |     5,788 
// -----------+-----------+----------
//      Total |    40,516 |    40,516 

drop if dpto_ccdgo ==50
save `sin_meta'
log using "${projectfolder}/Log/A3-Especificacion4-sin_meta.smcl", replace
timer clear
local timer_counter = 1

* Modelo 2
forvalues MODELO=2/2{
	local modelo "model`MODELO'"
	* Crear locals de grupos de control y tratamiento para estimación
	local grupo_control=N[`MODELO',1]
	local grupo_tratamiento=N[`MODELO',2]
	di "M`MODELO': Control: `grupo_control' Tratamiento: `grupo_tratamiento'"
	
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
		
		* Iterar sobre ZME - - - - - - - - - - - - - - - - - -
		forvalues ZME=0/1{
			di _col(4) "ZME `ZME'"
			qui tempfile completo mod2 mod3 
			qui save `completo' // Guardar base completa
			
			keep if zme ==`ZME'
			qui save `mod2' // Guardar base con subset ZME respectiva
			
			* Con outliers + + + + + + + + + + + + + + + + + + + + 
			di _col(6) "Con outliers"
			global estimate_file_name "${especificacion}-`modelo'-${tipm}-continua-Z`ZME'-sin_meta"
			
			qui timer on `timer_counter'
			csdid IPM_`ipm' trend if ///
				ejecucion_PNIS == `grupo_control' | ejecucion_PNIS == `grupo_tratamiento', ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(`year_treatment_var')
			estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
			timer off `timer_counter'
			di _col(7) "It (`timer_counter') successful. (M,IPM,OUT,ZME)=(`MODELO',`ipm',con,`ZME')"  _newline(2)
			di _col(7) "C: `grupo_control' T: `grupo_tratamiento' gvar: `year_treatment_var'"
			di "${estimate_file_name}"
			local timer_counter=`timer_counter'+1

			
			* SIN outliers + + + + + + + + + + + + + + + + + + + + 
			preserve
			di _col(6) "Sin outliers, (drop for IPM `ipm'):'"
			global estimate_file_name "${especificacion}-`modelo'-${tipm}-continua-no_outliers-Z`ZME'-sin_meta"
			
			drop if es_outlier_IPM_1==1 & `ipm'==1
			drop if es_outlier_IPM_2==1 & `ipm'==2
			qui timer on `timer_counter'
			csdid IPM_`ipm' trend if ///
				ejecucion_PNIS == `grupo_control' | ejecucion_PNIS == `grupo_tratamiento', ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(`year_treatment_var')
			estimates save "${output_path}/estimaciones/${estimate_file_name}.ster", replace
			timer off `timer_counter'
			di _col(7) "It (`timer_counter') successful. (M,IPM,OUT,ZME)=(`MODELO',`ipm',sin,`ZME')" _newline(2)
			di "${estimate_file_name}"
			restore 
			local timer_counter=`timer_counter'+1
			
			use `completo', clear // Cargar de nuevo base completa
		}
		
	}
 di _newline(5)
}
use `completo', clear
timer list
capture log close
