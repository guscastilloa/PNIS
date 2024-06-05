* Preámbulo
clear 
cls
set more off
set rmsg off
set scheme s1mono
* Fijar globals necesarios para fijar working directory y output directory
global path "/Users/upar/Library/CloudStorage/OneDrive-UniversidaddelosAndes/03 MONEY/CESED/Cuanti-PNIS"
global dir_estimaciones "${path}/Output/Estimación_modelos/estimaciones"
global output "${path}/Output"
global table_output "/Users/upar/Library/CloudStorage/OneDrive-UniversidaddelosAndes/03 MONEY/CESED/Cuanti-PNIS/Output/Estimación_modelos/tablas"

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
****************************
** AAI vs No recibió nada **
****************************
global modelnum 1
global modelo "model${modelnum}" 
global grupo_comparacion "AAI vs No recibió nada" 		// Global para títulos
* IPM 1 --------------------------------------------
* Cargar estimaciones
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm1)
* Exportar diagrama de efectos dinámicos
estat event, window(-6 6)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* IPM 2 --------------------------------------------
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm2)
* Exportar diagrama de efectos dinámicos
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estat event, window(-6 6)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* Exportar tabla en .tex ----------------------------
esttab ipm1 ipm2 using "${table_output}/${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress  ///
	nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap	///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
	
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
****************************
**	 	 SA vs AAI   	  **
**************************** 	
global modelnum 2 // Global para otros globals
global modelo "model${modelnum}"  // Global para nombre de archios
global grupo_comparacion "SA vs AAI" 		// Global para títulos

* IPM 1 --------------------------------------------
* Cargar estimaciones
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm1)
* Exportar diagrama de efectos dinámicos
estat event, window(-5 5)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* IPM 2 --------------------------------------------
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm2)
* Exportar diagrama de efectos dinámicos
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estat event, window(-5 5)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* Exportar tabla en .tex ----------------------------
esttab ipm1 ipm2 using "${table_output}/${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress  ///
	nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap booktabs	///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
	
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
****************************
**	 	 PPCC vs AAI   	  **
**************************** 
global grupo_comparacion "PPCC vs AAI" 		// Global para títulos
global modelnum 3 // Global para otros globals
global modelo "model${modelnum}"  // Global para nombre de archios

* IPM 1 --------------------------------------------
* Cargar estimaciones
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm1)
* Exportar diagrama de efectos dinámicos
estat event, window(-5 5)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* IPM 2 --------------------------------------------
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm2)
* Exportar diagrama de efectos dinámicos
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estat event, window(-5 5)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* Exportar tabla en .tex ----------------------------
esttab ipm1 ipm2 using "${table_output}/${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress  ///
	nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap booktabs	///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
	
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
****************************
**	 PPCC + SA vs AAI  	  **
**************************** 
global grupo_comparacion "PPCC + SA vs AAI" // Global para títulos
global modelnum 4 // Global para otros globals
global modelo "model${modelnum}"  // Global para nombre de archios

* IPM 1 --------------------------------------------
* Cargar estimaciones
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm1)
* Exportar diagrama de efectos dinámicos
estat event, window(-5 5)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* IPM 2 --------------------------------------------
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm2)
* Exportar diagrama de efectos dinámicos
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estat event, window(-5 5)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* Exportar tabla en .tex ----------------------------
esttab ipm1 ipm2 using "${table_output}/${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress  ///
	nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap booktabs	///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

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
****************************
**	 PPCC + SA vs SA   	  **
**************************** 
global grupo_comparacion "PPCC + SA vs SA" // Global para títulos
global modelnum 5 // Global para otros globals
global modelo "model${modelnum}"  // Global para nombre de archios

* IPM 1 --------------------------------------------
* Cargar estimaciones
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm1)
* Exportar diagrama de efectos dinámicos
estat event, window(-5 5)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* IPM 2 --------------------------------------------
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm2)
* Exportar diagrama de efectos dinámicos
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estat event, window(-5 5)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* Exportar tabla en .tex ----------------------------
esttab ipm1 ipm2 using "${table_output}/${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress  ///
	nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap booktabs	///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

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
****************************
**	 SA + PPCC vs PPCC 	  **
**************************** 
global grupo_comparacion "SA + PPCC vs PPCC" // Global para títulos
global modelnum 6 // Global para otros globals
global modelo "model${modelnum}"  // Global para nombre de archios

* IPM 1 --------------------------------------------
* Cargar estimaciones
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm1)
* Exportar diagrama de efectos dinámicos
estat event, window(-5 5)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* IPM 2 --------------------------------------------
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm2)
* Exportar diagrama de efectos dinámicos
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estat event, window(-5 5)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* Exportar tabla en .tex ----------------------------
esttab ipm1 ipm2 using "${table_output}/${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress  ///
	nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap booktabs	///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

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
****************************
**PPCL vs AAI + SA + PPCC **
**************************** 
global grupo_comparacion "PPCL vs AAI + SA + PPCC" // Global para títulos
global modelnum 7 // Global para otros globals
global modelo "model${modelnum}"  // Global para nombre de archios

* IPM 1 --------------------------------------------
* Cargar estimaciones
global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm1)
* Exportar diagrama de efectos dinámicos
estat event, window(-6 6)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* IPM 2 --------------------------------------------
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estimates use "${dir_estimaciones}/${modelo}-${ipm}.ster"
estat simple, estore(ipm2)
* Exportar diagrama de efectos dinámicos
global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
estat event, window(-6 6)
csdid_plot, title("${grupo_comparacion}" "${ipm}")
graph export "${output}/Estimación_modelos/graficos/${modelo}-${ipm}.jpg", replace

* Exportar tabla en .tex ----------------------------
esttab ipm1 ipm2 using "${table_output}/${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress  ///
	nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap booktabs	///
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

	
	
***************************
***************************
//          _______  _____ 
//      /\ |__   __||_   _|
//     /  \   | |     | |  
//    / /\ \  | |     | |  
//   / ____ \ | |    _| |_ 
//  /_/    \_\|_|   |_____| 
***************************
***************************
foreach x in 2 1 0{	
	local x=2
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
	****************************
	** AAI vs No recibió nada **
	****************************
	global modelnum 1
	global modelo "model${modelnum}" 
	global grupo_comparacion "AAI vs No recibió nada" 		// Global para títulos
	* IPM 1 --------------------------------------------
	* Cargar estimaciones
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm1)
	* Exportar diagrama de efectos dinámicos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* IPM 2 --------------------------------------------
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm2)
	* Exportar diagrama de efectos dinámicos
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* Exportar tabla en .tex ----------------------------
	esttab ipm1 ipm2 using "${table_output}/ati`x'-${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
		star(* 0.10 ** 0.05 *** 0.01) compress  ///
		nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap	///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
		
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
	****************************
	**	 	 SA vs AAI   	  **
	**************************** 	
	global modelnum 2 // Global para otros globals
	global modelo "model${modelnum}"  // Global para nombre de archios
	global grupo_comparacion "SA vs AAI" 		// Global para títulos

	* IPM 1 --------------------------------------------
	* Cargar estimaciones
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm1)
	* Exportar diagrama de efectos dinámicos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* IPM 2 --------------------------------------------
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm2)
	* Exportar diagrama de efectos dinámicos
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* Exportar tabla en .tex ----------------------------
	esttab ipm1 ipm2 using "${table_output}/ati`x'-${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
		star(* 0.10 ** 0.05 *** 0.01) compress  ///
		nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap	///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
		
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
	****************************
	**	 	 PPCC vs AAI   	  **
	**************************** 
	global grupo_comparacion "PPCC vs AAI" 		// Global para títulos
	global modelnum 3 // Global para otros globals
	global modelo "model${modelnum}"  // Global para nombre de archios

	* IPM 1 --------------------------------------------
	* Cargar estimaciones
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm1)
	* Exportar diagrama de efectos dinámicos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* IPM 2 --------------------------------------------
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm2)
	* Exportar diagrama de efectos dinámicos
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* Exportar tabla en .tex ----------------------------
	esttab ipm1 ipm2 using "${table_output}/ati`x'-${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
		star(* 0.10 ** 0.05 *** 0.01) compress  ///
		nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap	///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
		
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
	****************************
	**	 PPCC + SA vs AAI  	  **
	**************************** 
	global grupo_comparacion "PPCC + SA vs AAI" // Global para títulos
	global modelnum 4 // Global para otros globals
	global modelo "model${modelnum}"  // Global para nombre de archios

	* IPM 1 --------------------------------------------
	* Cargar estimaciones
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm1)
	* Exportar diagrama de efectos dinámicos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* IPM 2 --------------------------------------------
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm2)
	* Exportar diagrama de efectos dinámicos
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* Exportar tabla en .tex ----------------------------
	esttab ipm1 ipm2 using "${table_output}/ati`x'-${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
		star(* 0.10 ** 0.05 *** 0.01) compress  ///
		nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap	///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

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
	****************************
	**	 PPCC + SA vs SA   	  **
	**************************** 
	global grupo_comparacion "PPCC + SA vs SA" // Global para títulos
	global modelnum 5 // Global para otros globals
	global modelo "model${modelnum}"  // Global para nombre de archios

	* IPM 1 --------------------------------------------
	* Cargar estimaciones
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm1)
	* Exportar diagrama de efectos dinámicos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* IPM 2 --------------------------------------------
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm2)
	* Exportar diagrama de efectos dinámicos
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* Exportar tabla en .tex ----------------------------
	esttab ipm1 ipm2 using "${table_output}/ati`x'-${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
		star(* 0.10 ** 0.05 *** 0.01) compress  ///
		nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap	///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

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
	****************************
	**	 SA + PPCC vs PPCC 	  **
	**************************** 
	global grupo_comparacion "SA + PPCC vs PPCC" // Global para títulos
	global modelnum 6 // Global para otros globals
	global modelo "model${modelnum}"  // Global para nombre de archios

	* IPM 1 --------------------------------------------
	* Cargar estimaciones
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm1)
	* Exportar diagrama de efectos dinámicos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* IPM 2 --------------------------------------------
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm2)
	* Exportar diagrama de efectos dinámicos
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* Exportar tabla en .tex ----------------------------
	esttab ipm1 ipm2 using "${table_output}/ati`x'-${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
		star(* 0.10 ** 0.05 *** 0.01) compress  ///
		nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap	///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")

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
	****************************
	**PPCL vs AAI + SA + PPCC **
	**************************** 
	global grupo_comparacion "PPCL vs AAI + SA + PPCC" // Global para títulos
	global modelnum 7 // Global para otros globals
	global modelo "model${modelnum}"  // Global para nombre de archios

	* IPM 1 --------------------------------------------
	* Cargar estimaciones
	global ipm "IPM 1" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm1)
	* Exportar diagrama de efectos dinámicos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* IPM 2 --------------------------------------------
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estimates use "${dir_estimaciones}/ati`x'-${modelo}-${ipm}.ster"
	estat simple, estore(ipm2)
	* Exportar diagrama de efectos dinámicos
	global ipm "IPM 2" // Global para nombre archivos de estimación y gráficos
	estat event, window(-6 6)
	csdid_plot, title("${grupo_comparacion}" "${ipm}") subtitle("ATI = `x'")
	graph export "${output}/Estimación_modelos/graficos/ati`x'-${modelo}-${ipm}.jpg", replace

	* Exportar tabla en .tex ----------------------------
	esttab ipm1 ipm2 using "${table_output}/ati`x'-${modelo}.tex", replace main(b %6.4f) aux(se %6.4f) ///
		star(* 0.10 ** 0.05 *** 0.01) compress  ///
		nonotes noobs mtitle("IPM 1" "IPM 2") nonum gap	///
		note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
}
                        

