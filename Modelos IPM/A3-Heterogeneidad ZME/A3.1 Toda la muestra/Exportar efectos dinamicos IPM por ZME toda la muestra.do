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
	En el siguiente script se exportan las gráficas de efectos dinámicos de 
	las estimaciones del modelo 4 (especificaciones 4 y 5) para revisar efectos
	heterogéneos por si el beneficiario se encuentra en ZME o no.
	
	En este ejercicio agrupamos los proyectos productivos en la ejecución PP.
	
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

*------------------------------------------------------------------------------
**# Modelo 3 Especificación 4
*------------------------------------------------------------------------------
global modelo "model3"
global E=4
	* No Zme (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("No ZME") name(One, replace)
	
	* En ZME (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("En ZME") name(Two, replace) ///
	
	
	grc1leg One Two, title("Sin truncar") caption("PP", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-zme-${modelo}-esp${E}.jpg", replace
	
	
*------------------------------------------------------------------------------
**# Modelo 3 Especificación 5
*------------------------------------------------------------------------------
global modelo "model3"
global E=5
	* No Zme (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("No ZME") name(One, replace)
	
	* En ZME (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("En ZME") name(Two, replace) ///
	
	
	grc1leg One Two, title("Truncado") caption("PP", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-zme-${modelo}-esp${E}.jpg", replace
	
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
graph drop _all	
*------------------------------------------------------------------------------
**# Modelo 4 Especificación 4
*------------------------------------------------------------------------------
global modelo "model4"
global E=4
	* No Zme (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("No ZME") name(One, replace)
	
	* En ZME (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("En ZME") name(Two, replace) ///
	
	
	grc1leg One Two, title("Sin truncar") caption("PPSA", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-zme-${modelo}-esp${E}.jpg", replace
	
	
*------------------------------------------------------------------------------
**# Modelo 4 Especificación 4
*------------------------------------------------------------------------------
global modelo "model4"
global E=5
	* No Zme (0) - - - - - - - 
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(a, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme0-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(1.3) name(b, replace)
	
	grc1leg a b, ycommon row(1) title("No ZME") name(One, replace)
	
	* En ZME (1) - - - - - - - - -
	* IPM 1
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 1-zme1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 1") aspect(1.3) name(c, replace)
	
	* IPM 2
	estimates use "${dir_estimaciones}/esp${E}-${modelo}-IPM 2-zme1-PP.ster"
	estat event, window(-5 5)
	csdid_plot, title("IPM 2") aspect(1.3) name(d, replace)
	
	grc1leg c d, ycommon row(1) title("En ZME") name(Two, replace) ///
	
	
	grc1leg One Two, title("Truncado") caption("PPSA", color(gs15%50))
	graph export "${output_path}/efectos_dinamicos-zme-${modelo}-esp${E}.jpg", replace
