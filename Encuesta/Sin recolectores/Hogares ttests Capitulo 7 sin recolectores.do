/*
AUTOR: 
	Gustavo Castillo
	
FECHA:
	4/oct/2023
	
DESCRIPCIÓN:
	En este script se realiza la diferencia de medias de las variables de la 
	encuesta para HOGARES entre línea base y línea final únicamente para quienes
	no son recolectores. En este se analizan solo preguntas del capítulo 7 de la
	encuesta.

*/




//    _____            _ _         _         ______ 
//   / ____|          (_) |       | |       |____  |
//  | |     __ _ _ __  _| |_ _   _| | ___       / / 
//  | |    / _` | '_ \| | __| | | | |/ _ \     / /  
//  | |___| (_| | |_) | | |_| |_| | | (_) |   / /   
//   \_____\__,_| .__/|_|\__|\__,_|_|\___/   /_/    
//              | |                                 
//              |_|                                 


* Preámbulo luego de ejectuar _master.do
global output_table "${projectfolder}/Output/Encuesta/tablas/sin_recolectores"
global file_name "encuesta_cap7_sin_recolectores"
drop if recolector==1 | actividad==3 // Eliminar recolectores

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
drop c01* c02* c03* c04* c05* c06* c08* c09*
	
// Pregunta 1: todas dummies
//c07_01_1 c07_01_2 c07_01_3 c07_01_4 c07_01_5 c07_01_6 c07_01_89 c07_01_90
global p1 c07_01_1 c07_01_2 c07_01_3 c07_01_4 c07_01_5 c07_01_6 c07_01_89 c07_01_90 c07_01_89_2
// Pregunta 2: 19 vars categóricas ordenadas
recode c07_02_01_a 96=.
recode c07_02_01_b 96=.

global preguntas c07_02_a c07_02_b c07_02_c c07_02_d c07_02_e c07_02_f ///
	c07_02_g c07_02_h c07_02_i c07_02_j c07_02_l c07_02_m c07_02_n ///
	c07_02_o c07_02_p c07_02_q c07_02_r c07_02_01_a c07_02_01_b 
foreach x of global preguntas{
	di "`x'"
	tab `x', gen(`x'_d)
	
} 
// quedaron 74 variables que resultan de 4*19-2
global p2 c07_02_a_d1 c07_02_a_d2 c07_02_a_d3 c07_02_a_d4 c07_02_b_d1 c07_02_b_d2 c07_02_b_d3 c07_02_b_d4 c07_02_c_d1 c07_02_c_d2 c07_02_c_d3 c07_02_c_d4 c07_02_d_d1 c07_02_d_d2 c07_02_d_d3 c07_02_d_d4 c07_02_e_d1 c07_02_e_d2 c07_02_e_d3 c07_02_e_d4 c07_02_f_d1 c07_02_f_d2 c07_02_f_d3 c07_02_f_d4 c07_02_g_d1 c07_02_g_d2 c07_02_g_d3 c07_02_g_d4 c07_02_h_d1 c07_02_h_d2 c07_02_h_d3 c07_02_h_d4 c07_02_i_d1 c07_02_i_d2 c07_02_i_d3 c07_02_i_d4 c07_02_j_d1 c07_02_j_d2 c07_02_j_d3 c07_02_j_d4 c07_02_l_d1 c07_02_l_d2 c07_02_l_d3 c07_02_l_d4 c07_02_m_d1 c07_02_m_d2 c07_02_m_d3 c07_02_m_d4 c07_02_n_d1 c07_02_n_d2 c07_02_n_d3 c07_02_n_d4 c07_02_o_d1 c07_02_o_d2 c07_02_o_d3 c07_02_o_d4 c07_02_p_d1 c07_02_p_d2 c07_02_p_d3 c07_02_p_d4 c07_02_q_d1 c07_02_q_d2 c07_02_q_d3 c07_02_q_d4 c07_02_r_d1 c07_02_r_d2 c07_02_r_d3 c07_02_r_d4 c07_02_01_a_d1 c07_02_01_a_d2 c07_02_01_a_d3 c07_02_01_b_d1 c07_02_01_b_d2 c07_02_01_b_d3
 
// Pregunta 3:  13 variables todas dummies
// 	c07_03_1 c07_03_2 c07_03_3 c07_03_4 c07_03_5 c07_03_6 c07_03_7 
// 	c07_03_8 c07_03_9 c07_03_10 c07_03_11 c07_03_89 c07_03_90
global p3 c07_03_1 c07_03_2 c07_03_3 c07_03_4 c07_03_5 c07_03_6 c07_03_7 ///
		c07_03_8 c07_03_9 c07_03_10 c07_03_11 c07_03_89 c07_03_90



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
foreach VAR of varlist c07*{
	di "`VAR'"
	label32global `VAR'
}			
		
*-------------------------------------------------------------------------------
**# 3. Ttests por capítulo
*-------------------------------------------------------------------------------
**# Pregunta 1  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
foreach Q of global p1{
	tab `Q' linea
}

	// No hay observaciones para la línea base

	
	
**# Pregunta 2  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
global pregunta p2

local c=0
foreach Q of global p2{
	qui tab `Q' linea
	
	if r(c)>1{
		local c=`c'+1
		di " * * * * `Q' * * * * * * * (`c') "
	}
	else{
		di "No hay obs suficientes."
	}
}

// Redefinir global para las variables que sí tienen info para LB y LF.

global p2 c07_02_a_d1 c07_02_a_d2 c07_02_a_d3 c07_02_a_d4 ///
		  c07_02_b_d1 c07_02_b_d2 c07_02_b_d3 c07_02_b_d4 ///
		  c07_02_c_d1 c07_02_c_d2 c07_02_c_d3 c07_02_c_d4 ///
		  c07_02_f_d1 c07_02_f_d2 c07_02_f_d3 c07_02_f_d4 ///
		  c07_02_n_d1 c07_02_n_d2 c07_02_n_d3 c07_02_n_d4

matrix ${pregunta} = J(40,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="Alcaldía $c07_02_a_d1" "p" "Alcaldía $c07_02_a_d2" "p" ///
							"Alcaldía $c07_02_a_d3" "p" "Alcaldía $c07_02_a_d4" "p" ///
							"Defensoría $c07_02_b_d1" "p" "Defensoría $c07_02_b_d2" "p" ///
							"Defensoría $c07_02_b_d3" "p" "Defensoría $c07_02_b_d4" "p" ///
							"Juzgado $c07_02_c_d1" "p" "Juzgado $c07_02_c_d2" "p" ///
							"Juzgado $c07_02_c_d3" "p" "Juzgado $c07_02_c_d4" "p" ///
							"MinAgricultura $c07_02_f_d1" "p" "MinAgricultura $c07_02_f_d2" "p" ///
							"MinAgricultura $c07_02_f_d3" "p" "MinAgricultura $c07_02_f_d4" "p" ///
							"Personería $c07_02_n_d1" "p" "Personería $c07_02_n_d2" "p" ///
							"Personería $c07_02_n_d3" "p" "Personería $c07_02_n_d4" "p"

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

putexcel set "${output_table}/${file_name}.xlsx", sheet("pregunta2") replace
putexcel A1="¿Qué tanto confía usted en?: "
putexcel A2=matrix(${pregunta}), names










**# Pregunta 3  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
//¿quién ayuda a resolver los conflictos entre vecinos?:
// c07_03_X (13 vars, sin contar 89_2)
global pregunta p3
foreach Q of global p3{
	tab `Q' linea
}

foreach VAR of global p3{
// 	di "`VAR'"
	local Q:variable label `VAR'
	local pos =strpos("`Q'", ":")
	local varlabel=substr("`Q'", `pos'+2,32)
// 	di "`varlabel'"
	global `VAR'="`varlabel'"
}

matrix ${pregunta} = J(26,11,.)
matrix colnames ${pregunta}= "LB" ///
				   "muNada" "LB-Nada" ///
				   "muAAI"  "LB-AAI" ///
				   "muSA"   "LB-SA" ///
				   "muPP"   "LB-PP" ///
				   "muPPSA" "LB-PPSA"
matrix rownames ${pregunta}="$c07_03_1" "p" "$c07_03_2" "p" "$c07_03_3" "p" "$c07_03_4" "p" ///
							"$c07_03_5" "p" "$c07_03_6" "p" "$c07_03_7" "p" "$c07_03_8" "p" ///
							"$c07_03_9" "p" "$c07_03_10" "p" "$c07_03_11" "p" "$c07_03_89" "p" ///
							"$c07_03_90" "p" 

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
putexcel A1="¿quién ayuda a resolver los conflictos entre vecinos?:"
putexcel A2=matrix(${pregunta}), names





