global capitulo_archivo "capitulo5"

use "C:db_encuesta_hogar_sin_recolectores.dta"

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

**********************************************
*dejamos datos solo de linea final
keep if linea=="final"

**********************************************

* Crear variables agrupadoras por cada componente

gen l_ejecución_PNIS=ejecución_PNIS

label define lejecucion2 0 "Nada" 1 "AAI" 2 "SA" 3 "CC" 4 "PP&SA", replace
label values l_ejecución_PNIS lejecucion2
tab l_ejecución_PNIS

bysort linea: sum factor_exp

**Guardamos solo las variables que estan en linea final

keep id nse actividad codigo_departamento codigo_municipio codigo_vereda actividad factor_exp l_ejecución_PNIS ejecución_PNIS actividad c01_02 c01_06 c03_13 c07_01_1 c07_01_2 c07_01_3 c07_01_4 c07_01_5 c07_01_6 c07_01_89 c07_01_90 c05_08_1 c05_08_2 c05_08_3 c05_08_4 c05_08_5 c05_08_6 c05_08_7 c05_08_8 c05_08_9 c05_08_89 c08_01_1 c08_01_2 c08_01_3 c08_01_4 c08_01_5 c08_01_6 c08_01_7 c08_01_8 c08_01_9 c08_01_10 c08_01_11 c08_01_89 c08_01_90 c09_00_1 c09_00_2 c09_00_3 c09_00_4 c09_00_90 c09_01 c09_09_03 c09_16_1 c09_16_2 c09_16_3 c09_16_4 c09_16_5 c09_16_6 c09_16_90 c09_16_89 c09_17_1 c09_17_2 c09_17_3 c09_17_90 c09_17_89 i_bajo_educat~o i_analfabetismo i_inasistenci~r i_rezago_esco~r i_niños i_tasas_depen~a i_s_social i_agua i_excretas i_pisos i_paredes i_hacimiento ipm c03_14 c03_15_1 c03_15_2 c03_15_3 c03_15_4 c03_15_5 c03_15_6 c03_15_7 c07_02_a c07_02_d c07_02_e c07_02_g c07_02_h c07_02_i c07_02_j c07_02_l c07_02_m c07_02_o c07_02_q c07_02_r c07_02_01_a c07_02_01_b c06_01 c06_02 c06_03 c05_01_4 c05_01_5 c05_03_02 c05_11 c09_01_01 c09_08 c09_09 c09_09_89 c09_10 c09_11 c09_11_01 c09_12 c09_13 c09_14 c09_15 c09_18 c09_19 c01_06_89 c04_01 c04_02 c09_01 c09_01_h c09_01_02_h c09_02_h c09_04_h c09_09_01 c09_09_02 c09_20_a c09_20_b c09_20_c c09_20_i c09_20_d c09_20_e c09_20_f c09_20_g c09_20_h c09_20_h_89 c06_04 

*quitamos todas las variables que solo son para recolectores 
drop c09_09_01 c09_09_02 c09_09 c09_09  c09_09_89 c09_09_01  c09_09_02 c09_09_03 

***convertimos las variables categoricas en Dummies


foreach x of varlist actividad c01_02 c01_06 c03_13 c03_14 c03_15_1 c03_15_2 c03_15_3 c03_15_4 c03_15_5 c03_15_6 c03_15_7 c07_02_a c07_02_d c07_02_e c07_02_g c07_02_h c07_02_i c07_02_j c07_02_l c07_02_m c07_02_o c07_02_q c07_02_r c07_02_01_a c07_02_01_b c06_01 c06_02 c06_03 c06_04 c05_01_4 c05_01_5 c05_03_02 c05_11 c09_01_01 c09_08 c09_10 c09_11 c09_11_01 c09_12 c09_13 c09_14 c09_15 c09_18 c09_19 {
    tab `x', gen (`x'_d)
}


***Borramos las variables categoricas que ya son dummies
drop c01_02 c01_06 c03_13 c03_14 c03_15_1 c03_15_2 c03_15_3 c03_15_4 c03_15_5 c03_15_6 c03_15_7 c07_02_a c07_02_d c07_02_e c07_02_g c07_02_h c07_02_i c07_02_j c07_02_l c07_02_m c07_02_o c07_02_q c07_02_r c07_02_01_a c07_02_01_b c06_01 c06_02 c06_03 c06_04 c05_01_4 c05_01_5 c05_03_02 c05_11 c09_01_01 c09_08 c09_10 c09_11 c09_11_01 c09_12 c09_13 c09_14 c09_15 c09_18 c09_19 

*Eliminamos las variables continuas para ser sistematizadas posteriormente
drop c09_01_h c09_01_02_h c09_02_h c09_04_h c09_20_a c09_20_b c09_20_c c09_20_i c09_20_d c09_20_e c09_20_f c09_20_g c09_20_h c09_20_h_89 c09_01 c09_01_02 

****T-Test
**************Capitulo 5*********************

*Definimos las variables por grupo de preguntas 

global p5 "c05_08_1 c05_08_2 c05_08_3 c05_08_4 c05_08_5 c05_08_6 c05_08_7 c05_08_8 c05_08_9 c05_08_89 c05_01_4_d1 c05_01_4_d2 c05_01_5_d1 c05_01_5_d2 c05_03_02_d1 c05_03_02_d2 c05_03_02_d3 c05_03_02_d4 c05_03_02_d5 c05_03_02_d6 c05_11_d1 c05_11_d2 c05_11_d3"

* Definir función que asigne etiqueta de variable a global con nombre de var
capture program drop label32global
program label32global
	// Corte etiqueta de variable a 32 caracteres
	local Q: variable label `1'
	local pos=strpos("`Q'", "***")
	local varlabel=substr("`Q'", `pos'+2, 200)
	// Guarde etiqueta cortada en global que lleve el nombre de la variable
	global `1' = "`varlabel'"
end

* Ejecutar función sobre todas las variables del capítulo 5
foreach VAR of varlist c05*{
	di "`VAR'"
	label32global `VAR'
}	

*-------------------------------------------------------------------------------
**# 3. Ttests por capítulo
*-------------------------------------------------------------------------------
**# Cápitulo c05 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

global pregunta p5
matrix ${pregunta} = J(46,9,.)
matrix colnames ${pregunta}= "Nada" ///
				   "muAAI"  "Nada-AAI" ///
				   "muSA"   "Nada-SA" ///
				   "muPP"   "Nada-PP" ///
				   "muPPSA" "Nada-PP&SA"
matrix rownames ${pregunta}= "$c05_08_1" "p" "$c05_08_2" "p" "$c05_08_3" "p" "$c05_08_4" "p" "$c05_08_5" "p" "$c05_08_6" "p" "$c05_08_7" "p" "$c05_08_8" "p" "$c05_08_9" "p" "$c05_08_89" "p" "$c05_01_4_d1" "p" "$c05_01_4_d2" "p" "$c05_01_5_d1" "p" "$c05_01_5_d2" "p" "$c05_03_02_d1" "p" "$c05_03_02_d2" "p" "$c05_03_02_d3" "p" "$c05_03_02_d4" "p" "$c05_03_02_d5" "p" "$c05_03_02_d6" "p" "$c05_11_d1" "p" "$c05_11_d2" "p" "$c05_11_d3" "p" 

matlist $pregunta

* Loop
*----------
// Poner promedios de Nada en matriz
local row=1
foreach Q of global p5{
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
foreach Q of global p5{
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

matlist ${pregunta}
*----------
* Export
*----------

putexcel set encuesta_capitulos.xlsx, sheet("Capituloc05") modify
putexcel A1="c_05"
putexcel A2=matrix(${pregunta}), names nformat(number_d2)
    
	








	   
	   
	   

	   
