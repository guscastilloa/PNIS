/*
FECHA CREACIÓN:
	27/septiembre/2023
AUTOR:
	Gustavo Castillo
	
DESCRIPCIÓN.
	En este script se realizan las estimaciones del modelo 2 par la estimación
	4 dividiendo las muestras sobre las que se estima en aquellos CUBs 
	en zonas de manejo especial (ZME) y en aquellos que no estan en una ZME pero
	excluyendo todos los CUBs que están en parques (zona_zme==1). Esto a partir
	de la reunión del martes 26 de septiembre del 2023.
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
global output_path "${output}/Estimación_modelos/estimaciones/_heterogeneidad zme"
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
tempfile completo sin_parques
save `completo'

* Quitar todas las obsevaciones que están en parques
// . tab year zona_zme if zona_zme ==1, miss
//
//            | zme (zonas
//            | de manejo
//            | especial)
//       year |    Parque |     Total
// -----------+-----------+----------
//       2013 |     1,799 |     1,799 
//       2014 |     1,799 |     1,799 
//       2015 |     1,799 |     1,799 
//       2016 |     1,799 |     1,799 
//       2017 |     1,799 |     1,799 
//       2018 |     1,799 |     1,799 
//       2019 |     1,799 |     1,799 
//       2020 |     1,799 |     1,799 
//       2021 |     1,799 |     1,799 
//       2022 |     1,799 |     1,799 
//          . |     1,318 |     1,318 
// -----------+-----------+----------
//      Total |    19,308 |    19,308


drop if zona_zme ==1
keep if u2==3
* Revisar que panel esté balanceado
capture drop meanzme
bysort cub: egen meanzme = mean(zona_zme)
tab meanzme // No hay ningún número decimal, todos son enteros. Quedó balanceado.

save `sin_parques'
log using "${projectfolder}/Log/A3.3.1-Especificacion4-sin_parques.smcl", replace
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
			global estimate_file_name "${especificacion}-`modelo'-${tipm}-con_outliers-Z`ZME'-sin_parques"
			
			qui timer on `timer_counter'
			csdid IPM_`ipm' trend if ///
				ejecucion_PNIS == `grupo_control' | ejecucion_PNIS == `grupo_tratamiento', ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(`year_treatment_var')
			estimates save "${output_path}/${estimate_file_name}.ster", replace
			timer off `timer_counter'
			di _col(7) "It (`timer_counter') successful. (M,IPM,OUT,ZME)=(`MODELO',`ipm',con,`ZME')"  _newline(2)
			di _col(7) "C: `grupo_control' T: `grupo_tratamiento' gvar: `year_treatment_var'"
			di "${estimate_file_name}"
			local timer_counter=`timer_counter'+1

			
			* SIN outliers + + + + + + + + + + + + + + + + + + + + 
			preserve
			di _col(6) "Sin outliers, (drop for IPM `ipm'):'"
			global estimate_file_name "${especificacion}-`modelo'-${tipm}-sin_outliers-Z`ZME'-sin_parques"
			
			drop if es_outlier_IPM_1==1 & `ipm'==1
			drop if es_outlier_IPM_2==1 & `ipm'==2
			qui timer on `timer_counter'
			csdid IPM_`ipm' trend if ///
				ejecucion_PNIS == `grupo_control' | ejecucion_PNIS == `grupo_tratamiento', ///
				cluster(cod_mpio) ivar(cub) time(year) gvar(`year_treatment_var')
			estimates save "${output_path}/${estimate_file_name}.ster", replace
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
