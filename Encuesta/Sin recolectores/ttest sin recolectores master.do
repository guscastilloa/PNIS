/*
AUTOR:
	Gustavo Castillo
	
FECHA:
	5/oct/2023
	
DESCRIPCIÓN:
	En este script se realiza el pegue del identificador de recolectores
	con la base principal de encuesta de hogares para luego proceder a realizar
	las diferencias de medias para los capítulos para los que tenemos datos para
	línea base y final (2, 3, 5 y 7) habiendo eliminado a quienes fueron
	identificados como recolectores.
	
*/

* Preambulo luego de ejecutar _master.do
global dofiledir "${projectfolder}/Do/Encuesta/Sin recolectores"

* Realizar pegue entre base que identifica recolector y base de encuesta hogar:
tempfile principal using 
use "${projectfolder}/Datos/id_recolectores_LB.dta", clear
rename KEY respondent_serial
save `using'


use "${projectfolder}/Datos/db_encuesta_hogar.dta", clear

merge 1:1 respondent_serial using `using' 


// br respondent_serial recolector if _merge==1

*******************************************************************************
**# PART 1:  Ejecutar do files
*******************************************************************************

	// NOTA:
// 	Para poder ejecutar cada uno de los siguientes dofiles es necesario primero 
// 	ejecutar las líneas anteriores a esta parte (18 a la 29). Si se ejecuta de 
// 	corrido este script 

* Capítulo 2
	preserve
	do "${dofiledir}/Hogares ttests Capitulo 2 sin recolectores.do"
	restore
* Capítulo 3
	preserve
	do "${dofiledir}/Hogares ttests Capitulo 3 sin recolectores.do"
	restore
* Capítulo 5
	preserve
	do "${dofiledir}/Hogares ttests Capitulo 5 sin recolectores.do"	
	restore
* Capítulo 7	
	preserve
	do "${dofiledir}/Hogares ttests Capitulo 7 sin recolectores.do"
	restore

* IPM
	preserve
	do "${dofiledir}/Hogares ttests IPM sin recolectores.do"
	restore
* End
