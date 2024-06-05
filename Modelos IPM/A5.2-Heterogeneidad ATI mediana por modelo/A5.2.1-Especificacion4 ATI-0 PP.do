// ███████████████████████████
// ███████▀▀▀░░░░░░░▀▀▀███████
// ████▀░░░░░░░░░░░░░░░░░▀████
// ███│░░░░░░░░░░░░░░░░░░░│███
// ██▌│░░░░░░░░░░░░░░░░░░░│▐██
// ██░└┐░░░░░░░░░░░░░░░░░┌┘░██
// ██░░└┐░░░░░░░░░░░░░░░┌┘░░██
// ██░░┌┘▄▄▄▄▄░░░░░▄▄▄▄▄└┐░░██
// ██▌░│██████▌░░░▐██████│░▐██
// ███░│▐███▀▀░░▄░░▀▀███▌│░███
// ██▀─┘░░░░░░░▐█▌░░░░░░░└─▀██
// ██▄░░░▄▄▄▓░░▀█▀░░▓▄▄▄░░░▄██
// ████▄─┘██▌░░░░░░░▐██└─▄████
// █████░░▐█─┬┬┬┬┬┬┬─█▌░░█████
// ████▌░░░▀┬┼┼┼┼┼┼┼┬▀░░░▐████
// █████▄░░░└┴┴┴┴┴┴┴┘░░░▄█████
// ███████▄░░░░░░░░░░░▄███████
// ██████████▄▄▄▄▄▄▄██████████
// ███████████████████████████
/*
AUTOR:
	Gustavo Castillo

FECHA CREACIÓN:
	6/oct/2023
	
DESCRIPCIÓN.
	En este script se realizan las estimaciones de los modelos 3 y 4 de IPM
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
	de ATI fue 0=No recibió nada. 
	
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
log using "${projectfolder}/Log/A5-Especificacion4_ati0-mediana por modelo-PP.smcl", replace


global output_path "${output}/Modelos IPM/_heterogeneidad ati/estimaciones" 
cd "${output_path}"
global n_esp 4
global n_ati 0
global ESP "esp${n_esp}"
global ATI "ati${n_ati}"
use "${projectfolder}/Datos/base_estimaciones_pp.dta", clear

*-------------------------------------------------------------------------------
**# Estimar modelos 3' y 4' (PP y PPSA)
*-------------------------------------------------------------------------------
                                                                                    
//                                                                                    
//                AAA         TTTTTTTTTTTTTTTTTTTTTTTIIIIIIIIII          000000000     
//               A:::A        T:::::::::::::::::::::TI::::::::I        00:::::::::00   
//              A:::::A       T:::::::::::::::::::::TI::::::::I      00:::::::::::::00 
//             A:::::::A      T:::::TT:::::::TT:::::TII::::::II     0:::::::000:::::::0
//            A:::::::::A     TTTTTT  T:::::T  TTTTTT  I::::I       0::::::0   0::::::0
//           A:::::A:::::A            T:::::T          I::::I       0:::::0     0:::::0
//          A:::::A A:::::A           T:::::T          I::::I       0:::::0     0:::::0
//         A:::::A   A:::::A          T:::::T          I::::I       0:::::0 000 0:::::0
//        A:::::A     A:::::A         T:::::T          I::::I       0:::::0 000 0:::::0
//       A:::::AAAAAAAAA:::::A        T:::::T          I::::I       0:::::0     0:::::0
//      A:::::::::::::::::::::A       T:::::T          I::::I       0:::::0     0:::::0
//     A:::::AAAAAAAAAAAAA:::::A      T:::::T          I::::I       0::::::0   0::::::0
//    A:::::A             A:::::A   TT:::::::TT      II::::::II     0:::::::000:::::::0
//   A:::::A               A:::::A  T:::::::::T      I::::::::I      00:::::::::::::00 
//  A:::::A                 A:::::A T:::::::::T      I::::::::I        00:::::::::00   
// AAAAAAA                   AAAAAAATTTTTTTTTTT      IIIIIIIIII          000000000     
                                                                                    
*************************************
* Modelo 3: PP vs AAI
*************************************

* 1. Calcular mediana dentro de submuestra Modelo 3
	sum ati_porc if (ati_porc !=0) & (ejecucion_PNIS_prima ==1 | ejecucion_PNIS_prima ==3), d
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
tab year ejecucion_PNIS_prima
	global n_modelo 3
	global modelo "model${n_modelo}"
	qui tab year_t_PP_AAI if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3
	if r(r)>1{
		* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-${ATI}-PP"
			
			csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 3, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PP_AAI)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	}
	else{
		di "No hay suficientes observaciones
		tab year_t_PP_AAI if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==3
	}
restore
di _newline(9)

*************************************
* Modelo 4: PP&SA vs AAI
*************************************
* 1. Calcular mediana dentro de submuestra Modelo 4
	sum ati_porc if (ati_porc !=0) & (ejecucion_PNIS_prima ==1 | ejecucion_PNIS_prima ==4), d
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
tab year ejecucion_PNIS_prima
	global n_modelo 4
	global modelo "model${n_modelo}"
	qui tab year_t_PPySA if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4
	if r(r)>1{
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - -
		forvalues ipm=1/2{
			global tipm="IPM `ipm'"
			di "> IPM `ipm'"
			
			global estimate_file_name "${ESP}-${modelo}-${tipm}-${ATI}-PP"
			
			csdid IPM_`ipm' if ///
				ejecucion_PNIS_prima == 1 | ///
				ejecucion_PNIS_prima == 4, ///
				cluster(cod_mpio) ivar(cub) time(year) ///
				gvar(year_t_PPySA)
			estimates save "${output_path}/${estimate_file_name}.ster", replace
		}	
	}
	else{
		di "No hay suficientes observaciones"
		tab year_t_PPySA if ejecucion_PNIS_prima==1 | ejecucion_PNIS_prima==4
	}
restore
di _newline(9)

capture log close

* End
