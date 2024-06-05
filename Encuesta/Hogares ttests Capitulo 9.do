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


//  .----------------. 
// | .--------------. |
// | |    ______    | |
// | |  .' ____ '.  | |
// | |  | (____) |  | |
// | |  '_.____. |  | |
// | |  | \____| |  | |
// | |   \______,'  | |
// | |              | |
// | '--------------' |
//  '----------------' 
// Capítulo 9

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
**# 2. Preparar variables (hay 18 preguntas)
*-------------------------------------------------------------------------------
drop c01* c02* c03* c04* c05* c06* c07* c08*
	
// Pregunta 0: 5 dummies
global p0 c09_00_1 c09_00_2 c09_00_3 c09_00_4 c09_00_90

// Pregunta 1: c09_01_h y c09_01_02_h de conteo


// Pregunta 2: c09_02_h de conteo

// Pregunta 3: c09_03 continua

// Pregunta 4: c09_04 continua

// Pregunta 8: c09_08_01 categórica sin orden, revisar!!! ambiguedad con Excel

// Pregunta 9: 
	tab c09_09, gen(c09_09_d)
	// 	c09_09_01: continua
	// 	c09_09_02: continua
	// 	c09_09_03: Dummy
	
	global p9 c09_09_d1 c09_09_d2 c09_09_d3 c09_09_01 c09_09_02 c09_09_03

// Pregunta 10: SA, categórica ordenada
	tab c09_10_01, gen(c09_10_01_d)

	global p10 c09_10_01_d1 c09_10_01_d2 c09_10_01_d3 c09_10_01_d4

// Pregunta 11: ATI, categórica ordenada
	recode c09_11_01 96=.
	recode c09_11_01 0=.
	tab c09_11_01, gen(c09_11_01_d)
	
	global p11 c09_11_01_d1 c09_11_01_d2 c09_11_01_d3 c09_11_01_d4
	
// Pregunta 12: CC, categórica ordenada
	tab c09_12_01, gen(c09_12_01_d)
	global p12 c09_12_01_d1 c09_12_01_d2 c09_12_01_d3 c09_12_01_d4
	
// Pregunta 13: CL
	tab c09_13_01, gen(c09_13_01_d)
	global p13 c09_13_01_d1 c09_13_01_d2 c09_13_01_d3 c09_13_01_d4
	
// Pregunta 14: categórica no ordenada
	tab c09_14, gen(c09_14_d)
	
	global p14 c09_14_d1 c09_14_d2 c09_14_d3
	
// Pregunta 15: dummy luego de quitar "no aplica"
	recode c09_15 96=.
	tab c09_15
	
// Pregunta 16: 8 variables dummy
	// 	c09_16_1: dummy
	global p16 c09_16_1 c09_16_2 c09_16_3 c09_16_4 c09_16_5 c09_16_6 c09_16_90 c09_16_89
	
// Pregunta 17: 5 variables dummy
	global p17 c09_17_1 c09_17_2 c09_17_3 c09_17_90 c09_17_89

// Pregunta 18: categórica ordenada
	tab c09_18, gen(c09_18_d)
	global p18 c09_18_d1 c09_18_d2 c09_18_d3 c09_18_d4 c09_18_d5
	
// Pregunta 19: categórica ordenada
	tab c09_19, gen(c09_19_d)
	global p19 c09_19_d1 c09_19_d2 c09_19_d3 c09_19_d4 c09_19_d5
	
// Pregunta 20: Continuas todas las opciones
	global p20 c09_20_a c09_20_b c09_20_c c09_20_i c09_20_d c09_20_e c09_20_f c09_20_g c09_20_h
	
*-------------------------------------------------------------------------------
**# 3. Ttests por capítulo
*-------------------------------------------------------------------------------


// Revisar número de observaciones para todas las variables del capítulo 9:
foreach Q in c09_00_1 c09_00_2 c09_00_3 c09_00_4 c09_00_90 c09_01 c09_01_01 c09_01_01_89 c09_01_h c09_01_02 c09_01_03 c09_01_03_89 c09_01_02_h c09_02 c09_02_01 c09_02_01_89 c09_02_h c09_03 c09_04 c09_04_01 c09_04_01_89 c09_04_h c09_08 c09_08_89 c09_08_01 c09_09 c09_09_89 c09_09_01 c09_09_02 c09_09_03 c09_09_04 c09_09_05 c09_10 c09_10_89 c09_10_01 c09_11 c09_11_89 c09_11_01 c09_12 c09_12_89 c09_12_01 c09_12_02 c09_12_02_89 c09_13 c09_13_89 c09_13_01 c09_13_02 c09_13_02_89 c09_14 c09_15 c09_16_1 c09_16_2 c09_16_3 c09_16_4 c09_16_5 c09_16_6 c09_16_90 c09_16_89 c09_16_89_2 c09_17_1 c09_17_2 c09_17_3 c09_17_90 c09_17_89 c09_17_89_2 c09_18 c09_19 c09_20_a c09_20_b c09_20_c c09_20_i c09_20_d c09_20_e c09_20_f c09_20_g c09_20_h c09_20_h_89{
	qui sum `Q' if linea=="base"
	di "`Q'"
	di "> num. observaciones : `r(N)'" 
}

	// Solamente una variable, c09_11_01, tiene observaciones para línea base también, 
	// las demás solo tienen observaciones para línea final. Pero la varaible es
	// una pregunta adicional a quiénes respondieron afirmativamente a la c09_11 que
	// preguntaba sobre la recepción de ATI, por lo que no tiene sentido que
	// c09_11 no tenga observaciones y la subsecuente c09_11_01 sí. No se pueden realizar
	// pruebas con ninguna de las variables de este capítulo.
