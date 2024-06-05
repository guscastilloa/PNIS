/*
AUTOR: 
	Gustavo Castillo
	
FECHA:
	4/oct/2023
	
DESCRIPCIÓN:
	En este script se realiza la diferencia de medias de las variables de la 
	encuesta para HOGARES entre línea base y línea final únicamente para quienes
	no son recolectores. En este se analizan solo preguntas del capítulo 3 de la
	encuesta.

*/

//    _____            ___         _         ____  
//   / ____|          /_/ |       | |       |___ \ 
//  | |     __ _ _ __  _| |_ _   _| | ___     __) |
//  | |    / _` | '_ \| | __| | | | |/ _ \   |__ < 
//  | |___| (_| | |_) | | |_| |_| | | (_) |  ___) |
//   \_____\__,_| .__/|_|\__|\__,_|_|\___/  |____/ 
//              | |                                
//              |_|                               

* Preámbulo luego de ejectuar _master.do
global output_table "${projectfolder}/Output/Encuesta/tablas/sin_recolectores"
global file_name "encuesta_cap3_sin_recolectores"
drop if recolector==1 | actividad==3 // Eliminar recolectores

 
* Capítulo 3: Caracterización familiar:

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
**# 2. Preparar variables
*-------------------------------------------------------------------------------
drop c01* c02* c04* c05* c06* c07* c08* c09*

* Pregunta 1:
// c03_01: Conteo

* Pregunta 11: c03_11-Pertenencia grupo étncico: Categórica no ordenada
tab c03_11, gen(c03_11_d)
	global p11 c03_11_d1 c03_11_d2 c03_11_d3 c03_11_d4 ///
		c03_11_d5 c03_11_d6 c03_11_d7
		
* Pregunta 12: c03_12-Tiempo en vivienda meses: Conteo
sum c03_12

* Pregunta 15: c03_15_X: Dummies de 1-7 (7 vars)  
global p15 c03_15_1 c03_15_2 c03_15_3 c03_15_4 c03_15_5 c03_15_6 c03_15_7

* Pregunta 16: c03_16_X: Dummy 1,2,3 y 90 (3 vars)
global p16 c03_16_1 c03_16_2 c03_16_3 c03_16_90

	
*____________________________________
* Definir función que asigne etiqueta de variable a global con nombre de var
capture program drop label32global
program label32global
	// Corte etiqueta de variable a 32 caracteres
	local Q: variable label `1'
	local pos=strpos("`Q'", "==")
	local varlabel=substr("`Q'", `pos'+2, 32)
	// Guarde etiqueta cortada en global que lleve el nombre de la variable
	global `1' = "`varlabel'"
end
*____________________________________


* Ejecutar función sobre todas las variables del capítulo 3
foreach VAR of varlist c03*{
	di "`VAR'"
	label32global `VAR'
}	
	

 
*-------------------------------------------------------------------------------
**# 3. Ttests 
*-------------------------------------------------------------------------------
**# Pregunta 1  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c03_01
// ¿Cuál es el material predominante de los pisos en su vivienda?
global pregunta p1
global p1 c03_01

tab c03_01 linea
tab c03_01 l_ejecución_PNIS
* No hay observaciones para línea base



**# Pregunta 11  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c03_11
// ¿Pertenece usted a alguno de los siguientes grupos étnicos?
global pregunta p11
matrix ${pregunta} = J(14,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="$c03_11_d1" "p" "$c03_11_d2" "p" "$c03_11_d3" "p" ///
							"$c03_11_d4" "p" "$c03_11_d5" "p" "$c03_11_d6" "p" ///
							"$c03_11_d7" "p"

matlist $pregunta						
*----------
* Loop
*----------		  
// Poner promedios de línea base en matriz
local row=1
foreach Q of global p11{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Línea Base: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@99.l_ejecución_PNIS] // linea base
	
	local row=`row'+2
}

// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global p11{
	di "> `Q'"
	local col = 2
	
	
	* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Nada: promedio, diferncia medias, p-valor
	matrix ${pregunta}[`row',`col'] =  _b[c.`Q'@0bn.l_ejecución_PNIS] // mu_Nada
	matrix ${pregunta}[`row',`col'+1]=_b[c.`Q'@99.l_ejecución_PNIS] - _b[c.`Q'@0bn.l_ejecución_PNIS] // diff
		test _b[c.`Q'@99.l_ejecución_PNIS] = _b[c.`Q'@0bn.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+1] = r(p) // p-valor
	
	* AAI: promedio, diferencia medias, p-valor
	matrix ${pregunta}[`row',`col'+2] =  _b[c.`Q'@1.l_ejecución_PNIS]
	matrix ${pregunta}[`row',`col'+3]=_b[c.`Q'@99.l_ejecución_PNIS] - _b[c.`Q'@1.l_ejecución_PNIS]
		test _b[c.`Q'@99.l_ejecución_PNIS] = _b[c.`Q'@1.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+3] = r(p)
	
	* SA: promedio, diff, p-valor
	matrix ${pregunta}[`row',`col'+4] =  _b[c.`Q'@2.l_ejecución_PNIS]
	matrix ${pregunta}[`row',`col'+5]=_b[c.`Q'@99.l_ejecución_PNIS] - _b[c.`Q'@2.l_ejecución_PNIS]
		test _b[c.`Q'@99.l_ejecución_PNIS] = _b[c.`Q'@2.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+5] = r(p)
	
	* PP: promedio, diff, p-valor
	matrix ${pregunta}[`row', `col'+6] = _b[c.`Q'@3.l_ejecución_PNIS]	
	matrix ${pregunta}[`row', `col'+7] =_b[c.`Q'@99.l_ejecución_PNIS]- _b[c.`Q'@3.l_ejecución_PNIS]
		test _b[c.`Q'@99.l_ejecución_PNIS] = _b[c.`Q'@3.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+7] = r(p)
	
	* PPSA: promedio, diff, p-valor
	matrix ${pregunta}[`row',`col'+8] = _b[c.`Q'@4.l_ejecución_PNIS]
	matrix ${pregunta}[`row',`col'+9]=_b[c.`Q'@99.l_ejecución_PNIS] - _b[c.`Q'@4.l_ejecución_PNIS]
		test _b[c.`Q'@99.l_ejecución_PNIS] = _b[c.`Q'@4.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1,`col'+9] = r(p)

	
	
	local row=`row'+2
	local it = `it'+1
	di "Iteración `it'" 

}

matlist ${pregunta}
*----------
* Export
*----------
local dim=`=rowsof(${pregunta})'+3
di "`dim'"

putexcel set "${output_table}/${file_name}.xlsx", sheet("${pregunta}") replace
putexcel A1="¿Pertenece usted a alguno de los siguientes grupos étnicos?"
putexcel A2=matrix(${pregunta}), names






**# Pregunta 12  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c03_12: conteo "Homogenización de c03_12_1 y c03_12_2 en meses"
// ¿Hace cuánto tiempo vive en esta vivienda?: Meses
global pregunta p12
global p12 c03_12
matrix ${pregunta} = J(2,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}=c03_12 "p"
		   matlist $pregunta

bysort linea: sum c03_12

* No hay observaciones en línea base para estimar diferencia.








**# Pregunta 15  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// En los últimos 30 días, usted o algún miembro de su familia tuvo acceso a: 
global pregunta p15
matrix ${pregunta} = J(14,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}=c03_15_1 "p" c03_15_2 "p" c03_15_3 "p" ///
							c03_15_4 "p" c03_15_5 "p" c03_15_6 "p" ///
							c03_15_7 "p"

matlist $pregunta

* Revisar que haya observaciones
foreach Q of global p15{
	tab `Q' linea
}

* Solo hay observaciones en línea final







**# Pregunta 16  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// En su núcleo familiar hay niños entre 0 y 5 años con acceso a servicios de:
global pregunta p16
matrix ${pregunta} = J(8,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="Salud" "p" "Nutrición" "p" "Preescolar,guardería,hogarcomuni" "p" ///
							"Ningún servicio" "p" 		   

matlist $pregunta
*----------
* Loop
*----------
// Poner promedios de línea base en matriz
local row=1
foreach Q of global p16{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Línea Base: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@99.l_ejecución_PNIS] // linea base
	
	local row=`row'+2
}

// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global p16{
	di "> `Q'"
	local col = 2
	
	
	* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Nada: promedio, diferncia medias, p-valor
	matrix ${pregunta}[`row',`col'] =  _b[c.`Q'@0bn.l_ejecución_PNIS] // mu_Nada
	matrix ${pregunta}[`row',`col'+1]=_b[c.`Q'@99.l_ejecución_PNIS] - _b[c.`Q'@0bn.l_ejecución_PNIS] // diff
		test _b[c.`Q'@99.l_ejecución_PNIS] = _b[c.`Q'@0bn.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+1] = r(p) // p-valor
	
	* AAI: promedio, diferencia medias, p-valor
	matrix ${pregunta}[`row',`col'+2] =  _b[c.`Q'@1.l_ejecución_PNIS]
	matrix ${pregunta}[`row',`col'+3]=_b[c.`Q'@99.l_ejecución_PNIS] - _b[c.`Q'@1.l_ejecución_PNIS]
		test _b[c.`Q'@99.l_ejecución_PNIS] = _b[c.`Q'@1.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+3] = r(p)
	
	* SA: promedio, diff, p-valor
	matrix ${pregunta}[`row',`col'+4] =  _b[c.`Q'@2.l_ejecución_PNIS]
	matrix ${pregunta}[`row',`col'+5]=_b[c.`Q'@99.l_ejecución_PNIS] - _b[c.`Q'@2.l_ejecución_PNIS]
		test _b[c.`Q'@99.l_ejecución_PNIS] = _b[c.`Q'@2.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+5] = r(p)
	
	* PP: promedio, diff, p-valor
	matrix ${pregunta}[`row', `col'+6] = _b[c.`Q'@3.l_ejecución_PNIS]	
	matrix ${pregunta}[`row', `col'+7] =_b[c.`Q'@99.l_ejecución_PNIS]- _b[c.`Q'@3.l_ejecución_PNIS]
		test _b[c.`Q'@99.l_ejecución_PNIS] = _b[c.`Q'@3.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+7] = r(p)
	
	* PPSA: promedio, diff, p-valor
	matrix ${pregunta}[`row',`col'+8] = _b[c.`Q'@4.l_ejecución_PNIS]
	matrix ${pregunta}[`row',`col'+9]=_b[c.`Q'@99.l_ejecución_PNIS] - _b[c.`Q'@4.l_ejecución_PNIS]
		test _b[c.`Q'@99.l_ejecución_PNIS] = _b[c.`Q'@4.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1,`col'+9] = r(p)

	
	
	local row=`row'+2
	local it = `it'+1
	di "Iteración `it'" 

}

matlist ${pregunta}
*----------
* Export
*----------
local dim=`=rowsof(${pregunta})'+3
di "`dim'"

putexcel set "${output_table}/${file_name}.xlsx", sheet("${pregunta}") modify
putexcel A1="En su núcleo familiar hay niños entre 0 y 5 años con acceso a servicios de:"
putexcel A2=matrix(${pregunta}), names





