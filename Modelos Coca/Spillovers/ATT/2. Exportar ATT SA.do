/*
AUTOR:
	Gustavo Castillo

FECHA:
	29/sept/2023
	
DESCRIPCIÓN:
	En este script se producen y se exportan las tablas de resultados de los 7
	modelos de coca de spillovers por componentes.
*/

* Preámbulo luego de ejecutar _master.do
global dir_estimaciones "${projectfolder}/Output/Modelos Coca Spillovers/estimaciones"
global table_output "${projectfolder}/Output/Modelos Coca Spillovers/tablas"

*-------------------------------------------------------------------------------
* SA
*-------------------------------------------------------------------------------

* Componente en: Grilla PNIS - - - - - - - - - - - - - - - - - - - - - - - - - - 
	* 1. E2Gp vs E0G0: Grilla PNIS vs Control Puro
	estimates use "${dir_estimaciones}/d_SA_CP.ster"
	estat simple, estore(modelo1) // Guardar ATT en estimación
	scalar N_OBS_1= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo1
		estadd scalar OBS=N_OBS_1, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize C. Puro}" // Control Puro
	
	* 2: E2Gp vs E1Gp: Grilla PNIS vs Grillas solo AAI
	estimates use "${dir_estimaciones}/d_SA_AAI.ster"
	estat simple, estore(modelo2) // Guardar ATT en estimación
	scalar N_OBS_2= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo2
		estadd scalar OBS=N_OBS_2, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize Solo AAI}" // Solo AAI

// 	* 3. E2Gp vs E2Gv: Grilla PNIS vs Vecina
// 	estimates use "${dir_estimaciones}/d_SA_v.ster"
// 	estat simple, estore(modelo3) // Guardar ATT en estimación
// 	scalar N_OBS_3= e(N) 
// 		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
// 		est restore modelo3
// 		estadd scalar OBS=N_OBS_3, replace // Añadir número de observaciones
// 		qui estadd local EFT "\checkmark" // Efectos fijos de año
// 		qui estadd local EFG "\checkmark" // efectos fijos de grilla
// 		qui estadd local TREND "\checkmark" // Tendencia
// 		qui estadd local CLVER "\checkmark" // Cluster por vereda
// 		qui estadd local CONTROL "{\scriptsize Vecina}" // Vecina
//		
// 	* 4. E2Gp vs E2Gvv: Grilla PNIS vs Vecina de Vecina
// 	estimates use "${dir_estimaciones}/d_SA_vv.ster"
// 	estat simple, estore(modelo4) // Guardar ATT en estimación
// 	scalar N_OBS_4= e(N) 
// 		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
// 		est restore modelo4
// 		estadd scalar OBS=N_OBS_4, replace // Añadir número de observaciones
// 		qui estadd local EFT "\checkmark" // Efectos fijos de año
// 		qui estadd local EFG "\checkmark" // efectos fijos de grilla
// 		qui estadd local TREND "\checkmark" // Tendencia
// 		qui estadd local CLVER "\checkmark" // Cluster por vereda
// 		qui estadd local CONTROL "{\scriptsize V. de Vecina}" // Vecina de Vecina
	
	* 5. Grilla PNIS vs pre SA
	estimates use "${dir_estimaciones}/d_SA_ROLL.ster"
	estat simple, estore(modelo5) // Guardar ATT en estimación
	scalar N_OBS_5= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo5
		estadd scalar OBS=N_OBS_5, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize SA en 2022}" // pre SA
		
* Componente en : Grilla Vecina - - - - - - - - - -	- - - - - - - - - - - - - - -
	* 6. E2Gv vs E0G0: Grilla Vecina vs Control Puro
	estimates use "${dir_estimaciones}/v_SA_CP.ster"
	estat simple, estore(modelo6) // Guardar ATT en estimación
	scalar N_OBS_6= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo6
		estadd scalar OBS=N_OBS_6, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize C. Puro}" // Control Puro
	
	* 7. E2Gv vs E1Gp: Grilla Vecina vs solo AAI
	estimates use "${dir_estimaciones}/v_SA_AAI.ster"
	estat simple, estore(modelo7) // Guardar ATT en estimación
	scalar N_OBS_7= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo7
		estadd scalar OBS=N_OBS_7, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize Solo AAI}" // Solo AAI
	
	* 8. Grilla Vecina vs pre SA (SA en 2022)
	estimates use "${dir_estimaciones}/v_SA_ROLL.ster"
	estat simple, estore(modelo8) // Guardar ATT en estimación
	scalar N_OBS_8= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo8
		estadd scalar OBS=N_OBS_8, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize SA en 2022}" // pre SA
		
		
* Componente en : Grilla Vecina de Vecina - - - - - - - - - - - - - - - - - - - 
	* 9. E2Gvv vs E0G0: Grilla vecina de vecina vs Control Puro
	estimates use "${dir_estimaciones}/vv_SA_CP.ster"
	estat simple, estore(modelo9) // Guardar ATT en estimación
	scalar N_OBS_9= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo9
		estadd scalar OBS=N_OBS_9, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize C. Puro}" // Control Puro
		
	* 10. E2Gvv vs E1Gp: Grilla Vecina de Vecina vs solo AAI
	estimates use "${dir_estimaciones}/vv_SA_AAI.ster"
	estat simple, estore(modelo10) // Guardar ATT en estimación
	scalar N_OBS_10= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo10
		estadd scalar OBS=N_OBS_10, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize Solo AAI}" // Solo AAI
	
	* 11. Vecina de Vecina vs pre SA
	estimates use "${dir_estimaciones}/vv_SA_ROLL.ster"
	estat simple, estore(modelo11) // Guardar ATT en estimación
	scalar N_OBS_11= e(N) 
		* Crear escalares para luego añadirlos en la creación de la tabla con ATT
		est restore modelo11
		estadd scalar OBS=N_OBS_11, replace // Añadir número de observaciones
		qui estadd local EFT "\checkmark" // Efectos fijos de año
		qui estadd local EFG "\checkmark" // efectos fijos de grilla
		qui estadd local TREND "\checkmark" // Tendencia
		qui estadd local CLVER "\checkmark" // Cluster por vereda
		qui estadd local CONTROL "{\scriptsize SA en 2022}" // pre SA

esttab modelo1 modelo2 modelo5 modelo6 modelo7 modelo8 ///
	modelo9 modelo10 modelo11 using "${table_output}/coca_spillover_att_SA.tex", replace ///
	main(b %6.4f) aux(se %6.4f) ///
	star(* 0.10 ** 0.05 *** 0.01) compress ///
	gap nonotes noobs ///
	scalars("OBS Obs." "EFT EF Año" "EFG EF Grilla" "TREND Tendencia" ///
	"CLVER Cluster Vereda" "CONTROL Control")  ///
	mgroups("Grilla PNIS" "Grilla Vecina" "Grilla V. de Vecina", ///
	pattern(1 0 0 1 0 0 1 0 0) ///
	prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	alignment(D{.}{.}{-1}) /// 
	note("Error estándar en paréntesis." "* p$<0.10$, ** p$<0.05$, *** p$<0.01$")
