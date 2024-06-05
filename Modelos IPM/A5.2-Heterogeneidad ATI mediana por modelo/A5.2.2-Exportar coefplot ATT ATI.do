/*
AUTOR:
	Gustavo Castillo

FECHA: 
	27/sept/2023

DESCRIPCIÓN:
	En el siguiente script se exportan las gráficas de las estimaciones de los
	modelos 1-7 (especificaciones 4) para revisar la heterogeneidad en el efecto
	del IPM de aquellos CUBs de acuerdo a la categoría de ATI recibida. En este
	caso se exportan los modelos cuya definición de mediana fue dentro de
	cada modelo, i.e. dentro de cada par de grupos de comparación.
	En total hay 30 estimaciones (30 ATTs) que hay que observar: 
	- Modelo 1: 6 estimaciones
	- Modelo 2: 4 estimaciones
	- Modelo 3: 4 estimaciones
	- Modelo 4: 4 estimaciones
	- Modelo 5: 4 estimaciones
	- Modelo 6: 4 estimaciones
	- Modelo 7: 4 estimaciones
	

*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Estimación_modelos/estimaciones/_heterogeneidad ati/Mediana por modelo"
										
use "${datafolder}/base_estimaciones_gus.dta", clear
global output_path "${projectfolder}/Output/Graficos/_heterogeneidad ati/Mediana por modelo"
	sum ati_porc if ati_porc !=0, d
	scalar med = r(p50)
	di med
	replace d_ati = 1 if ati_porc<med
	replace d_ati = 2 if ati_porc>=med
	replace d_ati = 0 if ati_porc==0
	replace d_ati = . if activo==0 | actividad=="Recolector"
	label define l_ati 0 "Nada" 1 "Menos de la mediana" 2 "Más de la mediana", replace
	label values d_ati l_ati

* Fijar globals con value labels de d_ati para títulos 
global ATI0: label l_ati 0
global ATI1: label l_ati 1
global ATI2: label l_ati 2

mata st_global("ATI0", st_vlmap("l_ati", 0))
mata st_global("ATI1", st_vlmap("l_ati", 1))
mata st_global("ATI2", st_vlmap("l_ati", 2))

di "$ATI0"
di "$ATI1"
di "$ATI2"

*-------------------------------------------------------------------------------
**# Crear 4 matrices con ATT, IC y p-valor para cada modelo
*-------------------------------------------------------------------------------
//  .----------------. 
// | .--------------. |
// | |     __       | |
// | |    /  |      | |
// | |    `| |      | |
// | |     | |      | |
// | |    _| |_     | |
// | |   |_____|    | |
// | |              | |
// | '--------------' |
//  '----------------' 
cls
global n_model=1

*-------------------------------------------------------------------------
* Para especificación 4:
	* Hay 6 ATTs, para ati 0, 1 y 2
*-------------------------------------------------------------------------
local E=4
* Iterar sobre ATI- - - - - - - - - - - - - - - - - - - - - - - - -
forvalues ATI=0/2{
	local col=1
	
	* Crear Matriz
	matrix M${n_model}E`E'ati`ATI' = J(4,2,.)
	matrix rownames M${n_model}E`E'ati`ATI' = "ATT" "LB90" "UB90" "pvalue"
	matrix colnames M${n_model}E`E'ati`ATI' = "IPM 1" "IPM 2"
	
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - - - - - - -
	forvalues I=1/2{
		di "Columna `col'"
		* Cargar estimaciones
		estimates use "${dir_estimaciones}/esp`E'-model${n_model}-IPM `I'-con_outliers-ati`ATI'.ster"
		di _col(3) "Con outliers"
		di _col(3) "> ATI `ATI', IPM `I'"
		estat simple, estore(E`E'_`I'_c) level(90)
		
		matrix M${n_model}E`E'ati`ATI'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix M${n_model}E`E'ati`ATI'[2, `col']=r(table)[5,1] // Guardar LB
		matrix M${n_model}E`E'ati`ATI'[3, `col']=r(table)[6,1] // Guardar UB
		matrix M${n_model}E`E'ati`ATI'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		local col=`col'+1
		
	}

}
* Crear gráficos individuales para
* ATI = 0
coefplot matrix(M${n_model}E`E'ati0), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI0}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g0, replace)
* ATI = 1	
coefplot matrix(M${n_model}E`E'ati1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI1}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g1, replace)
* ATI = 2	
coefplot matrix(M${n_model}E`E'ati2), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI2}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g2, replace)

graph combine g0 g1 g2, ycommon title("Especificación `E'") ///
	name(combinado`E', replace) rows(1) ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%." ///
	"La mediana de recepción de ATI se calculó para cada submuestra.")
graph export "${output_path}/heterogeneidadATI_model${n_model}esp`E'-p50modelo.jpg", replace




//  .----------------. 
// | .--------------. |
// | |    _____     | |
// | |   / ___ `.   | |
// | |  |_/___) |   | |
// | |   .'____.'   | |
// | |  / /____     | |
// | |  |_______|   | |
// | |              | |
// | '--------------' |
//  '----------------' 
*-------------------------------------------------------------------------
* Para especificación 4: 
	* Hay 4 ATTs: para ati 1 y 2
*-------------------------------------------------------------------------
global n_model=2
local E=4
* Iterar sobre ATI- - - - - - - - - - - - - - - - - - - - - - - - -
forvalues ATI=1/2{
	local col=1
	
	* Crear Matriz
	matrix M${n_model}E`E'ati`ATI' = J(4,2,.)
	matrix rownames M${n_model}E`E'ati`ATI' = "ATT" "LB90" "UB90" "pvalue"
	matrix colnames M${n_model}E`E'ati`ATI' = "IPM 1" "IPM 2"
	
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - - - - - - -
	forvalues I=1/2{
		di "Columna `col'"
		* Cargar estimaciones
		estimates use "${dir_estimaciones}/esp`E'-model${n_model}-IPM `I'-con_outliers-ati`ATI'.ster"
		di _col(3) "Con outliers"
		di _col(3) "> ATI `ATI', IPM `I'"
		estat simple, estore(E`E'_`I'_c) level(90)
		
		matrix M${n_model}E`E'ati`ATI'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix M${n_model}E`E'ati`ATI'[2, `col']=r(table)[5,1] // Guardar LB
		matrix M${n_model}E`E'ati`ATI'[3, `col']=r(table)[6,1] // Guardar UB
		matrix M${n_model}E`E'ati`ATI'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		local col=`col'+1
		
	}

}
* Crear gráficos individuales para
* ATI = 1	
coefplot matrix(M${n_model}E`E'ati1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI1}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g1, replace)
* ATI = 2	
coefplot matrix(M${n_model}E`E'ati2), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI2}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g2, replace)

graph combine g1 g2, ycommon title("Especificación `E'") ///
	name(combinado`E', replace) rows(1) ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%." ///
	"La mediana de recepción de ATI se calculó para cada submuestra.")
graph export "${output_path}/heterogeneidadATI_model${n_model}esp`E'-p50modelo.jpg", replace
graph drop _all

//  .----------------. 
// | .--------------. |
// | |    ______    | |
// | |   / ____ `.  | |
// | |   `'  __) |  | |
// | |   _  |__ '.  | |
// | |  | \____) |  | |
// | |   \______.'  | |
// | |              | |
// | '--------------' |
//  '----------------' 
global n_model=3
*-------------------------------------------------------------------------
* Para especificación 4:
	* Hay 4 ATTs: para ati 1 y 2
*-------------------------------------------------------------------------
local E=4
* Iterar sobre ATI- - - - - - - - - - - - - - - - - - - - - - - - -
forvalues ATI=1/2{
	local col=1
	
	* Crear Matriz
	matrix M${n_model}E`E'ati`ATI' = J(4,2,.)
	matrix rownames M${n_model}E`E'ati`ATI' = "ATT" "LB90" "UB90" "pvalue"
	matrix colnames M${n_model}E`E'ati`ATI' = "IPM 1" "IPM 2"
	
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - - - - - - -
	forvalues I=1/2{
		di "Columna `col'"
		* Cargar estimaciones
		estimates use "${dir_estimaciones}/esp`E'-model${n_model}-IPM `I'-con_outliers-ati`ATI'.ster"
		di _col(3) "Con outliers"
		di _col(3) "> ATI `ATI', IPM `I'"
		estat simple, estore(E`E'_`I'_c) level(90)
		
		matrix M${n_model}E`E'ati`ATI'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix M${n_model}E`E'ati`ATI'[2, `col']=r(table)[5,1] // Guardar LB
		matrix M${n_model}E`E'ati`ATI'[3, `col']=r(table)[6,1] // Guardar UB
		matrix M${n_model}E`E'ati`ATI'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		local col=`col'+1
		
	}

}
* Crear gráficos individuales para
* ATI = 1	
coefplot matrix(M${n_model}E`E'ati1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI1}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g1, replace)  ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))
* ATI = 2	
coefplot matrix(M${n_model}E`E'ati2), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI2}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g2, replace) ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))

graph combine g1 g2, ycommon title("Especificación `E'") ///
	name(combinado`E', replace) rows(1) ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%." ///
	"La mediana de recepción de ATI se calculó para cada submuestra.")
graph export "${output_path}/heterogeneidadATI_model${n_model}esp`E'-p50modelo.jpg", replace
graph drop _all


//  .----------------. 
// | .--------------. |
// | |   _    _     | |
// | |  | |  | |    | |
// | |  | |__| |_   | |
// | |  |____   _|  | |
// | |      _| |_   | |
// | |     |_____|  | |
// | |              | |
// | '--------------' |
//  '----------------' 
global n_model=4
*-------------------------------------------------------------------------
* Para especificación 4:
	* Hay 4 ATTs, ati 1 y 2
*-------------------------------------------------------------------------
local E=4
* Iterar sobre ATI- - - - - - - - - - - - - - - - - - - - - - - - -
forvalues ATI=1/2{
	local col=1
	
	* Crear Matriz
	matrix M${n_model}E`E'ati`ATI' = J(4,2,.)
	matrix rownames M${n_model}E`E'ati`ATI' = "ATT" "LB90" "UB90" "pvalue"
	matrix colnames M${n_model}E`E'ati`ATI' = "IPM 1" "IPM 2"
	
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - - - - - - -
	forvalues I=1/2{
		di "Columna `col'"
		* Cargar estimaciones
		estimates use "${dir_estimaciones}/esp`E'-model${n_model}-IPM `I'-con_outliers-ati`ATI'.ster"
		di _col(3) "Con outliers"
		di _col(3) "> ATI `ATI', IPM `I'"
		estat simple, estore(E`E'_`I'_c) level(90)
		
		matrix M${n_model}E`E'ati`ATI'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix M${n_model}E`E'ati`ATI'[2, `col']=r(table)[5,1] // Guardar LB
		matrix M${n_model}E`E'ati`ATI'[3, `col']=r(table)[6,1] // Guardar UB
		matrix M${n_model}E`E'ati`ATI'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		local col=`col'+1
		
	}

}
* Crear gráficos individuales para
* ATI = 1	
coefplot matrix(M${n_model}E`E'ati1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI1}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g1, replace)  ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))
* ATI = 2	
coefplot matrix(M${n_model}E`E'ati2), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI2}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g2, replace) ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))

graph combine g1 g2, ycommon title("Especificación `E'") ///
name(combinado`E', replace) rows(1) ///
note("Los intervalos de confianza de los estimadores se calcularon al 90%." ///
	"La mediana de recepción de ATI se calculó para cada submuestra.")

graph export "${output_path}/heterogeneidadATI_model${n_model}esp`E'-p50modelo.jpg", replace
graph drop _all


//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  _____|   | |
// | |  | |____     | |
// | |  '_.____''.  | |
// | |  | \____) |  | |
// | |   \______.'  | |
// | |              | |
// | '--------------' |
//  '----------------' 
global n_model=5
*-------------------------------------------------------------------------
* Para especificación 4:
	* Hay 4 ATTs, para ati 1 y 2
*-------------------------------------------------------------------------
local E=4
* Iterar sobre ATI- - - - - - - - - - - - - - - - - - - - - - - - -
forvalues ATI=1/2{
	local col=1
	
	* Crear Matriz
	matrix M${n_model}E`E'ati`ATI' = J(4,2,.)
	matrix rownames M${n_model}E`E'ati`ATI' = "ATT" "LB90" "UB90" "pvalue"
	matrix colnames M${n_model}E`E'ati`ATI' = "IPM 1" "IPM 2"
	
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - - - - - - -
	forvalues I=1/2{
		di "Columna `col'"
		* Cargar estimaciones
		estimates use "${dir_estimaciones}/esp`E'-model${n_model}-IPM `I'-con_outliers-ati`ATI'.ster"
		di _col(3) "Con outliers"
		di _col(3) "> ATI `ATI', IPM `I'"
		estat simple, estore(E`E'_`I'_c) level(90)
		
		matrix M${n_model}E`E'ati`ATI'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix M${n_model}E`E'ati`ATI'[2, `col']=r(table)[5,1] // Guardar LB
		matrix M${n_model}E`E'ati`ATI'[3, `col']=r(table)[6,1] // Guardar UB
		matrix M${n_model}E`E'ati`ATI'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		local col=`col'+1
		
	}

}
* Crear gráficos individuales para
* ATI = 1	
coefplot matrix(M${n_model}E`E'ati1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI1}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g1, replace)  ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))
* ATI = 2	
coefplot matrix(M${n_model}E`E'ati2), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI2}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g2, replace) ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))

graph combine g1 g2, ycommon title("Especificación `E'") ///
name(combinado`E', replace) rows(1) ///
note("Los intervalos de confianza de los estimadores se calcularon al 90%." ///
	"La mediana de recepción de ATI se calculó para cada submuestra.")

graph export "${output_path}/heterogeneidadATI_model${n_model}esp`E'-p50modelo.jpg", replace
graph drop _all


//  .----------------. 
// | .--------------. |
// | |    ______    | |
// | |  .' ____ \   | |
// | |  | |____\_|  | |
// | |  | '____`'.  | |
// | |  | (____) |  | |
// | |  '.______.'  | |
// | |              | |
// | '--------------' |
//  '----------------' 
global n_model=6
*-------------------------------------------------------------------------
* Para especificación 4
*-------------------------------------------------------------------------
local E=4
* Iterar sobre ATI- - - - - - - - - - - - - - - - - - - - - - - - -
forvalues ATI=1/2{
	local col=1
	
	* Crear Matriz
	matrix M${n_model}E`E'ati`ATI' = J(4,2,.)
	matrix rownames M${n_model}E`E'ati`ATI' = "ATT" "LB90" "UB90" "pvalue"
	matrix colnames M${n_model}E`E'ati`ATI' = "IPM 1" "IPM 2"
	
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - - - - - - -
	forvalues I=1/2{
		di "Columna `col'"
		* Cargar estimaciones
		estimates use "${dir_estimaciones}/esp`E'-model${n_model}-IPM `I'-con_outliers-ati`ATI'.ster"
		di _col(3) "Con outliers"
		di _col(3) "> ATI `ATI', IPM `I': `e(N)' observaciones"
		estat simple, estore(E`E'_`I'_c) level(90)
		
		matrix M${n_model}E`E'ati`ATI'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix M${n_model}E`E'ati`ATI'[2, `col']=r(table)[5,1] // Guardar LB
		matrix M${n_model}E`E'ati`ATI'[3, `col']=r(table)[6,1] // Guardar UB
		matrix M${n_model}E`E'ati`ATI'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		local col=`col'+1
		
	}

}
* Crear gráficos individuales para
* ATI = 1	
coefplot matrix(M${n_model}E`E'ati1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI1}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g1, replace)  ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))
* ATI = 2	
coefplot matrix(M${n_model}E`E'ati2), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI2}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g2, replace) ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))

graph combine g1 g2, ycommon title("Especificación `E'") ///
name(combinado`E', replace) rows(1) ///
note("Los intervalos de confianza de los estimadores se calcularon al 90%." ///
	"La mediana de recepción de ATI se calculó para cada submuestra.")

graph export "${output_path}/heterogeneidadATI_model${n_model}esp`E'-p50modelo.jpg", replace
graph drop _all

//  .----------------. 
// | .--------------. |
// | |   _______    | |
// | |  |  ___  |   | |
// | |  |_/  / /    | |
// | |      / /     | |
// | |     / /      | |
// | |    /_/       | |
// | |              | |
// | '--------------' |
//  '----------------' 
global n_model=7
*-------------------------------------------------------------------------
* Para especificación 4: 
	* Hay 4 ATTs, para ati 1 y 2
*-------------------------------------------------------------------------
local E=4
* Iterar sobre ATI- - - - - - - - - - - - - - - - - - - - - - - - -
forvalues ATI=1/2{
	local col=1
	
	* Crear Matriz
	matrix M${n_model}E`E'ati`ATI' = J(4,2,.)
	matrix rownames M${n_model}E`E'ati`ATI' = "ATT" "LB90" "UB90" "pvalue"
	matrix colnames M${n_model}E`E'ati`ATI' = "IPM 1" "IPM 2"
	
	* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - - - - - - -
	forvalues I=1/2{
		di "Columna `col'"
		* Cargar estimaciones
		estimates use "${dir_estimaciones}/esp`E'-model${n_model}-IPM `I'-con_outliers-ati`ATI'.ster"
		di _col(3) "Con outliers"
		di _col(3) "> ATI `ATI', IPM `I': `e(N)' observaciones"
		estat simple, estore(E`E'_`I'_c) level(90)
		
		matrix M${n_model}E`E'ati`ATI'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix M${n_model}E`E'ati`ATI'[2, `col']=r(table)[5,1] // Guardar LB
		matrix M${n_model}E`E'ati`ATI'[3, `col']=r(table)[6,1] // Guardar UB
		matrix M${n_model}E`E'ati`ATI'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		local col=`col'+1
		
	}

}
* Crear gráficos individuales para
* ATI = 1	
coefplot matrix(M${n_model}E`E'ati1), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI1}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g1, replace)  ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))
* ATI = 2	
coefplot matrix(M${n_model}E`E'ati2), ci((2 3)) vert yline(0, lpattern(dash)) ///
	title("${ATI2}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
	scheme(s1color) ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) aspect(1.4) name(g2, replace) ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))

graph combine g1 g2, ycommon title("Especificación `E'") ///
name(combinado`E', replace) rows(1) ///
note("Los intervalos de confianza de los estimadores se calcularon al 90%." ///
	"La mediana de recepción de ATI se calculó para cada submuestra.")

graph export "${output_path}/heterogeneidadATI_model${n_model}esp`E'-p50modelo.jpg", replace
graph drop _all



* End
