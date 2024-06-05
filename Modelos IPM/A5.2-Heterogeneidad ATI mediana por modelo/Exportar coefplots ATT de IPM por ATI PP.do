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
	nivel de recepción de ATI con respecto a la mediana de cada modelo.
	
	En este ejercicio agrupamos los proyectos productivos en la ejecución PP.
	
NOTA: 
	En este script la "V" hace referencia a si la matriz tiene los coeficientes
	para el grupo 0 o 1, así M3V0 significa que son los coeficientes para el 
	Modelo 3, grupo 0 (no recibió nada).
	
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${output}/Modelos IPM/_heterogeneidad ati/estimaciones"
global output_path "${output}/Modelos IPM/_heterogeneidad ati/graficos"
global E=4

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
**# Crea matriz para Modelo 3
*-------------------------------------------------------------------------------
global modelo "model3"

* Crear matrices para coeficientes y pvalores
matrix M3V1=J(4,2,.)
matrix rownames M3V1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M3V1 = "IPM 1" "IPM 2"
matlist M3V1

matrix M3V2=J(4,2,.)
matrix rownames M3V2 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M3V2 = "IPM 1" "IPM 2"
matlist M3V2


* Iterar sobre modelos V1 y V2 (Recibió debajo de la mediana y encima de la mediana)
forvalues numV=1/2{
	* IPM 1: esp4-model3-IPM 1-ati1-PP.ster
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-ati`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M3V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M3V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M3V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M3V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-ati`numV'-PP.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M3V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M3V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M3V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M3V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M3V1

matlist M3V2	

* 1= Recibió debajo de la mediana (<)
coefplot matrix(M3V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(a, replace) title("Menos de la mediana") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D)

* 2= Recibió mayor o igual a la mediana (≥)
coefplot matrix(M3V2), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(b, replace) title("Más o igual a la mediana") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) 
* ------------------------	
* Exportar Modelo 3	
* ------------------------	
graph combine a b, title("Sin truncar") ycommon ///
	name(One, replace) row(1) caption("PP", color(gs15%50)) ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%.")
graph export "${output_path}/coefplot-IPM-ati-model3.jpg", replace	
	

	
	
	
	
	
	
	
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
**# Crea matriz para Modelo 3
*-------------------------------------------------------------------------------
global modelo "model4"

* Crear matrices para coeficientes y pvalores
matrix M4V1=J(4,2,.)
matrix rownames M4V1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M4V1 = "IPM 1" "IPM 2"
matlist M4V1

matrix M4V2=J(4,2,.)
matrix rownames M4V2 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M4V2 = "IPM 1" "IPM 2"
matlist M4V2


* Iterar sobre modelos V1 y V2 (Recibió debajo de la mediana y encima de la mediana)
forvalues numV=1/2{
	* IPM 1: esp4-model3-IPM 1-ati1-PP.ster
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-ati`numV'-PP.ster"
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M4V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M4V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M4V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M4V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-ati`numV'-PP.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M4V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M4V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M4V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M4V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M4V1

matlist M4V2	

* 1= Recibió debajo de la mediana (<)
coefplot matrix(M4V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(c, replace) title("Menos de la mediana") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))

* 2= Recibió mayor o igual a la mediana (≥)
coefplot matrix(M4V2), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(d, replace) title("Más o igual a la mediana") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) ///
	ylabel(-0.05(0.025)0.05) yscale(range(-0.05(0.025)0.05))
* ------------------------	
* Exportar Modelo 4
* ------------------------	
graph combine c d, title("Sin truncar") ycommon ///
	name(Two, replace) row(1) caption("PPSA", color(gs15%50)) ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%.")
graph export "${output_path}/coefplot-IPM-ati-model4.jpg", replace	




* Revisión que hayan quedado bien asignados los ATTs en los coefplots
cls
ssc install filelist
cd "${dir_estimaciones}"
filelist
local obs = _N

forvalues i=1/`obs'{
	preserve
	qui keep in `i'
	local f=filename 
	display "`i', `f'"
	estimates use "`f'"
	qui estat simple 
	di round(r(b)[1,1], 0.00001)
	restore
}

*-------------------------------------------------------------------------------
**# Crea matriz para Modelo PPCC+SA vs SA
*-------------------------------------------------------------------------------
global modelo "model5"

* Crear matrices para coeficientes y pvalores
matrix M5V1=J(4,2,.)
matrix rownames M5V1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M5V1 = "IPM 1" "IPM 2"
matlist M5V1

matrix M5V2=J(4,2,.)
matrix rownames M5V2 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M5V2 = "IPM 1" "IPM 2"
matlist M5V2


* Iterar sobre modelos V1 y V2 (Recibió debajo de la mediana y encima de la mediana)
forvalues numV=1/2{
	* IPM 1: esp4-model5-IPM 1-con_outliers-ati1.ster
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-con_outliers-ati`numV'.ster"
	
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M5V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M5V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M5V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M5V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-con_outliers-ati`numV'.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M5V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M5V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M5V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M5V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M5V1

matlist M5V2	

* 1= Recibió debajo de la mediana (<)
coefplot matrix(M5V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(e, replace) title("Menos de la mediana") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) 

* 2= Recibió mayor o igual a la mediana (≥)
coefplot matrix(M5V2), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(f, replace) title("Más o igual a la mediana") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) 
	
* ------------------------	
* Exportar Modelo
* ------------------------	
graph combine e f, title("Sin truncar") ycommon ///
	name(Three, replace) row(1) caption("PPCC+SA vs SA", color(gs15%50)) ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%.")
graph export "${output_path}/coefplot-IPM-ati-model5.jpg", replace	



*-------------------------------------------------------------------------------
**# Crea matriz para Modelo PPCC+SA vs PPCC
*-------------------------------------------------------------------------------
global modelo "model6"

* Crear matrices para coeficientes y pvalores
matrix M6V1=J(4,2,.)
matrix rownames M6V1 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M6V1 = "IPM 1" "IPM 2"
matlist M6V1

matrix M6V2=J(4,2,.)
matrix rownames M6V2 = "ATT" "LB90" "UB90" "pvalue"
matrix colnames M6V2 = "IPM 1" "IPM 2"
matlist M6V2


* Iterar sobre modelos V1 y V2 (Recibió debajo de la mediana y encima de la mediana)
forvalues numV=1/2{
	* IPM 1: esp4-model5-IPM 1-con_outliers-ati1.ster
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-con_outliers-ati`numV'.ster"
	
	qui estat simple, estore(v`numV'_1) level(90)

	matrix M6V`numV'[1, 1]=r(table)[1,1] // Guardar ATT
	matrix M6V`numV'[2, 1]=r(table)[5,1] // Guardar LB
	matrix M6V`numV'[3, 1]=r(table)[6,1] // Guardar UB
	matrix M6V`numV'[4, 1]=r(table)["pvalue",1] // Guardar p-valor
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-con_outliers-ati`numV'.ster"
	qui estat simple, estore(v`numV'_2) level(90)
	matrix M6V`numV'[1, 2]=r(table)[1,1] // Guardar ATT
	matrix M6V`numV'[2, 2]=r(table)[5,1] // Guardar LB
	matrix M6V`numV'[3, 2]=r(table)[6,1] // Guardar UB
	matrix M6V`numV'[4, 2]=r(table)["pvalue",1] // Guardar p-valor
}
matlist M6V1

matlist M6V2	

* 1= Recibió debajo de la mediana (<)
coefplot matrix(M6V1), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(g, replace) title("Menos de la mediana") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) 

* 2= Recibió mayor o igual a la mediana (≥)
coefplot matrix(M6V2), ci((2 3)) vert yline(0, lpattern(dash)) aspect(1.5) ///
	name(h, replace) title("Más o igual a la mediana") ///
	ytitle("ATT") mlabel(@b) format("%9.3g") scheme(s1color) ///
	ciopts(lcolor(red) recast(rcap)) ///
	mlabcolor(red) mcolor(red) msymbol(D) 
	
* ------------------------	
* Exportar Modelo
* ------------------------	
graph combine g h, title("Sin truncar") ycommon ///
	name(Four, replace) row(1) caption("PPCC+SA vs PPCC", color(gs15%50)) ///
	note("Los intervalos de confianza de los estimadores se calcularon al 90%.")
graph export "${output_path}/coefplot-IPM-ati-model6.jpg", replace	
