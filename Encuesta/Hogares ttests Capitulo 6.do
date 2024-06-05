/*
AUTOR: 
	Gustavo Castillo
	
FECHA:
	1/oct/2023
	
DESCRIPCIÓN:
	En este script se realiza la diferencia de medias de las variables de la 
	encuesta para HOGARES entre línea base y línea final.

*/

* Preámbulo luego de ejectuar _master.do
global output_table "${projectfolder}/Output/Encuesta/tablas"
use "${projectfolder}/Datos/db_encuesta_hogar.dta", clear

*-------------------------------------------------------------------------------
**# 1. Crear grupos de ejecución
*-------------------------------------------------------------------------------
foreach x of varlist c09_08 c09_10 c09_12 c09_13 { 
	
	replace `x' = 1 if `x' == 2
	label define eti_`x' 0 "No" 1 "Sí"
	label values `x' eti_`x'

	}

gen d=1

tab d [aw = factor_exp] if c09_08 == 0 & c09_10 == 0 & c09_12 == 0 & c09_13 == 0  // 53 nada
tab d [aw = factor_exp] if c09_08 == 1 & c09_10 == 0 & c09_12 == 0 & c09_13 == 0 //234 solo aai
tab d [aw = factor_exp] if c09_08 == 0 & c09_10 == 1 & c09_12 == 0 & c09_13 == 0 // 12 solo sa
tab d [aw = factor_exp] if c09_08 == 0 & c09_10 == 0 & c09_12 == 1 & c09_13 == 0  // 10 solo ppcc
tab d [aw = factor_exp] if c09_08 == 0 & c09_10 == 0 & c09_12 == 0 & c09_13 == 1  // 0 solo ppcl

tab d [aw = factor_exp] if c09_10 == 1 & c09_12 == 0 & c09_13 == 0 // 436  sa sin ppcc
tab d [aw = factor_exp] if c09_10 == 0 & c09_12 == 1 & c09_13 == 0  // 75  ppcc sin sa
tab d [aw = factor_exp] if c09_10 == 1 & c09_12 == 1 & c09_13 == 0  // 315 solo ppcl
tab d [aw = factor_exp] if c09_13 == 1  // 72 solo ppcl

gen ejecución_PNIS = .
replace ejecución_PNIS = 0 if c09_08 == 0 & c09_10 == 0 & c09_12 == 0 & c09_13 == 0 
replace ejecución_PNIS = 1 if c09_08 == 1 & c09_10 == 0 & c09_12 == 0 & c09_13 == 0 
replace ejecución_PNIS = 2 if c09_10 == 1 & c09_12 == 0 & c09_13 == 0
replace ejecución_PNIS = 3 if c09_10 == 0 & c09_12 == 1 & c09_13 == 0
replace ejecución_PNIS = 4 if c09_10 == 1 & c09_12 == 1 & c09_13 == 0
replace ejecución_PNIS = 5 if c09_13 == 1 & actividad != 3

label define grupos 0 "Nada" 1 "Asistencia Alimentaria Inmediata" 2 "Seguridad Alimentaria" 3 "Ciclo corto" 4 "SA + CC" 5 "Ciclo largo"
label values ejecución_PNIS grupos

tab ejecución_PNIS [aw=factor_exp]
tab ejecución_PNIS actividad

* Crear variables agrupadoras por cada componente

gen l_ejecución_PNIS=ejecución_PNIS
recode l_ejecución_PNIS .=99 if linea=="base"

label define lejecucion2 99 "LBase" 0 "Nada" 1 "AAI" 2 "SA" 3 "CC" 4 "CC&SA" 5 "CL", replace
label values l_ejecución_PNIS lejecucion2
tab l_ejecución_PNIS

bysort linea: sum factor_exp
*-------------------------------------------------------------------------------
**# 2. Preparar variables
*-------------------------------------------------------------------------------
drop c01* c02* c03* c04* c05* c07* c08* c09*
	
* Capítulo 6: Debo eliminar todas las opciones "92" de "No sabe"
// c06_01 c06_02 c06_03 c06_04
// Pregunta 1: 
recode c06_01 92=.

// Pregunta 2: dummy sin no sabe (92)
recode c06_02 92=.
tab c06_02

// Pregunta 3:
recode c06_03 92=.

// Pregunta 4
recode c06_04 92=.
tab c06_04
 
*-------------------------------------------------------------------------------
**# 3. Ttests por capítulo
*-------------------------------------------------------------------------------
**# Pregunta 1  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c06_01
tab c06_01 linea

	// No hay valores para línea base

**# Pregunta 2  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c06_02
tab c06_02 linea

	// No hay valores para línea base
	
**# Pregunta 3  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c06_03
tab c06_03 linea

	// No hay valores para línea base
	
**# Pregunta 4  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
tab c06_04 linea

	// No hay valores para línea base
