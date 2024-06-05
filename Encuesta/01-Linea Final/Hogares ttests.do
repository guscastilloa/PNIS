/*
DESCRIPCIÓN:
	En este script se realiza la diferencia de medias de las variables de la 
	encuesta para HOGARES entre los que no recibieron nada frente a cada uno de los hogares que recibieron cada uno de los componentes .

*/

* Preámbulo luego de ejectuar _master.do
global output_table "${projectfolder}/Output/Encuesta/tablas"
use "db_encuesta_hogar_sin_recolectores.dta", clear


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
*********************************************
* Crear variables agrupadoras por cada componente agrupando PP en uno solo
gen ejecución_PNIS_nueva=.
replace ejecución_PNIS_nueva=0 if ejecución_PNIS==0 // Nada
replace ejecución_PNIS_nueva=1 if ejecución_PNIS==1 // AAI
replace ejecución_PNIS_nueva=2 if ejecución_PNIS==2 // SA
replace ejecución_PNIS_nueva=3 if ejecución_PNIS==3 | ejecución_PNIS== 5 // PP = CC or CL
replace ejecución_PNIS_nueva=4 if c09_10==1 & (c09_12==1 | c09_13==1) // PP&SA

label define lejecucion2 0 "Nada" 1 "AAI" 2 "SA" 3 "PP" 4 "PP&SA", replace
label values ejecución_PNIS_nueva lejecucion2

tab ejecución_PNIS ejecución_PNIS_nueva 
//Se procede a reemplazar la variable anterior por la nueva
replace ejecución_PNIS=ejecución_PNIS_nueva
* Asignar etiqueta de valores de "ejecución_PNIS_nueva" a la variable anterior
label values ejecución_PNIS lejecucion2
* Crear variables agrupadoras por cada componente

gen l_ejecución_PNIS=ejecución_PNIS

label define lejecucion2 0 "Nada" 1 "AAI" 2 "SA" 3 "PP" 4 "PP&SA", replace
label values l_ejecución_PNIS lejecucion2
tab l_ejecución_PNIS

bysort linea: sum factor_exp
**Guardamos solo las variables que estan en linea final y que son continuas
keep id ipm nse actividad codigo_departamento codigo_municipio codigo_vereda actividad factor_exp l_ejecución_PNIS ejecución_PNIS actividad c09_01_h c09_01_02_h c09_02_h c09_04_h c09_20_a c09_20_b c09_20_c c09_20_i c09_20_d c09_20_e c09_20_f c09_20_g c09_20_h c09_01 c09_01_02 

****T-Test
**

*Definimos las variables de las preguntas 

global pc "c09_01 c09_01_h c09_01_02 c09_01_02_h c09_02_h c09_04_h c09_20_a c09_20_b c09_20_c c09_20_i c09_20_d c09_20_e c09_20_f c09_20_g c09_20_h"

* Definir función que asigne etiqueta de variable a global con nombre de var
capture program drop label32global
program label32global
	// Corte etiqueta de variable a 32 caracteres
	local Q: variable label `1'
	local pos=strpos("`Q'", "***")
	local varlabel=substr("`Q'", `pos'+2, 32)
	// Guarde etiqueta cortada en global que lleve el nombre de la variable
	global `1' = "`varlabel'"
end
* Ejecutar función sobre todas las variables continuas 
foreach VAR of varlist c*{
	di "`VAR'"
	label32global `VAR'
}	
*----------------------------------------------*-------------------------------------------------------------------------------
**# 3. Ttests por capítulo
*-------------------------------------------------------------------------------
* Matriz:
//columnas:
//mu_Nada,𝚫, mu_AAI,𝚫, mu_SA,𝚫, mu_CC,𝚫, mu_CCSA,𝚫, mu_CL,𝚫, Baseline.


// local ipm_label : var label ipm
// matrix rownames M= "`ipm_label'"
// global row: label ejecucion_prima ${grupo_control}
// global tratamiento: label ejecucion_prima ${grupo_tratamiento}

global pregunta pc 
matrix ${pregunta}= J(30,09,.)
matrix colnames ${pregunta}= "Nada" ///
				   "muAAI"  "Nada-AAI" ///
				   "muSA"   "Nada-SA" ///
				   "muPP"   "Nada-PP" ///
				   "muPPSA" "Nada-PP&SA"
				   
matrix rownames ${pregunta} = "$c09_01" "p-valor" "$c09_01_h" "p-valor" "$c09_01_02" "p-valor" "$c09_01_02_h" "p-valor" "$c09_02_h" "p-valor" "$c09_04_h" "p-valor" "$c09_20_a" "p-valor" "$c09_20_b" "p-valor" "$c09_20_c" "p-valor" "$c09_20_i" "p-valor" "$c09_20_d" "p-valor" "$c09_20_e" "p-valor" "$c09_20_f" "p-valor" "$c09_20_g" "p-valor" "$c09_20_h" "p-valor"

matlist ${pregunta}


**Loop 
* Calcular promedio por grupo
local row = 1
foreach Q of global pc{
* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* Nada: promedio
	matrix ${pregunta}[`row',1] =   _b[c.`Q'@0.l_ejecución_PNIS]
 // linea final
	
	local row=`row'+2
} 

// Poner promedios, diferencias y pvalor por componente
local it = 1
local row=1
foreach Q of global pc{
	di "> `Q'"
	local col = 2
	
	
	* Calcular promedio por grupo * * * * * * * * * 
	mean `Q' [aweight = factor_exp], over(l_ejecución_PNIS) coeflegend
	
	* AAI: promedio, diferencia medias, p-valor
	matrix ${pregunta}[`row',`col'] =  _b[c.`Q'@1.l_ejecución_PNIS]
	matrix ${pregunta}[`row',`col'+1]=_b[c.`Q'@0.l_ejecución_PNIS] - _b[c.`Q'@1.l_ejecución_PNIS]
		test _b[c.`Q'@0.l_ejecución_PNIS] = _b[c.`Q'@1.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+1] = r(p)
	
	* SA: promedio, diff, p-valor
	matrix ${pregunta}[`row',`col'+2] =  _b[c.`Q'@2.l_ejecución_PNIS]
	matrix ${pregunta}[`row',`col'+3]=_b[c.`Q'@0.l_ejecución_PNIS] - _b[c.`Q'@2.l_ejecución_PNIS]
		test _b[c.`Q'@0.l_ejecución_PNIS] = _b[c.`Q'@2.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+3] = r(p)
	
	* PP: promedio, diff, p-valor
	matrix ${pregunta}[`row',`col'+4] =  _b[c.`Q'@3.l_ejecución_PNIS]
	matrix ${pregunta}[`row', `col'+5]=_b[c.`Q'@0.l_ejecución_PNIS] - _b[c.`Q'@3.l_ejecución_PNIS]
		test _b[c.`Q'@0.l_ejecución_PNIS] = _b[c.`Q'@3.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1, `col'+5] = r(p)
	
	* PP&SA: promedio, diff, p-valor
	matrix ${pregunta}[`row',`col'+6] = _b[c.`Q'@4.l_ejecución_PNIS]
	matrix ${pregunta}[`row',`col'+7]=_b[c.`Q'@0.l_ejecución_PNIS] - _b[c.`Q'@4.l_ejecución_PNIS]
		test _b[c.`Q'@0.l_ejecución_PNIS] = _b[c.`Q'@4.l_ejecución_PNIS]
	matrix ${pregunta}[`row'+1,`col'+7] = r(p)
	

	
	
	local row=`row'+2
	local it = `it'+1
	di "Iteración `it'" 
	
}

matlist  ${pregunta}

putexcel set "encuesta_variables_continuas2.xlsx", sheet("Continuas") replace
putexcel A1=matrix(${pregunta}), names nformat(number_d2)






