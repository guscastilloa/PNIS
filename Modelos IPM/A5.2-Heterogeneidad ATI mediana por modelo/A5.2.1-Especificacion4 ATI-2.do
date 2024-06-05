/*
AUTOR:
	Gustavo Castillo

FECHA CREACIÓN:
	27/septiembre/2023
	
DESCRIPCIÓN.
	En este script se realizan las estimaciones de los modelos 1-7 de IPM
	para la especificació 4 dividiendo las muestras sobre las que se 
	estima por la recepción de ATI. En la reunión del 26 de septiembre se
	llegó a la idea de redefinir la mediana de recepción de ati (ati_porc)
	calculándo la mediana dentro de cada modelo, i.e. condicionando en los 
	dos grupos de control y tratamiento al calcularla. Así se siguen manteniendo
	los niveles de ATI de la siguiente forma:
		- 0= No recibió nada
		- 1= Recibió debajo de la mediana (<)
		- 2= Recibió mayor o igual a la mediana (≥)
	
	En este script únicamente se estiman los modelos para los que la recepción 
	de ATI fue 0=Nada. 
	
	En la reunión del miércoles 21 de septiembre se decidió estimar estos modelos:
		- Con outliers
		- sin tendencia
		- Solo la especificación 4
*/

//   ______                 _  _   
//  |  ____|               | || |  
//  | |__    ___  _ __     | || |_ 
//  |  __|  / __|| '_ \    |__   _|
//  | |____ \__ \| |_) |_     | |  
//  |______||___/| .__/(_)    |_|  
//               | |               
//               |_|               
* Without trend
* Cluster por municipio

* Preámbulo después de correr _master.do
capture log close
log using "${projectfolder}/Log/A5-Especificacion4_ati2-mediana_por_modelo.smcl", replace


global output_path "${output}/Estimación_modelos/estimaciones/_heterogeneidad ati/Mediana por modelo" 
global n_esp 4
global n_ati 2
global ESP "esp${n_esp}"
global ATI "ati${n_ati}"
use "${datafolder}/base_estimaciones_gus.dta", clear

*-------------------------------------------------------------------------------
**# Estimar modelos 1 a 7
*-------------------------------------------------------------------------------
                                                                                     
//                                                                                     
//                AAA         TTTTTTTTTTTTTTTTTTTTTTTIIIIIIIIII      222222222222222    
//               A:::A        T:::::::::::::::::::::TI::::::::I     2:::::::::::::::22  
//              A:::::A       T:::::::::::::::::::::TI::::::::I     2::::::222222:::::2 
//             A:::::::A      T:::::TT:::::::TT:::::TII::::::II     2222222     2:::::2 
//            A:::::::::A     TTTTTT  T:::::T  TTTTTT  I::::I                   2:::::2 
//           A:::::A:::::A            T:::::T          I::::I                   2:::::2 
//          A:::::A A:::::A           T:::::T          I::::I                2222::::2  
//         A:::::A   A:::::A          T:::::T          I::::I           22222::::::22   
//        A:::::A     A:::::A         T:::::T          I::::I         22::::::::222     
//       A:::::AAAAAAAAA:::::A        T:::::T          I::::I        2:::::22222        
//      A:::::::::::::::::::::A       T:::::T          I::::I       2:::::2             
//     A:::::AAAAAAAAAAAAA:::::A      T:::::T          I::::I       2:::::2             
//    A:::::A             A:::::A   TT:::::::TT      II::::::II     2:::::2       222222
//   A:::::A               A:::::A  T:::::::::T      I::::::::I     2::::::2222222:::::2
//  A:::::A                 A:::::A T:::::::::T      I::::::::I     2::::::::::::::::::2
// AAAAAAA                   AAAAAAATTTTTTTTTTT      IIIIIIIIII     22222222222222222222
//                                                                                     
                                                                                    
*************************************
* Modelo 1: AAI vs Nada
*************************************
* 1. Calcular mediana dentro de submuestra Modelo 1
	sum ati_porc if (ati_porc !=0) & (ejecucion_PNIS ==0 | ejecucion_PNIS ==1), d
	scalar med = r(p50)
* 2. Redefinir variable "d_ati"
	replace d_ati = 1 if ati_porc<med
	replace d_ati = 2 if ati_porc>=med
	replace d_ati = 0 if ati_porc==0
	replace d_ati = . if activo==0 | actividad=="Recolector"
	label define l_ati 0 "Nada" 1 "Menos de la mediana" 2 "Más de la mediana", replace
	label values d_ati l_ati
	tab d_ati
	
	di "Mediana: " med " ***************************"

* 3. Mantener solo observaciones en ATI==0.
preserve 
keep if d_ati==${n_ati}
tab year ejecucion_PNIS
	global n_modelo 1
	global modelo "model${n_modelo}"
	qui tab year_t_AAI_Nada if ejecucion_PNIS==0 | ejecucion_PNIS==1
	if r(r)>1{
		* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${ATI}"
			
			csdid IPM_`ipm' if ///
				ejecucion_PNIS == 0 | ///
				ejecucion_PNIS == 1, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_AAI_Nada)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
			}
	}
	else{
		di "No hay suficientes observaciones"
		tab year_t_AAI_Nada if ejecucion_PNIS==0 | ejecucion_PNIS==1
	}
restore
	
di _newline(9)


*************************************
* Modelo 2: SA vs AAI
*************************************
* 1. Calcular mediana dentro de submuestra Modelo 2
	sum ati_porc if (ati_porc !=0) & (ejecucion_PNIS ==1 | ejecucion_PNIS ==2), d
	scalar med = r(p50)
* 2. Redefinir variable "d_ati"
	replace d_ati = 1 if ati_porc<med
	replace d_ati = 2 if ati_porc>=med
	replace d_ati = 0 if ati_porc==0
	replace d_ati = . if activo==0 | actividad=="Recolector"
	label define l_ati 0 "Nada" 1 "Menos de la mediana" 2 "Más de la mediana", replace
	label values d_ati l_ati
	tab d_ati
	
	di "Mediana: " med " ***************************"

* 3. Mantener solo observaciones en ATI==0.
preserve 
keep if d_ati==${n_ati}
tab year ejecucion_PNIS
	global n_modelo 2
	global modelo "model${n_modelo}"
	qui tab year_t_SA_AAI if ejecucion_PNIS==1 | ejecucion_PNIS==2
	if r(r)>1{
		* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${ATI}"
			
			csdid IPM_`ipm' if ///
				ejecucion_PNIS == 1 | ///
				ejecucion_PNIS == 2, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_SA_AAI)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	}
	else {
		di "No hay suficientes observaciones"
		tab year_t_SA_AAI if ejecucion_PNIS==1 | ejecucion_PNIS==2
	}

restore	
di _newline(9)

*************************************
* Modelo 3: PPCC vs AAI
*************************************
* 1. Calcular mediana dentro de submuestra Modelo 3
	sum ati_porc if (ati_porc !=0) & (ejecucion_PNIS ==1 | ejecucion_PNIS ==3), d
	scalar med = r(p50)
* 2. Redefinir variable "d_ati"
	replace d_ati = 1 if ati_porc<med
	replace d_ati = 2 if ati_porc>=med
	replace d_ati = 0 if ati_porc==0
	replace d_ati = . if activo==0 | actividad=="Recolector"
	label define l_ati 0 "Nada" 1 "Menos de la mediana" 2 "Más de la mediana", replace
	label values d_ati l_ati
	tab d_ati
	
	di "Mediana: " med " ***************************"

* 3. Mantener solo observaciones en ATI==0.
preserve 
keep if d_ati==${n_ati}
tab year ejecucion_PNIS
	global n_modelo 3
	global modelo "model${n_modelo}"
	qui tab year_t_PPCC_AAI if ejecucion_PNIS==1 | ejecucion_PNIS==3
	if r(r)>1{
		* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${ATI}"
			
			csdid IPM_`ipm' if ///
				ejecucion_PNIS == 1 | ///
				ejecucion_PNIS == 3, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPCC_AAI)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	}
	else{
		di "No hay suficientes observaciones
		tab year_t_PPCC_AAI if ejecucion_PNIS==1 | ejecucion_PNIS==3
	}
restore
di _newline(9)

*************************************
* Modelo 4: PPCC&SA vs AAI
*************************************
* 1. Calcular mediana dentro de submuestra Modelo 4
	sum ati_porc if (ati_porc !=0) & (ejecucion_PNIS ==1 | ejecucion_PNIS ==4), d
	scalar med = r(p50)
* 2. Redefinir variable "d_ati"
	replace d_ati = 1 if ati_porc<med
	replace d_ati = 2 if ati_porc>=med
	replace d_ati = 0 if ati_porc==0
	replace d_ati = . if activo==0 | actividad=="Recolector"
	label define l_ati 0 "Nada" 1 "Menos de la mediana" 2 "Más de la mediana", replace
	label values d_ati l_ati
	tab d_ati
	
	di "Mediana: " med " ***************************"

* 3. Mantener solo observaciones en ATI==0.
preserve 
keep if d_ati==${n_ati}
tab year ejecucion_PNIS
	global n_modelo 4
	global modelo "model${n_modelo}"
	qui tab year_t_PPCCySA if ejecucion_PNIS==1 | ejecucion_PNIS==4
	if r(r)>1{
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${ATI}"
			
			csdid IPM_`ipm' if ///
				ejecucion_PNIS == 1 | ///
				ejecucion_PNIS == 4, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPCCySA)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	}
	else{
		di "No hay suficientes observaciones"
		tab year_t_PPCCySA if ejecucion_PNIS==1 | ejecucion_PNIS==4
	}
restore
di _newline(9)

*************************************
* Modelo 5: PPCC&SA vs SA
*************************************
* 1. Calcular mediana dentro de submuestra Modelo 5
	sum ati_porc if (ati_porc !=0) & (ejecucion_PNIS ==2 | ejecucion_PNIS ==4), d
	scalar med = r(p50)
* 2. Redefinir variable "d_ati"
	replace d_ati = 1 if ati_porc<med
	replace d_ati = 2 if ati_porc>=med
	replace d_ati = 0 if ati_porc==0
	replace d_ati = . if activo==0 | actividad=="Recolector"
	label define l_ati 0 "Nada" 1 "Menos de la mediana" 2 "Más de la mediana", replace
	label values d_ati l_ati
	tab d_ati
	
	di "Mediana: " med " ***************************"

* 3. Mantener solo observaciones en ATI==0.
preserve 
keep if d_ati==${n_ati}
tab year ejecucion_PNIS
	global n_modelo 5
	global modelo "model${n_modelo}"
	qui tab year_t_PPCCySA if ejecucion_PNIS==2 | ejecucion_PNIS==4
	if r(r)>1{
		* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${ATI}"
			
			csdid IPM_`ipm' if ///
				ejecucion_PNIS == 2 | ///
				ejecucion_PNIS == 4, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPCCySA)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	}
	else{
		di "No hay suficientes observaciones"
		tab year_t_PPCCySA if ejecucion_PNIS==2 | ejecucion_PNIS==4
	}
restore
di _newline(9)

*************************************
* Modelo 6: PPCC&SA vs PPCC
*************************************
* 1. Calcular mediana dentro de submuestra Modelo 6
	sum ati_porc if (ati_porc !=0) & (ejecucion_PNIS ==3 | ejecucion_PNIS ==4), d
	scalar med = r(p50)
* 2. Redefinir variable "d_ati"
	replace d_ati = 1 if ati_porc<med
	replace d_ati = 2 if ati_porc>=med
	replace d_ati = 0 if ati_porc==0
	replace d_ati = . if activo==0 | actividad=="Recolector"
	label define l_ati 0 "Nada" 1 "Menos de la mediana" 2 "Más de la mediana", replace
	label values d_ati l_ati
	tab d_ati
	
	di "Mediana: " med " ***************************"

* 3. Mantener solo observaciones en ATI==0.
preserve 
keep if d_ati==${n_ati}
tab year ejecucion_PNIS
	global n_modelo 6
	global modelo "model${n_modelo}"
	qui tab year_t_PPCCySA if ejecucion_PNIS==3 | ejecucion_PNIS==4
	if r(r)>1{
		* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${ATI}"
			
			csdid IPM_`ipm' if ///
				ejecucion_PNIS == 3 | ///
				ejecucion_PNIS == 4, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPCCySA)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}
	}
	else{
		di "No hay suficientes observaciones"
		tab year_t_PPCCySA if ejecucion_PNIS==3 | ejecucion_PNIS==4
	}
restore
di _newline(9)

*************************************
* Modelo 7: PPCL vs PPCC&SA
*************************************
* 1. Calcular mediana dentro de submuestra Modelo 7
	sum ati_porc if (ati_porc !=0) & (ejecucion_PNIS ==4 | ejecucion_PNIS ==5), d
	scalar med = r(p50)
* 2. Redefinir variable "d_ati"
	replace d_ati = 1 if ati_porc<med
	replace d_ati = 2 if ati_porc>=med
	replace d_ati = 0 if ati_porc==0
	replace d_ati = . if activo==0 | actividad=="Recolector"
	label define l_ati 0 "Nada" 1 "Menos de la mediana" 2 "Más de la mediana", replace
	label values d_ati l_ati
	tab d_ati
	
	di "Mediana: " med " ***************************"

* 3. Mantener solo observaciones en ATI==0.
preserve 
keep if d_ati==${n_ati}
tab year ejecucion_PNIS
	global n_modelo 7
	global modelo "model${n_modelo}"
	qui tab year_t_PPCL_PPCCySA if ejecucion_PNIS==4 | ejecucion_PNIS==5
	if r(r)>1{
		* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-con_outliers-${ATI}"
			
			csdid IPM_`ipm' if ///
				ejecucion_PNIS == 4 | ///
				ejecucion_PNIS == 5, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPCL_PPCCySA)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
			}	
	}
	else{
		di "No hay suficientes observaciones"
		tab year_t_PPCL_PPCCySA if ejecucion_PNIS==4 | ejecucion_PNIS==5
	}
restore

* End

capture log close

