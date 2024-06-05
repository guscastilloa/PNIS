/*
AUTOR: 
	Gustavo Castillo
	
FECHA:
	4/oct/2023
	
DESCRIPCIÓN:
	En este script se realiza la diferencia de medias de las variables de la 
	encuesta para HOGARES entre línea base y línea final únicamente para quienes
	son recolectores. En este se analizan solo preguntas del capítulo 5 de la
	encuesta.

*/




//    _____            _ _         _         _____ 
//   / ____|          (_) |       | |       | ____|
//  | |     __ _ _ __  _| |_ _   _| | ___   | |__  
//  | |    / _` | '_ \| | __| | | | |/ _ \  |___ \ 
//  | |___| (_| | |_) | | |_| |_| | | (_) |  ___) |
//   \_____\__,_| .__/|_|\__|\__,_|_|\___/  |____/ 
//              | |                                
//              |_|                                

* Preámbulo luego de ejectuar _master.do
global output_table "${projectfolder}/Output/Encuesta/tablas/solo_recolectores"
global file_name "encuesta_cap5_solo_recolectores"
keep if recolector==1 | actividad==3 // Quedarnos solo con recolectores

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
drop c01* c02* c03* c04* c06* c07* c08* c09*
* Pregunta 1 c05_01
	// c05_01_X: Dummy sin no aplica
	recode c05_01_1 96=.
	recode c05_01_2 96=.
	recode c05_01_3 96=.
	recode c05_01_4 96=.
	recode c05_01_5 96=.
	recode c05_01_90 96=.
	
	global p1 c05_01_1 c05_01_2 c05_01_3 c05_01_4 c05_01_5 c05_01_90
* Pregunta 2 (c05_02): Dummy
	// c05_01_3: Dummy sin no aplica
	recode c05_01_3 96=.
	tab c05_01_3
	// c05_01_4: Dummy sin no aplica
	recode c05_01_4 96=.
	tab c05_01_4
	// c05_01_5: Dummy sin no aplica
	recode c05_01_5 96=.
	tab c05_01_5
	global p2 c05_02_01_1 c05_02_01_2 c05_02_01_3 c05_02_01_4 ///
		c05_02_01_5 c05_02_01_6 c05_02_01_8 c05_02_01_9 c05_02_01_10 ///
		c05_02_01_11 c05_02_01_89 c05_02_01_90

* Pregunta 3: c05_03, Dummy
	// c05_03_01_h: conteo
* Pregunta 4: c05_04 conteo
* Pregunta 5: c05_05 conteo
* Pregunta 6: c05_06 conteo
* Pregunta 7: c05_07 conteo
* Pregunta 8: c05_08 dummies 1-9
	global p8 c05_08_1 c05_08_2 c05_08_3 c05_08_4 c05_08_5 c05_08_6 ///
		c05_08_7 c05_08_8 c05_08_9
* Pregunta 9: dummy sin no aplica
	recode c05_09 96=.
	recode c05_09_01 96=.
	tab1 c05_09 c05_09_01
	global p9 c05_09 c05_09_01
// Pregunta 10: dummy sinn no aplica
	recode c05_10 (96=.) (92=.)
	recode c05_10_01 (96=.)
	tab c05_10 c05_10_01
	global p10 c05_10 c05_10_01
// Pregunta 11: dummies creadas
	tab c05_11, gen(c05_11_d)
	global p11 c05_11_d1 c05_11_d2 c05_11_d3 
	
	

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
foreach VAR of varlist c05*{
	di "`VAR'"
	label32global `VAR'
}	
	

*-------------------------------------------------------------------------------
**# 3. Ttests
*-------------------------------------------------------------------------------

**# Pregunta 1  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c05_01
// Algún miembro de su hogar tiene: [herramientas financieras]
global pregunta p1
	//Revisar que existan observaciones para Línea base y tratamiento
	foreach Q of global p1{
		di "> `Q'"
		tab `Q' l_ejecución_PNIS
	}

	// 	Hay dos variables que no tienen información en línea base: 
	// - c05_01_4 (Préstamo informal)
	// - c05_01_5 (Nequi o davipplata)
	// 	por lo que estas opciones de respuesta se excluirán de las
	//	pruebas de diferencia de medias siguientes.

* Redefinir global de variables de la pregunta 1
global p1 c05_01_1 c05_01_2 c05_01_3 c05_01_90

foreach VAR of global p1{
// 	di "`VAR'"
	local Q:variable label `VAR'
	local pos =strpos("`Q'", ":")
	local varlabel=substr("`Q'", `pos'+2,32)
	global `VAR'="`varlabel'"
}

matrix ${pregunta} = J(8,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="$c05_01_1" "p" "$c05_01_2" "p" ///
							"$c05_01_3" "p" "$c05_01_90" "p"

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
putexcel A1="Algún miembro de su hogar tiene: "
putexcel A2=matrix(${pregunta}), names








**# Pregunta 2  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c05_02
// ¿Quién o quiénes le prestaron la plata?: [entidades]

//Revisar que existan observaciones para Línea base y tratamiento
	foreach Q of global p2{
		di "> `Q'"
		tab `Q' l_ejecución_PNIS
		di _newline(3)
	}

	// 	Hay 4 variables que no tienen información en línea base: 
	//  c05_02_01_9, c05_02_01_10, c05_02_01_11, c05_02_01_90. Por lo que
	//  estas opciones de respuesta se excluirán de las pruebas de diferencia
	//  de medias siguientes.
* Redefinimos global
global p2 c05_02 c05_02_01_1 c05_02_01_2 c05_02_01_3 c05_02_01_4 c05_02_01_5 ///
		  c05_02_01_6 c05_02_01_7 c05_02_01_8 c05_02_01_89	

global p2aux c05_02_01_1 c05_02_01_2 c05_02_01_3 c05_02_01_4 c05_02_01_5 ///
		  c05_02_01_6 c05_02_01_7 c05_02_01_8 c05_02_01_89		  
foreach VAR of global p2aux{
// 	di "`VAR'"
	local Q:variable label `VAR'
	local pos =strpos("`Q'", ":")
	local varlabel=substr("`Q'", `pos'+2,32)
// 	di "`varlabel'"
	global `VAR'="`varlabel'"
}		  
		 
matrix ${pregunta} = J(20,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="Sí solicitó préstamo" "p" "$c05_02_01_1" "p" ///
							"$c05_02_01_2" "p" "$c05_02_01_3" "p" ///
							"$c05_02_01_4" "p" "$c05_02_01_5" "p" ///
							"$c05_02_01_6" "p" "$c05_02_01_7" "p" ///
							"$c05_02_01_8" "p" "$c05_02_01_89" "p" 	

matlist $pregunta		 

*----------
* Loop
*----------
// Poner promedios de línea base en matriz
local row=1
foreach Q of global p2{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Línea Base: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@99.l_ejecución_PNIS] // linea base
	
	local row=`row'+2
}

// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global p2{
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

putexcel set "${output_table}/${file_name}.xlsx", sheet("pregunta2") modify
putexcel A1="En el último año ¿algún miembro de su hogar solicitó algún préstamo?"
putexcel A2="¿Quién o quiénes le prestaron la plata?:"
putexcel A3=matrix(${pregunta}), names






**# Pregunta 3  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c05_03
// ¿Ha tenido cultivos o huertas caseras para autoconsumo en el ultimo año?
global p3 c05_03

matrix ${pregunta} = J(2,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="Sí" "p"

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
local dim=`=rowsof(M)'+3
di "`dim'"

putexcel set "${output_table}/${file_name}.xlsx", sheet("pregunta3") modify
putexcel A1="¿Ha tenido cultivos o huertas caseras para autoconsumo en el ultimo año?"
putexcel A2=matrix(${pregunta}), names









**# Pregunta 4  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c05_04
// En el último mes, ¿cuántas vacas o toros vivos ha tenido el hogar?

bysort l_ejecución_PNIS: sum c05_04
	
	// No hay información de la variable para la línea base.
	
	
**# Pregunta 5  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c05_05
bysort l_ejecución_PNIS: sum c05_05

	// No hay información de la variable para la línea base.
	
	
**# Pregunta 6  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// c05_06
bysort l_ejecución_PNIS: sum c05_06

	// No hay información de la variable para la línea base.

	
**# Pregunta 7  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 	
// c05_07
tab c05_07 linea
	//	No hay información de la variable para la línea base.


**# Pregunta 8  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 	
// c05_08
foreach Q of global p8{
	tab `Q' linea
}
	
**# Pregunta 9  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 	
// c05_09
// ¿Su predio inscrito en el PNIS cuenta con vías de acceso terrestre?
foreach Q of global p9{
	tab `Q' linea
}
matrix ${pregunta} = J(4,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="Predio PNIS sí vias acceso terr" "p" ///
							"Vías sí habilitadas en ep lluvia" "p" 

matlist $pregunta

*----------
* Loop
*----------
// Poner promedios de línea base en matriz
local row=1
foreach Q of global p9{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Línea Base: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@99.l_ejecución_PNIS] // linea base
	
	local row=`row'+2
}

// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global p9{
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

putexcel set "${output_table}/${file_name}.xlsx", sheet("pregunta9") modify
putexcel A1="¿Su predio inscrito en el PNIS cuenta con vías de acceso terrestre?"
putexcel A2="¿Las vías están habilitadas en épocas de lluvia?"
putexcel A3=matrix(${pregunta}), names








**# Pregunta 10  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
// ¿Sus predios cuentan con vía de acceso fluvial?
foreach Q of global p10{
	tab `Q' l_ejecución_PNIS
}

matrix ${pregunta} = J(4,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="Predios sí cuentan via acc fluvi" "p" ///
							"Sí es transitable todo el año" "p"

matlist $pregunta

*----------
* Loop
*----------
// Poner promedios de línea base en matriz
local row=1
foreach Q of global p10{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Línea Base: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@99.l_ejecución_PNIS] // linea base
	
	local row=`row'+2
}

// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global p10{
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

putexcel set "${output_table}/${file_name}.xlsx", sheet("pregunta10") modify
putexcel A1="¿Sus predios cuentan con vía de acceso fluvial?"
putexcel A2="¿La vía fluvial es transitable en todas las épocas del año?"
putexcel A3=matrix(${pregunta}), names








**# Pregunta 11  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
foreach Q of global p11{
	tab `Q' linea
}

// No hay observaciones para línea base.


* End
