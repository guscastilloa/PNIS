/*
AUTOR: Gustavo Castillo

FECHA CREACIÓN:
	27/septiembre/2023

DESCRIPCIÓN:
	En el siguiente script se exportan las gráficas de las estimaciones del modelo
	2 (especificaciones 4 y 5) para revisar la heterogeneidad en el efecto
	del IPM de aquellos CUBs que se encuentran en Zonas de Manejo Especial (ZME)
	y aquellos que no, una vez se eliminan de la muestra los CUBs que están en
	parques.

*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Estimación_modelos/estimaciones/_heterogeneidad zme"
use "${datafolder}/base_estimaciones_simci.dta", clear
// cd "${projectfolder}/Output/Estimación_modelos/graficos/ZME"
global output_path "${projectfolder}/Output/Estimación_modelos/graficos/ZME/A3.3 Sin parques"

capture label define lzme 1 "En ZME" 0 "No ZME"
label values zme lzme

tab zme

global ZME0: label zme 0
global ZME1: label zme 1

mata st_global("ZME0", st_vlmap("lzme", 0))
mata st_global("ZME1", st_vlmap("lzme", 1))

di "$ZME0"
di "$ZME1"

*-------------------------------------------------------------------------------
**# Crear 4 matrices con ATT, IC y p-valor para cada modelo
*-------------------------------------------------------------------------------

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
global n_model=2
* Iterar sobre Especificaciones
forvalues E=4/5{
	
	
	* Iterar sobre ZME- - - - - - - - - - - - - - - - - - - - - - - - -
	forvalues ZME=0/1{
		local col=1
		
		* Crear Matriz
		matrix M${n_model}E`E'Z`ZME' = J(4,4,.)
		matrix rownames M${n_model}E`E'Z`ZME' = "ATT" "LB90" "UB90" "pvalue"
		matrix colnames M${n_model}E`E'Z`ZME' = "IPM 1" "IPM 1*" "IPM 2" "IPM 2*"
		
		* Iterar sobre IPM - - - - - - - - - - - - - - - - - - - - - - - - -
		forvalues I=1/2{
			di "Columna `col'"
			* Cargar estimaciones
			estimates use "${dir_estimaciones}/esp`E'-model${n_model}-IPM `I'-con_outliers-Z`ZME'-sin_parques.ster"
			di _col(3) "Con outliers"
			estat simple, estore(E`E'_`I'_c) level(90)
			
			matrix M${n_model}E`E'Z`ZME'[1, `col']=r(table)[1,1] // Guardar ATT
			matrix M${n_model}E`E'Z`ZME'[2, `col']=r(table)[5,1] // Guardar LB
			matrix M${n_model}E`E'Z`ZME'[3, `col']=r(table)[6,1] // Guardar UB
			matrix M${n_model}E`E'Z`ZME'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
			local col=`col'+1
			
			estimates use "${dir_estimaciones}/esp`E'-model${n_model}-IPM `I'-sin_outliers-Z`ZME'-sin_parques.ster"
			di _col(3) "SIN outliers"
			estat simple, estore(e`P'_`I'_s) level(90)
			
			matrix M${n_model}E`E'Z`ZME'[1, `col']=r(table)[1,1] // Guardar ATT
			matrix M${n_model}E`E'Z`ZME'[2, `col']=r(table)[5,1] // Guardar LB
			matrix M${n_model}E`E'Z`ZME'[3, `col']=r(table)[6,1] // Guardar UB
			matrix M${n_model}E`E'Z`ZME'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
			
			local col=`col'+1
			di _newline(3)
		}
	
	}
	
	* Crear gráficos individuales para
	* ZME = 0
// 	coefplot matrix(M${n_model}E`E'Z0), ci((2 3)) vert yline(0, lpattern(dash)) ///
// 		title("${ZME0}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
// 		scheme(s1color) ciopts(lcolor(green) recast(rcap)) ///
// 		mlabcolor(green) mcolor(green) msymbol(D) aspect(1) name(g0, replace)
	* ZME = 1	
	coefplot matrix(M${n_model}E`E'Z1), ci((2 3)) vert yline(0, lpattern(dash)) ///
		title("${ZME1}") ytitle("ATT") mlabel(@b) format("%9.3g") ///
		scheme(s1color) ciopts(lcolor(green) recast(rcap)) ///
		mlabcolor(green) mcolor(green) msymbol(D) aspect(1) name(g1, replace) ///
		ylabel(-0.1(0.025)0.05) yscale(range(-0.1(0.025)0.05))
	
	graph combine g1, ycommon title("Especificación `E'") ///
	subtitle("Excluyendo beneficiarios en parques") ///
	name(combinado`E', replace) ///
	note("Nota: IPM 1*, IPM 2* indica que se excluyeron los outliers de ese modelo."  ///
	"Los intervalos de confianza de los estimadores se calcularon al 90%.")
	graph export "${output_path}/heterogeneidadZME_model${n_model}esp`E'-sin_parques-Z1.jpg", replace
}



