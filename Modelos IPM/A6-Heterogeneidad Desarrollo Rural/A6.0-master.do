/*
AUTOR:
	Gustavo Castillo
	
FECHA:
	5/oct/2023

DESCRIPCIÓN:
	En este script se prepara la base para realizar las estimaciones del modelo
	4 de IPM con proyecto productivo agrupado (PP+SA) evaluando los efectos
	heterogéneos al desagregar los beneficiarios por si recibieron 1 o más
	programas de desarrollo rural o ninguno.
	
*/

* Preámbulo luego de ejecutar _master.do
global dofiledir "${projectfolder}/Do/Modelos IPM/A6-Heterogeneidad Desarrollo Rural"


* Pegarle a la base la información de aquellos CUBs con programas de desarrollo rural
tempfile original using
use "${projectfolder}/Datos/db_proyectos_rurales.dta", clear
save `using'

use "${projectfolder}/Datos/base_estimaciones_pp.dta", clear
merge m:1 cub using `using'

* Arreglar variable proyectos_rural para segmentar muestra
recode proyectos_rural .=0
tab year proyectos_rural, miss
label var proyectos_rural "Recibió proyectos desarrollo rural"
label define lproyecto 1 "1 o más proyectos" ///
					   0 "No recibió proyectos", replace
label values proyectos_rural lproyecto

drop if year==.

* Estimar modelo 3 (PP vs AAI)
if (1){ // Fijar como 1 para realizar estimación
	global switch_estimation_on 1 // Fijar global como 1 para estimar los modelos.
	do "${dofiledir}/A6.1-Estimar AAI_PP.do"
}


* Estimar modelo 4 (PP+SA vs AAI)
if (1){ // Fijar como 1 para realizar estimación
	global switch_estimation_on 1 // Fijar global como 1 para estimar los modelos.
	do "${dofiledir}/A6.2-Estimar AAI_PPSA.do"
} 					 
