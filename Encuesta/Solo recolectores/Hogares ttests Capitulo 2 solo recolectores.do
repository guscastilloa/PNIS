/*
AUTOR: 
	Gustavo Castillo
	
FECHA:
	4/oct/2023
	
DESCRIPCIÓN:
	En este script se realiza la diferencia de medias de las variables de la 
	encuesta para HOGARES entre línea base y línea final únicamente para quienes
	son recolectores. En este se analizan solo preguntas del capítulo 2 de la
	encuesta.

*/



//    _____            _ _         _         ___  
//   / ____|          (_) |       | |       |__ \ 
//  | |     __ _ _ __  _| |_ _   _| | ___      ) |
//  | |    / _` | '_ \| | __| | | | |/ _ \    / / 
//  | |___| (_| | |_) | | |_| |_| | | (_) |  / /_ 
//   \_____\__,_| .__/|_|\__|\__,_|_|\___/  |____|
//              | |                               
//              |_|                               


* Preámbulo luego de ejectuar _master.do
global output_table "${projectfolder}/Output/Encuesta/tablas/solo_recolectores"
global file_name "encuesta_cap2_solo_recolectores"

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
                                    keep if recolector==1 | actividad==3 // Quedarnos solo con recolectores

drop c01* c03* c04* c05* c06* c07* c08* c09*

* Pregunta 1: c02_01-Princ. fuente energía eléctrica: Categórica no ordenada
tab c02_01, gen(c02_01_d)
* Pregunta 2a: c02_02a-Material de pisos vivienda: Categórica no ordenada
tab c02_02a, gen(c02_02a_d)
* Pregunta 2b: c02_02b-Material de paredes: Categórica no ordenada
tab c02_02b, gen(c02_02b_d)
* Pregunta 3: c02_03-Fuente de donde obtiene agua: categórica no ordenada
tab c02_03, gen(c02_03_d)
* Pregunta 4: c02_04, Dummy
tab c02_04
* Pregunta 5:c02_05-Lugar necesidades fisiológicas: Cat. no ordenada
tab c02_05, gen(c02_05_d)

global p1 "c02_01_d1 c02_01_d2 c02_01_d3 c02_01_d4 c02_01_d5 c02_01_d6"
global p2a c02_02a_d1 c02_02a_d2 c02_02a_d3 c02_02a_d4 c02_02a_d5
global p2b c02_02b_d1 c02_02b_d2 c02_02b_d3 c02_02b_d4 ///
	c02_02b_d5 c02_02b_d6 c02_02b_d7
global p3 c02_03_d1 c02_03_d2 c02_03_d3 c02_03_d4 c02_03_d5 ///
	c02_03_d6 c02_03_d7 c02_03_d8 c02_03_d9 c02_03_d10 c02_03_d11
global p5 c02_05_d1 c02_05_d2 c02_05_d3 c02_05_d4 c02_05_d5 c02_05_d6
	
	
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


* Ejecutar función sobre todas las variables del capítulo 2
foreach VAR of varlist c02*{
	di "`VAR'"
	label32global `VAR'
}	
	
	
*-------------------------------------------------------------------------------
**# 3. Ttests por capítulo
*-------------------------------------------------------------------------------
**# Pregunta 1  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c02_01
// ¿Cuál es la principal fuente de energía eléctrica en su vivienda?


global pregunta p1
matrix ${pregunta} = J(12,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="$c02_01_d1" "p" "$c02_01_d2" "p" "$c02_01_d3" "p" ///
							"$c02_01_d4" "p" "$c02_01_d5" "p" "$c02_01_d6" "p"

matlist $pregunta

*----------
* Loop
*----------
// Poner promedios de línea base en matriz
local row=1
foreach Q of global p1{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Línea Base: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@99.l_ejecución_PNIS] // linea base
	
	local row=`row'+2
}

// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global p1{
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
local dim=`=rowsof(M)'+3
di "`dim'"

putexcel set "${output_table}/${file_name}.xlsx", sheet("pregunta1") replace
putexcel A1="¿Cuál es la principal fuente de energía eléctrica en su vivienda?"
putexcel A2=matrix(${pregunta}), names








**# Pregunta 2a  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// p2a
// ¿Cuál es el material predominante de los pisos en su vivienda?
global pregunta p2a
matrix ${pregunta} = J(10,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
				   
				   
matrix rownames ${pregunta}="$c02_02a_d1" "p" "$c02_02a_d2" "p" "$c02_02a_d3" "p" ///
					        "$c02_02a_d4" "p" "$c02_02a_d5" "p"
		   
*----------
* Loop
*----------
// Poner promedios de línea base en matriz
local row=1
foreach Q of global p2a{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Línea Base: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@99.l_ejecución_PNIS] // linea base
	
	local row=`row'+2
}


// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global p2a{
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
putexcel A1="¿Cuál es el material predominante de los pisos en su vivienda?"
putexcel A2=matrix(${pregunta}), names







**# Pregunta 2b  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c02_02b
// ¿Cuál es el material predominante de las paredes en su vivienda?
global pregunta p2b
matrix ${pregunta} = J(14,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="$c02_02b_d1" "p" "$c02_02b_d2" "p" "$c02_02b_d3" "p" ///
							"$c02_02b_d4" "p" "$c02_02b_d5" "p" "$c02_02b_d6" "p"  ///
							"$c02_02b_d7" "p" 
matlist $pregunta					
				   

*----------
* Loop
*----------		  
// Poner promedios de línea base en matriz
local row=1
foreach Q of global p2b{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Línea Base: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@99.l_ejecución_PNIS] // linea base
	
	local row=`row'+2
}

// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global p2b{
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
putexcel A1="¿Cuál es el material predominante de las paredes en su vivienda?"
putexcel A2=matrix(${pregunta}), names







**# Pregunta 3  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c02_03
//¿El agua para consumo y preparación de los alimentos la obtienen principalmente
global pregunta p3
matrix ${pregunta} = J(22,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="$c02_03_d1" "p" "$c02_03_d2" "p" "$c02_03_d3" "p" ///
							"$c02_03_d4" "p" "$c02_03_d5" "p" "$c02_03_d6" "p" ///
							"$c02_03_d7" "p" "$c02_03_d8" "p" "$c02_03_d9" "p" ///
							"$c02_03_d10" "p" "$c02_03_d11" "p"
				   
matlist $pregunta
*----------
* Loop
*----------		  
// Poner promedios de línea base en matriz
local row=1
foreach Q of global p3{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Línea Base: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@99.l_ejecución_PNIS] // linea base
	
	local row=`row'+2
}

// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global p3{
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
putexcel A1="¿El agua para consumo y preparación de los alimentos la obtienen principalmente de"
putexcel A2=matrix(${pregunta}), names




**# Pregunta 4  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c02_04
// En su vivienda ¿Tres o más personas duermen en la misma habitación?
global pregunta p4
global p4 c02_04
matrix ${pregunta} = J(2,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="Sí" "p" 
				   

*----------
* Loop
*----------		  
// Poner promedios de línea base en matriz
local row=1
foreach Q of global p4{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Línea Base: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@99.l_ejecución_PNIS] // linea base
	
	local row=`row'+2
}

// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global p4{
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
putexcel A1="En su vivienda ¿Tres o más personas duermen en la misma habitación?"
putexcel A2=matrix(${pregunta}), names

