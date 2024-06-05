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
global dofiledir "${projectfolder}/Do/Modelos IPM/A7-Heterogeneidad Grupos Armados"


* Pegarle a la base de estimaciones la información de grupos armados por municipio
tempfile panel armed_presence 

use "${projectfolder}/Datos/armed_presence.dta", clear

rename cod_dane_mpio cod_mpio
rename d grupos_armados
label variable grupos_armados "Presencia de grupos armados"
label define larmed 0 "Sin presencia" 1 "Un grupo armado" 2 "En disputa", replace
label values grupos_armados larmed 
save `armed_presence'

use "${projectfolder}/Datos/base_estimaciones_gus.dta", clear
save `panel'

merge m:1 cod_mpio using `armed_presence'
sort cub year


* Estimar modelo 4 (PP+SA)
if (1){ // Fijar como 1 para realizar estimación
	global switch_estimation_on 1 // Fijar global como 1 para estimar los modelos.
	do "${dofiledir}/A7.1-Estimar AAI_PPSA.do"
} 					 
