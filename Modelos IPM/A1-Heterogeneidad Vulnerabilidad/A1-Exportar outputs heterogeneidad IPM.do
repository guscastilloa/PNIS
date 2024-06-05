/*
AUTOR: Gustavo Castillo

DESCRIPCIÓN:
	En el siguiente script se exportan las gráficas de las estimaciones del
	modelo 4 (especificaciones 4 y 5) para revisar efetos heterogéneos por nivel
	de vulnerabilidad medida como abajo o por encima de la mediana del IPM
	en 2015 (pre tratamiento).

*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Estimación_modelos/estimaciones"
global table_output "${output}/Estimación_modelos/tablas"
*-------------------------------------------------------------------------------
**# Crea matriz para Especificación 4
*-------------------------------------------------------------------------------
global E=4
matrix C0=J(4,4,.)
matrix rownames C0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames C0 = "IPM 1" "IPM 1*" "IPM 2" "IPM 2*"
matlist C0

matrix C1=J(4,4,.)
matrix rownames C1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames C1 = "IPM 1" "IPM 1*" "IPM 2" "IPM 2*"
matlist C1

* Iterar sobre modelos h0 y h1 (Menos vulnerables y Más vulnerables respectivamente)
forvalues P=0/1{
	di "`P'"
	local col = 1
	* Iterar sobre IPM 1 y 2
	forvalues I=1/2{
		
		estimates use "${dir_estimaciones}/esp${E}-model4-IPM `I'-continua-h`P'.ster"
		qui estat simple, estore(e`P'_`I'_c) level(90)
		scalar N_OBS_`P'_`I'= e(N)
		
		matrix C`P'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix C`P'[2, `col']=r(table)[5,1] // Guardar LB
		matrix C`P'[3, `col']=r(table)[6,1] // Guardar UB
		matrix C`P'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		local col=`col'+1
		
		estimates use "${dir_estimaciones}/esp${E}-model4-IPM `I'-continua-no_outliers-h`P'.ster"
		qui estat simple, estore(e`P'_`I'_s) level(90)
		scalar N_OBS_`P'_`I'= e(N)
		
		matrix C`P'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix C`P'[2, `col']=r(table)[5,1] // Guardar LB
		matrix C`P'[3, `col']=r(table)[6,1] // Guardar UB
		matrix C`P'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		
		local col=`col'+1
	}
	
}
coefplot matrix(C1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1) name(a, replace) ///
	title("Más vulnerables") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(stc1) recast(rcap)) ///
	mlabcolor(stc1) mcolor(stc1) msymbol(D)
coefplot matrix(C0), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1) name(b, replace) ///
	title("Menos vulnerables") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(stc1) recast(rcap)) ///
	mlabcolor(stc1) mcolor(stc1) msymbol(D)
graph combine a b, title("Especificación 4") ycommon ///
	name(Four, replace) ///
	note("Nota: IPM 1*, IPM 2* indica que se excluyeron los outliers de ese modelo."  ///
	"Los intervalos de confianza de los estimadores se calcularon al 90%.")
graph export "${output}/Graficos/heterogeneidadIPM_esp${E}.jpg", replace


*-------------------------------------------------------------------------------
**# Crea tabla para Especificación 5
*-------------------------------------------------------------------------------
global E=5
matrix C50=J(4,4,.)
matrix rownames C50 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames C50 = "IPM 1" "IPM 1*" "IPM 2" "IPM 2*"
matlist C50

matrix C51=J(4,4,.)
matrix rownames C51 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames C51 = "IPM 1" "IPM 1*" "IPM 2" "IPM 2*"
matlist C51
* Iterar sobre modelos h0 y h1 (Menos vulnerables y Más vulnerables respectivamente)

forvalues P=0/1{
	di "`P'"
	local col = 1
	* Iterar sobre IPM 1 y 2
	forvalues I=1/2{
		
		estimates use "${dir_estimaciones}/esp${E}-model4-IPM `I'-continua-h`P'.ster"
		qui estat simple, estore(e`P'_`I'_c) level(90)
		scalar N_OBS_`P'_`I'= e(N)
		
		matrix C5`P'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix C5`P'[2, `col']=r(table)[5,1] // Guardar LB
		matrix C5`P'[3, `col']=r(table)[6,1] // Guardar UB
		matrix C5`P'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		
		local col=`col'+1
		
		estimates use "${dir_estimaciones}/esp${E}-model4-IPM `I'-continua-no_outliers-h`P'.ster"
		qui estat simple, estore(e`P'_`I'_s) level(90)
		scalar N_OBS_`P'_`I'= e(N)
		
		matrix C5`P'[1, `col']=r(table)[1,1] // Guardar ATT
		matrix C5`P'[2, `col']=r(table)[5,1] // Guardar LB
		matrix C5`P'[3, `col']=r(table)[6,1] // Guardar UB
		matrix C5`P'[4, `col']=r(table)["pvalue",1] // Guardar p-valor
		
		local col=`col'+1
	}
	
}
coefplot matrix(C51), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1) name(c, replace) ///
	title("Más vulnerables") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(stc1) recast(rcap)) ///
	mlabcolor(stc1) mcolor(stc1) msymbol(D)
coefplot matrix(C50), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1) name(d, replace) ///
	title("Menos vulnerables") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(stc1) recast(rcap)) ///
	mlabcolor(stc1) mcolor(stc1) msymbol(D)
graph combine c d, title("Especificación ${E}") ycommon ///
	name(Five, replace) ///
	note("Nota: IPM 1*, IPM 2* indica que se excluyeron los outliers de ese modelo."  ///
	"Los intervalos de confianza de los estimadores se calcularon al 90%.")
	
	
graph export "${output}/Graficos/heterogeneidadIPM_esp${E}.jpg", replace
