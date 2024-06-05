use "/Users/lucas_marinll/Dropbox/Lucas Marín Llanes/Investigación/2021/ZME - PNIS/Datos/Base2Sept.dta", clear

destring c07_02a c07_02b c07_02c c07_02d c07_02e, replace

gen suma = c07_02a + c07_02b 

gen rec_cultivador = 1 if suma == 2 
replace rec_cultivador = 0 if suma != 2

gen recolector = 1 if c07_02b == 1 & suma == 1
replace recolector = 0 if c07_02b == 0 | suma != 1

gen cultivador = 1 if c07_02a == 1 & suma == 1
replace cultivador = 0 if c07_02a == 0 | suma != 1

mean recolector cultivador rec_cultivador [aweight = factor]

gen relacion_cultivos = 0 if cultivador == 1
replace relacion_cultivos = 1 if recolector == 1
replace relacion_cultivos = 2 if rec_cultivador == 1

***** Distribución departamentos ***** 

sort relacion_cultivos
by relacion_cultivos: tab Departamento [aweight = factor]

***** Distribución tenencia de tierra ***** 

sort relacion_cultivos
by relacion_cultivos: tab c05_01 [aweight = factor]

***** Distribución documentación de propiedad ***** 

sort relacion_cultivos
by relacion_cultivos: tab c05_02 [aweight = factor]

***** Diferencias en IPM *****

mean d_ipm [aweight = factor], over(relacion_cultivos)

test _b[c.d_ipm@0bn.relacion_cultivos] = _b[c.d_ipm@1.relacion_cultivos]
test _b[c.d_ipm@0bn.relacion_cultivos] = _b[c.d_ipm@2.relacion_cultivos]
test _b[c.d_ipm@1.relacion_cultivos] = _b[c.d_ipm@2.relacion_cultivos]

*** Por dimensiones ***

matrix define A=J(24,6,.) 
matrix colnames A = "Cultivadores" "Recolectores" "Mean difference (p-value)" "Culti + Recolec" "Mean difference (p-value)" "Mean difference (p-value)"
matrix rownames A = "Logro edu" "" "Analfa" "" "Dependencia" "" "Seguro" "" "Agua" "" "Eliminación" "" "Primera infancia" "" "Inasistencia" "" "Extraedad" "" "Piso" "" "Paredes" "" "Hacinamiento" ""

global dimensiones logro_educativo analfabetismo dependencia no_seguro agua eliminación primera_infancia inasistencia extraedad piso paredes hacinamiento

local f=1

foreach x of global dimensiones { 

local c=1 

	mean `x' [aweight = factor], over(relacion_cultivos) coeflegend
	matrix A[`f',`c']=_b[c.`x'@0bn.relacion_cultivos]
	matrix A[`f',`c'+1]=_b[c.`x'@1.relacion_cultivos]
	matrix A[`f',`c'+2]=_b[c.`x'@0bn.relacion_cultivos] - _b[c.`x'@1.relacion_cultivos]
	test _b[c.`x'@0bn.relacion_cultivos] = _b[c.`x'@1.relacion_cultivos]
	matrix A[`f'+1,`c'+2]=r(p)
	
	matrix A[`f',`c'+3]=_b[c.`x'@2.relacion_cultivos]
	matrix A[`f',`c'+4]=_b[c.`x'@0bn.relacion_cultivos] - _b[c.`x'@2.relacion_cultivos]
	test _b[c.`x'@0bn.relacion_cultivos] = _b[c.`x'@2.relacion_cultivos]
	matrix A[`f'+1,`c'+4]=r(p)
	
	matrix A[`f',`c'+5]=_b[c.`x'@1.relacion_cultivos] - _b[c.`x'@2.relacion_cultivos]
	test _b[c.`x'@1.relacion_cultivos] = _b[c.`x'@2.relacion_cultivos]
	matrix A[`f'+1,`c'+5]=r(p)
	
	local f=`f'+2

}

	putexcel set "/Users/lucas_marinll/Dropbox/Lucas Marín Llanes/Investigación/2021/ZME - PNIS/Descriptivas/recolectores.xlsx", sheet("Hoja1") replace
	putexcel A1=matrix(A), names 


***** Diferencias en ingresos *****

destring Ingreso_Total, replace 
gen ln_ingreso = ln(Ingreso_Total + 1)

mean ln_ingreso [aweight = factor], over(relacion_cultivos)

test _b[c.ln_ingreso@0bn.relacion_cultivos] = _b[c.ln_ingreso@1.relacion_cultivos]
test _b[c.ln_ingreso@0bn.relacion_cultivos] = _b[c.ln_ingreso@2.relacion_cultivos]
test _b[c.ln_ingreso@1.relacion_cultivos] = _b[c.ln_ingreso@2.relacion_cultivos]

