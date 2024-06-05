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
	En el siguiente script se exportan las gráficas con el ATT de las estimaciones
	del	modelo 4 (especificaciones 4 y 5) para revisar efetos heterogéneos por si el
	beneficiario se encuentra en ZME o no.
	
	En este ejercicio agrupamos los proyectos productivos en la ejecución PP.
	
NOTA: 
	En este script la "V" hace referencia a si la matriz tiene los coeficientes
	para el grupo 0 o 1, así M3E4V0 significa que son los coeficientes para el 
	Modelo 3, Especificación 4, grupo 0 (No ZME).
	
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${output}/Modelos IPM/_heterogeneidad zme/estimaciones"
global output_path "${output}/Modelos IPM/_heterogeneidad zme/graficos"

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
**# Crea matriz para Modelo 3 Especificación 4
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


* Iterar sobre modelos V0 y V1 (no-ZME (0) y ZME (1) respectivamente)
forvalues numV=0/1{
	* IPM 1: esp4-model3-IPM 1-zme0-PP.ster
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M3E4V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M3E4V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M3E4V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M3E4V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)
	matrix M3E4V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M3E4V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M3E4V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M3E4V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M3E4V0

matlist M3E4V1	

* No-ZME (V0)
coefplot matrix(M3E4V0), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(a, replace) title("No ZME") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(brown) recast(rcap)) ///
	mlabcolor(brown) mcolor(brown) msymbol(D)

* En ZME (V1)
coefplot matrix(M3E4V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(b, replace) title("En ZME") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(brown) recast(rcap)) ///
	mlabcolor(brown) mcolor(brown) msymbol(D) 

graph combine a b, title("Sin truncar") ycommon ///
	name(One, replace) row(1)
	
*-------------------------------------------------------------------------------
**# Crea matriz para Modelo 3 Especificación 5
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


* Iterar sobre modelos V0 y V1 (no-ZME (0) y ZME (1) respectivamente)
forvalues numV=0/1{
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M3E5V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M3E5V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M3E5V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M3E5V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme`numV'-PP.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M3E5V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M3E5V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M3E5V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M3E5V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M3E5V0

matlist M3E5V1	

* No-ZME (V0)
coefplot matrix(M3E5V0), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(c, replace) title("No ZME") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(brown) recast(rcap)) ///
	mlabcolor(brown) mcolor(brown) msymbol(D)

* En ZME (V1)
coefplot matrix(M3E5V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(d, replace) title("En ZME") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(brown) recast(rcap)) ///
	mlabcolor(brown) mcolor(brown) msymbol(D)
	
	


graph combine c d, title("Truncado") ycommon ///
	name(Two, replace) row(1)
	
* ------------------------	
* Exportar Modelo 3	
* ------------------------	
graph combine One Two,  caption("PP", color(gs15%50)) ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%.")
graph export "${output_path}/coefplot-IPM-zme-model3.jpg", replace	
	
	
	
	
	
	
	
	
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
**# Crea matriz para Modelo 4 Especificación 4
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


* Iterar sobre modelos V0 y V1 (no-ZME (0) y ZME (1) respectivamente)
forvalues numV=0/1{
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M4E4V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M4E4V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M4E4V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M4E4V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme`numV'-PP.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M4E4V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M4E4V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M4E4V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M4E4V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M4E4V0

matlist M4E4V1	


* No-ZME (V0)
coefplot matrix(M4E4V0), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(a4, replace) title("No ZME") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(brown) recast(rcap)) ///
	mlabcolor(brown) mcolor(brown) msymbol(D)

* En ZME (V1)
coefplot matrix(M4E4V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(b4, replace) title("En ZME") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(brown) recast(rcap)) ///
	mlabcolor(brown) mcolor(brown) msymbol(D) 
	


graph combine a4 b4, title("Sin truncar") ycommon ///
	name(Three, replace) row(1)
	
*-------------------------------------------------------------------------------
**# Crea matriz para Modelo 4 Especificación 5
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


* Iterar sobre modelos V0 y V1 (no-ZME (0) y ZME (1) respectivamente)
forvalues numV=0/1{
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M4E5`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M4E5`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M4E5`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M4E5`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme`numV'-PP.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M4E5`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M4E5`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M4E5`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M4E5`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M4E50

matlist M4E51	

* No-ZME (V0)
coefplot matrix(M4E50), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(c4, replace) title("No ZME") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(brown) recast(rcap)) ///
	mlabcolor(brown) mcolor(brown) msymbol(D)

* En ZME (V1)
coefplot matrix(M4E51), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(d4, replace) title("En ZME") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(brown) recast(rcap)) ///
	mlabcolor(brown) mcolor(brown) msymbol(D)

graph combine c4 d4, title("Truncado") ycommon ///
	name(Four, replace) row(1)
	
* ------------------------	
* Exportar Modelo 4
* ------------------------	
graph combine Three Four, ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%.") caption("PPSA", color(gs15%50))
graph export "${output_path}/coefplot-IPM-zme-model4.jpg", replace		
	
	
	
	
	
	
	

	
