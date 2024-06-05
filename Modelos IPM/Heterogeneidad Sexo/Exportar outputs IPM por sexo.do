// ███████████████████████████
// ███████▀▀▀░░░░░░░▀▀▀███████
// ████▀░░░░░░░░░░░░░░░░░▀████
// ███│░░░░░░░░░░░░░░░░░░░│███
// ██▌│░░░░░░░░░░░░░░░░░░░│▐██
// ██░└┐░░░░░░░░░░░░░░░░░┌┘░██
// ██░░└┐░░░░░░░░░░░░░░░┌┘░░██
// ██░░┌┘▄▄▄▄▄░░░░░▄▄▄▄▄└┐░░██
// ██▌░│██████▌░░░▐██████│░▐██
// ███░│▐███▀▀░░▄░░▀▀███▌│░███
// ██▀─┘░░░░░░░▐█▌░░░░░░░└─▀██
// ██▄░░░▄▄▄▓░░▀█▀░░▓▄▄▄░░░▄██
// ████▄─┘██▌░░░░░░░▐██└─▄████
// █████░░▐█─┬┬┬┬┬┬┬─█▌░░█████
// ████▌░░░▀┬┼┼┼┼┼┼┼┬▀░░░▐████
// █████▄░░░└┴┴┴┴┴┴┴┘░░░▄█████
// ███████▄░░░░░░░░░░░▄███████
// ██████████▄▄▄▄▄▄▄██████████
// ███████████████████████████
/*
AUTOR:
	Gustavo Castillo

FECHA:
	8/oct/2023
	
DESCRIPCIÓN.
	En el siguiente script se exportan las gráficas de las estimaciones del
	modelo 4 (especificaciones 4 y 5) para revisar efetos heterogéneos por el 
	sexo del beneficiario.
	
	En este ejercicio agrupamos los proyectos productivos en la ejecución PP.
	
NOTA: 
	En este script la "V" hace referencia a si la matriz tiene los coeficientes
	para el grupo 0 o 1, así M3E4V0 significa que son los coeficientes para el 
	Modelo 3, Especificación 4, grupo 0 (hombres).
	
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${output}/Modelos IPM/_heterogeneidad sexo/estimaciones"
global output_path "${output}/Modelos IPM/_heterogeneidad sexo/graficos"

*-------------------------------------------------------------------------------
**# ATT: Crea matriz para Modelo 2 Especificación 4
*-------------------------------------------------------------------------------
global modelo "model2"
global E=4

* Crear matrices para coeficientes y pvalores
matrix M2E4V0=J(4,2,.)
matrix rownames M2E4V0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M2E4V0 = "IPM 1" "IPM 2"
matlist M2E4V0

matrix M2E4V1=J(4,2,.)
matrix rownames M2E4V1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M2E4V1 = "IPM 1" "IPM 2"
matlist M2E4V1


* Iterar sobre modelos V0 y V1 (hombres y mujeres respectivamente)
forvalues numV=0/1{
	* IPM 1: esp4-model3-IPM 1-sexo0-PP.ster
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo`numV'.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M2E4V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M2E4V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M2E4V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M2E4V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo`numV'.ster"
	qui estat simple, estore(v`numV'_1) level(90)
	matrix M2E4V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M2E4V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M2E4V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M2E4V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M2E4V0

matlist M2E4V1	

* Para hombres (V0)
coefplot matrix(M2E4V0), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(a, replace) title("Hombres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D)

* Para mujeres (V1)
coefplot matrix(M2E4V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(b, replace) title("Mujeres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D) 

graph combine a b, title("Sin truncar") ycommon ///
	name(One, replace) row(1)
	
*-------------------------------------------------------------------------------
**# ATT: Crea matriz para Modelo 2 Especificación 5
*-------------------------------------------------------------------------------
global modelo "model2"
global E=5

* Crear matrices para coeficientes y pvalores
matrix M2E5V0=J(4,2,.)
matrix rownames M2E5V0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M2E5V0 = "IPM 1" "IPM 2"
matlist M2E5V0

matrix M2E5V1=J(4,2,.)
matrix rownames M2E5V1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M2E5V1 = "IPM 1" "IPM 2"
matlist M2E5V1


* Iterar sobre modelos V0 y V1 (hombres y mujeres respectivamente)
forvalues numV=0/1{
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo`numV'.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M2E5V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M2E5V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M2E5V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M2E5V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo`numV'.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M2E5V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M2E5V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M2E5V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M2E5V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M2E5V0

matlist M2E5V1	

* Para hombres (V0)
coefplot matrix(M2E5V0), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(c, replace) title("Hombres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D)

* Para mujeres (V1)
coefplot matrix(M2E5V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(d, replace) title("Mujeres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D)
	
	


graph combine c d, title("Truncado") ycommon ///
	name(Two, replace) row(1)
	
* -------------------------------
* Exportar coefplot ATT Modelo 2	
* -------------------------------
graph combine One Two,  caption("SA", color(gs15%50)) ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%.")
graph export "${output_path}/coefplot-IPM-sexo-model2.jpg", replace	

*-------------------------------------------------------------------------------
**# Efectos Dinámicos: Modelo 2 Especificación 4
*-------------------------------------------------------------------------------
global modelo "model2"
global E=4
* Hombres (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo0.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo0.ster"
	estat event, window(-4 3)
	csdid_plot, title("IPM 2") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("Hombres") name(One, replace)
	
* Mujeres (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo1.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo1.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("Mujeres") name(Two, replace) ///
	
* Unir y exportar
	grc1leg One Two, title("Sin truncar") caption("SA", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-sexo-${modelo}-esp${E}.jpg", replace
		
	
*-------------------------------------------------------------------------------
**# Efectos Dinámicos: Modelo 2 Especificación 5
*-------------------------------------------------------------------------------	
global modelo "model2"
global E=5
* Hombres (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo0.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 1") aspect(2) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo0.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 2") aspect(2) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("Hombres") name(One, replace)
	
* Mujeres (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo1.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 1") aspect(2) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo1.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 2") aspect(2) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("Mujeres") name(Two, replace) ///
	
* Unir y exportar
	grc1leg One Two, title("Truncado") caption("PP", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-sexo-${modelo}-esp${E}.jpg", replace	

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

*-------------------------------------------------------------------------------
**# ATT: Crea matriz para Modelo 3 Especificación 4
*-------------------------------------------------------------------------------
global modelo "model3"
global E=4

* Crear matrices para coeficientes y pvalores
matrix M3E4V0=J(4,2,.)
matrix rownames M3E4V0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M3E4V0 = "IPM 1" "IPM 2"
matlist M3E4V0

matrix M3E4V1=J(4,2,.)
matrix rownames M3E4V1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M3E4V1 = "IPM 1" "IPM 2"
matlist M3E4V1


* Iterar sobre modelos V0 y V1 (hombres y mujeres respectivamente)
forvalues numV=0/1{
	* IPM 1: esp4-model3-IPM 1-sexo0-PP.ster
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M3E4V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M3E4V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M3E4V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M3E4V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)
	matrix M3E4V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M3E4V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M3E4V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M3E4V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M3E4V0

matlist M3E4V1	

* Para hombres (V0)
coefplot matrix(M3E4V0), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(a, replace) title("Hombres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D)

* Para mujeres (V1)
coefplot matrix(M3E4V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(b, replace) title("Mujeres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D) 

graph combine a b, title("Sin truncar") ycommon ///
	name(One, replace) row(1)
	
*-------------------------------------------------------------------------------
**# ATT: Crea matriz para Modelo 3 Especificación 5
*-------------------------------------------------------------------------------
global modelo "model3"
global E=5

* Crear matrices para coeficientes y pvalores
matrix M3E5V0=J(4,2,.)
matrix rownames M3E5V0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M3E5V0 = "IPM 1" "IPM 2"
matlist M3E5V0

matrix M3E5V1=J(4,2,.)
matrix rownames M3E5V1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M3E5V1 = "IPM 1" "IPM 2"
matlist M3E5V1


* Iterar sobre modelos V0 y V1 (hombres y mujeres respectivamente)
forvalues numV=0/1{
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M3E5V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M3E5V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M3E5V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M3E5V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo`numV'-PP.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M3E5V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M3E5V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M3E5V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M3E5V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M3E5V0

matlist M3E5V1	

* Para hombres (V0)
coefplot matrix(M3E5V0), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(c, replace) title("Hombres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D)

* Para mujeres (V1)
coefplot matrix(M3E5V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(d, replace) title("Mujeres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D)
	
	


graph combine c d, title("Truncado") ycommon ///
	name(Two, replace) row(1)
	
* -------------------------------
* Exportar coefplot ATT Modelo 3	
* -------------------------------
graph combine One Two,  caption("PP", color(gs15%50)) ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%.")
graph export "${output_path}/coefplot-IPM-sexo-model3.jpg", replace	
	
	
	
	
*-------------------------------------------------------------------------------
**# Efectos Dinámicos: Modelo 3 Especificación 4
*-------------------------------------------------------------------------------
global modelo "model3"
global E=4
* Hombres (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo0-PP.ster"
	estat event, window(-4 3)
	csdid_plot, title("IPM 2") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("Hombres") name(One, replace)
	
* Mujeres (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("Mujeres") name(Two, replace) ///
	
* Unir y exportar
	grc1leg One Two, title("Sin truncar") caption("PP", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-sexo-${modelo}-esp${E}.jpg", replace
		
	
*-------------------------------------------------------------------------------
**# Efectos Dinámicos: Modelo 3 Especificación 5
*-------------------------------------------------------------------------------	
global modelo "model3"
global E=5
* Hombres (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo0-PP.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 1") aspect(2) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo0-PP.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 2") aspect(2) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("Hombres") name(One, replace)
	
* Mujeres (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo1-PP.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 1") aspect(2) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo1-PP.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 2") aspect(2) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("Mujeres") name(Two, replace) ///
	
* Unir y exportar
	grc1leg One Two, title("Truncado") caption("PP", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-sexo-${modelo}-esp${E}.jpg", replace	
	

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
	
*-------------------------------------------------------------------------------
**# ATT: Crea matriz para Modelo 3 Especificación 4
*-------------------------------------------------------------------------------
global modelo "model4"
global E=4

* Crear matrices para coeficientes y pvalores
matrix M4E4V0=J(4,2,.)
matrix rownames M4E4V0 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M4E4V0 = "IPM 1" "IPM 2"
matlist M4E4V0

matrix M4E4V1=J(4,2,.)
matrix rownames M4E4V1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M4E4V1 = "IPM 1" "IPM 2"
matlist M4E4V1


* Iterar sobre modelos V0 y V1 (hombres y mujeres respectivamente)
forvalues numV=0/1{
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M4E4V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M4E4V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M4E4V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M4E4V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo`numV'-PP.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M4E4V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M4E4V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M4E4V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M4E4V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M4E4V0

matlist M4E4V1	


* Para hombres (V0)
coefplot matrix(M4E4V0), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(a4, replace) title("Hombres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D)

* Para mujeres (V1)	
coefplot matrix(M4E4V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(b4, replace) title("Mujeres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D) 
	


graph combine a4 b4, title("Sin truncar") ycommon ///
	name(Three, replace) row(1)
	
*-------------------------------------------------------------------------------
**# ATT: Crea matriz para Modelo 3 Especificación 5
*-------------------------------------------------------------------------------
global modelo "model4"
global E=5

* Crear matrices para coeficientes y pvalores
matrix M4E50=J(4,2,.)
matrix rownames M4E50 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M4E50 = "IPM 1" "IPM 2"
matlist M4E50

matrix M4E51=J(4,2,.)
matrix rownames M4E51 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M4E51 = "IPM 1" "IPM 2"
matlist M4E51


* Iterar sobre modelos V0 y V1 (hombres y mujeres respectivamente)
forvalues numV=0/1{
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M4E5`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M4E5`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M4E5`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M4E5`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo`numV'-PP.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M4E5`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M4E5`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M4E5`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M4E5`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M4E50

matlist M4E51	

* Para hombres (V0)
coefplot matrix(M4E50), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(c4, replace) title("Hombres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D)

* Para mujeres (V1)
coefplot matrix(M4E51), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(d4, replace) title("Mujeres") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(gs6) recast(rcap)) ///
	mlabcolor(gs6) mcolor(gs6) msymbol(D)

graph combine c4 d4, title("Truncado") ycommon ///
	name(Four, replace) row(1)
	
* ------------------------	
* Exportar Modelo 4
* ------------------------	
graph combine Three Four, ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%.") caption("PPSA", color(gs15%50))
graph export "${output_path}/coefplot-IPM-sexo-model4.jpg", replace		
	
	
*-------------------------------------------------------------------------------
**# Efectos Dinámicos: Modelo 4 Especificación 4
*-------------------------------------------------------------------------------	
global modelo "model4"
global E=4
* Hombres (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(2) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(2) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("Hombres") name(One, replace)
	
* Mujeres (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(2) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(2) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("Mujeres") name(Two, replace) ///
	
* Unir y exportar
	grc1leg One Two, title("Sin truncar") caption("PPSA", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-sexo-${modelo}-esp${E}.jpg", replace		

*-------------------------------------------------------------------------------
**# Efectos Dinámicos: Modelo 4 Especificación 5
*-------------------------------------------------------------------------------		
global modelo "model4"
global E=5
* Hombres (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo0-PP.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 1") aspect(2) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo0-PP.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 2") aspect(2) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("Hombres") name(One, replace)
	
* Mujeres (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-sexo1-PP.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 1") aspect(2) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-sexo1-PP.ster"
	estat event, window(-3 3)
	csdid_plot, title("IPM 2") aspect(2) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("Mujeres") name(Two, replace) ///
	
* Unir y exportar
	grc1leg One Two, title("Truncado") caption("PPSA", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-sexo-${modelo}-esp${E}.jpg", replace		
	
	
	
	

	
