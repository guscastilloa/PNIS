/*
AUTOR: 
	Gustavo Castillo
	
FECHA:
	1/oct/2023
	
DESCRIPCIÓN:
	En este script se realiza la diferencia de medias de la variable continua
	del IPM de la encuesta para HOGARES entre línea base y línea final.	

*/

* Preámbulo luego de ejectuar _master.do
cls 
clear all
use "/Users/lucasrodriguez/PISDA/ProjectFolderEncuesta/Datos/id_recolectores_LB.dta"
rename KEY respondent_serial
merge 1:1 respondent_serial using "/Users/lucasrodriguez/PISDA/ProjectFolderEncuesta/Datos/db_encuesta_hogar.dta"
drop _merge


replace c09_09=2 if c09_09==1
replace c09_09=99 if c09_09==0
replace c09_09=0 if c09_09==2
label define x 99 "No" 0 "Sí", replace
label values c09_09 x 

gen grupos = 0 if recolector == 1 
replace grupos = 1 if c09_09 == 99 
replace grupos = 2 if c09_09 == 0 
label define g 0 "Base" 1 "No recibe nada" 2 "Recibe", replace
label values grupos g 

global output_table "${projectfolder}/Output/Encuesta/tablas/con_recolectores"
global file_name "encuesta_ipm_con_recolectores"
keep if recolector==1 | actividad==3 // Eliminar recolectores

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

* Crear variables agrupadoras por cada componente agrupando PP en uno solo

gen l_ejecución_PNIS=.
replace l_ejecución_PNIS=99 if linea=="base"
replace l_ejecución_PNIS=0 if ejecución_PNIS==0 // Nada
replace l_ejecución_PNIS=1 if ejecución_PNIS==1 // AAI
replace l_ejecución_PNIS=2 if ejecución_PNIS==2 // SA
replace l_ejecución_PNIS=3 if ejecución_PNIS==3 | ejecución_PNIS== 5 // PP = CC or CL
replace l_ejecución_PNIS=4 if c09_10==1 & (c09_12==1 | c09_13==1) // PP&SA

label define lejecucion2 99 "LBase" 0 "Nada" 1 "AAI" 2 "SA" 3 "PP" 4 "PP&SA", replace
label values l_ejecución_PNIS lejecucion2

// Revisar que variable con PP agrupado se haya creado bien:
tab ejecución_PNIS l_ejecución_PNIS 

*-------------------------------------------------------------------------------
**# 2. Preparar variables (hay 18 preguntas)
*-------------------------------------------------------------------------------
drop c01* c02* c03* c04* c05* c06* c07* c08*
	

*-------------------------------------------------------------------------------
**# 3. Ttests por capítulo
*-------------------------------------------------------------------------------
* Matriz:
//columnas:
//mu_Nada,𝚫, mu_AAI,𝚫, mu_SA,𝚫, mu_CC,𝚫, mu_CCSA,𝚫, mu_CL,𝚫, Baseline.
matrix M = J(2,5,.)

// local ipm_label : var label ipm
// matrix rownames M= "`ipm_label'"
// global row: label ejecucion_prima ${grupo_control}
// global tratamiento: label ejecucion_prima ${grupo_tratamiento}

matrix colnames M= "Base" "Nada" "Dif" "Recibió" "Dif"
				   
matrix rownames M= "IPM" "p-valor"
matlist M

* Calcular promedio por grupo
local col = 1
mean ipm [aweight =factor_exp ], over(grupos) coeflegend

* Poner promedios en matriz
matrix M[1,`col'+1] = _b[c.ipm@0bn.grupos] // recolectores

matlist M


* Poner diferencia de medias en matriz
	// LB-Nada
	matrix M[1,`col'+2]=_b[c.ipm@0.grupos] - _b[c.ipm@1bn.grupos]
 	test _b[c.ipm@0.grupos] = _b[c.ipm@1bn.grupos]
	matrix M[2, `col'+2] = r(p)

matlist M

putexcel set "${output_table}/encuesta_ipm_con_recolectores.xlsx", sheet("ipm") replace
putexcel A1=matrix(M), names






